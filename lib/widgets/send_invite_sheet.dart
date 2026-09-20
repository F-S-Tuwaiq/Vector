import 'package:flutter/material.dart';

import '../data/hackathon_repository.dart';
import '../models/member.dart';
import '../models/team.dart';
import '../theme/vector_colors.dart';
import '../theme/vector_text.dart';

/// Bottom sheet for inviting [member] to join one of the current user's
/// teams. Same style as [showMemberSheet]: white surface, dialog barrier,
/// 26-radius top corners, drag handle.
Future<void> showSendInviteSheet(BuildContext context, Member member) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: VectorColors.surfaceWhite,
    barrierColor: VectorColors.dialogBarrier,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (context) => _SendInviteSheetContent(member: member),
  );
}

class _SendInviteSheetContent extends StatefulWidget {
  const _SendInviteSheetContent({required this.member});

  final Member member;

  @override
  State<_SendInviteSheetContent> createState() =>
      _SendInviteSheetContentState();
}

class _SendInviteSheetContentState extends State<_SendInviteSheetContent> {
  final _repo = HackathonRepository();
  List<Team>? _teams;
  String? _sendingTeamId;
  Team? _sentTeam;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final teams = await _repo.fetchMyTeams();
    if (!mounted) return;
    setState(() => _teams = teams);
  }

  Future<void> _send(Team team) async {
    if (_sendingTeamId != null) return;
    setState(() => _sendingTeamId = team.id);
    final success = await _repo.sendInvitation(
      team: team,
      member: widget.member,
    );
    if (!mounted) return;
    if (success) {
      setState(() {
        _sendingTeamId = null;
        _sentTeam = team;
      });
    } else {
      setState(() => _sendingTeamId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not send invite. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: VectorColors.surfaceLavender,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (_sentTeam != null)
              _InviteSentContent(member: widget.member, team: _sentTeam!)
            else
              _TeamPicker(
                member: widget.member,
                teams: _teams,
                sendingTeamId: _sendingTeamId,
                onSelect: _send,
              ),
          ],
        ),
      ),
    );
  }
}

class _TeamPicker extends StatelessWidget {
  const _TeamPicker({
    required this.member,
    required this.teams,
    required this.sendingTeamId,
    required this.onSelect,
  });

  final Member member;
  final List<Team>? teams;
  final String? sendingTeamId;
  final ValueChanged<Team> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Send invite',
          style: VectorText.headlineMedium.copyWith(
            color: VectorColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Invite ${member.name} to one of your teams.',
          style: VectorText.bodyMedium.copyWith(
            color: VectorColors.textSecondary,
          ),
        ),
        const SizedBox(height: 18),
        if (teams == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          for (final team in teams!)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TeamRow(
                team: team,
                busy: sendingTeamId == team.id,
                disabled: sendingTeamId != null && sendingTeamId != team.id,
                onTap: () => onSelect(team),
              ),
            ),
      ],
    );
  }
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({
    required this.team,
    required this.busy,
    required this.disabled,
    required this.onTap,
  });

  final Team team;
  final bool busy;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final spotsOpen = team.maxMembers - team.members;
    return Material(
      color: VectorColors.background,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: disabled || busy ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: VectorColors.surfaceLavender,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  team.name.isEmpty ? '?' : team.name[0].toUpperCase(),
                  style: VectorText.titleMedium.copyWith(
                    color: VectorColors.purpleBrand,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name,
                      style: VectorText.titleMedium.copyWith(
                        color: disabled
                            ? VectorColors.textMuted
                            : VectorColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$spotsOpen spots open',
                      style: VectorText.bodyMedium.copyWith(
                        color: VectorColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 22,
                height: 22,
                child: busy
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : Icon(
                        Icons.send_rounded,
                        size: 20,
                        color: disabled
                            ? VectorColors.textMuted
                            : VectorColors.purpleBrand,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InviteSentContent extends StatelessWidget {
  const _InviteSentContent({required this.member, required this.team});

  final Member member;
  final Team team;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: VectorColors.apricot,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.check, color: VectorColors.textNeutral),
        ),
        const SizedBox(height: 20),
        Text(
          'Invitation sent!',
          style: VectorText.headlineMedium.copyWith(
            color: VectorColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '${member.name} has been invited to join ${team.name}.',
          style: VectorText.bodyMedium.copyWith(
            color: VectorColors.textSecondary,
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
              'Done',
              style: VectorText.labelLarge.copyWith(
                color: VectorColors.textOnPurple,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
