import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../gumiho_game.dart';

class BombAimIndicator extends Component with HasGameReference<GumihoGame> {
  @override
  void render(Canvas canvas) {
    final target = game.bombAimWorld;
    if (target == null) return;

    const radius = 48.0;
    canvas.drawCircle(
      Offset(target.x, target.y),
      radius,
      Paint()..color = const Color(0xFFFF5722).withValues(alpha: 0.2),
    );
    canvas.drawCircle(
      Offset(target.x, target.y),
      radius,
      Paint()
        ..color = const Color(0xFFFF5722).withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawCircle(
      Offset(target.x, target.y),
      6,
      Paint()..color = const Color(0xFFFF5722),
    );
  }
}
