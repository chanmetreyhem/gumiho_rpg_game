import '../../features/game/domain/enemy_type.dart';

class EnemyBaseStats {
  const EnemyBaseStats({
    required this.hp,
    required this.speed,
    required this.contactDamage,
    required this.coinReward,
    required this.size,
    required this.attackStopDistance,
  });

  final double hp;
  final double speed;
  final double contactDamage;
  final int coinReward;
  final double size;
  final double attackStopDistance;
}

class LevelCurve {
  /// Visual scale applied to all enemy types.
  static const double enemySizeScale = 1.3;

  /// Collision radius vs sprite size (higher = easier to land shots).
  static const double hurtboxRadiusScale = 0.82;

  static double hpMultiplier(int level) => 1 + level * 0.04;
  static double speedMultiplier(int level) => 1 + level * 0.012;

  static double hurtboxRadius(double visualSize) =>
      visualSize * 0.5 * hurtboxRadiusScale;

  static EnemyBaseStats baseStats(EnemyType type) {
    return switch (type) {
      EnemyType.zombie => const EnemyBaseStats(
          hp: 26,
          speed: 72,
          contactDamage: 6,
          coinReward: 5,
          size: 36,
          attackStopDistance: 44,
        ),
      EnemyType.monster => const EnemyBaseStats(
          hp: 42,
          speed: 118,
          contactDamage: 9,
          coinReward: 10,
          size: 32,
          attackStopDistance: 38,
        ),
      EnemyType.tank => const EnemyBaseStats(
          hp: 95,
          speed: 50,
          contactDamage: 15,
          coinReward: 25,
          size: 52,
          attackStopDistance: 58,
        ),
      EnemyType.scalebladeRavager => const EnemyBaseStats(
          hp: 34,
          speed: 128,
          contactDamage: 8,
          coinReward: 12,
          size: 38,
          attackStopDistance: 40,
        ),
      EnemyType.blazingBoneRaider => const EnemyBaseStats(
          hp: 48,
          speed: 96,
          contactDamage: 11,
          coinReward: 14,
          size: 40,
          attackStopDistance: 46,
        ),
      EnemyType.venomjawBlaster => const EnemyBaseStats(
          hp: 38,
          speed: 88,
          contactDamage: 10,
          coinReward: 16,
          size: 36,
          attackStopDistance: 52,
        ),
      EnemyType.stoneClubBrute => const EnemyBaseStats(
          hp: 110,
          speed: 44,
          contactDamage: 18,
          coinReward: 30,
          size: 56,
          attackStopDistance: 62,
        ),
    };
  }

  static EnemyBaseStats scaledStats(EnemyType type, int level) {
    final base = baseStats(type);
    final hpMult = hpMultiplier(level);
    final spdMult = speedMultiplier(level);
    return EnemyBaseStats(
      hp: base.hp * hpMult,
      speed: base.speed * spdMult,
      contactDamage: base.contactDamage,
      coinReward: base.coinReward + (level ~/ 5),
      size: base.size * enemySizeScale,
      attackStopDistance: base.attackStopDistance * enemySizeScale,
    );
  }
}
