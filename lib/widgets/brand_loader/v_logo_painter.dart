import 'package:flutter/material.dart';

import '../../theme/vector_colors.dart';

/// Paints the two-stroke "V" mark on a 500x500 viewBox, scaled to fit
/// [Size]. Orange is painted first (underneath), white second (on top),
/// so the white round cap covers the orange arm's start at the vertex.
class VLogoPainter extends CustomPainter {
  const VLogoPainter({
    required this.whiteReveal,
    required this.orangeReveal,
    required this.orangeOpacity,
  });

  /// 0..1 fraction of the white arm drawn, from (130,142) to (251,346).
  final double whiteReveal;

  /// 0..1 fraction of the orange arm drawn, from (256,337) to (371,134).
  final double orangeReveal;

  /// 0 or 1 — the orange arm is fully hidden while the white arm draws,
  /// then snaps to visible.
  final double orangeOpacity;

  static const double _viewBoxSize = 500;
  static const double _strokeWidth = 34;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / _viewBoxSize;
    canvas.save();
    canvas.scale(scale, scale);

    final Path orangePath = Path()
      ..moveTo(256, 337)
      ..lineTo(371, 134);
    final Path whitePath = Path()
      ..moveTo(130, 142)
      ..lineTo(251, 346);

    _drawProgressive(
      canvas,
      orangePath,
      orangeReveal,
      VectorColors.loaderOrange,
      opacity: orangeOpacity,
    );
    _drawProgressive(canvas, whitePath, whiteReveal, VectorColors.loaderWhite);

    canvas.restore();
  }

  void _drawProgressive(
    Canvas canvas,
    Path path,
    double progress,
    Color color, {
    double opacity = 1,
  }) {
    if (progress <= 0 || opacity <= 0) return;
    final metric = path.computeMetrics().first;
    final revealed = metric.extractPath(
      0,
      metric.length * progress.clamp(0.0, 1.0),
    );
    final paint = Paint()
      ..color = color.withValues(alpha: opacity.clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(revealed, paint);
  }

  @override
  bool shouldRepaint(covariant VLogoPainter oldDelegate) {
    return whiteReveal != oldDelegate.whiteReveal ||
        orangeReveal != oldDelegate.orangeReveal ||
        orangeOpacity != oldDelegate.orangeOpacity;
  }
}
