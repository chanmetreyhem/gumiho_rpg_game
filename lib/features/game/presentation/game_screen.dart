import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/game.dart';
import 'package:go_router/go_router.dart';
import 'package:gumiho_rpg_game/l10n/app_localizations.dart';

import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';

import '../../monetization/application/monetization_service.dart';
import '../../profile/application/profile_notifier.dart';
import '../../settings/application/settings_notifier.dart';
import '../application/game_session_notifier.dart';
import '../flame/gumiho_game.dart';
import '../flame/overlays/combo_pick_overlay.dart';
import '../flame/overlays/game_end_dialog.dart';
import '../flame/overlays/game_hud_overlay.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.levelId});

  final int levelId;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  GumihoGame? _game;
  int _gameSessionKey = 0;
  bool _pauseDialogOpen = false;
  bool _endDialogOpen = false;
  bool _initializing = false;
  bool _sessionReady = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    WidgetsBinding.instance.addPostFrameCallback((_) => _initGame());
  }

  Future<void> _teardownGame() async {
    final game = _game;
    _game = null;
    if (game != null) {
      await game.audio.dispose();
      game.pauseEngine();
    }
  }

  Future<void> _initGame() async {
    if (!mounted || _initializing || _game != null) return;
    _initializing = true;

    final profileAsync = ref.read(profileNotifierProvider);
    if (!profileAsync.hasValue) {
      _initializing = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _initGame());
      return;
    }

    await _teardownGame();

    if (!mounted) {
      _initializing = false;
      return;
    }

    final profile = profileAsync.requireValue;
    final settings = ref.read(settingsNotifierProvider);
    final sessionNotifier = ref.read(gameSessionNotifierProvider.notifier);
    sessionNotifier.reset();
    sessionNotifier.startLevel(widget.levelId, maxHp: 100);

    _pauseDialogOpen = false;
    _endDialogOpen = false;
    _sessionReady = true;
    _gameSessionKey++;

    setState(() {
      _game = _buildGame(profile, settings, sessionNotifier);
    });
    _initializing = false;
  }

  Future<void> _restartGame() async {
    _sessionReady = false;
    _pauseDialogOpen = false;
    _endDialogOpen = false;
    ref.read(gameSessionNotifierProvider.notifier).reset();
    await _teardownGame();
    if (!mounted) return;
    setState(() {});
    await _initGame();
  }

  @override
  void dispose() {
    unawaited(_teardownGame());
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(gameSessionNotifierProvider, (prev, next) {
      if (!_sessionReady) return;

      final pausedNow = next.isPaused &&
          !next.isGameOver &&
          !next.isLevelComplete &&
          (prev == null || !prev.isPaused);
      if (pausedNow) {
        _showPauseDialog();
      }

      final endedNow = (next.isGameOver || next.isLevelComplete) &&
          (prev == null || (!prev.isGameOver && !prev.isLevelComplete));
      if (endedNow) {
        _showEndDialog(next.isLevelComplete);
      }
    });

    if (_game == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: GameWidget(
        key: ValueKey(_gameSessionKey),
        game: _game!,
        overlayBuilderMap: {
          'hud': (context, game) => GameHudOverlay(game: game as GumihoGame),
          'combo': (context, game) =>
              ComboPickOverlay(game: game as GumihoGame),
        },
        initialActiveOverlays: const ['hud'],
      ),
    );
  }

  GumihoGame _buildGame(
    profile,
    settings,
    GameSessionNotifier sessionNotifier,
  ) {
    return GumihoGame.fromLoadout(
      levelId: widget.levelId,
      skinId: profile.equippedSkinId,
      gunId: profile.equippedGunId,
      joystickSensitivity: settings.joystickSensitivity,
      musicVolume: settings.musicVolume,
      sfxVolume: settings.sfxVolume,
      onHudUpdate: ({
        required hp,
        required maxHp,
        required wave,
        required totalWaves,
        required bombs,
        required coins,
      }) {
        _safeUpdateHud(
          sessionNotifier,
          playerHp: hp,
          currentWave: wave,
          bombsRemaining: bombs,
          runCoins: coins,
        );
      },
      onPlayerDied: () => _safeEndGame(sessionNotifier, won: false),
      onLevelComplete: ({
        required stars,
        required runCoins,
        required bonusCoins,
      }) {
        final total = runCoins + bonusCoins;
        ref.read(profileNotifierProvider.notifier).completeLevel(
              widget.levelId,
              stars,
              total,
            );
        _safeEndGame(
          sessionNotifier,
          won: true,
          stars: stars,
          bonusCoins: bonusCoins,
          runCoins: runCoins,
        );
      },
      onPauseRequested: () => _safeUpdatePause(true),
    );
  }

  void _safeUpdateHud(
    GameSessionNotifier notifier, {
    required double playerHp,
    required int currentWave,
    required int bombsRemaining,
    required int runCoins,
  }) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      notifier.updateHud(
        playerHp: playerHp,
        currentWave: currentWave,
        bombsRemaining: bombsRemaining,
        runCoins: runCoins,
      );
    });
  }

  void _safeEndGame(
    GameSessionNotifier notifier, {
    required bool won,
    int stars = 0,
    int bonusCoins = 0,
    int runCoins = 0,
  }) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      notifier.endGame(
        won: won,
        stars: stars,
        bonusCoins: bonusCoins,
        runCoins: runCoins,
      );
    });
  }

  void _safeUpdatePause(bool paused) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(gameSessionNotifierProvider.notifier).setPaused(paused);
    });
  }

  void _showPauseDialog() {
    if (_pauseDialogOpen || !mounted) return;
    _pauseDialogOpen = true;
    final l10n = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.pause,
                style: Theme.of(ctx).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: l10n.resume,
                icon: Icons.play_arrow_rounded,
                onPressed: () {
                  Navigator.pop(ctx);
                  _pauseDialogOpen = false;
                  ref.read(gameSessionNotifierProvider.notifier).setPaused(false);
                  _game?.resumeFromPause();
                },
              ),
              const SizedBox(height: 10),
              SecondaryButton(
                label: l10n.quit,
                onPressed: () {
                  Navigator.pop(ctx);
                  _pauseDialogOpen = false;
                  ref.read(gameSessionNotifierProvider.notifier).reset();
                  context.go('/');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEndDialog(bool won) {
    if (_endDialogOpen || !mounted) return;
    _endDialogOpen = true;

    final session = ref.read(gameSessionNotifierProvider);
    final profile = ref.read(profileNotifierProvider).requireValue;
    final monetization = ref.read(monetizationServiceProvider);
    final l10n = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GameEndDialog(
        won: won,
        stars: session.starsEarned,
        totalCoins: won ? session.totalCoinsEarned : session.runCoins,
        onPlayAgain: won
            ? () {
                Navigator.pop(ctx);
                unawaited(_restartGame());
              }
            : null,
        onWatchAdToRevive: won
            ? null
            : () async {
                final rewarded = await monetization.showRewardedAd();
                if (!rewarded || !ctx.mounted) return;
                Navigator.pop(ctx);
                _endDialogOpen = false;
                ref.read(gameSessionNotifierProvider.notifier).revive();
                _game?.revivePlayer();
              },
        onWatchAdForCoins: won
            ? null
            : () async {
                final rewarded = await monetization.showRewardedAd();
                if (!rewarded || !ctx.mounted) return;
                await ref
                    .read(profileNotifierProvider.notifier)
                    .grantRewardedCoins();
                if (!ctx.mounted) return;
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text(l10n.rewardedCoinsGranted)),
                );
              },
        onContinue: () async {
          if (!won) {
            await monetization.showInterstitialIfAllowed(
              adsRemoved: profile.removeAdsPurchased,
            );
          }
          if (!ctx.mounted) return;
          Navigator.pop(ctx);
          _endDialogOpen = false;
          ref.read(gameSessionNotifierProvider.notifier).reset();
          ctx.go('/levels');
        },
      ),
    );
  }
}
