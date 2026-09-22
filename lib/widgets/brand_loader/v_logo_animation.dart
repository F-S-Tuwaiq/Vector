import 'package:flutter/material.dart';

import 'v_logo_painter.dart';

enum VLogoSequence {
  oneV(Duration(milliseconds: 1100), 0.55),
  oneVAndWhite(Duration(milliseconds: 2380), 0.19);

  const VLogoSequence(this.duration, this.finalProgress);
  final Duration duration;
  final double finalProgress;
}

class VLogoAnimation extends StatefulWidget {
  const VLogoAnimation({
    required this.size,
    this.sequence,
    this.onComplete,
    super.key,
  });

  final VLogoSequence? sequence;
  final VoidCallback? onComplete;

  final double size;

  static const Cubic _drawCurve = Cubic(0.6, 0.05, 0.35, 1);

  static double _windowProgress(
    double t,
    double start,
    double end,
    Curve curve,
  ) {
    if (t <= start) return 0;
    if (t >= end) return 1;
    return curve.transform((t - start) / (end - start));
  }

  static VLogoPainter painterAt(double progress) => VLogoPainter(
    whiteReveal: _windowProgress(progress, 0, 0.19, _drawCurve),
    orangeReveal: _windowProgress(progress, 0.19, 0.37, _drawCurve),
    orangeOpacity: progress < 0.19 ? 0 : 1,
  );

  @override
  State<VLogoAnimation> createState() => _VLogoAnimationState();
}

class _VLogoAnimationState extends State<VLogoAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.sequence?.duration ?? const Duration(milliseconds: 2000),
    );
    if (widget.sequence == null) {
      _controller.repeat();
    } else {
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onComplete?.call();
      });
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final sequence = widget.sequence;
        final double t = sequence == null
            ? _controller.value
            : _controller.isCompleted
            ? sequence.finalProgress
            : (_controller.value * sequence.duration.inMilliseconds / 2000) % 1;

        final double logoOpacity;
        if (t <= 0.88) {
          logoOpacity = 1;
        } else if (t <= 0.94) {
          logoOpacity =
              1 - Curves.easeOut.transform((t - 0.88) / (0.94 - 0.88));
        } else {
          logoOpacity = 0;
        }

        return Opacity(
          opacity: logoOpacity,
          child: CustomPaint(
            size: Size.square(widget.size),
            painter: VLogoAnimation.painterAt(t),
          ),
        );
      },
    );
  }
}
