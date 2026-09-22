import 'package:flutter/material.dart';

import '../models/team.dart';
import '../theme/vector_colors.dart';
import '../theme/vector_text.dart';

Future<void> showRequestSentDialog(BuildContext context, Team team) {
  final disableAnimations = MediaQuery.disableAnimationsOf(context);
  final duration = disableAnimations
      ? Duration.zero
      : const Duration(milliseconds: 350);

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Request sent',
    barrierColor: VectorColors.dialogBarrier,
    transitionDuration: duration,
    pageBuilder: (context, animation, secondaryAnimation) {
      return _RequestSentDialogContent(team: team);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: const Cubic(0.22, 1, 0.36, 1),
      );
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _RequestSentDialogContent extends StatelessWidget {
  const _RequestSentDialogContent({required this.team});

  final Team team;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        decoration: BoxDecoration(
          color: VectorColors.surfaceWhite,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: VectorColors.hairline),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _CelebrationIcon(),
            const SizedBox(height: 20),
            Text(
              'Request sent!',
              style: VectorText.headlineMedium.copyWith(
                color: VectorColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                style: VectorText.bodyMedium.copyWith(
                  color: VectorColors.textSecondary,
                  height: 1.55,
                ),
                children: [
                  TextSpan(
                    text: team.name,
                    style: const TextStyle(
                      color: VectorColors.buttonEnd,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(
                    text: ' got your request.\nStay close — teams move fast.',
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: VectorColors.purpleBrand,
                  foregroundColor: VectorColors.textOnPurple,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: Text(
                  "Let's go",
                  style: VectorText.labelLarge.copyWith(
                    color: VectorColors.textOnPurple,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CelebrationIcon extends StatelessWidget {
  const _CelebrationIcon();

  static const List<_ConfettiSpec> _confetti = [
    _ConfettiSpec(Offset(-46, -30), 10, -0.4, true),
    _ConfettiSpec(Offset(44, -34), 8, 0.6, false),
    _ConfettiSpec(Offset(-52, 14), 7, 1.1, false),
    _ConfettiSpec(Offset(50, 18), 12, -0.9, true),
    _ConfettiSpec(Offset(-18, -46), 6, 0.2, false),
    _ConfettiSpec(Offset(20, -48), 9, -1.3, true),
    _ConfettiSpec(Offset(0, 44), 8, 0.8, true),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final spec in _confetti)
            Positioned(
              left: 70 + spec.offset.dx - spec.size / 2,
              top: 60 + spec.offset.dy - spec.size / 2,
              child: Transform.rotate(
                angle: spec.rotation,
                child: CustomPaint(
                  size: Size.square(spec.size),
                  painter: _TrianglePainter(
                    color: spec.apricot
                        ? VectorColors.apricot
                        : VectorColors.surfaceLavender,
                  ),
                ),
              ),
            ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: VectorColors.apricot,
              borderRadius: BorderRadius.circular(13),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.check, color: VectorColors.textNeutral),
          ),
        ],
      ),
    );
  }
}

class _ConfettiSpec {
  const _ConfettiSpec(this.offset, this.size, this.rotation, this.apricot);

  final Offset offset;
  final double size;
  final double rotation;
  final bool apricot;
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}
