import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../../data/config/game_assets.dart';
import '../../domain/weapon_stats.dart';
import '../gumiho_game.dart';

class GunComponent extends PositionComponent with HasGameReference<GumihoGame> {
  GunComponent({required this.weapon});

  WeaponStats weapon;
  double aimAngle = 0;
  double _cooldown = 0;
  bool _wantsFire = false;

  late double barrelLength = 26;

  static const double _targetHeight = 28;

  Vector2 get aimDirection => Vector2(cos(aimAngle), sin(aimAngle));

  void setAimDirection(Vector2 direction) {
    aimAngle = atan2(direction.y, direction.x);
    angle = aimAngle;
    _wantsFire = true;
  }

  void stopFiring() {
    _wantsFire = false;
  }

  @override
  Future<void> onLoad() async {
    final path = GameAssets.gunPath(weapon.id);
    try {
      final image = game.images.containsKey(path)
          ? game.images.fromCache(path)
          : await game.images.load(path);
      final scale = _targetHeight / image.height;
      final gunSize = Vector2(image.width * scale, image.height * scale);
      barrelLength = gunSize.x * 0.92;

      add(
        SpriteComponent(
          sprite: Sprite(image),
          size: gunSize,
          anchor: Anchor.centerLeft,
          position: Vector2(-6, 0),
        ),
      );
    } on Object {
      // Keep default barrelLength if gun sprite is missing.
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_cooldown > 0) _cooldown -= dt;
    if (_wantsFire) tryFire();
  }

  void tryFire() {
    if (_cooldown > 0) return;
    _cooldown = 1 / (weapon.fireRate * game.runBuffs.fireRateMultiplier);
    game.audio.playShoot();

    final spread = (weapon.spreadAngle * 2) * (Random().nextDouble() - 0.5);
    final shotAngle = absoluteAngle + spread;
    final dir = Vector2(cos(shotAngle), sin(shotAngle));
    final muzzleOffset = Vector2(barrelLength, 0)..rotate(absoluteAngle);
    final muzzle = absolutePosition + muzzleOffset;

    game.spawnMuzzleFlash(
      worldPosition: muzzle,
      angle: shotAngle,
      coreColor: Color(weapon.bulletColor),
      glowColor: Color(weapon.bulletGlowColor),
    );

    game.bulletPool.spawn(
      position: muzzle,
      direction: dir,
      damage: weapon.damage * game.runBuffs.damageMultiplier,
      speed: weapon.bulletSpeed * game.runBuffs.bulletSpeedMultiplier,
      special: weapon.special,
      bulletColor: weapon.bulletColor,
      bulletGlowColor: weapon.bulletGlowColor,
    );
  }
}
