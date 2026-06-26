import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../gumiho_game.dart';

class DualJoystickSetup extends Component with HasGameReference<GumihoGame> {
  late final JoystickComponent moveJoystick;
  late final JoystickComponent aimJoystick;

  static const _moveDeadZone = 0.14;
  static const _aimDeadZone = 0.1;

  @override
  Future<void> onLoad() async {
    final knobPaint = Paint()..color = Colors.white.withValues(alpha: 0.92);
    final bgPaint = Paint()..color = Colors.white.withValues(alpha: 0.22);

    moveJoystick = JoystickComponent(
      priority: 100,
      margin: const EdgeInsets.only(left: 24, bottom: 88),
      knob: CircleComponent(radius: 22, paint: knobPaint),
      background: CircleComponent(radius: 56, paint: bgPaint),
    );

    aimJoystick = JoystickComponent(
      priority: 100,
      margin: const EdgeInsets.only(right: 24, bottom: 88),
      knob: CircleComponent(radius: 22, paint: knobPaint),
      background: CircleComponent(radius: 56, paint: bgPaint),
    );

    game.camera.viewport.addAll([moveJoystick, aimJoystick]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final sensitivity = game.joystickSensitivity;

    final moveDelta = moveJoystick.relativeDelta;
    if (moveDelta.length >= _moveDeadZone) {
      game.player.setMoveDirection(
        moveDelta.normalized(),
        speedScale: sensitivity,
      );
    } else {
      game.player.setMoveDirection(null);
    }

    final aimDelta = aimJoystick.relativeDelta;
    if (aimDelta.length >= _aimDeadZone) {
      game.player.setAimDirection(aimDelta.normalized());
    } else {
      game.player.stopAiming();
    }
  }
}
