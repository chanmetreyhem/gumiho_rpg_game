import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../gumiho_game.dart';
import 'explosion_component.dart';

class BombComponent extends PositionComponent with HasGameReference<GumihoGame> {
  BombComponent({
    required Vector2 position,
    required Vector2 target,
  })  : _target = target.clone(),
        super(
          position: position,
          size: Vector2(16, 16),
          anchor: Anchor.center,
        );

  final Vector2 _target;
  static const double speed = 320;
  static const double fuseTime = 2.5;
  double _timer = fuseTime;

  @override
  void update(double dt) {
    super.update(dt);
    _timer -= dt;

    final toTarget = _target - position;
    final distance = toTarget.length;
    if (distance <= speed * dt + 6) {
      _explode();
      return;
    }

    position += toTarget.normalized() * speed * dt;

    if (_timer <= 0) {
      _explode();
    }
  }

  void _explode() {
    game.world.add(
      ExplosionComponent(
        position: position.clone(),
        radius: 120,
        baseDamage: 80,
      ),
    );
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      7,
      Paint()..color = const Color(0xFFFF5722),
    );
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      7,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }
}
