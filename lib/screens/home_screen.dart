import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/hackathon_repository.dart';
import '../models/hackathon.dart';
import '../models/team.dart';
import '../theme/vector_colors.dart';
import '../theme/vector_text.dart';
import '../widgets/hackathon_cards.dart';
import '../widgets/vector_header.dart';
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

  /// Which card is expanded, if any. A [ValueNotifier] (rather than
  /// `setState`) so toggling it only notifies the per-card
  /// `ValueListenableBuilder`s below — the list, chips, and header never
  /// rebuild on expand/collapse.
  final ValueNotifier<String?> _expandedId = ValueNotifier<String?>(null);
  final Map<String, GlobalKey> _cardKeys = {};

  GlobalKey _keyFor(String id) => _cardKeys.putIfAbsent(id, () => GlobalKey());

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _expandedId.dispose();
    super.dispose();
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

  void _toggleExpanded(Hackathon hackathon) {
    final bool nowExpanding = _expandedId.value != hackathon.id;
    _expandedId.value = nowExpanding ? hackathon.id : null;
    if (!nowExpanding) return;

    final bool disableAnimations = MediaQuery.disableAnimationsOf(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _keyFor(hackathon.id).currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 350),
        curve: const Cubic(0.22, 1, 0.36, 1),
        alignment: 0.1,
      );
    });
  }

  Future<void> _handleArrowTap(Hackathon hackathon) async {
    final List<Team> teams = await _repo.fetchTeams(hackathon.id);
    if (!mounted) return;
    if (teams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Teams are open soon on this hackathon'),
        ),
      );
      return;
    }
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

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: VectorColors.background,
        body: Column(
          children: [
            const VectorHeader.home(),
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
          HackathonCardSkeleton(),
          SizedBox(height: 12),
          HackathonCardSkeleton(),
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
        return KeyedSubtree(
          key: _keyFor(h.id),
          child: ValueListenableBuilder<String?>(
            valueListenable: _expandedId,
            builder: (context, expandedId, _) {
              return HackathonCard(
                hackathon: h,
                isExpanded: expandedId == h.id,
                onTap: () => _toggleExpanded(h),
                onArrowTap: () => _handleArrowTap(h),
              );
            },
          ),
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
