import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/hackathon_repository.dart';
import '../models/hackathon.dart';
import '../theme/vector_colors.dart';
import '../theme/vector_text.dart';
import '../widgets/hackathon_cards.dart';
import '../widgets/vector_wordmark.dart';
import 'teams_screen.dart';

/// Chip filter order, per the design spec. "All" applies no filter.
const List<String> _kFieldChips = [
  'All',
  'Security',
  'AI',
  'GovTech',
  'Energy',
  'Industry',
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HackathonRepository _repo = HackathonRepository();

  bool _loading = true;
  List<Hackathon> _hackathons = const [];
  String _selectedField = 'All';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final List<Hackathon> hackathons = await _repo.fetchHackathons();
    if (!mounted) return;
    setState(() {
      _hackathons = hackathons;
      _loading = false;
    });
  }

  List<Hackathon> get _filtered {
    if (_selectedField == 'All') return _hackathons;
    return _hackathons.where((h) => h.field == _selectedField).toList();
  }

  void _openFeatured(Hackathon hackathon) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 425),
        reverseTransitionDuration: const Duration(milliseconds: 425),
        pageBuilder: (context, animation, secondaryAnimation) {
          return TeamsScreen(hackathon: hackathon);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final CurvedAnimation curved = CurvedAnimation(
            parent: animation,
            curve: const Cubic(0.22, 1, 0.36, 1),
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _showCompactSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Teams are open on featured hackathons'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: VectorColors.background,
        body: Column(
          children: [
            _Header(),
            _FieldChipBar(
              selected: _selectedField,
              onSelected: (field) => setState(() => _selectedField = field),
            ),
            Expanded(child: _buildList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final bool disableAnimations = MediaQuery.disableAnimationsOf(context);

    if (_loading) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        children: const [
          HackathonCardSkeleton(),
          SizedBox(height: 12),
          CompactHackathonCardSkeleton(),
          SizedBox(height: 12),
          CompactHackathonCardSkeleton(),
        ],
      );
    }

    final List<Hackathon> items = _filtered;
    final Widget list = ListView.separated(
      key: ValueKey<String>(_selectedField),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final Hackathon h = items[index];
        if (h.isFeatured) {
          return FeaturedHackathonCard(
            hackathon: h,
            onTap: () => _openFeatured(h),
          );
        }
        return CompactHackathonCard(
          hackathon: h,
          onTap: _showCompactSnackBar,
        );
      },
    );

    if (disableAnimations) return list;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: const Cubic(0.4, 0, 0.2, 1),
      switchOutCurve: const Cubic(0.4, 0, 0.2, 1),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: list,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(26),
        bottomRight: Radius.circular(26),
      ),
      child: Container(
        color: VectorColors.purpleBrand,
        child: Stack(
          children: [
            // Large low-opacity triangle bleeding off the top-right
            // corner, behind all header text.
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
              child: Padding(
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
                        color: VectorColors.textOnPurple.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
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

class _HeaderTrianglePainter extends CustomPainter {
  const _HeaderTrianglePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..moveTo(size.width * 0.15, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.85)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _HeaderTrianglePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _FieldChipBar extends StatelessWidget {
  const _FieldChipBar({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VectorColors.background,
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _kFieldChips.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final String field = _kFieldChips[index];
            final bool isSelected = field == selected;
            return _FieldChip(
              label: field,
              selected: isSelected,
              onTap: () => onSelected(field),
            );
          },
        ),
      ),
    );
  }
}

class _FieldChip extends StatelessWidget {
  const _FieldChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color background = selected
        ? VectorColors.apricot
        : VectorColors.surfaceLavender;
    final Color textColor = selected
        ? VectorColors.textNeutral
        : VectorColors.textSecondaryPurple;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: ShapeDecoration(
            color: background,
            shape: const StadiumBorder(),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: VectorText.labelLarge.copyWith(color: textColor),
          ),
        ),
      ),
    );
  }
}
