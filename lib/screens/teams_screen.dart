import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/hackathon_repository.dart';
import '../models/hackathon.dart';
import '../models/team.dart';
import '../theme/vector_colors.dart';
import '../theme/vector_text.dart';
import '../widgets/flip_carousel.dart';
import '../widgets/request_sent_dialog.dart';
import '../widgets/vector_header.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key, required this.hackathon});

  final Hackathon hackathon;

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  final _repo = HackathonRepository();

  List<Team>? _teams;
  int _currentIndex = 0;

  /// Team ids with an in-flight join request. Tracked per-team (rather than
  /// one shared bool) so sending a request from one card doesn't visually
  /// disable every other team's button while the network call is pending -
  /// each card only reflects its own team's state.
  final Set<String> _sendingTeamIds = {};

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    final teams = await _repo.fetchTeams(widget.hackathon.id);
    if (!mounted) return;
    setState(() {
      _teams = teams;
      _currentIndex = 0;
    });
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

    return Scaffold(
      backgroundColor: VectorColors.background,
      body: Column(
        children: [
          VectorHeader.slim(title: widget.hackathon.name),
          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Expanded(child: _buildCarouselArea(teams)),
                  const SizedBox(height: 12),
                  _PageDots(count: teams?.length ?? 0, currentIndex: _currentIndex),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselArea(List<Team>? teams) {
    if (teams == null) {
      return const Center(
        child: CircularProgressIndicator(color: VectorColors.purpleBrand),
      );
    }
    if (teams.isEmpty) {
      return Center(
        child: Text(
          'No teams yet.',
          style: VectorText.bodyMedium.copyWith(
            color: VectorColors.textSecondary,
          ),
        ),
      );
    }

    return Center(
      child: FlipCarousel(
        itemCount: teams.length,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemBuilder: (context, index) {
          final team = teams[index];
          // Each page returns the FULL styled purple card (not just the
          // inner text) so the whole card participates in FlipCarousel's
          // 3D rotation - see _TeamCard below.
          final page = Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _TeamCard(
                team: team,
                index: index,
                total: teams.length,
                isSending: _sendingTeamIds.contains(team.id),
                onSendRequest: () => _handleSendRequest(team),
              ),
            ),
          );

          // Only the first page carries the Hero tag. PageView.builder may
          // keep neighboring pages alive for smooth dragging, and Flutter
          // throws if two mounted widgets share a Hero tag at once.
          return index == 0
              ? Hero(
                  tag: 'hackathon-card-${widget.hackathon.id}',
                  child: Material(color: Colors.transparent, child: page),
                )
              : page;
        },
      ),
    );
  }
}

/// The full purple team card: background/decoration/triangle AND content,
/// all in one widget so a whole page of [FlipCarousel] flips as a unit.
class _TeamCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TEAM ${index + 1} / $total'.toUpperCase(),
                  style: VectorText.labelSmall.copyWith(
                    color: VectorColors.apricot,
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
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$openSpots',
                      style: VectorText.displayLarge.copyWith(
                        fontSize: 56,
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
                          color: VectorColors.textOnPurple.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(team.maxMembers, (i) {
                    if (i < team.members) {
                      final initials = i < team.memberInitials.length
                          ? team.memberInitials[i]
                          : '';
                      return _MemberTile(initials: initials);
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
                const SizedBox(height: 16),
                Text(
                  'MISSING ROLES'.toUpperCase(),
                  style: VectorText.labelSmall.copyWith(
                    color: VectorColors.apricot,
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
                const SizedBox(height: 20),
                _SendJoinRequestButton(
                  isLoading: isSending,
                  onTap: onSendRequest,
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
  const _MemberTile({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
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
  }
}

class _EmptyMemberTile extends StatelessWidget {
  const _EmptyMemberTile();

  @override
  Widget build(BuildContext context) {
    final dashColor = VectorColors.textOnPurple.withValues(alpha: 0.4);
    return SizedBox(
      width: 40,
      height: 40,
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

/// "Send join request" - the single accent-filled element on this screen,
/// now living as the last element inside each per-team card so it always
/// acts on that card's own team (see [_TeamCard.onSendRequest]).
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

/// Draws a low-opacity triangle bleeding off the bottom-right corner of the
/// team card, meant to sit behind the foreground content.
class _CornerTrianglePainter extends CustomPainter {
  _CornerTrianglePainter({required this.color});

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
  bool shouldRepaint(covariant _CornerTrianglePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// A dashed rounded-rect stroke, used to approximate a "dashed border" for
/// empty member-slot tiles (Flutter has no built-in dashed border support).
class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.radius});

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
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }

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
