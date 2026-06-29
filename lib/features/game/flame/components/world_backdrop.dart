import 'dart:ui' as ui;

import 'package:flame/components.dart';

import '../gumiho_game.dart';

/// Grey tiled floor and props outside the main arena — visible near arena edges.
class WorldBackdrop extends PositionComponent with HasGameReference<GumihoGame> {
  WorldBackdrop({
    required Vector2 arenaSize,
    double padding = 1600,
  }) : super(
          position: Vector2(-padding, -padding),
          size: arenaSize + Vector2.all(padding * 2),
          priority: -40,
          anchor: Anchor.topLeft,
        );

  static const _tile = 64.0;
  static const _floorLight = ui.Color(0xFFB8BEC8);
  static const _floorDark = ui.Color(0xFF9AA3B0);
  static const _grout = ui.Color(0xFF7A8494);

  @override
  void render(ui.Canvas canvas) {
    _drawTileFloor(canvas);
    _drawProps(canvas);
  }

  void _drawTileFloor(ui.Canvas canvas) {
    final cols = (size.x / _tile).ceil();
    final rows = (size.y / _tile).ceil();

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final x = col * _tile;
        final y = row * _tile;
        final even = (row + col).isEven;
        final fill = ui.Paint()..color = even ? _floorLight : _floorDark;
        canvas.drawRect(ui.Rect.fromLTWH(x, y, _tile, _tile), fill);
        canvas.drawRect(
          ui.Rect.fromLTWH(x, y, _tile, _tile),
          ui.Paint()
            ..color = _grout
            ..style = ui.PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      }
    }
  }

  void _drawProps(ui.Canvas canvas) {
    final shelfPaint = ui.Paint()..color = const ui.Color(0xFF6E7A8C);
    final shelfTop = ui.Paint()..color = const ui.Color(0xFF8A96A8);
    final accent = [
      const ui.Color(0xFF9B59B6),
      const ui.Color(0xFF2ECC71),
      const ui.Color(0xFFF1C40F),
      const ui.Color(0xFFE74C3C),
    ];

    final shelves = <ui.Offset>[
      const ui.Offset(120, 180),
      ui.Offset(size.x - 220, 260),
      ui.Offset(size.x * 0.35, size.y - 280),
      ui.Offset(size.x - 320, size.y - 360),
      const ui.Offset(480, 920),
    ];

    for (final origin in shelves) {
      canvas.drawRect(
        ui.Rect.fromLTWH(origin.dx, origin.dy, 96, 14),
        shelfTop,
      );
      canvas.drawRect(
        ui.Rect.fromLTWH(origin.dx, origin.dy + 14, 96, 52),
        shelfPaint,
      );
      for (var i = 0; i < 4; i++) {
        canvas.drawRect(
          ui.Rect.fromLTWH(
            origin.dx + 8 + i * 22,
            origin.dy + 22,
            16,
            20,
          ),
          ui.Paint()..color = accent[i % accent.length],
        );
      }
    }

    final basketPaint = ui.Paint()..color = const ui.Color(0xFF4A90D9);
    for (final point in [
      ui.Offset(size.x * 0.18, size.y * 0.72),
      ui.Offset(size.x * 0.82, size.y * 0.55),
    ]) {
      canvas.drawRRect(
        ui.RRect.fromRectAndRadius(
          ui.Rect.fromCenter(center: point, width: 36, height: 28),
          const ui.Radius.circular(6),
        ),
        basketPaint,
      );
    }
  }
}

/// Darkens and hides space beyond the playable arena (fog-of-war style).
class ArenaFogLayer extends Component with HasGameReference<GumihoGame> {
  ArenaFogLayer({required this.arenaSize}) : super(priority: -15);

  final Vector2 arenaSize;

  static const _deepFog = ui.Color(0xFF050508);
  static const _fadeFog = ui.Color(0x880A0A12);

  @override
  void render(ui.Canvas canvas) {
    final arena = ui.Rect.fromLTWH(0, 0, arenaSize.x, arenaSize.y);
    const extent = 2400.0;
    const fade = 220.0;

    _drawFogRect(
      canvas,
      ui.Rect.fromLTRB(-extent, -extent, 0, arenaSize.y + extent),
      _deepFog,
    );
    _drawFogRect(
      canvas,
      ui.Rect.fromLTRB(arenaSize.x, -extent, arenaSize.x + extent, arenaSize.y + extent),
      _deepFog,
    );
    _drawFogRect(
      canvas,
      ui.Rect.fromLTRB(0, -extent, arenaSize.x, 0),
      _deepFog,
    );
    _drawFogRect(
      canvas,
      ui.Rect.fromLTRB(0, arenaSize.y, arenaSize.x, arenaSize.y + extent),
      _deepFog,
    );

    _drawEdgeFade(canvas, arena, fade);
  }

  void _drawFogRect(ui.Canvas canvas, ui.Rect rect, ui.Color color) {
    canvas.drawRect(rect, ui.Paint()..color = color);
  }

  void _drawEdgeFade(ui.Canvas canvas, ui.Rect arena, double fadeWidth) {
    final bands = [
      ui.Rect.fromLTRB(arena.left - fadeWidth, arena.top, arena.left, arena.bottom),
      ui.Rect.fromLTRB(arena.right, arena.top, arena.right + fadeWidth, arena.bottom),
      ui.Rect.fromLTRB(arena.left, arena.top - fadeWidth, arena.right, arena.top),
      ui.Rect.fromLTRB(arena.left, arena.bottom, arena.right, arena.bottom + fadeWidth),
    ];

    for (final band in bands) {
      canvas.drawRect(band, ui.Paint()..color = _fadeFog);
    }

    const edgeStrip = ui.Color(0x590A0A12);
    canvas.drawRect(
      ui.Rect.fromLTRB(arena.left, arena.top, arena.right, arena.top + 28),
      ui.Paint()..color = edgeStrip,
    );
    canvas.drawRect(
      ui.Rect.fromLTRB(arena.left, arena.bottom - 28, arena.right, arena.bottom),
      ui.Paint()..color = edgeStrip,
    );
    canvas.drawRect(
      ui.Rect.fromLTRB(arena.left, arena.top, arena.left + 28, arena.bottom),
      ui.Paint()..color = edgeStrip,
    );
    canvas.drawRect(
      ui.Rect.fromLTRB(arena.right - 28, arena.top, arena.right, arena.bottom),
      ui.Paint()..color = edgeStrip,
    );
  }
}
