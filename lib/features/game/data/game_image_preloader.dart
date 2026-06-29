import 'package:flame/flame.dart';

import '../../../data/config/game_assets.dart';
import '../../../data/config/wave_config.dart';
import '../domain/enemy_type.dart';

/// Shared image cache via [Flame.images] so assets survive across game sessions.
class GameImagePreloader {
  GameImagePreloader._();

  static final Set<String> _loaded = <String>{};

  /// Common enemies used from level 1 — warm during splash.
  static Future<void> preloadCore() => loadPaths([
        ...GameAssets.enemyPartPathsFor(const {
          EnemyType.zombie,
          EnemyType.monster,
        }),
      ]);

  static Future<void> preloadForSession({
    required int levelId,
    required String skinFolder,
    required String weaponId,
    required String arenaId,
  }) {
    final enemyTypes = WaveConfig.enemyTypesForLevel(levelId);
    return loadPaths([
      ...GameAssets.preloadPaths(
        characterFolders: [skinFolder],
        weaponIds: [weaponId],
        arenaId: arenaId,
      ),
      ...GameAssets.enemyPartPathsFor(enemyTypes),
    ]);
  }

  static Future<void> loadPaths(Iterable<String> paths) async {
    final pending = paths.where((path) => !_loaded.contains(path)).toList();
    if (pending.isEmpty) return;

    await Future.wait(
      pending.map((path) async {
        if (_loaded.contains(path)) return;
        if (Flame.images.containsKey(path)) {
          _loaded.add(path);
          return;
        }
        try {
          await Flame.images.load(path);
          _loaded.add(path);
        } on Object {
          // Optional sprite part.
        }
      }),
    );
  }
}
