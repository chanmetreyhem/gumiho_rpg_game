import 'package:flame/components.dart';

import '../components/bullet_component.dart';
import '../gumiho_game.dart';
import '../../domain/weapon_special.dart';

/// Reuses [BulletComponent] instances to cut GC churn during rapid fire.
class BulletPool {
  BulletPool(this._game);

  final GumihoGame _game;
  final List<BulletComponent> _available = [];

  static const int preloadCount = 36;
  static const int maxPoolSize = 72;

  int _active = 0;
  int get active => _active;

  Future<void> preload() async {
    for (var i = 0; i < preloadCount; i++) {
      final bullet = BulletComponent.forPool();
      await _game.world.add(bullet);
      bullet.deactivate();
      bullet.removeFromParent();
      _available.add(bullet);
    }
  }

  void spawn({
    required Vector2 position,
    required Vector2 direction,
    required double damage,
    required double speed,
    WeaponSpecial special = WeaponSpecial.none,
    int bulletColor = 0xFFFFF59D,
    int bulletGlowColor = 0xFFFFEB3B,
  }) {
    final bullet = _acquire();
    bullet.activate(
      position: position,
      direction: direction,
      damage: damage,
      speed: speed,
      special: special,
      bulletColor: bulletColor,
      bulletGlowColor: bulletGlowColor,
    );
    if (bullet.parent == null) {
      _game.world.add(bullet);
    }
    _active++;
  }

  BulletComponent _acquire() {
    if (_available.isNotEmpty) {
      return _available.removeLast();
    }
    return BulletComponent.forPool();
  }

  void release(BulletComponent bullet) {
    if (!bullet.isActive) return;

    bullet.deactivate();
    if (bullet.parent != null) {
      bullet.removeFromParent();
    }

    if (_available.length < maxPoolSize) {
      _available.add(bullet);
    }

    if (_active > 0) _active--;
  }

  void clear() {
    for (final bullet in _available) {
      if (bullet.parent != null) {
        bullet.removeFromParent();
      }
    }
    _available.clear();
    _active = 0;
  }
}
