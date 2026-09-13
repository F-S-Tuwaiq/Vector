import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/vector_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: VectorColors.surfaceWhite,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: VectorColors.background,
        body: Column(
          children: [
            const _HomeHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _ProfileReadinessCard(),
                    SizedBox(height: 26),
                    _SectionHeader(title: 'Open hackathons', trailing: 'All 7'),
                    SizedBox(height: 14),
                    _FeaturedHackathonCard(),
                    SizedBox(height: 14),
                    _CompactHackathonCard(
                      title: 'Digital Health Hackathon',
                      meta: 'Ministry of Health · Jeddah · Nov 20–22',
                      prize: 'SAR 150,000',
                      participants: '216 participants',
                    ),
                    SizedBox(height: 12),
                    _CompactHackathonCard(
                      title: 'Fintech Hackathon',
                      meta: 'Fintech Saudi · Remote · Dec 5–7',
                      prize: 'SAR 200,000',
                      participants: '189 participants',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const _BottomNav(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
      child: ColoredBox(
        color: VectorColors.purpleBrand,
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -50,
              child: Transform.rotate(
                angle: 0.35,
                child: CustomPaint(
                  size: const Size(230, 230),
                  painter: _TrianglePainter(
                    color: VectorColors.apricot.withValues(alpha: 0.14),
                  ),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good evening,',
                                style: TextStyle(
                                  color: VectorColors.textOnPurple
                                      .withValues(alpha: 0.7),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Salem Alotaibi',
                                style: TextStyle(
                                  color: VectorColors.textOnPurple,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const _AvatarWithBadge(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _SearchRow(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarWithBadge extends StatelessWidget {
  const _AvatarWithBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: VectorColors.apricot,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'SA',
              style: TextStyle(
                color: VectorColors.purpleDeep,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: VectorColors.error,
                shape: BoxShape.circle,
                border: Border.all(color: VectorColors.purpleBrand, width: 2),
              ),
              child: const Text(
                '3',
                style: TextStyle(
                  color: VectorColors.textOnPurple,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: VectorColors.textOnPurple.withValues(alpha: 0.65),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Search hackathons or fields…',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: VectorColors.textOnPurple.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: VectorColors.apricot,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const _OpposedTrianglesIcon(),
        ),
      ],
    );
  }
}

class _OpposedTrianglesIcon extends StatelessWidget {
  const _OpposedTrianglesIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 18,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            child: CustomPaint(
              size: const Size(14, 7),
              painter: const _TrianglePainter(
                color: VectorColors.purpleDeep,
                pointing: _TrianglePoint.down,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: CustomPaint(
              size: const Size(14, 7),
              painter: const _TrianglePainter(
                color: VectorColors.purpleDeep,
                pointing: _TrianglePoint.up,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile readiness strip
// ---------------------------------------------------------------------------

class _ProfileReadinessCard extends StatelessWidget {
  const _ProfileReadinessCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VectorColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VectorColors.hairline),
      ),
      child: Row(
        children: [
          const _ProgressRing(progress: 0.85, size: 56),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your profile is match-ready',
                  style: TextStyle(
                    color: VectorColors.textNeutral,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '3 verified skills · 9 teams looking for a designer',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: VectorColors.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: VectorColors.purpleDeep,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'View teams',
              style: TextStyle(
                color: VectorColors.textOnPurple,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.progress, required this.size});

  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: progress,
              color: VectorColors.purpleDeep,
              background: VectorColors.surfaceLavender,
            ),
          ),
          Text(
            '${(progress * 100).round()}%',
            style: const TextStyle(
              color: VectorColors.purpleDeep,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CustomPaint(
              size: const Size(10, 10),
              painter: const _TrianglePainter(color: VectorColors.purpleDeep),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: VectorColors.textNeutral,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
          trailing,
          style: const TextStyle(
            color: VectorColors.linkWarm,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Featured hackathon card
// ---------------------------------------------------------------------------

class _FeaturedHackathonCard extends StatelessWidget {
  const _FeaturedHackathonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: VectorColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VectorColors.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 86,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          VectorColors.purpleBrand,
                          VectorColors.purpleSurfaceEnd,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _TrianglePatternPainter(
                      color: VectorColors.textOnPurple.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: _Badge(
                    label: 'Matches your skills',
                    background: VectorColors.apricot,
                    textColor: VectorColors.purpleDeep,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: _Badge(
                    label: 'Registration closes in 3 days',
                    background: Colors.black.withValues(alpha: 0.28),
                    textColor: VectorColors.textOnPurple,
                    maxWidth: 160,
                    maxLines: 2,
                  ),
                ),
                Positioned(
                  left: 14,
                  bottom: 10,
                  right: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Tuwaiq Academy · Riyadh',
                        style: TextStyle(
                          color: VectorColors.textOnPurple.withValues(alpha: 0.85),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Tuwaiq AI Hackathon',
                        style: TextStyle(
                          color: VectorColors.textOnPurple,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('Oct 12–14', style: _metaStyle),
                    _MetaDivider(),
                    Text('In-person', style: _metaStyle),
                    _MetaDivider(),
                    Text('Teams of 3–5', style: _metaStyle),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: VectorColors.hairline),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total prizes',
                          style: TextStyle(
                            color: VectorColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'SAR 300,000',
                          style: TextStyle(
                            color: VectorColors.textNeutral,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const _OverlappingAvatars(count: 3),
                        const SizedBox(width: 8),
                        Text(
                          '428 participants',
                          style: TextStyle(
                            color: VectorColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _metaStyle = TextStyle(color: VectorColors.textSecondary, fontSize: 12);

class _MetaDivider extends StatelessWidget {
  const _MetaDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: VectorColors.hairline,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.textColor,
    this.maxWidth = 150,
    this.maxLines = 1,
  });

  final String label;
  final Color background;
  final Color textColor;
  final double maxWidth;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textColor,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
    );
  }
}

class _OverlappingAvatars extends StatelessWidget {
  const _OverlappingAvatars({required this.count});

  final int count;

  static const _colors = [
    VectorColors.purpleSurfaceLight,
    VectorColors.textSecondaryPurple,
    VectorColors.purpleBrand,
  ];

  @override
  Widget build(BuildContext context) {
    const double diameter = 24;
    const double step = 16;
    return SizedBox(
      width: diameter + step * (count - 1),
      height: diameter,
      child: Stack(
        children: [
          for (var i = 0; i < count; i++)
            Positioned(
              left: i * step,
              child: Container(
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _colors[i % _colors.length],
                  border: Border.all(
                    color: VectorColors.surfaceWhite,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Compact hackathon card
// ---------------------------------------------------------------------------

class _CompactHackathonCard extends StatelessWidget {
  const _CompactHackathonCard({
    required this.title,
    required this.meta,
    required this.prize,
    required this.participants,
  });

  final String title;
  final String meta;
  final String prize;
  final String participants;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: VectorColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VectorColors.hairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: VectorColors.surfaceLavender,
              borderRadius: BorderRadius.circular(14),
            ),
            child: CustomPaint(
              size: const Size(20, 20),
              painter: const _TrianglePainter(color: VectorColors.purpleDeep),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: VectorColors.textNeutral,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: VectorColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      prize,
                      style: const TextStyle(
                        color: VectorColors.textNeutral,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const _MetaDivider(),
                    Expanded(
                      child: Text(
                        participants,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: VectorColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom navigation
// ---------------------------------------------------------------------------

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: VectorColors.surfaceWhite,
        border: Border(top: BorderSide(color: VectorColors.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: const [
              Expanded(
                child: _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  active: true,
                ),
              ),
              Expanded(
                child: _NavItem(
                  isTriangle: true,
                  label: 'Matching',
                  active: false,
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.mail_outline_rounded,
                  label: 'Invites',
                  active: false,
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  active: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    this.icon,
    this.isTriangle = false,
    required this.label,
    required this.active,
  });

  final IconData? icon;
  final bool isTriangle;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? VectorColors.purpleDeep : VectorColors.textMuted;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isTriangle
            ? CustomPaint(
                size: const Size(16, 16),
                painter: _TrianglePainter(color: color),
              )
            : Icon(icon, size: 22, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared painters
// ---------------------------------------------------------------------------

enum _TrianglePoint { up, down }

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter({
    required this.color,
    this.pointing = _TrianglePoint.up,
  });

  final Color color;
  final _TrianglePoint pointing;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (pointing == _TrianglePoint.up) {
      path
        ..moveTo(size.width / 2, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close();
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return color != oldDelegate.color || pointing != oldDelegate.pointing;
  }
}

class _TrianglePatternPainter extends CustomPainter {
  const _TrianglePatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const step = 22.0;
    for (double y = -step; y < size.height + step; y += step * 0.6) {
      var flip = false;
      for (double x = -step; x < size.width + step; x += step) {
        final path = Path();
        if (flip) {
          path
            ..moveTo(x, y + step * 0.6)
            ..lineTo(x + step, y + step * 0.6)
            ..lineTo(x + step / 2, y)
            ..close();
        } else {
          path
            ..moveTo(x, y)
            ..lineTo(x + step, y)
            ..lineTo(x + step / 2, y + step * 0.6)
            ..close();
        }
        canvas.drawPath(path, paint);
        flip = !flip;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TrianglePatternPainter oldDelegate) =>
      color != oldDelegate.color;
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.background,
  });

  final double progress;
  final Color color;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.14;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final backgroundPaint = Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final foregroundPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * math.pi, false, backgroundPaint);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        color != oldDelegate.color ||
        background != oldDelegate.background;
  }
}
