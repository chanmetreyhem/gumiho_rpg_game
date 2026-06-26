import 'package:flutter/material.dart';

/// Fades and slides a child in when it first appears.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 420),
    this.offset = const Offset(0, 18),
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;
  final Curve curve;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _controller, curve: widget.curve);
    _slide = Tween<Offset>(begin: widget.offset, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

/// Scales and fades content in — good for dialogs and overlays.
class ScaleFadeIn extends StatefulWidget {
  const ScaleFadeIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 360),
    this.beginScale = 0.88,
  });

  final Widget child;
  final Duration duration;
  final double beginScale;

  @override
  State<ScaleFadeIn> createState() => _ScaleFadeInState();
}

class _ScaleFadeInState extends State<ScaleFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween<double>(begin: widget.beginScale, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

/// Animates integer changes (coins, wave, etc.).
class AnimatedCountText extends StatefulWidget {
  const AnimatedCountText({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 280),
  });

  final int value;
  final TextStyle? style;
  final Duration duration;

  @override
  State<AnimatedCountText> createState() => _AnimatedCountTextState();
}

class _AnimatedCountTextState extends State<AnimatedCountText> {
  late int _from;
  late int _to;

  @override
  void initState() {
    super.initState();
    _from = widget.value;
    _to = widget.value;
  }

  @override
  void didUpdateWidget(covariant AnimatedCountText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _from = oldWidget.value;
      _to = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      key: ValueKey('$_from-$_to'),
      tween: IntTween(begin: _from, end: _to),
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      builder: (context, animated, child) {
        return Text('$animated', style: widget.style);
      },
    );
  }
}

/// Subtle press scale for tappable UI.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    required this.onTap,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel:
          widget.enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Smoothly animates a 0–1 progress value (HP bar, etc.).
class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({
    super.key,
    required this.value,
    required this.backgroundColor,
    required this.foregroundColor,
    this.lowForegroundColor,
    this.width = 120,
    this.height = 10,
    this.duration = const Duration(milliseconds: 320),
  });

  final double value;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? lowForegroundColor;
  final double width;
  final double height;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final ratio = value.clamp(0.0, 1.0);
    final fg = ratio > 0.3
        ? foregroundColor
        : (lowForegroundColor ?? foregroundColor);

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: backgroundColor),
            AnimatedContainer(
              duration: duration,
              curve: Curves.easeOutCubic,
              width: width * ratio,
              color: fg,
            ),
          ],
        ),
      ),
    );
  }
}
