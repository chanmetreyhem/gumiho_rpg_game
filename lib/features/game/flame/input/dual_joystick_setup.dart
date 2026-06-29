import 'package:flame/components.dart';

import '../../../../core/theme/game_ui_theme.dart';
import '../gumiho_game.dart';
import 'modern_joystick_visual.dart';

class DualJoystickSetup extends Component with HasGameReference<GumihoGame> {
  late final CornerJoystick moveJoystick;
  late final CornerJoystick aimJoystick;

  static const _moveDeadZone = 0.14;
  static const _aimDeadZone = 0.1;
  static const _joystickRadius = 46.0;
  static const _knobRadius = 20.0;

  /// Clears system nav bar + matches Flutter HUD bomb row.
  static const _bottomInset = 48.0;
  static const _sideInset = 56.0;

  @override
  Future<void> onLoad() async {
    moveJoystick = CornerJoystick(
      label: 'MOVE',
      accent: GameUiColors.expCyan,
      knobRadius: _knobRadius,
      ringRadius: _joystickRadius,
    );

    aimJoystick = CornerJoystick(
      label: 'AIM',
      accent: GameUiColors.actionOrange,
      knobRadius: _knobRadius,
      ringRadius: _joystickRadius,
    );

    game.camera.viewport.addAll([moveJoystick, aimJoystick]);
    _placeJoysticks(_viewportSize);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      _placeJoysticks(size);
    }
  }

  Vector2 get _viewportSize {
    final size = game.camera.viewport.size;
    if (size.x > 0 && size.y > 0) return size;
    final gameSize = game.size;
    if (gameSize.x > 0 && gameSize.y > 0) return gameSize;
    return GumihoGame.portraitViewSize;
  }

  void _placeJoysticks(Vector2 viewSize) {
    moveJoystick
      ..anchor = Anchor.bottomLeft
      ..position = Vector2(60, viewSize.y - _bottomInset);

    aimJoystick
      ..anchor = Anchor.bottomRight
      ..position = Vector2(viewSize.x - 0, viewSize.y - _bottomInset);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final sensitivity = game.joystickSensitivity;

    final moveDelta = moveJoystick.joystick.relativeDelta;
    if (moveDelta.length >= _moveDeadZone) {
      game.player.setMoveDirection(
        moveDelta.normalized(),
        speedScale: sensitivity,
      );
    } else {
      game.player.setMoveDirection(null);
    }

    final aimDelta = aimJoystick.joystick.relativeDelta;
    if (aimDelta.length >= _aimDeadZone) {
      game.player.setAimDirection(aimDelta.normalized());
    } else {
      game.player.stopAiming();
    }
  }
}
