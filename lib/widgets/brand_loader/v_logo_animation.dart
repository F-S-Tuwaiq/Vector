import 'package:flutter/material.dart';

import 'v_logo_painter.dart';

/// The self-drawing two-stroke "V" mark: white arm draws, then the orange
/// arm draws in, the mark holds fully drawn, then the whole thing fades
/// out quickly right before the 2s cycle restarts.
///
/// Used, at different sizes, for both the full-screen brand loader and the
/// mini overlay loader — the timing and colors are identical, only the
/// size and surrounding chrome (background, dots) differ.
class VLogoAnimation extends StatefulWidget {
  const VLogoAnimation({required this.size, super.key});

  final double size;

  @override
  State<VLogoAnimation> createState() => _VLogoAnimationState();
}

class _VLogoAnimationState extends State<VLogoAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const Cubic _drawCurve = Cubic(0.6, 0.05, 0.35, 1);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Progress of [t] through the window [start]..[end] (both fractions of
  /// the 2s cycle), eased by [curve]. 0 before the window opens, 1 once it
  /// has closed.
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = _controller.value;

        final double whiteReveal = _windowProgress(t, 0, 0.19, _drawCurve);
        final double orangeReveal = _windowProgress(
          t,
          0.19,
          0.37,
          _drawCurve,
        );
        final double orangeOpacity = t < 0.19 ? 0 : 1;

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
            painter: VLogoPainter(
              whiteReveal: whiteReveal,
              orangeReveal: orangeReveal,
              orangeOpacity: orangeOpacity,
            ),
          ),
        );
      },
    );
  }
}
