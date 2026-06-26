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

class RunBuffs {
  double damageMultiplier = 1;
  double fireRateMultiplier = 1;
  double speedMultiplier = 1;
  double bulletSpeedMultiplier = 1;
  double damageReduction = 0;

  void apply(RunCombo combo) {
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
