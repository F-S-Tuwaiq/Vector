import 'package:flutter/material.dart';

import '../theme/vector_colors.dart';
import '../theme/vector_text.dart';
import 'vector_wordmark.dart';

/// The one reusable purple header used by both Home and Teams.
///
/// Always: [VectorColors.purpleBrand] fill, edge-to-edge (full screen
/// width, attached to the very top, painted BEHIND the status bar — no
/// floating inset block), bottom corner radius 26, with one large
/// low-opacity apricot triangle bleeding off the top-right corner behind
/// all content.
///
/// Two variants:
/// - [VectorHeader.home] — wordmark, "Hackathons" headline, subtitle.
/// - [VectorHeader.slim] — a single row: back chevron + hackathon name.
class VectorHeader extends StatelessWidget {
  const VectorHeader.home({super.key})
    : slim = false,
      title = null,
      onBack = null,
      showBackButton = true;

  const VectorHeader.slim({
    super.key,
    required this.title,
    this.onBack,
    this.showBackButton = true,
  }) : slim = true;

  final bool slim;
  final String? title;
  final VoidCallback? onBack;

  /// Root tabs in the bottom-nav shell have nothing to go back to —
  /// pass false to hide the chevron on those.
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
        child: DecoratedBox(
          decoration: const BoxDecoration(color: VectorColors.purpleBrand),
          child: Stack(
            children: [
              // Large low-opacity triangle bleeding off the top-right
              // corner, always behind content.
              Positioned(
                top: -20,
                right: -40,
                width: 220,
                height: 220,
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _HeaderTrianglePainter(
                      color: VectorColors.apricot.withValues(alpha: 0.10),
                    ),
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: slim ? _buildSlim(context) : _buildHome(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHome(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VectorWordmark(
            style: VectorText.headlineMedium.copyWith(
              color: VectorColors.textOnPurple,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Hackathons',
            style: VectorText.headlineLarge.copyWith(
              color: VectorColors.textOnPurple,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Find your field. Join a team.',
            style: VectorText.bodyMedium.copyWith(
              color: VectorColors.textOnPurple.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlim(BuildContext context) {
    const double sideWidth = 48;
    // Row (not a fixed-height Stack) so a long hackathon name can wrap to a
    // second line and still be shown in full instead of being clipped.
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: sideWidth,
            child: showBackButton
                ? IconButton(
                    onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.chevron_left_rounded),
                    color: VectorColors.textOnPurple,
                    iconSize: 28,
                    splashRadius: 24,
                  )
                : null,
          ),
          Expanded(
            child: Text(
              title ?? '',
              textAlign: TextAlign.center,
              style: VectorText.titleLarge.copyWith(
                fontSize: 23,
                fontWeight: FontWeight.w700,
                color: VectorColors.textOnPurple,
              ),
            ),
          ),
          SizedBox(width: sideWidth),
        ],
      ),
    );
  }
}

class _HeaderTrianglePainter extends CustomPainter {
  const _HeaderTrianglePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.35, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.85)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _HeaderTrianglePainter oldDelegate) =>
      color != oldDelegate.color;
}
