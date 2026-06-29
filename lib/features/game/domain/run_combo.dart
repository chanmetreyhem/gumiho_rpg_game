import 'dart:math';

enum ComboType {
  damageUp,
  fireRateUp,
  maxHpUp,
  heal,
  speedUp,
  extraBomb,
  bulletSpeedUp,
}

class RunCombo {
  const RunCombo({
    required this.type,
    required this.value,
  });

  final ComboType type;
  final double value;
}

enum ComboCategory {
  active,
  stat,
  passive,
}

class RunBuffs {
  RunBuffs();

  double damageMultiplier = 1;
  double fireRateMultiplier = 1;
  double speedMultiplier = 1;
  double bulletSpeedMultiplier = 1;
  double damageReduction = 0;

  final Map<ComboType, int> _pickCounts = {};

  int pickCount(ComboType type) => _pickCounts[type] ?? 0;

  void apply(RunCombo combo) {
    _pickCounts[combo.type] = pickCount(combo.type) + 1;

    switch (combo.type) {
      case ComboType.damageUp:
        damageMultiplier += combo.value;
      case ComboType.fireRateUp:
        fireRateMultiplier += combo.value;
      case ComboType.speedUp:
        speedMultiplier += combo.value;
      case ComboType.bulletSpeedUp:
        bulletSpeedMultiplier += combo.value;
      case ComboType.maxHpUp:
      case ComboType.heal:
      case ComboType.extraBomb:
        break;
    }
  }
}

extension ComboTypeUi on ComboType {
  ComboCategory get category => switch (this) {
        ComboType.damageUp ||
        ComboType.fireRateUp ||
        ComboType.extraBomb =>
          ComboCategory.active,
        ComboType.maxHpUp || ComboType.heal || ComboType.speedUp =>
          ComboCategory.stat,
        ComboType.bulletSpeedUp => ComboCategory.passive,
      };

  int get progressMax => switch (category) {
        ComboCategory.active => 1,
        ComboCategory.stat => 8,
        ComboCategory.passive => 5,
      };
}

class ComboCatalog {
  ComboCatalog._();

  static final _random = Random();

  static const _pool = <RunCombo>[
    RunCombo(type: ComboType.damageUp, value: 0.2),
    RunCombo(type: ComboType.fireRateUp, value: 0.25),
    RunCombo(type: ComboType.maxHpUp, value: 0.25),
    RunCombo(type: ComboType.heal, value: 0.35),
    RunCombo(type: ComboType.speedUp, value: 0.15),
    RunCombo(type: ComboType.extraBomb, value: 1),
    RunCombo(type: ComboType.bulletSpeedUp, value: 0.2),
    RunCombo(type: ComboType.damageUp, value: 0.12),
    RunCombo(type: ComboType.fireRateUp, value: 0.15),
    RunCombo(type: ComboType.heal, value: 0.2),
  ];

  static List<RunCombo> rollThree({int level = 1, int wave = 1}) {
    final options = List<RunCombo>.from(_pool);
    options.shuffle(_random);

    final picks = <RunCombo>[];
    for (final combo in options) {
      if (picks.any((p) => p.type == combo.type)) continue;
      picks.add(combo);
      if (picks.length == 3) break;
    }

    while (picks.length < 3) {
      picks.add(_pool[picks.length % _pool.length]);
    }

    if (level <= 5 && wave <= 2) {
      return [
        const RunCombo(type: ComboType.heal, value: 0.35),
        const RunCombo(type: ComboType.damageUp, value: 0.2),
        const RunCombo(type: ComboType.fireRateUp, value: 0.25),
      ];
    }

    return picks;
  }
}
