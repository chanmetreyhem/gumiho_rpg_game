import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../gumiho_game.dart';

/// Arena floor drawn once into a [ui.Picture] to avoid per-frame tile loops.
class ArenaBackground extends Component with HasGameReference<GumihoGame> {
  ArenaBackground({required this.arenaSize});

  final Vector2 arenaSize;

  static final Paint _bgPaint = Paint()..color = const Color(0xFF2A4A2E);
  static final Paint _patchPaint = Paint()..color = const Color(0xFF325632);
  static final Paint _gridPaint = Paint()
    ..color = const Color(0xFF3E6B3E).withValues(alpha: 0.35)
    ..strokeWidth = 1;
  static final Paint _borderPaint = Paint()
    ..color = const Color(0xFF1A2F1A)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 8;

  ui.Picture? _picture;

  @override
  Future<void> onLoad() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    _drawArena(canvas);
    _picture = recorder.endRecording();
  }

  void _drawArena(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, arenaSize.x, arenaSize.y), _bgPaint);

    const step = 64.0;
    for (var y = 0.0; y < arenaSize.y; y += step) {
      for (var x = 0.0; x < arenaSize.x; x += step) {
        if (((x / step).round() + (y / step).round()).isEven) {
          canvas.drawRect(Rect.fromLTWH(x, y, step, step), _patchPaint);
        }
      }
    }

    for (var x = 0.0; x <= arenaSize.x; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, arenaSize.y), _gridPaint);
    }
    for (var y = 0.0; y <= arenaSize.y; y += step) {
      canvas.drawLine(Offset(0, y), Offset(arenaSize.x, y), _gridPaint);
    }

    canvas.drawRect(Rect.fromLTWH(0, 0, arenaSize.x, arenaSize.y), _borderPaint);
  }

  @override
  void render(Canvas canvas) {
    final picture = _picture;
    if (picture != null) {
      canvas.drawPicture(picture);
    }
  }
}
