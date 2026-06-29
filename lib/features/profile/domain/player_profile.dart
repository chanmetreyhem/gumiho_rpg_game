class PlayerProfile {
  const PlayerProfile({
    this.coins = 75,
    this.ownedSkins = const ['default'],
    this.ownedGuns = const ['pistol'],
    this.ownedArenas = const ['forest'],
    this.equippedSkinId = 'default',
    this.equippedGunId = 'pistol',
    this.equippedArenaId = 'forest',
    this.highestLevelCleared = 0,
    this.levelStars = const {},
    this.removeAdsPurchased = false,
  });

  final int coins;
  final List<String> ownedSkins;
  final List<String> ownedGuns;
  final List<String> ownedArenas;
  final String equippedSkinId;
  final String equippedGunId;
  final String equippedArenaId;
  final int highestLevelCleared;
  final Map<int, int> levelStars;
  final bool removeAdsPurchased;

  bool isLevelUnlocked(int level) => level == 1 || highestLevelCleared >= level - 1;

  PlayerProfile copyWith({
    int? coins,
    List<String>? ownedSkins,
    List<String>? ownedGuns,
    List<String>? ownedArenas,
    String? equippedSkinId,
    String? equippedGunId,
    String? equippedArenaId,
    int? highestLevelCleared,
    Map<int, int>? levelStars,
    bool? removeAdsPurchased,
  }) {
    return PlayerProfile(
      coins: coins ?? this.coins,
      ownedSkins: ownedSkins ?? this.ownedSkins,
      ownedGuns: ownedGuns ?? this.ownedGuns,
      ownedArenas: ownedArenas ?? this.ownedArenas,
      equippedSkinId: equippedSkinId ?? this.equippedSkinId,
      equippedGunId: equippedGunId ?? this.equippedGunId,
      equippedArenaId: equippedArenaId ?? this.equippedArenaId,
      highestLevelCleared: highestLevelCleared ?? this.highestLevelCleared,
      levelStars: levelStars ?? this.levelStars,
      removeAdsPurchased: removeAdsPurchased ?? this.removeAdsPurchased,
    );
  }

  Map<String, dynamic> toJson() => {
        'coins': coins,
        'ownedSkins': ownedSkins,
        'ownedGuns': ownedGuns,
        'ownedArenas': ownedArenas,
        'equippedSkinId': equippedSkinId,
        'equippedGunId': equippedGunId,
        'equippedArenaId': equippedArenaId,
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
      ownedArenas: (json['ownedArenas'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['forest'],
      equippedSkinId: json['equippedSkinId'] as String? ?? 'default',
      equippedGunId: json['equippedGunId'] as String? ?? 'pistol',
      equippedArenaId: json['equippedArenaId'] as String? ?? 'forest',
      highestLevelCleared: json['highestLevelCleared'] as int? ?? 0,
      levelStars: starsRaw.map(
        (k, v) => MapEntry(int.parse(k), v as int),
      ),
      removeAdsPurchased: json['removeAdsPurchased'] as bool? ?? false,
    );
  }
}
