import 'package:flutter/material.dart';

import '../models/hackathon.dart';
import '../theme/vector_colors.dart';
import '../theme/vector_text.dart';

/// Background geometry: a single large, low-opacity triangle used behind
/// card content. Always painted BEHIND text via a `Stack`, and clipped to
/// the card's own bounds so it never bleeds outside the rounded corners.
class _BackgroundTriangle extends StatelessWidget {
  const _BackgroundTriangle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _TrianglePainter(color: color),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // A large triangle anchored to the top-right corner, pointing down
    // and to the left, evoking the brand's arrow/triangle motif.
    final Path path = Path()
      ..moveTo(size.width * 0.35, -size.height * 0.25)
      ..lineTo(size.width * 1.25, size.height * 0.15)
      ..lineTo(size.width * 0.55, size.height * 0.95)
      ..close();
    final Paint paint = Paint()..color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// Small filled apricot triangle pointing right — used as a section /
/// eyebrow marker throughout the app.
class _EyebrowTriangle extends StatelessWidget {
  const _EyebrowTriangle({this.size = 8});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: const _RightTrianglePainter(color: VectorColors.apricot),
    );
  }
}

class _RightTrianglePainter extends CustomPainter {
  const _RightTrianglePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _RightTrianglePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// A hairline vertical rule (1px x 12px) used to separate meta items in a
/// row, per the design system's meta-row convention.
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

/// Status pill — top-right of a card, both collapsed and expanded.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    late final Color background;
    late final Color textColor;
    late final String label;

    switch (status) {
      case 'open':
        background = VectorColors.apricot;
        textColor = VectorColors.textNeutral;
        label = 'Open';
        break;
      case 'closing_soon':
        // Urgency reads as the theme's soft red — the only status that
        // isn't apricot (open) or the dark neutral pill (tba).
        background = VectorColors.error.withValues(alpha: 0.14);
        textColor = VectorColors.error;
        label = 'Closing soon';
        break;
      case 'tba':
      default:
        background = Colors.black.withValues(alpha: 0.55);
        textColor = VectorColors.textOnPurple;
        label = 'Dates TBA';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: VectorText.labelSmall.copyWith(color: textColor),
      ),
    );
  }
}

/// The one unified hackathon card, used for every hackathon regardless of
/// `isFeatured`/`pinRank` (those only affect list sort order, never a
/// visible badge). Has two visual states:
///
/// - Collapsed (default): white surface, small eyebrow, name, meta row.
/// - Expanded: purple hero surface with background triangle, larger
///   type, an optional gated prize hero-number block, and a bottom meta
///   row whose apricot arrow tile is the only tap target that navigates
///   to Teams.
///
/// Wrapped in a [Hero] using the tag convention `'hackathon-card-${id}'`,
/// shared with `TeamsScreen`'s full-page purple card, so tapping through
/// to Teams visually "grows" the card into the next screen.
class HackathonCard extends StatefulWidget {
  static const expansionDuration = Duration(milliseconds: 320);
  const HackathonCard({
    super.key,
    required this.hackathon,
    required this.isExpanded,
    this.onTap,
    this.onArrowTap,
    this.teamCount,
  });

  final Hackathon hackathon;

  /// Whether this card should render its expanded (purple hero) state.
  /// Expansion is controlled by the parent list — only one card in the
  /// list is expanded at a time.
  final bool isExpanded;

  /// Fires when the card (in either state) is tapped anywhere except the
  /// expanded-state arrow tile — toggles expand/collapse in the parent.
  final VoidCallback? onTap;

  /// Fires only when the expanded-state apricot arrow tile is tapped —
  /// the sole trigger for navigating to Teams.
  final VoidCallback? onArrowTap;

  /// Optional team count for the "{n} teams" meta segment. When null (or
  /// zero), the segment is simply omitted.
  final int? teamCount;

  @override
  State<HackathonCard> createState() => _HackathonCardState();
}

class _HackathonCardState extends State<HackathonCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.isExpanded) return; // press feedback only in collapsed state
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final Hackathon h = widget.hackathon;
    final bool disableAnimations = MediaQuery.disableAnimationsOf(context);
    final bool expanded = widget.isExpanded;

    // The giant apricot hero number is exclusively for prize money.
    final bool isPrize = h.heroCaption.toLowerCase().contains('prize');
    final String statText = isPrize
        ? '${h.heroValue} SAR'
        : '${h.heroValue} ${h.heroCaption}';

    final Duration morphDuration = disableAnimations
        ? Duration.zero
        : HackathonCard.expansionDuration;
    const Cubic morphCurve = Cubic(0.22, 1, 0.36, 1);

    final double pressScale = (!disableAnimations && _pressed && !expanded)
        ? 0.97
        : 1.0;

    final Widget cardBody = ClipRRect(
      borderRadius: BorderRadius.circular(21),
      child: AnimatedContainer(
        duration: morphDuration,
        curve: morphCurve,
        decoration: BoxDecoration(
          color: expanded
              ? VectorColors.purpleBrand
              : VectorColors.surfaceWhite,
          border: expanded ? null : Border.all(color: VectorColors.hairline),
        ),
        child: AnimatedCrossFade(
          duration: morphDuration,
          firstCurve: morphCurve,
          secondCurve: morphCurve,
          sizeCurve: morphCurve,
          crossFadeState: expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: _CollapsedContent(hackathon: h, statText: statText),
          secondChild: _ExpandedContent(
            hackathon: h,
            statText: statText,
            isPrize: isPrize,
            teamCount: widget.teamCount,
            onArrowTap: widget.onArrowTap,
          ),
        ),
      ),
    );

    return Hero(
      tag: 'hackathon-card-${h.id}',
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: pressScale,
            duration: disableAnimations
                ? Duration.zero
                : const Duration(milliseconds: 120),
            curve: morphCurve,
            child: cardBody,
          ),
        ),
      ),
    );
  }
}

/// Collapsed card content — white surface, eyebrow + status, name, and a
/// plain-text meta row (never a giant prize number).
class _CollapsedContent extends StatelessWidget {
  const _CollapsedContent({required this.hackathon, required this.statText});

  final Hackathon hackathon;
  final String statText;

  @override
  Widget build(BuildContext context) {
    final Hackathon h = hackathon;
    final TextStyle metaStyle = VectorText.bodyMedium.copyWith(
      color: VectorColors.textSecondary,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const _EyebrowTriangle(size: 8),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  h.field.toUpperCase(),
                  style: VectorText.labelSmall.copyWith(
                    color: VectorColors.textSecondaryPurple,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: h.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            h.name,
            style: VectorText.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(statText, style: metaStyle),
              const _MetaDivider(),
              Text(h.eventDates ?? 'Dates TBA', style: metaStyle),
              const _MetaDivider(),
              Text(h.city, style: metaStyle),
            ],
          ),
        ],
      ),
    );
  }
}

/// Expanded card content — purple hero surface with background triangle,
/// larger type, a gated prize hero-number block, and a bottom meta row
/// whose arrow tile is the sole Teams tap target.
class _ExpandedContent extends StatelessWidget {
  const _ExpandedContent({
    required this.hackathon,
    required this.statText,
    required this.isPrize,
    required this.teamCount,
    required this.onArrowTap,
  });

  final Hackathon hackathon;
  final String statText;
  final bool isPrize;
  final int? teamCount;
  final VoidCallback? onArrowTap;

  @override
  Widget build(BuildContext context) {
    final Hackathon h = hackathon;
    final TextStyle metaStyle = VectorText.bodyMedium.copyWith(
      color: VectorColors.textOnPurple.withValues(alpha: 0.85),
    );

    // The prize hero number already conveys `statText`'s value, so it is
    // only added to the meta row when there is no hero block to show it.
    final List<Widget> metaChildren = [];
    if (!isPrize) {
      metaChildren.add(Text(statText, style: metaStyle));
      metaChildren.add(const _MetaDivider());
    }
    metaChildren.add(Text(h.eventDates ?? 'Dates TBA', style: metaStyle));
    metaChildren.add(const _MetaDivider());
    metaChildren.add(Text(h.city, style: metaStyle));
    if (teamCount != null && teamCount! > 0) {
      metaChildren.add(const _MetaDivider());
      metaChildren.add(Text('$teamCount teams', style: metaStyle));
    }

    return Stack(
      children: [
        // Background geometry — behind all content.
        Positioned.fill(
          child: _BackgroundTriangle(
            color: VectorColors.apricot.withValues(alpha: 0.10),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const _EyebrowTriangle(),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      h.field.toUpperCase(),
                      style: VectorText.labelSmall.copyWith(
                        color: VectorColors.apricot,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(status: h.status),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                h.name,
                style: VectorText.titleLarge.copyWith(
                  color: VectorColors.textOnPurple,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              _StaggeredIn(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (h.organizer != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        h.organizer!,
                        style: VectorText.bodyMedium.copyWith(
                          color: VectorColors.textOnPurple.withValues(
                            alpha: 0.65,
                          ),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (isPrize) ...[
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            h.heroValue,
                            style: const TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1.0,
                              color: VectorColors.apricot,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              h.heroCaption,
                              style: VectorText.bodyMedium.copyWith(
                                color: VectorColors.textOnPurple.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: metaChildren,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(13),
                            onTap: onArrowTap,
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: VectorColors.apricot,
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_outlined,
                                color: VectorColors.textNeutral,
                                size: 20,
                              ),
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
        ),
      ],
    );
  }
}

/// Fades + slides its child in AFTER the enclosing card's container has
/// already started growing (the last 65% of the morph), so expanded-only
/// content never appears squashed mid-grow.
class _StaggeredIn extends StatelessWidget {
  const _StaggeredIn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: const Interval(0.35, 1.0, curve: Cubic(0.22, 1, 0.36, 1)),
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 4),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Placeholder block shaped like the collapsed [HackathonCard], shown
/// while hackathons are loading.
class HackathonCardSkeleton extends StatelessWidget {
  const HackathonCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: VectorColors.surfaceLavender.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(21),
      ),
    );
  }
}
