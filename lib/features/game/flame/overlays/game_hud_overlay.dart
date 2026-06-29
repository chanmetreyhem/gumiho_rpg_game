import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gumiho_rpg_game/l10n/app_localizations.dart';

import '../../../../core/theme/game_ui_theme.dart';
import '../../../../core/widgets/app_animations.dart';
import '../../../../core/widgets/game_ui_widgets.dart';
import '../../application/game_session_notifier.dart';
import '../gumiho_game.dart';

class GameHudOverlay extends ConsumerStatefulWidget {
  const GameHudOverlay({super.key, required this.game});

  final GumihoGame game;

  @override
  ConsumerState<GameHudOverlay> createState() => _GameHudOverlayState();
}

class _GameHudOverlayState extends ConsumerState<GameHudOverlay> {
  String _formatTime(double seconds) {
    final total = seconds.floor();
    final minutes = total ~/ 60;
    final secs = total % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(gameSessionNotifierProvider);
    final playerHp = session.playerHp;
    final maxHp = session.maxHp;
    final currentWave = session.currentWave;
    final totalWaves = session.totalWaves;
    final runCoins = session.runCoins;
    final killCount = session.killCount;
    final elapsedSeconds = session.elapsedSeconds;
    final bombsRemaining = session.bombsRemaining;
    final bombEnabled = bombsRemaining > 0 && !widget.game.paused;
    final bombAiming = widget.game.isBombAiming;

    final waveProgress =
        totalWaves > 0 ? (currentWave / totalWaves).clamp(0.0, 1.0) : 0.0;
    final hpRatio = maxHp > 0 ? (playerHp / maxHp).clamp(0.0, 1.0) : 0.0;

    return Stack(
      children: [
        SafeArea(
          child: Stack(
            children: [
              // Top HUD — decorative stats ignore touches so joysticks work mid-screen edges.
              Positioned(
                top: 8,
                left: 10,
                right: 10,
                child: FadeSlideIn(
                  offset: const Offset(0, -16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GameRoundButton(
                        icon: Icons.pause_rounded,
                        onPressed: widget.game.requestPause,
                        tooltip: l10n.pause,
                      ),
                      Expanded(
                        child: IgnorePointer(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.timer_rounded,
                                    color: GameUiColors.actionYellow,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatTime(elapsedSeconds),
                                    style: GameUiText.hudBold(
                                      16,
                                      color: GameUiColors.actionYellow,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        GameThickBar(
                                          value: waveProgress,
                                          trackColor: GameUiColors.waveTrack,
                                          fillColor: GameUiColors.waveRed,
                                          height: 12,
                                        ),
                                        ...List.generate(totalWaves, (index) {
                                          if (totalWaves <= 1) {
                                            return const SizedBox.shrink();
                                          }
                                          final x = (index + 1) /
                                              totalWaves *
                                              constraints.maxWidth;
                                          final isBoss =
                                              index == totalWaves - 1;
                                          return Positioned(
                                            left: x - 8,
                                            top: -4,
                                            child: Icon(
                                              isBoss
                                                  ? Icons
                                                      .workspace_premium_rounded
                                                  : Icons.flag_rounded,
                                              size: 14,
                                              color: index < currentWave
                                                  ? Colors.white
                                                  : Colors.white38,
                                            ),
                                          );
                                        }),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.wave(currentWave, totalWaves),
                                style: GameUiText.label(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IgnorePointer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            GameStatChip(
                              icon: Icons.monetization_on_rounded,
                              value: '$runCoins',
                            ),
                            const SizedBox(height: 6),
                            GameStatChip(
                              icon: Icons.bolt_rounded,
                              value: '$killCount',
                              iconColor: Colors.white70,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 92,
                left: 10,
                right: 10,
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 80),
                  child: IgnorePointer(
                    child: _ExpBar(
                      wave: currentWave,
                      progress: waveProgress,
                    ),
                  ),
                ),
              ),
              // HP at top — keeps bottom clear for joysticks + bomb.
              Positioned(
                top: 132,
                left: 10,
                right: 10,
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 120),
                  child: IgnorePointer(
                    child: GameHudPanel(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite_rounded,
                            color: hpRatio > 0.3
                                ? GameUiColors.hpGreen
                                : GameUiColors.waveRed,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GameThickBar(
                              value: hpRatio,
                              trackColor: GameUiColors.hpTrack,
                              fillColor: hpRatio > 0.3
                                  ? GameUiColors.hpGreen
                                  : GameUiColors.waveRed,
                              height: 10,
                              radius: 5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${playerHp.round()}',
                            style: GameUiText.hudBold(12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Bomb display only — input handled by [BombInputController] in Flame.
              Positioned(
                left: 0,
                right: 0,
                bottom: 28,
                child: Center(
                  child: IgnorePointer(
                    child: _BombButton(
                      label: l10n.bomb,
                      count: bombsRemaining,
                      enabled: bombEnabled,
                      aiming: bombAiming,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExpBar extends StatelessWidget {
  const _ExpBar({
    required this.wave,
    required this.progress,
  });

  final int wave;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: GameUiColors.purpleBadge,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 2),
          ),
          alignment: Alignment.center,
          child: Text('$wave', style: GameUiText.hudBold(13)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GameThickBar(
            value: progress,
            trackColor: GameUiColors.expTrack,
            fillColor: GameUiColors.expCyan,
            height: 14,
          ),
        ),
      ],
    );
  }
}

class _BombButton extends StatelessWidget {
  const _BombButton({
    required this.label,
    required this.count,
    required this.enabled,
    required this.aiming,
  });

  final String label;
  final int count;
  final bool enabled;
  final bool aiming;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '$label · drag to aim',
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: aiming ? 0.35 : 1,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: enabled
                ? GameUiColors.playGradient
                : const LinearGradient(
                    colors: [Color(0xFF4A4A4A), Color(0xFF2A2A2A)],
                  ),
            border: Border.all(
              color: aiming
                  ? Colors.white
                  : GameUiColors.actionOrange.withValues(alpha: 0.8),
              width: 3,
            ),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color:
                          GameUiColors.actionOrange.withValues(alpha: 0.45),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.whatshot_rounded,
                color: enabled ? Colors.white : Colors.white38,
                size: 28,
              ),
              Text(
                '$count',
                style: GameUiText.hudBold(11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
