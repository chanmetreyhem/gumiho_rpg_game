import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Square joystick ring — size matches the touch area so the knob stays centered.
class ModernJoystickRing extends PositionComponent {
  ModernJoystickRing({
    required double radius,
    required this.accent,
  })  : _radius = radius,
        super(
          size: Vector2.all(radius * 2),
          anchor: Anchor.topLeft,
        );

  final Color accent;
  final double _radius;

  @override
  Future<void> onLoad() async {
    final center = size / 2;

    add(
      CircleComponent(
        radius: _radius,
        paint: Paint()..color = const Color(0xD9121824),
        anchor: Anchor.center,
        position: center,
      ),
    );

    add(
      CircleComponent(
        radius: _radius,
        paint: Paint()
          ..color = accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
        anchor: Anchor.center,
        position: center,
      ),
    );
  }
}

class ModernJoystickKnob extends PositionComponent {
  ModernJoystickKnob({
    required double radius,
    required this.accent,
  })  : _radius = radius,
        super(
          size: Vector2.all(radius * 2),
          anchor: Anchor.center,
        );

  final Color accent;
  final double _radius;

  @override
  Future<void> onLoad() async {
    final center = size / 2;
    add(
      CircleComponent(
        radius: _radius,
        paint: Paint()..color = Colors.white.withValues(alpha: 0.92),
        anchor: Anchor.center,
        position: center,
      ),
    );
    add(
      CircleComponent(
        radius: _radius * 0.38,
        paint: Paint()..color = accent,
        anchor: Anchor.center,
        position: center,
      ),
    );
  }
}

/// Joystick + label below; ring stays square so the knob is centered in the ring.
class CornerJoystick extends PositionComponent {
  CornerJoystick({
    required this.label,
    required this.accent,
    required this.knobRadius,
    required this.ringRadius,
  })  : _ringRadius = ringRadius,
        super(
          size: Vector2(ringRadius * 2, ringRadius * 2 + 16),
          anchor: Anchor.topLeft,
        );

  final String label;
  final Color accent;
  final double knobRadius;
  final double ringRadius;
  final double _ringRadius;

  late final JoystickComponent joystick;

  @override
  Future<void> onLoad() async {
    joystick = JoystickComponent(
      knob: ModernJoystickKnob(radius: knobRadius, accent: accent),
      background: ModernJoystickRing(radius: _ringRadius, accent: accent),
    );
    add(joystick);

    add(
      TextComponent(
        text: label,
        textRenderer: TextPaint(
          style: TextStyle(
            color: accent.withValues(alpha: 0.95),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        anchor: Anchor.topCenter,
        position: Vector2(_ringRadius, _ringRadius * 2 + 4),
      ),
    );
  }
}
