class PlayerProfile {
  const PlayerProfile({
    this.coins = 75,
    this.ownedSkins = const ['default'],
    this.ownedGuns = const ['pistol'],
    this.equippedSkinId = 'default',
    this.equippedGunId = 'pistol',
    this.highestLevelCleared = 0,
    this.levelStars = const {},
    this.removeAdsPurchased = false,
  });

  final int coins;
  final List<String> ownedSkins;
  final List<String> ownedGuns;
  final String equippedSkinId;
  final String equippedGunId;
  final int highestLevelCleared;
  final Map<int, int> levelStars;
  final bool removeAdsPurchased;

  bool isLevelUnlocked(int level) => level == 1 || highestLevelCleared >= level - 1;

  PlayerProfile copyWith({
    int? coins,
    List<String>? ownedSkins,
    List<String>? ownedGuns,
    String? equippedSkinId,
    String? equippedGunId,
    int? highestLevelCleared,
    Map<int, int>? levelStars,
    bool? removeAdsPurchased,
  }) {
    return PlayerProfile(
      coins: coins ?? this.coins,
      ownedSkins: ownedSkins ?? this.ownedSkins,
      ownedGuns: ownedGuns ?? this.ownedGuns,
      equippedSkinId: equippedSkinId ?? this.equippedSkinId,
      equippedGunId: equippedGunId ?? this.equippedGunId,
      highestLevelCleared: highestLevelCleared ?? this.highestLevelCleared,
      levelStars: levelStars ?? this.levelStars,
      removeAdsPurchased: removeAdsPurchased ?? this.removeAdsPurchased,
    );
  }

  Map<String, dynamic> toJson() => {
        'coins': coins,
        'ownedSkins': ownedSkins,
        'ownedGuns': ownedGuns,
        'equippedSkinId': equippedSkinId,
        'equippedGunId': equippedGunId,
        'highestLevelCleared': highestLevelCleared,
        'levelStars': levelStars.map((k, v) => MapEntry(k.toString(), v)),
        'removeAdsPurchased': removeAdsPurchased,
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    final starsRaw = json['levelStars'] as Map<String, dynamic>? ?? {};
    return PlayerProfile(
      coins: json['coins'] as int? ?? 0,
      ownedSkins: (json['ownedSkins'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['default'],
      ownedGuns: (json['ownedGuns'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['pistol'],
      equippedSkinId: json['equippedSkinId'] as String? ?? 'default',
      equippedGunId: json['equippedGunId'] as String? ?? 'pistol',
      highestLevelCleared: json['highestLevelCleared'] as int? ?? 0,
      levelStars: starsRaw.map(
        (k, v) => MapEntry(int.parse(k), v as int),
      ),
      removeAdsPurchased: json['removeAdsPurchased'] as bool? ?? false,
    );
  }
}
