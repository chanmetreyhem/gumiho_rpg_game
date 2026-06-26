class GameAssets {
  GameAssets._();

  static const _characterRoot = 'Characters';

  static String characterPart(String folder, String part) =>
      '$_characterRoot/$folder/$part.png';

  static const characterParts = ['Left_Foot', 'Right_Foot', 'Body', 'Head'];

  static const gunPaths = <String, String>{
    'pistol': 'gun/riffle.png',
    'rifle': 'gun/rifle.png',
    'shotgun': 'gun/shotgun.png',
    'sniper': 'gun/sniper.png',
    'plasma_pistol': 'gun/Sleek Plasma Pistol.png',
    'pulse_smg': 'gun/Sub-Orbital Pulse SMG.png',
    'tesla_carbine': 'gun/Charged Tesla Carbine.png',
  };

  static String gunPath(String weaponId) =>
      gunPaths[weaponId] ?? gunPaths['pistol']!;

  static const enemyFolders = <String, String>{
    'zombie': 'enemies/zombie',
    'monster': 'enemies/monster',
    'tank': 'enemies/tank',
  };

  static const enemyParts = [
    'left_foot',
    'right_foot',
    'body',
    'left_hand',
    'right_hand',
    'head',
  ];

  static String enemyPart(String typeName, String part) =>
      '${enemyFolders[typeName] ?? enemyFolders['zombie']}/$part.png';

  static List<String> get allEnemyPartPaths => [
        for (final folder in enemyFolders.values)
          for (final part in enemyParts)
            '$folder/$part.png',
      ];

  static Iterable<String> preloadPaths({
    required Iterable<String> characterFolders,
    required Iterable<String> weaponIds,
  }) sync* {
    for (final folder in characterFolders) {
      for (final part in characterParts) {
        yield characterPart(folder, part);
      }
    }
    for (final id in weaponIds) {
      yield gunPath(id);
    }
  }
}
