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
  static Set<EnemyType> enemyTypesForLevel(int level) {
    final types = <EnemyType>{};
    for (final wave in wavesForLevel(level)) {
      for (final group in wave.groups) {
        types.add(group.type);
      }
    }
    return types;
  }

  static List<WaveDefinition> wavesForLevel(int level) {
    final waveCount = LevelConfig.waveCountForLevel(level);
    return List.generate(
      waveCount,
      (index) => _waveForLevel(level, index + 1, waveCount),
    );
  }

  static WaveDefinition _waveForLevel(int level, int wave, int totalWaves) {
    if (level <= 3) {
      return _tutorialWave(level, wave);
    }

    final tier = (level - 1) ~/ 10;
    final waveScale = 1.0 + (level - 1) * 0.018 + (wave - 1) * 0.06;
    final isFinalWave = wave >= totalWaves;
    final isPenultimateWave = wave >= totalWaves - 1;

    final groups = <EnemySpawnGroup>[
      EnemySpawnGroup(
        type: EnemyType.zombie,
        count: _scaledCount(3 + wave + tier, waveScale, min: 2, max: 12),
        spawnInterval: 0.85,
      ),
    ];

    if (level >= 2) {
      groups.add(
        EnemySpawnGroup(
          type: EnemyType.monster,
          count: _scaledCount(wave + tier ~/ 2, waveScale * 0.85, min: 1, max: 8),
          spawnInterval: 1.0,
        ),
      );
    }

    if (level >= 11) {
      groups.add(
        EnemySpawnGroup(
          type: EnemyType.scalebladeRavager,
          count: _scaledCount(1 + wave ~/ 2 + tier ~/ 3, waveScale * 0.75,
              min: 1, max: 6),
          spawnInterval: 0.95,
        ),
      );
    }

    if (level >= 21) {
      groups.add(
        EnemySpawnGroup(
          type: EnemyType.blazingBoneRaider,
          count: _scaledCount(wave ~/ 2 + tier ~/ 4, waveScale * 0.7, min: 0, max: 5),
          spawnInterval: 1.05,
        ),
      );
    }

    if (level >= 41) {
      groups.add(
        EnemySpawnGroup(
          type: EnemyType.venomjawBlaster,
          count: _scaledCount(1 + tier ~/ 5, waveScale * 0.65, min: 0, max: 4),
          spawnInterval: 1.15,
        ),
      );
    }

    if (level >= 4 && (isPenultimateWave || isFinalWave)) {
      groups.add(
        EnemySpawnGroup(
          type: EnemyType.tank,
          count: level >= 40 && isFinalWave ? 2 : 1,
          spawnInterval: 1.5,
        ),
      );
    }

    if (level >= 61 && isFinalWave) {
      groups.add(
        EnemySpawnGroup(
          type: EnemyType.stoneClubBrute,
          count: level >= 120 ? 2 : 1,
          spawnInterval: 1.65,
        ),
      );
    }

    groups.removeWhere((g) => g.count <= 0);
    return WaveDefinition(groups: groups);
  }

  static WaveDefinition _tutorialWave(int level, int wave) {
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

  static int _scaledCount(
    int base,
    double scale, {
    required int min,
    required int max,
  }) =>
      (base * scale).round().clamp(min, max);
}
