class StarRating {
  StarRating._();

  static int fromHp(double hp, double maxHp) {
    if (maxHp <= 0) return 1;
    final ratio = hp / maxHp;
    if (ratio >= 0.7) return 3;
    if (ratio >= 0.4) return 2;
    return 1;
  }

  static int levelClearBonus(int level, {int stars = 1}) =>
      level * 15 + stars * 10;
}
