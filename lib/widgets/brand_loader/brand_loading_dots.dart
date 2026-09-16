import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../theme/vector_colors.dart';

/// Three dots blinking in sequence below the full-screen logo: a separate
/// 1.2s loop (independent of the logo's 2s cycle), each dot delayed by
/// 0 / 0.2 / 0.4s, opacity keyframed 0.2 -> 1 at 30% -> 0.2.
class BrandLoadingDots extends StatefulWidget {
  const BrandLoadingDots({super.key});

  @override
  State<BrandLoadingDots> createState() => _BrandLoadingDotsState();
}

class _BrandLoadingDotsState extends State<BrandLoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const List<double> _delayFractions = [0, 0.2 / 1.2, 0.4 / 1.2];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static double _blinkOpacity(double localT) {
    if (localT <= 0.3) return ui.lerpDouble(0.2, 1, localT / 0.3)!;
    return ui.lerpDouble(1, 0.2, (localT - 0.3) / 0.7)!;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < _delayFractions.length; i++) ...[
              if (i != 0) const SizedBox(width: 4),
              _dot(_controller.value, _delayFractions[i]),
            ],
          ],
        );
      },
    );
  }

  Widget _dot(double value, double delayFraction) {
    double localT = value - delayFraction;
    localT -= localT.floorToDouble();
    final double blink = _blinkOpacity(localT);
    return Opacity(
      opacity: 0.55 * blink,
      child: const Text(
        '•',
        style: TextStyle(
          color: VectorColors.loaderWhite,
          fontSize: 15,
          height: 1,
        ),
      ),
    );
  }
}
