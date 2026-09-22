import 'package:flutter/material.dart';

import '../theme/vector_colors.dart';
import '../theme/vector_text.dart';

class VectorWordmark extends StatelessWidget {
  const VectorWordmark({super.key, this.style});

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final TextStyle effectiveStyle =
        style ??
        VectorText.titleLarge.copyWith(color: VectorColors.textOnPurple);
    final double fontSize = MediaQuery.textScalerOf(context)
        .scale(effectiveStyle.fontSize ?? 19);

    final double scale = fontSize / 31;
    final double imageSize = 52 * scale;

    return Semantics(
      label: 'Vector',
      image: true,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 29 * scale,
              height: 31 * scale,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.center,
                  minWidth: imageSize,
                  maxWidth: imageSize,
                  minHeight: imageSize,
                  maxHeight: imageSize,
                  child: Image.asset(
                    'assets/logo/vector-mark-dark-1024-removebg-preview.png',
                    width: imageSize,
                    height: imageSize,
                  ),
                ),
              ),
            ),
            Text('ector', style: effectiveStyle),
          ],
        ),
      ),
    );
  }
}
