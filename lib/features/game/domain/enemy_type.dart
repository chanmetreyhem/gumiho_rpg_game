enum EnemyType {
  zombie,
  monster,
  tank,
  venomjawBlaster,
  scalebladeRavager,
  blazingBoneRaider,
  stoneClubBrute,
}

extension EnemyTypeStats on EnemyType {
  /// Heavy enemies take reduced explosion damage and bonus armor-pierce damage.
  bool get isHeavy =>
      this == EnemyType.tank || this == EnemyType.stoneClubBrute;
}
