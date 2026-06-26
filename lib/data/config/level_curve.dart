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
  static double hpMultiplier(int level) => 1 + level * 0.055;
  static double speedMultiplier(int level) => 1 + level * 0.018;

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
      size: base.size,
      attackStopDistance: base.attackStopDistance,
    );
  }
}
