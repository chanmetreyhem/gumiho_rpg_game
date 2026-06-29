import '../../features/game/domain/enemy_type.dart';
import 'shop_catalog.dart';

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

  static String arenaPath(String arenaId) =>
      ShopCatalog.arenaById(arenaId).assetPath;

  static const enemyParts = [
    'left_foot',
    'right_foot',
    'body',
    'left_hand',
    'right_hand',
    'head',
  ];

  static const _enemyFolders = <EnemyType, String>{
    EnemyType.zombie: 'enemies/zombie',
    EnemyType.monster: 'enemies/monster',
    EnemyType.tank: 'enemies/tank',
    EnemyType.venomjawBlaster: 'enemies/venomjaw_blaster',
    EnemyType.scalebladeRavager: 'enemies/scaleblade_ravager',
    EnemyType.blazingBoneRaider: 'enemies/blazing_bone_raider',
    EnemyType.stoneClubBrute: 'enemies/stone_club_brute',
  };

  static const _optionalEnemyParts = <EnemyType, List<String>>{
    EnemyType.venomjawBlaster: ['heat'],
  };

  static String enemyFolder(EnemyType type) =>
      _enemyFolders[type] ?? _enemyFolders[EnemyType.zombie]!;

  static String enemyPartPath(EnemyType type, String part) =>
      '${enemyFolder(type)}/$part.png';

  static List<String> optionalPartsFor(EnemyType type) =>
      _optionalEnemyParts[type] ?? const [];

  @Deprecated('Use enemyPartPath(EnemyType, part)')
  static String enemyPart(String typeName, String part) =>
      'enemies/$typeName/$part.png';

  static List<String> get allEnemyPartPaths => enemyPartPathsFor(
        _enemyFolders.keys,
      );

  static List<String> enemyPartPathsFor(Iterable<EnemyType> types) => [
        for (final type in types)
          for (final part in enemyParts)
            '${enemyFolder(type)}/$part.png',
        for (final type in types)
          for (final part in optionalPartsFor(type))
            '${enemyFolder(type)}/$part.png',
      ];

  static Iterable<String> preloadPaths({
    required Iterable<String> characterFolders,
    required Iterable<String> weaponIds,
    String? arenaId,
  }) sync* {
    for (final folder in characterFolders) {
      for (final part in characterParts) {
        yield characterPart(folder, part);
      }
    }
    for (final id in weaponIds) {
      yield gunPath(id);
    }
    if (arenaId != null) {
      yield arenaPath(arenaId);
    }
  }
}
