import 'package:flutter/material.dart';

import '../theme/vector_colors.dart';
import 'vector_shapes.dart';

/// Shares the login painter's geometry, layers and triangles without scaling text.
class LoginStyleHeader extends StatelessWidget {
  const LoginStyleHeader({
    super.key,
    this.overlapAvatar = false,
    this.onSettings,
    this.onBack,
  });
  final bool overlapAvatar;
  final VoidCallback? onSettings;
  final VoidCallback? onBack;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final height = (constraints.maxWidth / 390 * 234).clamp(200.0, 290.0);
      final inset = MediaQuery.paddingOf(context).top;
      return SizedBox(
        height: height + inset + (overlapAvatar ? 48 : 0),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: height + inset,
              child: ClipRect(
                child: CustomPaint(painter: _LoginHeaderPainter()),
              ),
            ),
            if (onBack != null)
              Positioned(
                left: 18,
                top: inset + 20,
                child: IconButton(
                  tooltip: 'Back',
                  onPressed: onBack,
                  color: VectorColors.background,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
            Positioned(
              left: 30,
              top: inset + (onBack == null ? 34 : 86),
              child: const LoginWordmark(),
            ),
            if (onSettings != null)
              Positioned(
                top: inset + 26,
                right: 14,
                child: IconButton(
                  tooltip: 'Settings',
                  onPressed: onSettings,
                  color: VectorColors.purpleDeep,
                  icon: const Icon(Icons.settings_outlined),
                ),
              ),
            if (overlapAvatar)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: VectorColors.background,
                      border: Border.all(color: VectorColors.apricot),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      size: 48,
                      color: VectorColors.purpleDeep,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}

class LoginWordmark extends StatelessWidget {
  const LoginWordmark({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Vector',
    image: true,
    child: ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 29,
            height: 31,
            child: ClipRect(
              child: OverflowBox(
                minWidth: 52,
                maxWidth: 52,
                minHeight: 52,
                maxHeight: 52,
                child: Image.asset(
                  'assets/logo/vector-mark-dark-1024-removebg-preview.png',
                  width: 52,
                  height: 52,
                ),
              ),
            ),
          ),
          const Text(
            'ector',
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 31,
              fontWeight: FontWeight.w500,
              letterSpacing: -1.4,
              height: 1,
              color: VectorColors.background,
            ),
          ),
        ],
      ),
    ),
  );
}

class _LoginHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 390, size.height / 234);
    VectorBackground(animation: const AlwaysStoppedAnimation(0))
        .paint(canvas, const Size(390, 680));
    // Login's fine apricot accent at the curve.
    canvas.drawLine(
      const Offset(228, 206),
      const Offset(256, 173),
      Paint()
        ..color = VectorColors.apricot
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
