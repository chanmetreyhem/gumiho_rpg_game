import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../domain/enemy_type.dart';
import '../gumiho_game.dart';
import 'enemy_component.dart';

class ExplosionComponent extends PositionComponent
    with HasGameReference<GumihoGame> {
  ExplosionComponent({
    required Vector2 position,
    required this.radius,
    required this.baseDamage,
  }) : super(
          position: position,
          size: Vector2.all(radius * 2),
          anchor: Anchor.center,
        );

  final double radius;
  final double baseDamage;

  static const double _duration = 0.45;
  double _life = _duration;
  bool _damaged = false;

  @override
  Future<void> onLoad() async {
    game.audio.playExplosion();
    _applyDamage();
  }

  void _applyDamage() {
    if (_damaged) return;
    _damaged = true;

    final enemies = game.world.children.whereType<EnemyComponent>().toList();
    for (final enemy in enemies) {
      final dist = enemy.position.distanceTo(position);
      if (dist <= radius) {
        final falloff = 1 - (dist / radius) * 0.3;
        var damage = baseDamage * falloff;
        if (enemy.type.isHeavy) damage *= 0.5;
        enemy.takeDamage(damage);
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _life -= dt;
    if (_life <= 0) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final progress = 1 - (_life / _duration).clamp(0.0, 1.0);
    final alpha = (1 - progress).clamp(0.0, 1.0);
    final center = Offset(size.x / 2, size.y / 2);

    for (var i = 0; i < 3; i++) {
      final ringProgress = (progress - i * 0.12).clamp(0.0, 1.0);
      final ringRadius = radius * (0.3 + ringProgress * 0.9);
      final ringAlpha = alpha * (1 - ringProgress) * 0.55;
      canvas.drawCircle(
        center,
        ringRadius,
        Paint()
          ..color = Colors.orange.withValues(alpha: ringAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4 - i.toDouble(),
      );
    }

    canvas.drawCircle(
      center,
      radius * (0.25 + progress * 0.35),
      Paint()..color = Colors.yellow.withValues(alpha: 0.75 * alpha),
    );
    canvas.drawCircle(
      center,
      radius * 0.15,
      Paint()..color = Colors.white.withValues(alpha: 0.6 * alpha),
    );
  }
}
