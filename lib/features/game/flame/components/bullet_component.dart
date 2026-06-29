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
          size: Vector2(14, 14),
          anchor: Anchor.center,
        );

  factory BulletComponent.forPool() => BulletComponent._();

  static const double hitRadius = 6;
  static const double _maxMoveStep = 10;

  double damage = 0;
  double speed = 0;
  WeaponSpecial special = WeaponSpecial.none;
  int bulletColor = 0xFFFFF59D;
  int bulletGlowColor = 0xFFFFEB3B;

  Vector2 _direction;
  double _traveled = 0;
  bool _active = false;
  bool _hitProcessed = false;

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
    _hitProcessed = false;
    _updatePaints();
    _hitbox?.collisionType = CollisionType.active;
  }

  void deactivate() {
    _active = false;
    _hitProcessed = false;
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
    _hitbox = CircleHitbox(
      radius: hitRadius,
      anchor: Anchor.center,
    );
    await add(_hitbox!);
    if (!_active) {
      _hitbox!.collisionType = CollisionType.inactive;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_active) return;

    var remaining = speed * dt;
    while (remaining > 0 && _active) {
      final step = remaining > _maxMoveStep ? _maxMoveStep : remaining;
      remaining -= step;

      position += _direction * step;
      _traveled += step;

      if (_traveled >= GumihoGame.bulletMaxDistance) {
        _release();
        return;
      }

      if (_tryHitEnemy()) {
        return;
      }
    }
  }

  /// Distance check each sub-step so fast bullets do not tunnel through foes.
  bool _tryHitEnemy() {
    for (final enemy in game.world.children.whereType<EnemyComponent>()) {
      final combined = hitRadius + enemy.hitRadius;
      if (position.distanceToSquared(enemy.position) > combined * combined) {
        continue;
      }
      _registerHit(enemy);
      return true;
    }

    return false;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (!_active || _hitProcessed || other is! EnemyComponent) return;
    _registerHit(other);
  }

  void _registerHit(EnemyComponent enemy) {
    if (!_active || _hitProcessed) return;
    _hitProcessed = true;

    game.audio.playHit();
    enemy.takeDamage(_resolveDamage(enemy));
    _applySpecial(enemy);
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
    if (special == WeaponSpecial.armorPierce && enemy.type.isHeavy) {
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
    canvas.drawCircle(center, 7, _glowPaint);
    canvas.drawCircle(center, 5, _bodyPaint);
    canvas.drawCircle(center, 2.5, _corePaint);
  }
}
