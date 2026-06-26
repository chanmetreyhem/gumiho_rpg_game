import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../domain/enemy_type.dart';
import '../../domain/weapon_special.dart';
import '../gumiho_game.dart';
import 'enemy_component.dart';

class BulletComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<GumihoGame> {
  BulletComponent._()
      : _direction = Vector2(1, 0),
        super(
          size: Vector2(12, 12),
          anchor: Anchor.center,
        );

  factory BulletComponent.forPool() => BulletComponent._();

  double damage = 0;
  double speed = 0;
  WeaponSpecial special = WeaponSpecial.none;
  int bulletColor = 0xFFFFF59D;
  int bulletGlowColor = 0xFFFFEB3B;

  Vector2 _direction;
  double _traveled = 0;
  bool _active = false;

  CircleHitbox? _hitbox;

  late Paint _glowPaint = Paint()
    ..color = const Color(0xFFFFEB3B).withValues(alpha: 0.35);
  late Paint _bodyPaint = Paint()..color = const Color(0xFFFFF59D);
  static final Paint _corePaint = Paint()..color = Colors.white;

  bool get isActive => _active;

  void activate({
    required Vector2 position,
    required Vector2 direction,
    required double damage,
    required double speed,
    WeaponSpecial special = WeaponSpecial.none,
    int bulletColor = 0xFFFFF59D,
    int bulletGlowColor = 0xFFFFEB3B,
  }) {
    this.position.setFrom(position);
    _direction = direction.normalized();
    this.damage = damage;
    this.speed = speed;
    this.special = special;
    this.bulletColor = bulletColor;
    this.bulletGlowColor = bulletGlowColor;
    _traveled = 0;
    _active = true;
    _updatePaints();
    _hitbox?.collisionType = CollisionType.active;
  }

  void deactivate() {
    _active = false;
    _hitbox?.collisionType = CollisionType.inactive;
  }

  void _updatePaints() {
    _glowPaint = Paint()
      ..color = Color(bulletGlowColor).withValues(alpha: 0.35);
    _bodyPaint = Paint()..color = Color(bulletColor);
  }

  void _release() => game.bulletPool.release(this);

  @override
  Future<void> onLoad() async {
    _hitbox = CircleHitbox(radius: 4);
    await add(_hitbox!);
    if (!_active) {
      _hitbox!.collisionType = CollisionType.inactive;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_active) return;

    final delta = _direction * speed * dt;
    position += delta;
    _traveled += delta.length;
    if (_traveled >= GumihoGame.bulletMaxDistance) {
      _release();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (!_active || other is! EnemyComponent) return;

    game.audio.playHit();
    other.takeDamage(_resolveDamage(other));
    _applySpecial(other);
    game.spawnHitEffect(
      worldPosition: position.clone(),
      direction: _direction,
      coreColor: Color(bulletColor),
      glowColor: Color(bulletGlowColor),
    );
    _release();
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
    if (!_active) return;

    final center = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(center, 6, _glowPaint);
    canvas.drawCircle(center, 4, _bodyPaint);
    canvas.drawCircle(center, 2, _corePaint);
  }
}
