import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../domain/enemy_type.dart';
import '../../domain/weapon_special.dart';
import '../gumiho_game.dart';
import 'enemy_component.dart';

class BulletComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<GumihoGame> {
  BulletComponent({
    required Vector2 position,
    required Vector2 direction,
    required this.damage,
    required this.speed,
    this.special = WeaponSpecial.none,
    this.bulletColor = 0xFFFFF59D,
    this.bulletGlowColor = 0xFFFFEB3B,
  })  : _direction = direction.normalized(),
        super(
          position: position,
          size: Vector2(12, 12),
          anchor: Anchor.center,
        );

  final double damage;
  final double speed;
  final WeaponSpecial special;
  final int bulletColor;
  final int bulletGlowColor;
  final Vector2 _direction;
  double _traveled = 0;

  late final Paint _glowPaint = Paint()
    ..color = Color(bulletGlowColor).withValues(alpha: 0.35);
  late final Paint _bodyPaint = Paint()..color = Color(bulletColor);
  static final Paint _corePaint = Paint()..color = Colors.white;

  @override
  Future<void> onLoad() async {
    add(CircleHitbox(radius: 4));
  }

  @override
  void update(double dt) {
    super.update(dt);
    final delta = _direction * speed * dt;
    position += delta;
    _traveled += delta.length;
    if (_traveled >= GumihoGame.bulletMaxDistance) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is! EnemyComponent) return;

    game.audio.playHit();
    other.takeDamage(_resolveDamage(other));
    _applySpecial(other);
    game.spawnHitEffect(
      worldPosition: position.clone(),
      direction: _direction,
      coreColor: Color(bulletColor),
      glowColor: Color(bulletGlowColor),
    );
    removeFromParent();
  }

  double _resolveDamage(EnemyComponent enemy) {
    var amount = damage;
    if (special == WeaponSpecial.armorPierce &&
        enemy.type == EnemyType.tank) {
      amount *= 1.35;
    }
    return amount;
  }

  void _applySpecial(EnemyComponent enemy) {
    switch (special) {
      case WeaponSpecial.disorient:
        enemy.applyDisorient(0.35);
      case WeaponSpecial.shock:
        enemy.applyShock(0.18);
      case WeaponSpecial.none:
      case WeaponSpecial.armorPierce:
        break;
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(center, 6, _glowPaint);
    canvas.drawCircle(center, 4, _bodyPaint);
    canvas.drawCircle(center, 2, _corePaint);
  }
}
