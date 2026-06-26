import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../gumiho_game.dart';

class _Spark {
  _Spark({
    required this.offset,
    required this.velocity,
    required this.size,
  });

  Vector2 offset;
  Vector2 velocity;
  final double size;
}

/// Lightweight canvas particle burst — auto-disposes and releases effect slot.
class ParticleBurstComponent extends PositionComponent
    with HasGameReference<GumihoGame> {
  ParticleBurstComponent._({
    required Vector2 worldPosition,
    required this.duration,
    required List<_Spark> sparks,
    required this.coreColor,
    required this.glowColor,
    this.onReleased,
    bool showCenterFlash = false,
    this.streakAngle,
    this.showRing = false,
    this.ringColor,
  })  : _sparks = sparks,
        _life = duration,
        _showCenterFlash = showCenterFlash,
        super(
          position: worldPosition,
          anchor: Anchor.center,
          priority: 80,
        );

  final double duration;
  final Color coreColor;
  final Color glowColor;
  final VoidCallback? onReleased;
  final double? streakAngle;
  final bool showRing;
  final Color? ringColor;

  final List<_Spark> _sparks;
  double _life;
  bool _released = false;
  final bool _showCenterFlash;

  factory ParticleBurstComponent.muzzle({
    required Vector2 worldPosition,
    required double angle,
    required Color coreColor,
    required Color glowColor,
    VoidCallback? onReleased,
  }) {
    final sparks = <_Spark>[
      _Spark(
        offset: Vector2.zero(),
        velocity: Vector2(cos(angle), sin(angle)) * 220,
        size: 7,
      ),
      for (var i = -2; i <= 2; i++)
        _Spark(
          offset: Vector2.zero(),
          velocity: Vector2(
            cos(angle + i * 0.28),
            sin(angle + i * 0.28),
          ) *
              (140 + i.abs() * 25),
          size: 4.0 + (2 - i.abs()),
        ),
    ];
    return ParticleBurstComponent._(
      worldPosition: worldPosition,
      duration: 0.16,
      sparks: sparks,
      coreColor: coreColor,
      glowColor: glowColor,
      onReleased: onReleased,
      showCenterFlash: true,
      streakAngle: angle,
    );
  }

  factory ParticleBurstComponent.hit({
    required Vector2 worldPosition,
    required Vector2 direction,
    required Color coreColor,
    required Color glowColor,
    VoidCallback? onReleased,
  }) {
    final baseAngle = atan2(direction.y, direction.x);
    final sparks = List.generate(10, (i) {
      final spread = (i - 4.5) * 0.38;
      final speed = 110.0 + i * 18;
      return _Spark(
        offset: Vector2.zero(),
        velocity: Vector2(
          cos(baseAngle + pi + spread),
          sin(baseAngle + pi + spread),
        ) *
            speed,
        size: 3.5 + (i % 3),
      );
    });
    return ParticleBurstComponent._(
      worldPosition: worldPosition,
      duration: 0.26,
      sparks: sparks,
      coreColor: coreColor,
      glowColor: glowColor,
      onReleased: onReleased,
      showCenterFlash: true,
      showRing: true,
      ringColor: glowColor,
    );
  }

  factory ParticleBurstComponent.death({
    required Vector2 worldPosition,
    required Color coreColor,
    VoidCallback? onReleased,
  }) {
    final sparks = List.generate(12, (i) {
      final angle = i * (pi * 2 / 12);
      return _Spark(
        offset: Vector2.zero(),
        velocity: Vector2(cos(angle), sin(angle)) * (90 + i * 8),
        size: 4 + (i % 2) * 1.5,
      );
    });
    return ParticleBurstComponent._(
      worldPosition: worldPosition,
      duration: 0.38,
      sparks: sparks,
      coreColor: coreColor,
      glowColor: coreColor.withValues(alpha: 0.65),
      onReleased: onReleased,
      showCenterFlash: true,
      showRing: true,
      ringColor: coreColor,
    );
  }

  factory ParticleBurstComponent.hurt({
    required Vector2 worldPosition,
    VoidCallback? onReleased,
  }) {
    final sparks = List.generate(8, (i) {
      final angle = (i / 8) * pi * 2;
      return _Spark(
        offset: Vector2.zero(),
        velocity: Vector2(cos(angle), sin(angle)) * (70 + i * 5),
        size: 4.5,
      );
    });
    return ParticleBurstComponent._(
      worldPosition: worldPosition,
      duration: 0.3,
      sparks: sparks,
      coreColor: const Color(0xFFFF1744),
      glowColor: const Color(0xFFFF8A80),
      onReleased: onReleased,
      showCenterFlash: true,
      showRing: true,
      ringColor: const Color(0xFFFF5252),
    );
  }

  void _releaseSlot() {
    if (_released) return;
    _released = true;
    onReleased?.call();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _life -= dt;
    if (_life <= 0) {
      removeFromParent();
      return;
    }

    const drag = 0.9;
    for (final spark in _sparks) {
      spark.offset += spark.velocity * dt;
      spark.velocity *= drag;
    }
  }

  @override
  void onRemove() {
    _releaseSlot();
    super.onRemove();
  }

  double get _progress => 1 - (_life / duration).clamp(0.0, 1.0);

  double get _alpha {
    final t = (_life / duration).clamp(0.0, 1.0);
    // Stay bright longer than t² — easier to spot in fast combat.
    return sqrt(t).clamp(0.0, 1.0);
  }

  void _drawSpark(Canvas canvas, Offset center, double size, double alpha) {
    final glow = Paint()..color = glowColor.withValues(alpha: alpha * 0.55);
    final mid = Paint()..color = glowColor.withValues(alpha: alpha * 0.8);
    final core = Paint()..color = coreColor.withValues(alpha: alpha);
    final hot = Paint()..color = Colors.white.withValues(alpha: alpha * 0.95);

    canvas.drawCircle(center, size * 2.4, glow);
    canvas.drawCircle(center, size * 1.5, mid);
    canvas.drawCircle(center, size, core);
    canvas.drawCircle(center, size * 0.42, hot);
  }

  @override
  void render(Canvas canvas) {
    final alpha = _alpha;
    final progress = _progress;

    if (showRing) {
      final ring = ringColor ?? glowColor;
      final ringRadius = 10 + progress * 28;
      final ringAlpha = alpha * (1 - progress) * 0.85;
      canvas.drawCircle(
        Offset.zero,
        ringRadius,
        Paint()
          ..color = ring.withValues(alpha: ringAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5,
      );
      canvas.drawCircle(
        Offset.zero,
        ringRadius * 0.55,
        Paint()..color = ring.withValues(alpha: ringAlpha * 0.35),
      );
    }

    for (final spark in _sparks) {
      _drawSpark(
        canvas,
        Offset(spark.offset.x, spark.offset.y),
        spark.size,
        alpha,
      );
    }

    if (_showCenterFlash) {
      final flashRadius = 14 + progress * 6;
      canvas.drawCircle(
        Offset.zero,
        flashRadius,
        Paint()..color = glowColor.withValues(alpha: alpha * 0.45),
      );
      canvas.drawCircle(
        Offset.zero,
        flashRadius * 0.55,
        Paint()..color = Colors.white.withValues(alpha: alpha * 0.9),
      );
    }

    final angle = streakAngle;
    if (angle != null) {
      final streakLen = 22 * alpha;
      final end = Offset(cos(angle) * streakLen, sin(angle) * streakLen);
      canvas.drawLine(
        Offset.zero,
        end,
        Paint()
          ..color = Colors.white.withValues(alpha: alpha * 0.85)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        Offset.zero,
        end * 0.65,
        Paint()
          ..color = coreColor.withValues(alpha: alpha * 0.7)
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round,
      );
    }
  }
}
