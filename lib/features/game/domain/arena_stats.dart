class ArenaStats {
  const ArenaStats({
    required this.id,
    required this.name,
    required this.imageFileName,
    this.price = 0,
  });

  final String id;
  final String name;
  final String imageFileName;
  final int price;

  String get assetPath => 'arenas/$imageFileName';
}
