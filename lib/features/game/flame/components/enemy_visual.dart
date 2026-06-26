import 'dart:math';

import 'package:flame/components.dart';

import '../../../../data/config/game_assets.dart';
import '../../domain/enemy_type.dart';
import '../gumiho_game.dart';

class _EnemyPartLayer {
  const _EnemyPartLayer(this.part, this.offset);

  final String part;
  final Vector2 offset;
}

class EnemyVisual extends PositionComponent with HasGameReference<GumihoGame> {
  EnemyVisual({
    required this.enemyType,
    required this.targetHeight,
  });

  final EnemyType enemyType;
  final double targetHeight;

  static final _layers = <_EnemyPartLayer>[
    _EnemyPartLayer('left_foot', Vector2(-7, 16)),
    _EnemyPartLayer('right_foot', Vector2(7, 16)),
    _EnemyPartLayer('body', Vector2(0, 2)),
    _EnemyPartLayer('left_hand', Vector2(-14, -2)),
    _EnemyPartLayer('right_hand', Vector2(14, -2)),
    _EnemyPartLayer('head', Vector2(0, -14)),
  ];

  final Map<String, SpriteComponent> _parts = {};
  final Map<String, Vector2> _basePositions = {};

  double _walkPhase = 0;
  double _attackPhase = 0;
  bool _wasAttacking = false;
  double _facing = 1;

  void faceToward(Vector2 direction) {
    if (direction.x.abs() <= 0.1) return;

    final newFacing = direction.x >= 0 ? 1.0 : -1.0;
    if (newFacing == _facing) return;

    _facing = newFacing;
    _resetPartOffsets();
  }

  void updateAnimation({
    required bool isMoving,
    required bool isAttacking,
    required double dt,
  }) {
    if (isMoving) {
      _walkPhase += dt * 12;
      final sway = sin(_walkPhase);
      _setPartOffset('left_foot', yDelta: sway * 4);
      _setPartOffset('right_foot', yDelta: -sway * 4);
      _setPartOffset('left_hand', yDelta: -sway * 2);
      _setPartOffset('right_hand', yDelta: sway * 2);
      position.y = sin(_walkPhase * 2) * 1.5;
      _attackPhase = 0;
      _wasAttacking = false;
      return;
    }

    position.y = 0;
    _walkPhase = 0;
    _resetPartOffsets();

    if (isAttacking) {
      if (!_wasAttacking) {
        _attackPhase = 0;
      }
      _attackPhase = min(1, _attackPhase + dt * 7);
      final lunge = sin(_attackPhase * pi) * 10;
      _setPartOffset('right_hand', xDelta: lunge);
      _setPartOffset('left_hand', xDelta: lunge * 0.55);
      _setPartOffset('body', xDelta: lunge * 0.15);
    }

    _wasAttacking = isAttacking;
  }

  void _setPartOffset(
    String part, {
    double xDelta = 0,
    double yDelta = 0,
  }) {
    final base = _basePositions[part];
    final sprite = _parts[part];
    if (base == null || sprite == null) return;

    final x = _facing < 0 ? -base.x : base.x;
    sprite.position = Vector2(x + xDelta * _facing, base.y + yDelta);
  }

  void _resetPartOffsets() {
    for (final entry in _parts.entries) {
      final base = _basePositions[entry.key]!;
      entry.value.position =
          Vector2(_facing < 0 ? -base.x : base.x, base.y);
    }
  }

  @override
  Future<void> onLoad() async {
    for (final layer in _layers) {
      final path = GameAssets.enemyPart(enemyType.name, layer.part);
      try {
        final image = game.images.containsKey(path)
            ? game.images.fromCache(path)
            : await game.images.load(path);
        final scale = targetHeight / image.height;
        final scaledOffset = layer.offset * scale;
        final sprite = SpriteComponent(
          sprite: Sprite(image),
          size: Vector2(image.width * scale, image.height * scale),
          anchor: Anchor.center,
          position: scaledOffset,
        );
        _parts[layer.part] = sprite;
        _basePositions[layer.part] = scaledOffset.clone();
        add(sprite);
      } on Object {
        // Some enemy types omit optional parts (e.g. zombie has no left_hand).
      }
    }
  }
}
