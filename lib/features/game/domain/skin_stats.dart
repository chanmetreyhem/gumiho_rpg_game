class SkinStats {
  const SkinStats({
    required this.id,
    required this.name,
    required this.characterFolder,
    required this.hpBonus,
    required this.speedBonus,
    this.price = 0,
    this.colorValue = 0xFF4CAF50,
  });

  final String id;
  final String name;
  final String characterFolder;
  final double hpBonus;
  final double speedBonus;
  final int price;
  final int colorValue;
}
