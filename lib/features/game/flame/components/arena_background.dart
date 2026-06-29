import 'dart:ui' as ui;

import 'package:flame/components.dart';

import '../gumiho_game.dart';

/// Arena floor rendered from a single stretched sprite image.
class ArenaBackground extends SpriteComponent with HasGameReference<GumihoGame> {
  ArenaBackground({
    required Vector2 arenaSize,
    required this.assetPath,
  }) : super(
          size: arenaSize,
          position: Vector2.zero(),
          anchor: Anchor.topLeft,
          priority: -20,
        );

  final String assetPath;

  static final ui.Paint _borderPaint = ui.Paint()
    ..color = const ui.Color(0xFF1A2F1A)
    ..style = ui.PaintingStyle.stroke
    ..strokeWidth = 6;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final image = game.images.containsKey(assetPath)
        ? game.images.fromCache(assetPath)
        : await game.images.load(assetPath);
    sprite = Sprite(image);
  }

  @override
  void render(ui.Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), _borderPaint);
  }
}
