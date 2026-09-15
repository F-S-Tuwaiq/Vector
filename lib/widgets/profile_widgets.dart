import 'package:flutter/material.dart';

import '../data/profile_repository.dart';
import '../theme/profile_theme.dart';
import '../theme/vector_colors.dart';
import 'login_style_header.dart';

class ProfileSurface extends StatelessWidget {
  const ProfileSurface({
    super.key,
    required this.child,
    this.accent = VectorColors.apricot,
  });
  final Widget child;
  final Color accent;
  @override
  Widget build(BuildContext context) => Material(
    color: VectorColors.surfaceWhite,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(
        color: VectorColors.purpleDeep.withValues(alpha: .13),
        width: .8,
      ),
    ),
    clipBehavior: Clip.antiAlias,
    child: Stack(
      children: [
        Positioned(
          left: 0,
          top: 18,
          bottom: 18,
          width: 3,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.all(18), child: child),
      ],
    ),
  );
}

class ProfileAction extends StatelessWidget {
  const ProfileAction({super.key, required this.label, this.onPressed});
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$label  '),
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(Icons.play_arrow_rounded, size: 18),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

enum AttachmentAction { removeAttachment, removeSkill }

class AttachmentMenu extends StatelessWidget {
  const AttachmentMenu({
    super.key,
    required this.skillName,
    required this.hasAttachment,
    required this.onSelected,
    this.enabled = true,
  });
  final String skillName;
  final bool hasAttachment, enabled;
  final ValueChanged<AttachmentAction> onSelected;
  @override
  Widget build(BuildContext context) {
    final label = 'Manage $skillName';
    if (!hasAttachment) {
      return IconButton(
        tooltip: label,
        onPressed: enabled
            ? () => onSelected(AttachmentAction.removeSkill)
            : null,
        icon: const Icon(Icons.close, size: 18),
      );
    }
    return PopupMenuButton<AttachmentAction>(
      tooltip: label,
      enabled: enabled,
      icon: const Icon(Icons.close, size: 18),
      onSelected: onSelected,
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: AttachmentAction.removeAttachment,
          child: Text('Remove attachment'),
        ),
        PopupMenuItem(
          value: AttachmentAction.removeSkill,
          child: Text('Remove skill'),
        ),
      ],
    );
  }
}

class ProfileSkillRow extends StatelessWidget {
  const ProfileSkillRow({
    super.key,
    required this.name,
    required this.attachments,
    this.editable = false,
    this.busy = false,
    this.locked = false,
    this.message,
    this.failed = false,
    this.onAttach,
    this.onManage,
    required this.onOpen,
  });
  final String name;
  final List<Map<String, dynamic>> attachments;
  final bool editable, busy, failed, locked;
  final String? message;
  final VoidCallback? onAttach;
  final ValueChanged<AttachmentAction>? onManage;
  final ValueChanged<Map<String, dynamic>> onOpen;
  @override
  Widget build(BuildContext context) => ProfileSurface(
    accent: attachments.isEmpty
        ? VectorColors.apricot
        : VectorColors.purpleBrand,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(name, style: Theme.of(context).textTheme.titleMedium),
            ),
            if (editable)
              AttachmentMenu(
                skillName: name,
                hasAttachment: attachments.isNotEmpty,
                enabled: !busy && !locked,
                onSelected: onManage!,
              ),
          ],
        ),
        ...attachments.map((attachment) {
          final filename = attachment['file_name'].toString();
          final extension = filename.split('.').last.toUpperCase();
          return TextButton(
            onPressed: busy ? null : () => onOpen(attachment),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.centerLeft,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  extension == 'PDF'
                      ? Icons.picture_as_pdf_outlined
                      : Icons.image_outlined,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$filename · $extension',
                    softWrap: true,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        if (editable && attachments.length < 3)
          TextButton.icon(
            onPressed: busy || locked ? null : onAttach,
            icon: const Icon(Icons.attach_file, size: 17),
            label: const Text('Attach evidence'),
          ),
        if (busy)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(),
          ),
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Semantics(
              liveRegion: true,
              child: Text(
                message!,
                style: TextStyle(
                  color: failed
                      ? VectorColors.error
                      : VectorColors.textSecondary,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class ProfileStatusPill extends StatelessWidget {
  const ProfileStatusPill({
    super.key,
    required this.label,
    this.requested = false,
    this.leader = false,
  });
  final String label;
  final bool requested, leader;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: requested
          ? VectorColors.apricot.withValues(alpha: .35)
          : VectorColors.apricot.withValues(alpha: .16),
      borderRadius: BorderRadius.circular(20),
      border: leader
          ? Border.all(color: VectorColors.textSecondaryPurple, width: .7)
          : null,
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        color: VectorColors.purpleDeep,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class ProfileTeamRow extends StatelessWidget {
  const ProfileTeamRow({super.key, required this.record, required this.onTap});
  final ProfileParticipation record;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final status = switch (record.status) {
      MembershipStatus.member => 'Member',
      MembershipStatus.requested => 'Requested',
      MembershipStatus.leader => 'Leader',
    };
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.groups_outlined,
                  size: 22,
                  color: VectorColors.purpleBrand,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    record.team.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${record.event.name} · ${record.team.members} members',
              style: const TextStyle(color: VectorColors.textSecondary),
            ),
            const SizedBox(height: 12),
            ProfileStatusPill(
              label: status,
              requested: record.status == MembershipStatus.requested,
              leader: record.status == MembershipStatus.leader,
            ),
          ],
        ),
      ),
    );
  }
}

class PreviousParticipationRow extends StatelessWidget {
  const PreviousParticipationRow({super.key, required this.record});
  final ProfileParticipation record;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(record.event.name, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(
          [
            record.team.name,
            if (record.role?.isNotEmpty == true) record.role!,
          ].join(' · '),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (record.date?.isNotEmpty == true)
              Text(
                record.date!,
                style: const TextStyle(color: VectorColors.textSecondary),
              ),
            if (record.completed) const ProfileStatusPill(label: 'Completed'),
          ],
        ),
      ],
    ),
  );
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, this.onSettings, this.onBack});
  final VoidCallback? onSettings;
  final VoidCallback? onBack;
  @override
  Widget build(BuildContext context) => LoginStyleHeader(
    overlapAvatar: true,
    onSettings: onSettings,
    onBack: onBack,
  );
}

class ProfileTriangles extends CustomPainter {
  const ProfileTriangles();
  @override
  void paint(Canvas canvas, Size size) {
    for (final point in [
      Offset(size.width * .88, 300),
      Offset(size.width * .08, 720),
      Offset(size.width * .9, 1230),
    ]) {
      final triangle = Path()
        ..moveTo(point.dx, point.dy)
        ..lineTo(point.dx + 18, point.dy + 10)
        ..lineTo(point.dx, point.dy + 20)
        ..close();
      canvas.drawPath(
        triangle,
        Paint()..color = VectorColors.purpleDeep.withValues(alpha: .035),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ProfileSection extends StatelessWidget {
  const ProfileSection({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.action,
  });
  final String title;
  final String? subtitle;
  final Widget? action;
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: ProfileTheme.heading)),
            ?action,
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: const TextStyle(color: VectorColors.textSecondary),
          ),
        ],
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}
