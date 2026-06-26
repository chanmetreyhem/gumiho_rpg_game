import '../../features/game/domain/enemy_type.dart';
import 'level_config.dart';

class EnemySpawnGroup {
  const EnemySpawnGroup({
    required this.type,
    required this.count,
    this.spawnInterval = 0.8,
  });

  final EnemyType type;
  final int count;
  final double spawnInterval;
}

class WaveDefinition {
  const WaveDefinition({required this.groups});

  final List<EnemySpawnGroup> groups;

  int get totalEnemies => groups.fold(0, (sum, g) => sum + g.count);
}

class WaveConfig {
  static List<WaveDefinition> wavesForLevel(int level) {
    final waveCount = LevelConfig.waveCountForLevel(level);
    return List.generate(
      waveCount,
      (index) => _waveForLevel(level, index + 1, waveCount),
    );
  }

  static WaveDefinition _waveForLevel(int level, int wave, int totalWaves) {
    final tier = (level - 1) ~/ 10;
    final waveScale = 1.0 + (level - 1) * 0.025 + (wave - 1) * 0.08;

    final zombieCount = (3 + wave + tier).clamp(2, 8);
    final monsterCount = level >= 2
        ? (wave - 1 + tier ~/ 2).clamp(0, 5)
        : 0;
    final tankCount = level >= 4 && wave >= totalWaves - 1
        ? (level >= 20 ? 2 : 1)
        : level >= 8 && wave == totalWaves
            ? 1
            : 0;

    final groups = <EnemySpawnGroup>[
      EnemySpawnGroup(
        type: EnemyType.zombie,
        count: (zombieCount * waveScale * 0.85).round().clamp(2, 10),
        spawnInterval: 0.85,
      ),
    ];

    if (monsterCount > 0) {
      groups.add(
        EnemySpawnGroup(
          type: EnemyType.monster,
          count: (monsterCount * waveScale * 0.8).round().clamp(1, 6),
          spawnInterval: 1.0,
        ),
      );
    }

    if (tankCount > 0) {
      groups.add(
        EnemySpawnGroup(
          type: EnemyType.tank,
          count: tankCount,
          spawnInterval: 1.5,
        ),
      );
    }

    if (level <= 3) {
      return switch (wave) {
        1 => const WaveDefinition(groups: [
            EnemySpawnGroup(type: EnemyType.zombie, count: 4, spawnInterval: 0.9),
          ]),
        2 => const WaveDefinition(groups: [
            EnemySpawnGroup(type: EnemyType.zombie, count: 3, spawnInterval: 0.9),
            EnemySpawnGroup(type: EnemyType.monster, count: 2, spawnInterval: 1.1),
          ]),
        _ => WaveDefinition(groups: [
            const EnemySpawnGroup(type: EnemyType.zombie, count: 3),
            EnemySpawnGroup(
              type: level >= 2 ? EnemyType.tank : EnemyType.monster,
              count: 1,
              spawnInterval: 1.3,
            ),
          ]),
      };
    }

    return WaveDefinition(groups: groups);
  }
}
