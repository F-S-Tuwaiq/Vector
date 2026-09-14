import 'package:flutter/material.dart';

import '../theme/vector_colors.dart';
import '../theme/vector_text.dart';

typedef _TabSpec = ({IconData icon, String label});

const List<_TabSpec> _kTabs = [
  (icon: Icons.home_outlined, label: 'Home'),
  (icon: Icons.mail_outline_rounded, label: 'Invites'),
  (icon: Icons.person_outline_rounded, label: 'Profile'),
];

/// The bottom nav bar: surfaceWhite, hairline top border, three equal
/// items, and a single sliding apricot triangle overlay (never per-item)
/// that translates behind the active icon.
class VectorBottomBar extends StatelessWidget {
  const VectorBottomBar({
    super.key,
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  static const double _contentHeight = 52;
  static const double _triangleWidth = 52;
  static const double _triangleHeight = 29;

  @override
  Widget build(BuildContext context) {
    final bool disableAnimations = MediaQuery.disableAnimationsOf(context);
    final Duration slideDuration = disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 380);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: VectorColors.surfaceWhite,
        border: Border(top: BorderSide(color: VectorColors.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: SizedBox(
            height: _contentHeight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double itemWidth = constraints.maxWidth / _kTabs.length;
                final double triangleLeft =
                    itemWidth * index + (itemWidth - _triangleWidth) / 2;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedPositioned(
                      duration: slideDuration,
                      curve: const Cubic(0.22, 1, 0.36, 1),
                      left: triangleLeft,
                      top: 0,
                      width: _triangleWidth,
                      height: _triangleHeight,
                      child: const IgnorePointer(
                        child: CustomPaint(painter: _NavTrianglePainter()),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      height: _contentHeight,
                      child: Row(
                        children: [
                          for (var i = 0; i < _kTabs.length; i++)
                            Expanded(
                              child: _NavItem(
                                icon: _kTabs[i].icon,
                                label: _kTabs[i].label,
                                active: i == index,
                                onTap: () => onChanged(i),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool disableAnimations = MediaQuery.disableAnimationsOf(context);
    final Color color = active ? VectorColors.purpleBrand : VectorColors.textMuted;
    final Duration duration = disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 250);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 8.3),
          TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: color),
            duration: duration,
            builder: (context, animatedColor, child) {
              return Icon(icon, size: 22, color: animatedColor);
            },
          ),
          const SizedBox(height: 5),
          AnimatedDefaultTextStyle(
            duration: duration,
            style: VectorText.labelMedium.copyWith(
              fontSize: 10,
              color: color,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}

/// Flat apricot triangle, apex up, 35% opacity — the sliding active-tab
/// indicator. Width 52 / height 29; centroid (where the icon center must
/// land) sits at height*2/3 ≈ 19.3 from the apex.
class _NavTrianglePainter extends CustomPainter {
  const _NavTrianglePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = VectorColors.apricot.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(covariant _NavTrianglePainter oldDelegate) => false;
}
