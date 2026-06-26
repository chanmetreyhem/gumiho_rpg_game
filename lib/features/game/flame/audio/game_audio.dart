import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

class GameAudio {
  GameAudio({
    required this.musicVolume,
    required this.sfxVolume,
  });

  final double musicVolume;
  final double sfxVolume;

  static const _sfxFiles = [
    'shoot.wav',
    'hit.wav',
    'enemy_death.wav',
    'explosion.wav',
    'bomb_throw.wav',
    'level_complete.wav',
    'game_over.wav',
  ];

  static const _loadTimeout = Duration(seconds: 8);
  static const _playTimeout = Duration(milliseconds: 800);

  static bool _cacheLoaded = false;
  static bool _bgmInitialized = false;
  static Future<void>? _bgmInitFuture;

  bool _disposed = false;
  double _shootCooldown = 0;
  double _hitCooldown = 0;

  Future<void> init() async {
    if (_disposed) return;

    if (!_cacheLoaded) {
      try {
        await FlameAudio.audioCache
            .loadAll([
              ..._sfxFiles,
              'music_loop.wav',
            ])
            .timeout(_loadTimeout);
        _cacheLoaded = true;
      } on Object {
        // Audio unavailable — game still runs without sound.
      }
    }

    if (!_bgmInitialized) {
      _bgmInitFuture ??= _initBgm();
      try {
        await _bgmInitFuture!.timeout(_loadTimeout);
      } on Object {
        // BGM unavailable.
      }
    }
  }

  Future<void> _initBgm() async {
    await FlameAudio.bgm.initialize();
    _bgmInitialized = true;
  }

  void tick(double dt) {
    if (_shootCooldown > 0) _shootCooldown -= dt;
    if (_hitCooldown > 0) _hitCooldown -= dt;
  }

  Future<void> startMusic() async {
    if (_disposed || !_bgmInitialized || musicVolume <= 0) return;
    try {
      await FlameAudio.bgm.stop().timeout(_playTimeout);
      await FlameAudio.bgm
          .play('music_loop.wav', volume: musicVolume)
          .timeout(_playTimeout);
    } on Object {
      // BGM is optional — never block gameplay if audio fails.
    }
  }

  Future<void> stopMusic() async {
    if (!_bgmInitialized) return;
    try {
      await FlameAudio.bgm.stop().timeout(_playTimeout);
    } on Object {
      // Ignore stop failures during teardown.
    }
  }

  void playShoot() {
    if (_shootCooldown > 0) return;
    _shootCooldown = 0.04;
    _playSfx('shoot.wav', 0.7);
  }

  void playHit() {
    if (_hitCooldown > 0) return;
    _hitCooldown = 0.06;
    _playSfx('hit.wav', 0.8);
  }

  void playEnemyDeath() => _playSfx('enemy_death.wav');
  void playExplosion() => _playSfx('explosion.wav');
  void playBombThrow() => _playSfx('bomb_throw.wav', 0.9);
  void playLevelComplete() => _playSfx('level_complete.wav');
  void playGameOver() => _playSfx('game_over.wav');

  void _playSfx(String file, [double scale = 1.0]) {
    if (_disposed || !_cacheLoaded || sfxVolume <= 0) return;
    unawaited(() async {
      try {
        await FlameAudio.play(file, volume: sfxVolume * scale)
            .timeout(_playTimeout);
      } on Object {
        // Ignore SFX failures.
      }
    }());
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await stopMusic();
  }
}
