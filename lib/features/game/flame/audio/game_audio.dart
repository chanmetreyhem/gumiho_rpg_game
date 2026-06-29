import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

class GameAudio {
  GameAudio({
    required double musicVolume,
    required double sfxVolume,
  })  : _musicVolume = musicVolume.clamp(0.0, 1.0),
        _sfxVolume = sfxVolume.clamp(0.0, 1.0);

  static const _musicFile = 'new_music.mp3';

  static const _sfxFiles = [
    'shoot.wav',
    'hit.wav',
    'enemy_death.wav',
    'explosion.wav',
    'bomb_throw.wav',
    'level_complete.wav',
    'game_over.wav',
  ];

  static const _poolConfig = <String, ({int min, int max})>{
    'shoot.wav': (min: 4, max: 12),
    'hit.wav': (min: 4, max: 10),
    'enemy_death.wav': (min: 2, max: 6),
    'explosion.wav': (min: 2, max: 4),
    'bomb_throw.wav': (min: 2, max: 4),
    'level_complete.wav': (min: 1, max: 2),
    'game_over.wav': (min: 1, max: 2),
  };

  static final Map<String, AudioPool> _pools = {};
  static Future<void>? _bootstrapFuture;
  static bool _assetsReady = false;

  static final AudioContext _sfxContext = AudioContextConfig(
    focus: AudioContextConfigFocus.mixWithOthers,
  ).build();

  double _musicVolume;
  double _sfxVolume;

  bool _disposed = false;
  bool _musicStarted = false;

  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  /// Loads SFX/BGM and pre-warms audio pools — call from splash or level load.
  static Future<void> warmUp() async {
    _bootstrapFuture ??= _bootstrapAssets();
    await _bootstrapFuture;
  }

  Future<void> init() async {
    if (_disposed) return;
    await warmUp();
  }

  static Future<void> _bootstrapAssets() async {
    if (_assetsReady) return;

    await FlameAudio.audioCache.loadAll([
      ..._sfxFiles,
      _musicFile,
    ]);

    await Future.wait(
      _poolConfig.entries.map((entry) async {
        final file = entry.key;
        final config = entry.value;
        if (_pools.containsKey(file)) return;

        _pools[file] = await AudioPool.create(
          source: AssetSource(file),
          audioCache: FlameAudio.audioCache,
          minPlayers: config.min,
          maxPlayers: config.max,
          audioContext: _sfxContext,
        );
      }),
    );

    await FlameAudio.bgm.initialize();
    _assetsReady = true;
  }

  void updateVolumes({double? musicVolume, double? sfxVolume}) {
    if (musicVolume != null) {
      _musicVolume = musicVolume.clamp(0.0, 1.0);
    }
    if (sfxVolume != null) {
      _sfxVolume = sfxVolume.clamp(0.0, 1.0);
    }

    if (!_assetsReady || _disposed) return;

    unawaited(FlameAudio.bgm.audioPlayer.setVolume(_musicVolume));
    if (_musicVolume <= 0 && _musicStarted) {
      unawaited(stopMusic());
    } else if (_musicVolume > 0 && _musicStarted) {
      unawaited(resumeMusic());
    }
  }

  Future<void> startMusic() async {
    if (_disposed || !_assetsReady || _musicVolume <= 0) return;
    try {
      await FlameAudio.bgm.play(_musicFile, volume: _musicVolume);
      _musicStarted = true;
    } on Object {
      // BGM is optional.
    }
  }

  Future<void> stopMusic() async {
    if (!_assetsReady) return;
    try {
      await FlameAudio.bgm.stop();
      _musicStarted = false;
    } on Object {
      // Ignore stop failures during teardown.
    }
  }

  Future<void> pauseMusic() async {
    if (!_assetsReady || !_musicStarted) return;
    try {
      await FlameAudio.bgm.pause();
    } on Object {
      // Ignore pause failures.
    }
  }

  Future<void> resumeMusic() async {
    if (_disposed || !_assetsReady || _musicVolume <= 0) return;
    try {
      final player = FlameAudio.bgm.audioPlayer;
      if (player.state == PlayerState.paused && player.source != null) {
        await FlameAudio.bgm.audioPlayer.setVolume(_musicVolume);
        await FlameAudio.bgm.resume();
        _musicStarted = true;
      } else if (!FlameAudio.bgm.isPlaying) {
        await startMusic();
      }
    } on Object {
      // Ignore resume failures.
    }
  }

  void playShoot() => _playPooled('shoot.wav', 0.7);

  void playHit() => _playPooled('hit.wav', 0.8);

  void playEnemyDeath() => _playPooled('enemy_death.wav');

  void playExplosion() => _playPooled('explosion.wav');

  void playBombThrow() => _playPooled('bomb_throw.wav', 0.9);

  void playLevelComplete() => _playPooled('level_complete.wav');

  void playGameOver() => _playPooled('game_over.wav');

  void _playPooled(String file, [double scale = 1.0]) {
    if (_disposed || !_assetsReady || _sfxVolume <= 0) return;

    final pool = _pools[file];
    if (pool != null) {
      unawaited(pool.start(volume: _sfxVolume * scale));
      return;
    }

    // Fallback if pool failed to initialize.
    unawaited(FlameAudio.play(file, volume: _sfxVolume * scale));
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _musicStarted = false;
    await stopMusic();
    // Shared SFX pools are kept alive for the next game session.
  }
}
