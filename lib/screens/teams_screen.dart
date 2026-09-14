import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/hackathon_repository.dart';
import '../models/hackathon.dart';
import '../models/member.dart';
import '../models/team.dart';
import '../theme/vector_colors.dart';
import '../theme/vector_text.dart';
import '../widgets/member_sheet.dart';
import '../widgets/request_sent_dialog.dart';
import '../widgets/vector_header.dart';
import 'create_team_screen.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key, required this.hackathon});

  final Hackathon hackathon;

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  final HackathonRepository _repo = HackathonRepository();
  late final PageController _pageController;

  List<Team>? _teams;
  int _currentIndex = 0;

  /// Team ids with an in-flight join request.
  final Set<String> _sendingTeamIds = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadTeams();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadTeams({int? jumpToIndex}) async {
    final teams = await _repo.fetchTeams(widget.hackathon.id);
    if (!mounted) return;
    setState(() {
      _teams = teams;
      _currentIndex = jumpToIndex ?? 0;
    });
    if (jumpToIndex != null && _pageController.hasClients) {
      _pageController.animateToPage(
        jumpToIndex,
        duration: const Duration(milliseconds: 420),
        curve: const Cubic(0.22, 1, 0.36, 1),
      );
    }
  }

  Future<void> _openCreateTeamForm() async {
    final Team? created = await Navigator.of(context).push<Team>(
      MaterialPageRoute(
        builder: (_) => CreateTeamScreen(hackathon: widget.hackathon),
      ),
    );
    if (created == null || !mounted) return;
    await _loadTeams(jumpToIndex: (_teams?.length ?? 0));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Team created — you're the lead")),
    );
  }

  Future<void> _handleSendRequest(Team team) async {
    if (_sendingTeamIds.contains(team.id)) return;

    setState(() => _sendingTeamIds.add(team.id));
    final success = await _repo.sendJoinRequest(team.id);
    if (!mounted) return;
    setState(() => _sendingTeamIds.remove(team.id));

    if (success) {
      await showRequestSentDialog(context, team);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not send request. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final teams = _teams;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: VectorColors.background,
        body: Column(
          children: [
            VectorHeader.slim(
              title: widget.hackathon.name,
              onBack: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Expanded(child: _buildCarouselArea(teams)),
                    const SizedBox(height: 12),
                    _PageDots(
                      count: teams == null ? 0 : teams.length + 1,
                      currentIndex: _currentIndex,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselArea(List<Team>? teams) {
    if (teams == null) {
      return const Center(
        child: CircularProgressIndicator(color: VectorColors.purpleBrand),
      );
    }

    final bool disableAnimations = MediaQuery.disableAnimationsOf(context);
    // +1 for the trailing create-team page (Section C).
    final int pageCount = teams.length + 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Card height is EXACTLY 75% of the available space, computed
        // responsively — never a hardcoded pixel value.
        final double cardHeight = constraints.maxHeight * 0.75;

        return Center(
          child: AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              final double currentPage = _pageController.hasClients
                  ? (_pageController.page ?? _currentIndex.toDouble())
                  : _currentIndex.toDouble();

              return PageView.builder(
                controller: _pageController,
                clipBehavior: Clip.none,
                itemCount: pageCount,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (context, index) {
                  final bool isCreatePage = index == teams.length;

                  // Every page (team cards AND the create-team card) shares
                  // identical horizontal padding, width, and height.
                  final Widget inner = SizedBox(
                    height: cardHeight,
                    child: isCreatePage
                        ? _CreateTeamCard(onStart: _openCreateTeamForm)
                        : _TeamCard(
                            team: teams[index],
                            index: index,
                            total: teams.length,
                            isSending: _sendingTeamIds.contains(
                              teams[index].id,
                            ),
                            onSendRequest: () =>
                                _handleSendRequest(teams[index]),
                          ),
                  );

                  final Widget card = Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: inner,
                    ),
                  );

                  if (disableAnimations) {
                    return index == 0
                        ? Hero(
                            tag: 'hackathon-card-${widget.hackathon.id}',
                            child: Material(
                              color: Colors.transparent,
                              child: card,
                            ),
                          )
                        : card;
                  }

                  // Exact 3D flip transform on the ENTIRE purple card
                  final double delta = (index - currentPage).clamp(-1.0, 1.0);
                  final Widget flippedCard = Opacity(
                    opacity: (1.0 - delta.abs() * 0.6).clamp(0.0, 1.0),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0015)
                        ..rotateY(delta * math.pi * 0.75)
                        ..scaleByDouble(
                          1.0 - delta.abs() * 0.1,
                          1.0 - delta.abs() * 0.1,
                          1.0 - delta.abs() * 0.1,
                          1,
                        ),
                      child: card,
                    ),
                  );

                  return index == 0
                      ? Hero(
                          tag: 'hackathon-card-${widget.hackathon.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: flippedCard,
                          ),
                        )
                      : flippedCard;
                },
              );
            },
          ),
        );
      },
    );
  }
}

/// The full purple team card: hugs its content (mainAxisSize.min)
/// and centers vertically with zero dead space.
class _TeamCard extends StatefulWidget {
  const _TeamCard({
    required this.team,
    required this.index,
    required this.total,
    required this.isSending,
    required this.onSendRequest,
  });

  final Team team;
  final int index;
  final int total;
  final bool isSending;
  final VoidCallback onSendRequest;

  @override
  State<_TeamCard> createState() => _TeamCardState();
}

class _TeamCardState extends State<_TeamCard> {
  int? _openMemberIndex;

  Future<void> _handleMemberTap(int i, Member member) async {
    setState(() => _openMemberIndex = i);
    await showMemberSheet(context, member);
    if (mounted) setState(() => _openMemberIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    final team = widget.team;
    final openSpots = team.maxMembers - team.members;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: VectorColors.purpleBrand,
        borderRadius: BorderRadius.circular(21),
      ),
      child: Stack(
        children: [
          // Large low-opacity apricot triangle anchored bleeding off the bottom corner
          Positioned(
            bottom: -40,
            right: -40,
            child: CustomPaint(
              size: const Size(240, 240),
              painter: _CornerTrianglePainter(
                color: VectorColors.apricot.withValues(alpha: 0.12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TEAM ${widget.index + 1} / ${widget.total}'.toUpperCase(),
                  style: VectorText.labelSmall.copyWith(
                    color: VectorColors.apricot,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  team.name,
                  style: VectorText.displayLarge.copyWith(
                    fontSize: 29,
                    fontWeight: FontWeight.w700,
                    color: VectorColors.textOnPurple,
                  ),
                ),
                const SizedBox(height: 14),
                // Hero spots-open number (the one non-prize exception)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$openSpots',
                      style: VectorText.displayLarge.copyWith(
                        fontSize: 52,
                        fontWeight: FontWeight.w700,
                        color: VectorColors.apricot,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'spots open',
                        style: VectorText.bodyLarge.copyWith(
                          color: VectorColors.textOnPurple.withValues(
                            alpha: 0.75,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(team.maxMembers, (i) {
                    if (i < team.members) {
                      final initials = i < team.memberInitials.length
                          ? team.memberInitials[i]
                          : '';
                      final member = i < team.membersInfo.length
                          ? team.membersInfo[i]
                          : null;
                      return _MemberTile(
                        initials: initials,
                        selected: _openMemberIndex == i,
                        onTap: member == null
                            ? null
                            : () => _handleMemberTap(i, member),
                      );
                    }
                    return const _EmptyMemberTile();
                  }),
                ),
                const SizedBox(height: 6),
                Text(
                  '${team.members} of ${team.maxMembers} members',
                  style: VectorText.bodyMedium.copyWith(
                    color: VectorColors.textOnPurple.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'MISSING ROLES'.toUpperCase(),
                  style: VectorText.labelSmall.copyWith(
                    color: VectorColors.apricot,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: team.missingRoles
                      .map((role) => _MissingRolePill(label: role))
                      .toList(),
                ),
                // Flexible spacer absorbs the leftover height (card is a
                // fixed 75%-of-page height) so the button pins to the
                // bottom without squeezing the content above it.
                const Spacer(),
                const SizedBox(height: 20),
                _SendJoinRequestButton(
                  isLoading: widget.isSending,
                  onTap: widget.onSendRequest,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.initials,
    this.selected = false,
    this.onTap,
  });

  final String initials;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget tile = Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: VectorColors.surfaceLavender,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        initials,
        style: VectorText.labelMedium.copyWith(
          color: VectorColors.purpleBrand,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    // Pressed tile gets a 2px apricot outline with a 2px offset while
    // its member sheet is open.
    final Widget outlined = Container(
      padding: EdgeInsets.all(selected ? 2 : 0),
      decoration: selected
          ? BoxDecoration(
              border: Border.all(color: VectorColors.apricot, width: 2),
              borderRadius: BorderRadius.circular(15),
            )
          : null,
      child: tile,
    );

    if (onTap == null) return outlined;
    return GestureDetector(onTap: onTap, child: outlined);
  }
}

class _EmptyMemberTile extends StatelessWidget {
  const _EmptyMemberTile();

  @override
  Widget build(BuildContext context) {
    final dashColor = VectorColors.textOnPurple.withValues(alpha: 0.4);
    return SizedBox(
      width: 42,
      height: 42,
      child: CustomPaint(
        painter: _DashedRRectPainter(color: dashColor, radius: 13),
        child: Center(
          child: Icon(Icons.add, size: 16, color: dashColor),
        ),
      ),
    );
  }
}

class _MissingRolePill extends StatelessWidget {
  const _MissingRolePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: ShapeDecoration(
        color: VectorColors.textOnPurple.withValues(alpha: 0.12),
        shape: const StadiumBorder(),
      ),
      child: Text(
        label,
        style: VectorText.labelSmall.copyWith(
          color: VectorColors.textOnPurple,
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.currentIndex});

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox(height: 6);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 20 : 6,
          height: 6,
          decoration: ShapeDecoration(
            color: active ? VectorColors.apricot : VectorColors.surfaceLavender,
            shape: const StadiumBorder(),
          ),
        );
      }),
    );
  }
}

class _SendJoinRequestButton extends StatelessWidget {
  const _SendJoinRequestButton({
    required this.isLoading,
    required this.onTap,
  });

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final canTap = !isLoading;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [VectorColors.buttonStart, VectorColors.buttonEnd],
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(13),
            onTap: canTap ? onTap : null,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: VectorColors.textNeutral,
                      ),
                    )
                  : Text(
                      'Send join request',
                      style: VectorText.labelLarge.copyWith(
                        color: VectorColors.textNeutral,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CornerTrianglePainter extends CustomPainter {
  const _CornerTrianglePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerTrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
      Radius.circular(radius),
    );
    final source = Path()..addRRect(rrect);
    canvas.drawPath(_dashPath(source, dashLength: 4, gapLength: 3), paint);
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;

  static Path _dashPath(
    Path source, {
    required double dashLength,
    required double gapLength,
  }) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final length = draw ? dashLength : gapLength;
        final next = math.min(distance + length, metric.length);
        if (draw) {
          dest.addPath(metric.extractPath(distance, next), Offset.zero);
        }
        distance = next;
        draw = !draw;
      }
    }
    return dest;
  }
}
/// The trailing carousel page: matches the team cards' medium sizing and
/// flips like any other page, but is visually distinct (dashed border,
/// white surface) since it isn't a real team.
class _CreateTeamCard extends StatelessWidget {
  const _CreateTeamCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: VectorColors.surfaceWhite,
        borderRadius: BorderRadius.circular(21),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DashedRRectPainter(
                color: VectorColors.inputBorder,
                radius: 21,
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: -40,
            child: CustomPaint(
              size: const Size(200, 200),
              painter: _CornerTrianglePainter(
                color: VectorColors.apricot.withValues(alpha: 0.10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: VectorColors.apricot,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.add,
                    size: 34,
                    color: VectorColors.textNeutral,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Create a new team',
                  textAlign: TextAlign.center,
                  style: VectorText.titleLarge.copyWith(
                    fontSize: 21,
                    color: VectorColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Didn't find your fit? Start your own team and let "
                  'people come to you.',
                  textAlign: TextAlign.center,
                  style: VectorText.bodyMedium.copyWith(
                    color: VectorColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onStart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VectorColors.purpleBrand,
                      foregroundColor: VectorColors.textOnPurple,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: Text(
                      'Start a team',
                      style: VectorText.labelLarge.copyWith(
                        color: VectorColors.textOnPurple,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
