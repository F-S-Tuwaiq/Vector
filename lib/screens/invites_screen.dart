import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/hackathon_repository.dart';
import '../models/hackathon.dart';
import '../models/invitation.dart';
import '../models/sent_request.dart';
import '../theme/vector_colors.dart';
import '../theme/vector_text.dart';
import '../widgets/loading_button_content.dart';
import '../widgets/skeleton/skeleton_loader.dart';
import '../widgets/vector_header.dart';
import 'teams_screen.dart';
import '../widgets/confirm_action_dialog.dart';

class InvitesScreen extends StatefulWidget {
  const InvitesScreen({super.key, required this.onOpenHackathon});

  /// Called with a hackathon id when the hackathon-strip deep link is
  /// tapped — the shell switches to Home and expands that card.
  final ValueChanged<String> onOpenHackathon;

  @override
  State<InvitesScreen> createState() => InvitesScreenState();
}

/// Public so [RootShell] can hold a `GlobalKey<InvitesScreenState>` and
/// call [refreshOnFocus] when this tab gains focus.
class InvitesScreenState extends State<InvitesScreen> {
  final HackathonRepository _repo = HackathonRepository();

  bool _loading = true;
  bool _hasLoaded = false;
  int _tabIndex = 0;
  List<Invitation> _invitations = const [];
  List<SentRequest> _sentRequests = const [];
  String? _expandedInvitationId;
  final Set<String> _respondingIds = {};
  final Set<String> _exitingInvitationIds = {};
  final Set<String> _withdrawingIds = {};
  final Set<String> _exitingSentIds = {};

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final results = await Future.wait<Object>([
      _repo.fetchInvitations(),
      _repo.fetchSentRequests(),
    ]);
    final invitations = results[0] as List<Invitation>;
    final sentRequests = results[1] as List<SentRequest>;
    if (!mounted) return;
    setState(() {
      _invitations = invitations;
      _sentRequests = sentRequests;
      _expandedInvitationId = invitations.isNotEmpty
          ? invitations.first.id
          : null;
      _loading = false;
      _hasLoaded = true;
    });
  }

  /// Refetches both lists — called when this tab gains focus so a
  /// just-sent join request shows up in Sent without a manual pull.
  void refreshOnFocus() {
    if (!_loading) _loadAll();
  }

  Future<void> _handleAccept(Invitation invitation) async {
    if (_respondingIds.contains(invitation.id)) return;
    final confirmed = await showConfirmActionDialog(
      context,
      title: 'Accept invitation?',
      message:
          'Are you sure you want to accept the invitation to join ${invitation.teamName}?',
      confirmLabel: 'Accept',
    );
    if (!mounted || !confirmed || _respondingIds.contains(invitation.id)) {
      return;
    }
    setState(() => _respondingIds.add(invitation.id));
    final success = await _repo.respondToInvitation(invitation.id, 'accepted');
    if (!mounted) return;
    setState(() => _respondingIds.remove(invitation.id));
    if (success) {
      _dismissInvitation(invitation.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You're in — say hi to the team!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something broke. Try again.')),
      );
    }
  }

  Future<void> _handleDecline(Invitation invitation) async {
    setState(() => _respondingIds.add(invitation.id));
    final success = await _repo.respondToInvitation(invitation.id, 'declined');
    if (!mounted) return;
    setState(() => _respondingIds.remove(invitation.id));
    if (success) {
      _dismissInvitation(invitation.id);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invitation declined')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something broke. Try again.')),
      );
    }
  }

  void _dismissInvitation(String id) {
    setState(() => _exitingInvitationIds.add(id));
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _invitations = _invitations.where((i) => i.id != id).toList();
        _exitingInvitationIds.remove(id);
        if (_expandedInvitationId == id) {
          _expandedInvitationId = _invitations.isNotEmpty
              ? _invitations.first.id
              : null;
        }
      });
    });
  }

  Future<void> _handleWithdraw(SentRequest request) async {
    if (_withdrawingIds.contains(request.id)) return;
    final confirmed = await showConfirmActionDialog(
      context,
      title: 'Withdraw request?',
      message:
          'Are you sure you want to withdraw your request to join ${request.teamName}?',
      confirmLabel: 'Withdraw',
    );
    if (!mounted || !confirmed || _withdrawingIds.contains(request.id)) return;
    setState(() => _withdrawingIds.add(request.id));
    final success = await _repo.withdrawRequest(request.id);
    if (!mounted) return;
    setState(() => _withdrawingIds.remove(request.id));
    if (success) {
      setState(() => _exitingSentIds.add(request.id));
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() {
          _sentRequests = _sentRequests
              .where((r) => r.id != request.id)
              .toList();
          _exitingSentIds.remove(request.id);
        });
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Request withdrawn')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something broke. Try again.')),
      );
    }
  }

  void _handleMeetTeam(SentRequest request) {
    TeamsScreen.open(
      context,
      hackathon: Hackathon(
        id: request.hackathonId,
        name: request.hackathonName,
        field: '',
        heroValue: '',
        heroCaption: '',
        city: '',
        status: 'open',
      ),
      initialTeamId: request.teamId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VectorColors.background,
      body: Column(
        children: [
          const VectorHeader.slim(title: 'Invites', showBackButton: false),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: _SegmentedControl(
              index: _tabIndex,
              incomingCount: _invitations.length,
              onChanged: (i) => setState(() => _tabIndex = i),
            ),
          ),
          Expanded(
            child: !_hasLoaded
                ? const _InviteListSkeleton()
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _tabIndex == 0
                        ? _buildIncoming(const ValueKey('incoming'))
                        : _buildSent(const ValueKey('sent')),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncoming(Key key) {
    if (_invitations.isEmpty) {
      return _EmptyTab(key: key, caption: 'New invites land here.');
    }
    return ListView.separated(
      key: key,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      itemCount: _invitations.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final invitation = _invitations[index];
        final exiting = _exitingInvitationIds.contains(invitation.id);
        return AnimatedOpacity(
          opacity: exiting ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          child: AnimatedSlide(
            offset: exiting ? const Offset(0, -0.06) : Offset.zero,
            duration: const Duration(milliseconds: 300),
            curve: const Cubic(0.22, 1, 0.36, 1),
            child: _InvitationCard(
              invitation: invitation,
              expanded: _expandedInvitationId == invitation.id,
              responding: _respondingIds.contains(invitation.id),
              onTap: () =>
                  setState(() => _expandedInvitationId = invitation.id),
              onAccept: () => _handleAccept(invitation),
              onDecline: () => _handleDecline(invitation),
              onOpenHackathon: () =>
                  widget.onOpenHackathon(invitation.hackathonId),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSent(Key key) {
    if (_sentRequests.isEmpty) {
      return _EmptyTab(
        key: key,
        caption: 'Nothing sent yet — find a team on Home.',
      );
    }
    return ListView(
      key: key,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      children: [
        for (final request in _sentRequests) ...[
          Builder(
            builder: (context) {
              final exiting = _exitingSentIds.contains(request.id);
              return AnimatedOpacity(
                opacity: exiting ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                child: AnimatedSlide(
                  offset: exiting ? const Offset(0, -0.06) : Offset.zero,
                  duration: const Duration(milliseconds: 300),
                  curve: const Cubic(0.22, 1, 0.36, 1),
                  child: _SentRequestCard(
                    request: request,
                    withdrawing: _withdrawingIds.contains(request.id),
                    onWithdraw: () => _handleWithdraw(request),
                    onMeetTeam: () => _handleMeetTeam(request),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 8),
        Text(
          'Requests you send from any team page land here.',
          textAlign: TextAlign.center,
          style: VectorText.bodyMedium.copyWith(color: VectorColors.textMuted),
        ),
      ],
    );
  }
}

class _SegmentedControl extends StatelessWidget {
  const _SegmentedControl({
    required this.index,
    required this.incomingCount,
    required this.onChanged,
  });

  final int index;
  final int incomingCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: VectorColors.surfaceLavender,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Segment(
              label: 'Incoming',
              selected: index == 0,
              badgeCount: incomingCount,
              onTap: () => onChanged(0),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _Segment(
              label: 'Sent',
              selected: index == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 36,
          decoration: BoxDecoration(
            color: selected ? VectorColors.surfaceWhite : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: VectorText.labelLarge.copyWith(
                  color: selected
                      ? VectorColors.textPrimary
                      : VectorColors.textSecondaryPurple,
                ),
              ),
              if (badgeCount != null && badgeCount! > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: VectorColors.apricot,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: VectorText.labelMedium.copyWith(
                      color: VectorColors.textNeutral,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamTile extends StatelessWidget {
  const _TeamTile({required this.initial, required this.size});

  final String initial;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: VectorColors.surfaceLavender,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        initial,
        style: VectorText.titleLarge.copyWith(
          color: VectorColors.purpleBrand,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ExpiryChip extends StatelessWidget {
  const _ExpiryChip({required this.urgent, required this.label});

  final bool urgent;
  final String label;

  @override
  Widget build(BuildContext context) {
    final Color background = urgent
        ? VectorColors.error.withValues(alpha: 0.14)
        : Colors.transparent;
    final Color foreground = urgent
        ? VectorColors.error
        : VectorColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 12, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: VectorText.labelMedium.copyWith(
              fontSize: 11,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder rows shaped like the collapsed [_InvitationCard] /
/// [_SentRequestCard], shown while invites/requests are loading — one
/// shimmer sweep across the whole list rather than one per row.
class _InviteListSkeleton extends StatelessWidget {
  const _InviteListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => const _InviteRowSkeleton(),
    );
  }
}

class _InviteRowSkeleton extends StatelessWidget {
  const _InviteRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: VectorColors.surfaceWhite,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: VectorColors.hairline),
      ),
      child: SkeletonShimmer(
        child: Row(
          children: const [
            SkeletonBox.circle(size: 46),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 140, height: 14),
                  SizedBox(height: 8),
                  SkeletonBox(width: 200, height: 11),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({
    required this.invitation,
    required this.expanded,
    required this.responding,
    required this.onTap,
    required this.onAccept,
    required this.onDecline,
    required this.onOpenHackathon,
  });

  final Invitation invitation;
  final bool expanded;
  final bool responding;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onOpenHackathon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(21),
        onTap: expanded ? null : onTap,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: const Cubic(0.22, 1, 0.36, 1),
          alignment: Alignment.topCenter,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(expanded ? 17 : 15),
            decoration: BoxDecoration(
              color: VectorColors.surfaceWhite,
              borderRadius: BorderRadius.circular(21),
              border: Border.all(color: VectorColors.hairline),
            ),
            child: expanded ? _buildExpanded() : _buildCollapsed(),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsed() {
    return Row(
      children: [
        _TeamTile(initial: invitation.teamInitial, size: 46),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                invitation.teamName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: VectorText.titleMedium.copyWith(
                  fontSize: 15,
                  color: VectorColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${invitation.hackathonName} · '
                '${invitation.senderName.split(' ').first} · '
                '${_expiryLabel(invitation.expiresAt)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: VectorText.bodyMedium.copyWith(
                  fontSize: 11.5,
                  color: VectorColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: VectorColors.textMuted),
      ],
    );
  }

  Widget _buildExpanded() {
    final bool urgent = _isUrgent(invitation.expiresAt);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TeamTile(initial: invitation.teamInitial, size: 46),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invitation.teamName,
                    style: VectorText.titleLarge.copyWith(
                      fontSize: 18,
                      color: VectorColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'invited by ${invitation.senderName}, lead',
                    style: VectorText.bodyMedium.copyWith(
                      fontSize: 11.5,
                      color: VectorColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            _ExpiryChip(
              urgent: urgent,
              label: _expiryLabel(invitation.expiresAt),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: onOpenHackathon,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: VectorColors.surfaceLavender,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                const CustomPaint(
                  size: Size(9, 8),
                  painter: _SmallTrianglePainter(color: VectorColors.apricot),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invitation.hackathonName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: VectorText.bodyMedium.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: VectorColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${invitation.hackathonHero} · '
                        '${invitation.hackathonDates ?? 'Dates TBA'} · '
                        '${invitation.hackathonCity}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: VectorText.bodyMedium.copyWith(
                          fontSize: 11,
                          color: VectorColors.textSecondaryPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: VectorColors.textSecondaryPurple,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: VectorColors.backgroundLight,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: VectorColors.hairline),
          ),
          child: Text(
            '"${invitation.message}"',
            style: VectorText.bodyMedium.copyWith(
              fontSize: 13,
              height: 1.5,
              color: VectorColors.textNeutral,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 46,
                child: OutlinedButton(
                  onPressed: responding ? null : onDecline,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: VectorColors.hairline),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: LoadingButtonContent(
                    loading: responding,
                    spinnerColor: VectorColors.textSecondary,
                    spinnerSize: 16,
                    child: Text(
                      'Decline',
                      style: VectorText.labelLarge.copyWith(
                        color: VectorColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: _AcceptButton(onTap: onAccept, loading: responding),
            ),
          ],
        ),
      ],
    );
  }
}

/// The Accept CTA: apricot gradient, a soft shine sweep and a subtle
/// breathe (scale 1.0 -> 1.015) on the same ~2.6s period — fully still
/// when [MediaQuery.disableAnimationsOf] is true.
class _AcceptButton extends StatefulWidget {
  const _AcceptButton({required this.onTap, required this.loading});

  final VoidCallback onTap;
  final bool loading;

  @override
  State<_AcceptButton> createState() => _AcceptButtonState();
}

class _AcceptButtonState extends State<_AcceptButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: widget.loading ? null : widget.onTap,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final double t = _controller.value;
              final double scale =
                  1.0 + 0.015 * (0.5 - 0.5 * math.cos(2 * math.pi * t));
              return Transform.scale(
                scale: scale,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                VectorColors.buttonStart,
                                VectorColors.buttonEnd,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: FractionalTranslation(
                          translation: Offset(2.6 * t - 1.3, 0),
                          child: const _ShineBand(),
                        ),
                      ),
                      Center(
                        child: widget.loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: VectorColors.textNeutral,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CustomPaint(
                                    size: Size(10, 9),
                                    painter: _SmallTrianglePainter(
                                      color: VectorColors.textNeutral,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Accept',
                                    style: VectorText.labelLarge.copyWith(
                                      color: VectorColors.textNeutral,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ShineBand extends StatelessWidget {
  const _ShineBand();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0),
          ],
          stops: const [0.42, 0.5, 0.58],
        ),
      ),
    );
  }
}

class _SentRequestCard extends StatelessWidget {
  const _SentRequestCard({
    required this.request,
    required this.withdrawing,
    required this.onWithdraw,
    required this.onMeetTeam,
  });

  final SentRequest request;
  final bool withdrawing;
  final VoidCallback onWithdraw;
  final VoidCallback onMeetTeam;

  @override
  Widget build(BuildContext context) {
    final bool declined = request.status == 'declined';
    final bool accepted = request.status == 'accepted';
    final Color borderColor = accepted
        ? VectorColors.apricot
        : VectorColors.hairline;

    return Opacity(
      opacity: declined ? 0.75 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
        decoration: BoxDecoration(
          color: VectorColors.surfaceWhite,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TeamTile(initial: request.teamInitial, size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.teamName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: VectorText.titleMedium.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: VectorColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    request.hackathonName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: VectorText.bodyMedium.copyWith(
                      fontSize: 11.5,
                      color: VectorColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sent ${_relativeTime(request.createdAt)}',
                    style: VectorText.bodyMedium.copyWith(
                      fontSize: 11,
                      color: VectorColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(status: request.status),
                const SizedBox(height: 6),
                if (request.status == 'pending')
                  GestureDetector(
                    onTap: withdrawing ? null : onWithdraw,
                    child: Text(
                      withdrawing ? '···' : 'Withdraw',
                      style: VectorText.labelMedium.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: VectorColors.linkWarm,
                      ),
                    ),
                  ),
                if (accepted)
                  GestureDetector(
                    onTap: onMeetTeam,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Meet the team',
                          style: VectorText.labelMedium.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: VectorColors.purpleBrand,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 14,
                          color: VectorColors.purpleBrand,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color foreground;
    final String label;
    switch (status) {
      case 'accepted':
        background = VectorColors.apricot;
        foreground = VectorColors.textNeutral;
        label = 'Accepted';
      case 'declined':
        background = VectorColors.error.withValues(alpha: 0.14);
        foreground = VectorColors.error;
        label = 'Declined';
      default:
        background = VectorColors.surfaceLavender;
        foreground = VectorColors.textSecondaryPurple;
        label = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: VectorText.labelMedium.copyWith(fontSize: 11, color: foreground),
      ),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({super.key, required this.caption});

  final String caption;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: CustomPaint(
                painter: _DashedSquarePainter(color: VectorColors.inputBorder),
                child: const Center(
                  child: CustomPaint(
                    size: Size(16, 14),
                    painter: _SmallTrianglePainter(
                      color: VectorColors.surfaceLavender,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              caption,
              textAlign: TextAlign.center,
              style: VectorText.bodyMedium.copyWith(
                color: VectorColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedSquarePainter extends CustomPainter {
  const _DashedSquarePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
      const Radius.circular(13),
    );
    final path = Path()..addRRect(rrect);
    canvas.drawPath(_dashPath(path, dashLength: 4, gapLength: 3), paint);
  }

  @override
  bool shouldRepaint(covariant _DashedSquarePainter oldDelegate) =>
      oldDelegate.color != color;

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

class _SmallTrianglePainter extends CustomPainter {
  const _SmallTrianglePainter({required this.color});

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
  bool shouldRepaint(covariant _SmallTrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}

bool _isUrgent(DateTime expiresAt) =>
    expiresAt.difference(DateTime.now()).inHours < 48;

String _expiryLabel(DateTime expiresAt) {
  final diff = expiresAt.difference(DateTime.now());
  final hours = diff.inHours;
  if (hours < 48) return '${hours < 0 ? 0 : hours}h';
  return '${diff.inDays}d';
}

String _relativeTime(DateTime createdAt) {
  final diff = DateTime.now().difference(createdAt);
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes < 1 ? 1 : diff.inMinutes}m ago';
  }
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'yesterday';
  return '${diff.inDays}d ago';
}
