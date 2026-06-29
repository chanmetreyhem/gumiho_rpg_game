import 'dart:ui' as ui;

import 'package:flame/components.dart';

import '../gumiho_game.dart';

class BombAimIndicator extends Component with HasGameReference<GumihoGame> {
  static const _targetRadius = 48.0;
  static const _accent = ui.Color(0xFFFF8A3D);
  static const _accentDim = ui.Color(0x66FF8A3D);

  @override
  void render(ui.Canvas canvas) {
    final target = game.bombAimWorld;
    if (target == null) return;

    final player = game.player.position;
    final throwRange = GumihoGame.bombThrowRange;

    // Max throw range around player.
    canvas.drawCircle(
      ui.Offset(player.x, player.y),
      throwRange,
      ui.Paint()
        ..color = _accentDim
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Trajectory from player to aim point.
    canvas.drawLine(
      ui.Offset(player.x, player.y),
      ui.Offset(target.x, target.y),
      ui.Paint()
        ..color = _accent
        ..strokeWidth = 3
        ..strokeCap = ui.StrokeCap.round,
    );

    // Landing zone fill + ring.
    canvas.drawCircle(
      ui.Offset(target.x, target.y),
      _targetRadius,
      ui.Paint()..color = _accent.withValues(alpha: 0.22),
    );
    canvas.drawCircle(
      ui.Offset(target.x, target.y),
      _targetRadius,
      ui.Paint()
        ..color = _accent
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(
      ui.Offset(target.x, target.y),
      7,
      ui.Paint()..color = _accent,
    );
  }
}
