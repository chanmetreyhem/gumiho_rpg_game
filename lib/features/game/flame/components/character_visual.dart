import 'dart:math';

import 'package:flame/components.dart';

import '../../../../data/config/game_assets.dart';
import '../gumiho_game.dart';

class CharacterVisual extends PositionComponent
    with HasGameReference<GumihoGame> {
  CharacterVisual({required this.characterFolder});

  final String characterFolder;

  static const double _targetHeight = 52;

  static final _layers = <(String, Vector2)>[
    ('Left_Foot', Vector2(-8, 20)),
    ('Right_Foot', Vector2(8, 20)),
    ('Body', Vector2(0, 0)),
    ('Head', Vector2(0, -16)),
  ];

  double _bobPhase = 0;

  void updateMovement(bool isMoving, double dt) {
    if (isMoving) {
      _bobPhase += dt * 14;
      position.y = sin(_bobPhase) * 2.5;
    } else {
      _bobPhase = 0;
      position.y = 0;
    }
  }

  @override
  Future<void> onLoad() async {
    for (final (part, offset) in _layers) {
      final path = GameAssets.characterPart(characterFolder, part);
      try {
        final image = game.images.containsKey(path)
            ? game.images.fromCache(path)
            : await game.images.load(path);
        final scale = _targetHeight / image.height;
        add(
          SpriteComponent(
            sprite: Sprite(image),
            size: Vector2(image.width * scale, image.height * scale),
            anchor: Anchor.center,
            position: offset * scale,
          ),
        );
      } on Object {
        // Some characters omit optional parts.
      }
    }
  }
}
