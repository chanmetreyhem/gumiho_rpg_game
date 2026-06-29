import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../../data/config/game_assets.dart';
import '../../../data/config/shop_catalog.dart';
import '../../../data/config/wave_config.dart';
import '../data/game_image_preloader.dart';
import '../domain/arena_stats.dart';
import '../domain/run_combo.dart';
import '../domain/skin_stats.dart';
import '../domain/star_rating.dart';
import '../domain/weapon_stats.dart';
import 'audio/game_audio.dart';
import 'components/arena_background.dart';
import 'components/world_backdrop.dart';
import 'components/bomb_aim_indicator.dart';
import 'components/bomb_component.dart';
import 'components/enemy_component.dart';
import 'components/player_component.dart';
import 'input/bomb_input_controller.dart';
import 'input/dual_joystick_setup.dart';
import 'managers/bullet_pool.dart';
import 'managers/effect_manager.dart';
import 'managers/wave_manager.dart';
import 'components/effects/particle_burst_component.dart';

typedef LevelCompleteCallback = void Function({
  required int stars,
  required int runCoins,
  required int bonusCoins,
});

class GumihoGame extends FlameGame with HasCollisionDetection {
  GumihoGame({
    required this.levelId,
    required this.skin,
    required this.weapon,
    required this.arena,
    required this.joystickSensitivity,
    required this.musicVolume,
    required this.sfxVolume,
    required this.onHudUpdate,
    required this.onPlayerDiedCallback,
    required this.onLevelCompleteCallback,
    required this.onPauseRequested,
  });

  final int levelId;
  final SkinStats skin;
  final WeaponStats weapon;
  final ArenaStats arena;
  final double joystickSensitivity;
  final double musicVolume;
  final double sfxVolume;
  final void Function({
    required double hp,
    required double maxHp,
    required int wave,
    required int totalWaves,
    required int bombs,
    required int coins,
    required int kills,
    required double elapsedSeconds,
  }) onHudUpdate;

  final VoidCallback onPlayerDiedCallback;
  final LevelCompleteCallback onLevelCompleteCallback;
  final VoidCallback onPauseRequested;

  static final Vector2 arenaSize = Vector2(2000, 2000);
  static final Vector2 portraitViewSize = Vector2(450, 800);
  static const double bulletMaxDistance = 800;
  static const double offscreenCullDistance = 560;

  late final PlayerComponent player;
  late final WaveManager waveManager;

  int bombsRemaining = 3;
  int runCoins = 0;
  int killCount = 0;
  int currentWave = 1;
  int totalWaves = 3;

  double _elapsedSeconds = 0;
  int _lastNotifiedElapsedSecond = -1;

  Vector2? bombAimWorld;
  static const double bombThrowRange = 420;
  bool isBombAiming = false;

  final RunBuffs runBuffs = RunBuffs();
  List<RunCombo> comboChoices = const [];
  VoidCallback? _comboResume;

  DateTime? _lastHudNotify;

  final EffectManager effects = EffectManager();
  late final BulletPool bulletPool;

  late final GameAudio audio;

  @override
  Color backgroundColor() => const Color(0xFF050508);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.visibleGameSize = portraitViewSize;

    world.add(WorldBackdrop(arenaSize: arenaSize));
    world.add(
      ArenaBackground(
        arenaSize: arenaSize,
        assetPath: arena.assetPath,
      ),
    );
    world.add(ArenaFogLayer(arenaSize: arenaSize));

    audio = GameAudio(musicVolume: musicVolume, sfxVolume: sfxVolume);
    await Future.wait([
      audio.init(),
      _preloadAssets(),
    ]);

    bulletPool = BulletPool(this);
    unawaited(bulletPool.preload());

    player = PlayerComponent(
      skin: skin,
      weapon: weapon,
      startPosition: arenaSize / 2,
    );
    world.add(player);

    waveManager = WaveManager(levelId: levelId);
    world.add(waveManager);

    world.add(BombAimIndicator());

    camera.follow(player);

    world.add(DualJoystickSetup());

    camera.viewport.add(BombInputController());

    await audio.startMusic();
    notifyHud(force: true);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!paused) {
      _elapsedSeconds += dt;
      final sec = _elapsedSeconds.floor();
      if (sec != _lastNotifiedElapsedSecond) {
        _lastNotifiedElapsedSecond = sec;
        notifyHud();
      }
    }
  }

  @override
  void onRemove() {
    bulletPool.clear();
    effects.reset();
    audio.dispose();
    super.onRemove();
  }

  Future<void> _preloadAssets() async {
    final enemyTypes = WaveConfig.enemyTypesForLevel(levelId);
    final paths = [
      ...GameAssets.preloadPaths(
        characterFolders: [skin.characterFolder],
        weaponIds: [weapon.id],
        arenaId: arena.id,
      ),
      ...GameAssets.enemyPartPathsFor(enemyTypes),
    ];
    await GameImagePreloader.loadPaths(paths);
  }

  bool isNearCamera(Vector2 worldPosition) =>
      worldPosition.distanceTo(player.position) <= offscreenCullDistance;

  void _addEffect(ParticleBurstComponent effect) {
    if (!effects.tryAcquire()) return;
    world.add(
      effect,
    );
  }

  void spawnMuzzleFlash({
    required Vector2 worldPosition,
    required double angle,
    required Color coreColor,
    required Color glowColor,
  }) {
    _addEffect(
      ParticleBurstComponent.muzzle(
        worldPosition: worldPosition,
        angle: angle,
        coreColor: coreColor,
        glowColor: glowColor,
        onReleased: effects.release,
      ),
    );
  }

  void spawnHitEffect({
    required Vector2 worldPosition,
    required Vector2 direction,
    required Color coreColor,
    required Color glowColor,
  }) {
    _addEffect(
      ParticleBurstComponent.hit(
        worldPosition: worldPosition,
        direction: direction,
        coreColor: coreColor,
        glowColor: glowColor,
        onReleased: effects.release,
      ),
    );
  }

  void spawnHurtEffect(Vector2 worldPosition) {
    _addEffect(
      ParticleBurstComponent.hurt(
        worldPosition: worldPosition.clone(),
        onReleased: effects.release,
      ),
    );
  }

  void spawnDeathEffect(Vector2 worldPosition) {
    _addEffect(
      ParticleBurstComponent.death(
        worldPosition: worldPosition.clone(),
        coreColor: const Color(0xFFFFAB40),
        onReleased: effects.release,
      ),
    );
  }

  void notifyHud({bool force = false}) {
    final now = DateTime.now();
    if (!force &&
        _lastHudNotify != null &&
        now.difference(_lastHudNotify!).inMilliseconds < 120) {
      return;
    }
    _lastHudNotify = now;
    onHudUpdate(
      hp: player.hp,
      maxHp: player.maxHp,
      wave: currentWave,
      totalWaves: totalWaves,
      bombs: bombsRemaining,
      coins: runCoins,
      kills: killCount,
      elapsedSeconds: _elapsedSeconds,
    );
  }

  void onPlayerHpChanged(double hp, double maxHp) {
    _lastHudNotify = DateTime.now();
    onHudUpdate(
      hp: hp,
      maxHp: maxHp,
      wave: currentWave,
      totalWaves: totalWaves,
      bombs: bombsRemaining,
      coins: runCoins,
      kills: killCount,
      elapsedSeconds: _elapsedSeconds,
    );
  }

  Vector2 bombTargetFromCanvas(Vector2 canvasPoint) =>
      _clampBombTarget(camera.globalToLocal(canvasPoint));

  void setBombAimPreview(Vector2? worldTarget) {
    bombAimWorld = worldTarget == null ? null : _clampBombTarget(worldTarget);
  }

  Vector2 _clampBombTarget(Vector2 target) {
    final clampedArena = Vector2(
      target.x.clamp(0, arenaSize.x),
      target.y.clamp(0, arenaSize.y),
    );
    final offset = clampedArena - player.position;
    if (offset.length <= bombThrowRange) return clampedArena;
    return player.position + offset.normalized() * bombThrowRange;
  }

  void offerComboPick({required VoidCallback onResume}) {
    if (paused) return;
    pauseEngine();
    _comboResume = onResume;
    comboChoices = ComboCatalog.rollThree(level: levelId, wave: currentWave);
    overlays.add('combo');
  }

  void pickCombo(RunCombo combo) {
    runBuffs.apply(combo);
    switch (combo.type) {
      case ComboType.maxHpUp:
        final bonus = player.maxHp * combo.value;
        player.maxHp += bonus;
        player.hp += bonus;
      case ComboType.heal:
        player.hp = (player.hp + player.maxHp * combo.value).clamp(0, player.maxHp);
      case ComboType.extraBomb:
        bombsRemaining += combo.value.round();
      case ComboType.damageUp:
      case ComboType.fireRateUp:
      case ComboType.speedUp:
      case ComboType.bulletSpeedUp:
        break;
    }

    overlays.remove('combo');
    comboChoices = const [];
    notifyHud(force: true);

    if (paused) {
      resumeEngine();
    }
    final resume = _comboResume;
    _comboResume = null;
    resume?.call();
  }

  void throwBombAt(Vector2 worldTarget) {
    if (bombsRemaining <= 0 || paused) return;

    final target = _clampBombTarget(worldTarget);
    final direction = (target - player.position);
    if (direction.length < 24) return;

    bombsRemaining--;
    audio.playBombThrow();
    bombAimWorld = null;

    final start = player.position + direction.normalized() * 36;
    world.add(BombComponent(position: start, target: target));
    notifyHud(force: true);
  }

  void throwBomb() {
    throwBombAt(player.position + player.gun.aimDirection * bombThrowRange);
  }

  void onEnemyKilled(EnemyComponent enemy) {
    audio.playEnemyDeath();
    runCoins += enemy.coinReward;
    killCount++;
    waveManager.onEnemyRemoved();
    notifyHud(force: true);
  }

  void onLevelComplete() {
    pauseEngine();
    audio.playLevelComplete();
    audio.stopMusic();
    final stars = StarRating.fromHp(player.hp, player.maxHp);
    final bonus = StarRating.levelClearBonus(levelId, stars: stars);
    onLevelCompleteCallback(
      stars: stars,
      runCoins: runCoins,
      bonusCoins: bonus,
    );
  }

  void onPlayerDied() {
    pauseEngine();
    audio.playGameOver();
    audio.stopMusic();
    onPlayerDiedCallback();
  }

  void revivePlayer() {
    player.hp = player.maxHp;
    resumeEngine();
    unawaited(audio.resumeMusic());
    notifyHud(force: true);
  }

  void requestPause() {
    if (!paused) {
      pauseEngine();
      unawaited(audio.pauseMusic());
      onPauseRequested();
    }
  }

  void resumeFromPause() {
    if (paused) {
      resumeEngine();
      unawaited(audio.resumeMusic());
    }
  }

  factory GumihoGame.fromLoadout({
    required int levelId,
    required String skinId,
    required String gunId,
    required String arenaId,
    required double joystickSensitivity,
    required double musicVolume,
    required double sfxVolume,
    required void Function({
      required double hp,
      required double maxHp,
      required int wave,
      required int totalWaves,
      required int bombs,
      required int coins,
      required int kills,
      required double elapsedSeconds,
    }) onHudUpdate,
    required VoidCallback onPlayerDied,
    required LevelCompleteCallback onLevelComplete,
    required VoidCallback onPauseRequested,
  }) {
    return GumihoGame(
      levelId: levelId,
      skin: ShopCatalog.skinById(skinId),
      weapon: ShopCatalog.weaponById(gunId),
      arena: ShopCatalog.arenaById(arenaId),
      joystickSensitivity: joystickSensitivity,
      musicVolume: musicVolume,
      sfxVolume: sfxVolume,
      onHudUpdate: onHudUpdate,
      onPlayerDiedCallback: onPlayerDied,
      onLevelCompleteCallback: onLevelComplete,
      onPauseRequested: onPauseRequested,
    );
  }
}
