import 'dart:math';

import 'package:flame/components.dart';

import '../../../../data/config/wave_config.dart';
import '../components/enemy_component.dart';
import '../gumiho_game.dart';

class _SpawnTask {
  _SpawnTask({required this.group, required this.remaining});

  final EnemySpawnGroup group;
  int remaining;
  double timer = 0;
}

class WaveManager extends Component with HasGameReference<GumihoGame> {
  WaveManager({required this.levelId});

  final int levelId;
  final _random = Random();

  late final List<WaveDefinition> _waves;
  int _waveIndex = 0;
  final List<_SpawnTask> _tasks = [];
  int _aliveEnemies = 0;
  bool _spawningDone = false;
  bool _levelCompleted = false;
  bool _awaitingCombo = false;
  double _waveDelay = 2;

  @override
  Future<void> onLoad() async {
    _waves = WaveConfig.wavesForLevel(levelId);
    game.totalWaves = _waves.length;
    game.currentWave = 1;
    _startWave();
  }

  void _startWave() {
    _tasks.clear();
    _spawningDone = false;
    _waveDelay = 2;

    if (_waveIndex >= _waves.length) return;

    final wave = _waves[_waveIndex];
    for (final group in wave.groups) {
      _tasks.add(_SpawnTask(group: group, remaining: group.count));
    }

    game.currentWave = _waveIndex + 1;
    game.notifyHud(force: true);
  }

  void _spawnEnemy(EnemySpawnGroup group) {
    final enemy = EnemyComponent(
      type: group.type,
      level: levelId,
      spawnPosition: _randomEdgePosition(),
    );
    game.world.add(enemy);
    _aliveEnemies++;
  }

  Vector2 _randomEdgePosition() {
    final arena = GumihoGame.arenaSize;
    final side = _random.nextInt(4);
    final padding = 40.0;

    return switch (side) {
      0 => Vector2(_random.nextDouble() * arena.x, -padding),
      1 => Vector2(arena.x + padding, _random.nextDouble() * arena.y),
      2 => Vector2(_random.nextDouble() * arena.x, arena.y + padding),
      _ => Vector2(-padding, _random.nextDouble() * arena.y),
    };
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_waveIndex >= _waves.length) return;

    if (_awaitingCombo) return;

    if (_waveDelay > 0) {
      _waveDelay -= dt;
      return;
    }

    if (!_spawningDone) {
      var allDone = true;
      for (final task in _tasks) {
        if (task.remaining <= 0) continue;
        allDone = false;
        task.timer -= dt;
        if (task.timer <= 0) {
          _spawnEnemy(task.group);
          task.remaining--;
          task.timer = task.group.spawnInterval;
        }
      }
      if (allDone) _spawningDone = true;
    }

    if (_spawningDone && _aliveEnemies <= 0 && !_levelCompleted) {
      _waveIndex++;
      if (_waveIndex >= _waves.length) {
        _levelCompleted = true;
        game.onLevelComplete();
      } else {
        _awaitingCombo = true;
        game.offerComboPick(
          onResume: () {
            _awaitingCombo = false;
            _waveDelay = 2;
            _startWave();
          },
        );
      }
    }
  }

  void onEnemyRemoved() {
    _aliveEnemies--;
    if (_aliveEnemies < 0) _aliveEnemies = 0;
  }
}
