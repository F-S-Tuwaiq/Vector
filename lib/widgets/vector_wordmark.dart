import 'package:flutter/material.dart';

import '../theme/vector_colors.dart';
import '../theme/vector_text.dart';

/// The Vector brand mark: a two-stroke "V" glyph standing in for the
/// literal letter V, immediately followed by "ector" — together reading
/// as one word, "Vector". Never render a literal "V" character; the
/// painted mark IS the V.
class VectorWordmark extends StatelessWidget {
  const VectorWordmark({super.key, this.style});

  /// Text style for the "ector" portion; also used to size the painted
  /// V mark so it visually matches the text. Defaults to
  /// [VectorText.titleLarge] on [VectorColors.textOnPurple], since the
  /// wordmark typically sits on a purple header/surface.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final TextStyle effectiveStyle =
        style ??
        VectorText.titleLarge.copyWith(color: VectorColors.textOnPurple);
    final double fontSize = effectiveStyle.fontSize ?? 19;

    // Size the painted V to match the cap-height of the adjoining text.
    final double markHeight = fontSize * 0.74;
    final double markWidth = fontSize * 0.66;
    const double strokeWidth = 3.4;
    // Right stroke renders in the same color the text will use, so the
    // mark reads as part of the word rather than a separate logo color.
    final Color rightStrokeColor = effectiveStyle.color ?? VectorColors.textOnPurple;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: markWidth,
          height: markHeight,
          child: CustomPaint(
            painter: _VMarkPainter(
              leftColor: VectorColors.apricot,
              rightColor: rightStrokeColor,
              strokeWidth: strokeWidth,
            ),
          ),
        ),
        // Hairline gap so "V" + "ector" reads as one word "Vector".
        const SizedBox(width: 1),
        Text('ector', style: effectiveStyle),
      ],
    );
  }
}

class _VMarkPainter extends CustomPainter {
  const _VMarkPainter({
    required this.leftColor,
    required this.rightColor,
    required this.strokeWidth,
  });

  final Color leftColor;
  final Color rightColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset topLeft = Offset(strokeWidth / 2, 0);
    final Offset bottomCenter = Offset(size.width / 2, size.height);
    final Offset topRight = Offset(size.width - strokeWidth / 2, 0);

    final Paint leftPaint = Paint()
      ..color = leftColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Paint rightPaint = Paint()
      ..color = rightColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(topLeft, bottomCenter, leftPaint);
    canvas.drawLine(bottomCenter, topRight, rightPaint);
  }

  @override
  bool shouldRepaint(covariant _VMarkPainter oldDelegate) {
    return oldDelegate.leftColor != leftColor ||
        oldDelegate.rightColor != rightColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
