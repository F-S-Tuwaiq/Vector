import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/hackathon_repository.dart';
import '../data/mock_hackathons.dart';
import '../data/profile_repository.dart';
import '../data/skill_catalog.dart';
import '../models/member.dart';
import '../services/supabase_service.dart';
import '../theme/profile_theme.dart';
import '../theme/vector_colors.dart';
import '../theme/vector_text.dart';
import '../widgets/confirm_action_dialog.dart';
import '../widgets/profile_widgets.dart';
import '../widgets/profile_edit_dialog.dart';
import '../widgets/evidence_preview_dialog.dart';
import '../widgets/send_invite_sheet.dart';
import '../widgets/vector_header.dart';
import 'settings_screen.dart';
import 'teams_screen.dart';

typedef EvidencePicker = Future<XFile?> Function();

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.name,
    this.member,
    this.participation,
    this.onBack,
    this.onDiscover,
    this.repository = const ProfileRepository(),
    this.maxEvidenceBytes = 10 * 1024 * 1024,
    this.pickEvidence,
  });
  final String? name;

  final Member? member;
  final ProfileParticipation? participation;
  final VoidCallback? onBack, onDiscover;
  final ProfileRepository repository;
  final int maxEvidenceBytes;
  final EvidencePicker? pickEvidence;
  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> _profile = {};
  List<Map<String, dynamic>> _skills = [], _certificates = [];
  List<ProfileParticipation> _participations = [];
  bool _loading = true,
      _busy = false,
      _teamsLoading = true,
      _undoPending = false;
  bool _editingSkills = false;
  String? _error, _teamsError;
  int? _activeSkill;
  String? _skillMessage;
  bool _skillFailed = false;
  bool get _own => widget.name == null && widget.member == null;
  bool get _editable =>
      _own && !_loading && !_busy && !_undoPending && _error == null;

  @override
  void initState() {
    super.initState();
    if (_own) {
      _load();
      _loadTeams();
    } else {
      _loading = false;
      _teamsLoading = false;
      _profile = {
        'full_name': widget.member?.name ?? widget.name,
        'headline': widget.member?.role,
      };
      _skills = [
        for (final skill in widget.member?.skills ?? <String>[])
          {'skill': skill},
      ];
      final member = widget.member;
      if (member != null) {
        _participations = widget.participation != null
            ? [widget.participation!]
            : [
                for (final team in mockTeamsForMember(
                  member.initials,
                  member.name,
                ))
                  ProfileParticipation(
                    id: team.id,
                    team: team,
                    event: mockHackathons.firstWhere(
                      (h) => h.id == team.hackathonId,
                      orElse: () => mockHackathons.first,
                    ),
                    status:
                        team.membersInfo
                            .firstWhere(
                              (m) =>
                                  m.initials == member.initials &&
                                  m.name == member.name,
                              orElse: () => member,
                            )
                            .lead
                        ? MembershipStatus.leader
                        : MembershipStatus.member,
                  ),
              ];
      }
    }
  }

  Future<void> _load() async {
    try {
      final data = await widget.repository.load();
      if (!mounted) return;
      setState(() {
        _profile = Map<String, dynamic>.from(data['profile']);
        _skills = List<Map<String, dynamic>>.from(data['skills']);
        _certificates = List<Map<String, dynamic>>.from(data['certificates']);
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = SupabaseService.isLoggedIn
              ? 'Could not load your profile. Please try again.'
              : 'Sign in to see your name, skills and certificates.';
        });
      }
    }
  }

  Future<void> _loadTeams() async {
    try {
      final records = await widget.repository.participations();
      if (!mounted) return;
      final seen = <String>{};
      setState(() {
        _participations = records
            .where(
              (r) =>
                  seen.add(r.id) &&
                  !(r.completed && r.status == MembershipStatus.requested),
            )
            .toList();
        _teamsError = null;
        _teamsLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _teamsLoading = false;
          _teamsError =
              'Team and participation information is currently unavailable.';
        });
      }
    }
  }

  Future<void> _refresh() async {
    if (!_busy && !_undoPending && _own) {
      await Future.wait([_load(), _loadTeams()]);
    }
  }

  void refreshOnFocus() {
    if (!_teamsLoading && _own) _loadTeams();
  }

  Future<bool> _mutate(
    Future<void> Function() action, {
    int? skillId,
    String? working,
    String? success,
  }) async {
    if (_busy) return false;
    setState(() {
      _busy = true;
      _activeSkill = skillId;
      _skillMessage = working;
      _skillFailed = false;
    });
    try {
      await action();
      await _load();
      if (!mounted) return true;
      setState(() => _skillMessage = success);
      if (success != null) _message(success);
      return true;
    } catch (error) {
      if (mounted) {
        final text = error is ArgumentError
            ? error.message.toString()
            : 'Could not save this change. Please try again.';
        setState(() {
          _skillMessage = text;
          _skillFailed = true;
        });
        _message(text);
      }
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _addSkill() async {
    if (_skills.length >= 6) {
      _message('You can choose up to 6 skills, just like signup.');
      return;
    }
    final skill = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: VectorColors.background,
      builder: (_) => _AddSkillSheet(
        existing: _skills.map((s) => s['skill'].toString()).toList(),
      ),
    );
    if (skill != null && mounted) {
      await _mutate(
        () => widget.repository.addSkill(skill),
        success: 'Skill added.',
      );
    }
  }

  Future<void> _attach(Map<String, dynamic> skill) async {
    try {
      final file =
          await (widget.pickEvidence?.call() ??
              openFile(
                acceptedTypeGroups: const [
                  XTypeGroup(
                    label: 'Evidence',
                    extensions: ['pdf', 'png', 'jpg', 'jpeg'],
                    uniformTypeIdentifiers: [
                      'com.adobe.pdf',
                      'public.png',
                      'public.jpeg',
                    ],
                  ),
                ],
                confirmButtonText: 'Attach',
              ));
      if (file == null || !mounted) return;
      final extension = file.name.split('.').last.toLowerCase();
      if (!['pdf', 'png', 'jpg', 'jpeg'].contains(extension)) {
        _message('Choose a PDF, PNG or JPG file.');
        return;
      }
      if (await file.length() > widget.maxEvidenceBytes) {
        if (mounted) {
          _message(
            'Choose a file smaller than ${widget.maxEvidenceBytes ~/ (1024 * 1024)} MB.',
          );
        }
        return;
      }
      if (!mounted) return;
      await _mutate(
        () => widget.repository.attach(
          skill['id'] as int,
          file,
          widget.maxEvidenceBytes,
        ),
        skillId: skill['id'] as int,
        working: 'Uploading ${file.name}…',
        success: 'Evidence uploaded.',
      );
    } catch (_) {
      if (mounted) _message('Could not open the evidence picker.');
    }
  }

  List<Map<String, dynamic>> _attachments(Map<String, dynamic> skill) => _own
      ? _certificates.where((c) => c['skill_id'] == skill['id']).toList()
      : [];

  Future<void> _manage(
    Map<String, dynamic> skill,
    AttachmentAction action,
  ) async {
    final attachments = _attachments(skill)
        .map((a) => Map<String, dynamic>.from(a))
        .toList();
    Map<String, dynamic>? attachment;
    if (action == AttachmentAction.removeAttachment) {
      if (attachments.length == 1) {
        attachment = attachments.single;
      } else {
        attachment = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (context) => SimpleDialog(
            title: const Text('Choose attachment to remove'),
            children: attachments
                .map(
                  (a) => SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, a),
                    child: Text(a['file_name'].toString()),
                  ),
                )
                .toList(),
          ),
        );
      }
      if (attachment == null || !mounted) return;
    }
    final removedAttachment = attachment;
    final removedSkill = Map<String, dynamic>.from(skill);
    final success = await _mutate(
      () => action == AttachmentAction.removeSkill
          ? widget.repository.removeSkill(removedSkill, attachments)
          : widget.repository.removeAttachment(removedAttachment!),
      skillId: skill['id'] as int,
      working: 'Removing…',
    );
    if (!success || !mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    setState(() => _undoPending = true);
    final notice = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          action == AttachmentAction.removeSkill
              ? 'Skill removed.'
              : 'Attachment removed.',
        ),
        duration: const Duration(seconds: 6),
        persist: false,
        showCloseIcon: true,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            if (!mounted) return;
            await _mutate(
              () => action == AttachmentAction.removeSkill
                  ? widget.repository.restoreSkill(removedSkill, attachments)
                  : widget.repository.restoreAttachment(
                      removedSkill,
                      removedAttachment!,
                    ),
              skillId: skill['id'] as int,
              working: 'Restoring…',
              success: 'Restored.',
            );
          },
        ),
      ),
    );
    await notice.closed;
    if (mounted) setState(() => _undoPending = false);
  }

  Future<void> _openAttachment(Map<String, dynamic> attachment) async {
    await showDialog<void>(
      context: context,
      builder: (_) => Theme(
        data: ProfileTheme.data,
        child: EvidencePreviewDialog(
          filename: attachment['file_name'].toString(),
          loadUrl: () =>
              widget.repository.attachmentUrl(attachment['id'] as int),
        ),
      ),
    );
  }

  Future<void> _social(String value, String host) async {
    final uri = Uri.tryParse(
      value.startsWith('https://') ? value : 'https://$value',
    );
    if (uri == null || !(uri.host == host || uri.host.endsWith('.$host'))) {
      _message('This profile link is not a valid $host link.');
      return;
    }
    try {
      if (!await launchUrl(uri)) throw StateError('Cannot open link');
    } catch (_) {
      if (mounted) _message('Could not open this link.');
    }
  }

  Future<void> _editIdentity() async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Theme(
        data: ProfileTheme.data,
        child: ProfileEditDialog(
          title: 'Your details',
          fields: {
            'GitHub': (_profile['github'] ?? '').toString(),
            'Name':
                (_profile['full_name'] ??
                        SupabaseService
                            .currentUser
                            ?.userMetadata?['full_name'] ??
                        '')
                    .toString(),
            'LinkedIn': (_profile['linkedin'] ?? '').toString(),
          },
          onSave: (values) => widget.repository.saveIdentity(
            name: values['Name']!,
            github: values['GitHub']!,
            linkedin: values['LinkedIn']!,
          ),
        ),
      ),
    );
    if (saved == true && mounted) {
      await _load();
    }
  }

  String get _aboutText =>
      (_profile['about'] ??
              (_own
                  ? (SupabaseService.currentUser?.userMetadata?['about'])
                  : null) ??
              '')
          .toString();

  Future<void> _editAbout() async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Theme(
        data: ProfileTheme.data,
        child: ProfileEditDialog(
          title: 'About you',
          multiline: true,
          fields: {'About': _aboutText},
          onSave: (values) => widget.repository.saveAbout(values['About']!),
        ),
      ),
    );
    if (saved == true && mounted) {
      await _load();
    }
  }

  Widget _pencil(String label, VoidCallback onPressed) => IconButton(
    tooltip: label,
    onPressed: _editable ? onPressed : null,
    icon: const Icon(Icons.edit_outlined, size: 19),
    color: VectorColors.textSecondaryPurple,
  );

  Future<void> _settings() async {
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, animation, secondaryAnimation) =>
            SettingsScreen(profile: _profile),
        transitionsBuilder: (_, animation, secondaryAnimation, child) =>
            SlideTransition(
              position: Tween(begin: const Offset(1, 0), end: Offset.zero)
                  .animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
      ),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final name =
        (_profile['full_name'] ??
                (_own
                    ? (SupabaseService.currentUser?.userMetadata?['full_name'])
                    : null) ??
                'Your profile')
            .toString();
    final firstName = name.trim().split(RegExp(r'\s+')).first;
    final metadata = _own ? SupabaseService.currentUser?.userMetadata : null;
    String field(String key) =>
        (_profile[key] ?? metadata?[key] ?? '').toString().trim();
    final current = _participations.where((p) => !p.completed).toList();
    final previous = _participations.where((p) => p.completed).toList();
    return Theme(
      data: ProfileTheme.data,
      child: Scaffold(
        backgroundColor: VectorColors.background,
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            key: const Key('profile-scroll'),
            physics: const AlwaysScrollableScrollPhysics(),
            child: CustomPaint(
              painter: const ProfileTriangles(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProfileHeader(
                    onBack: _own
                        ? null
                        : () => Navigator.of(context).maybePop(),
                    onSettings: _own
                        ? () {
                            if (!_busy && !_undoPending) _settings();
                          }
                        : null,
                  ),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          16,
                          24,
                          48 + MediaQuery.paddingOf(context).bottom,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    name,
                                    textAlign: TextAlign.center,
                                    style: ProfileTheme.heading.copyWith(
                                      fontSize: 36,
                                    ),
                                  ),
                                ),
                                if (_own)
                                  _pencil('Edit name and links', _editIdentity),
                              ],
                            ),
                            if (field('headline').isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                field('headline'),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            if (field('availability').isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Center(
                                child: ProfileStatusPill(
                                  label: field('availability'),
                                ),
                              ),
                            ],
                            if (field('github').isNotEmpty ||
                                field('linkedin').isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 12,
                                children: [
                                  if (field('github').isNotEmpty)
                                    TextButton(
                                      onPressed: () => _social(
                                        field('github'),
                                        'github.com',
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('GitHub'),
                                          SizedBox(width: 5),
                                          Icon(Icons.north_east, size: 14),
                                        ],
                                      ),
                                    ),
                                  if (field('linkedin').isNotEmpty)
                                    TextButton(
                                      onPressed: () => _social(
                                        field('linkedin'),
                                        'linkedin.com',
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('LinkedIn'),
                                          SizedBox(width: 5),
                                          Icon(Icons.north_east, size: 14),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                            if (!_own && widget.member != null) ...[
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: () => showSendInviteSheet(
                                    context,
                                    widget.member!,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: VectorColors.purpleBrand,
                                    foregroundColor: VectorColors.textOnPurple,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                  ),
                                  icon: const Icon(Icons.send_rounded),
                                  label: Text(
                                    'Send invite',
                                    style: VectorText.labelLarge.copyWith(
                                      color: VectorColors.textOnPurple,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            if (_loading)
                              const Padding(
                                padding: EdgeInsets.all(24),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            if (_error != null)
                              ProfileSurface(
                                child: Column(
                                  children: [
                                    Text(_error!),
                                    TextButton(
                                      onPressed: _load,
                                      child: const Text('Try again'),
                                    ),
                                  ],
                                ),
                              ),
                            ProfileSection(
                              title: 'About',
                              action: _own
                                  ? _pencil('Edit About', _editAbout)
                                  : null,
                              child: Text(
                                _aboutText.trim().isEmpty
                                    ? (_own
                                          ? 'Tell future teammates a little about yourself.'
                                          : 'No public bio yet.')
                                    : _aboutText,
                              ),
                            ),
                            ProfileSection(
                              title: 'Skills & evidence',
                              action: _own
                                  ? _pencil(
                                      _editingSkills
                                          ? 'Done editing skills'
                                          : 'Edit skills & evidence',
                                      () => setState(
                                        () => _editingSkills = !_editingSkills,
                                      ),
                                    )
                                  : null,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (_skills.isEmpty &&
                                      !_loading &&
                                      _error == null)
                                    Text(
                                      _own
                                          ? 'Add the skills you bring to a team.'
                                          : 'No public skills to display.',
                                    ),
                                  ..._skills.map(
                                    (skill) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: ProfileSkillRow(
                                        key: ValueKey(
                                          'skill-${skill['id'] ?? skill['skill']}',
                                        ),
                                        name: skill['skill'].toString(),
                                        attachments: _attachments(skill),
                                        editable:
                                            _own &&
                                            _editingSkills &&
                                            _error == null,
                                        busy: _busy,
                                        locked: _undoPending,
                                        message: _activeSkill == skill['id']
                                            ? _skillMessage
                                            : null,
                                        failed: _skillFailed,
                                        onAttach: () => _attach(skill),
                                        onManage: (action) =>
                                            _manage(skill, action),
                                        onOpen: _openAttachment,
                                      ),
                                    ),
                                  ),
                                  if (_own && _editingSkills) ...[
                                    const SizedBox(height: 4),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: TextButton.icon(
                                        onPressed: _editable ? _addSkill : null,
                                        icon: const Icon(Icons.add, size: 18),
                                        label: const Text('Add skill'),
                                      ),
                                    ),
                                    Text(
                                      'PDF, PNG or JPG · up to ${widget.maxEvidenceBytes ~/ (1024 * 1024)} MB per file',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: VectorColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            ProfileSection(
                              title: _own ? 'Your teams' : "$firstName's teams",
                              subtitle: _own
                                  ? (current.any((p) => p.isPreview)
                                        ? 'The people you build with. · Sample teams'
                                        : 'The people you build with.')
                                  : 'Teams $firstName is part of.',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (_teamsLoading)
                                    const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  else if (_teamsError != null)
                                    ProfileSurface(child: Text(_teamsError!))
                                  else if (current.isEmpty)
                                    ProfileSurface(
                                      child: Text(
                                        _own
                                            ? 'You haven’t joined a team yet.'
                                            : '$firstName hasn’t joined a team yet.',
                                      ),
                                    )
                                  else
                                    ...current.map(
                                      (record) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: ProfileSurface(
                                          accent:
                                              record.status ==
                                                  MembershipStatus.requested
                                              ? VectorColors.apricot
                                              : VectorColors.purpleBrand,
                                          child: ProfileTeamRow(
                                            record: record,
                                            onTap: () => Navigator.of(context).push(
                                              MaterialPageRoute<void>(
                                                builder: (_) => ProfileTeamDetails(
                                                  record: record,
                                                  onDeleted:
                                                      _own &&
                                                          widget.repository
                                                              is DemoProfileRepository &&
                                                          record.status ==
                                                              MembershipStatus
                                                                  .leader
                                                      ? _loadTeams
                                                      : null,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (_own &&
                                      !_teamsLoading &&
                                      current.isEmpty &&
                                      widget.onDiscover != null) ...[
                                    const SizedBox(height: 14),
                                    ProfileAction(
                                      label: 'Discover teams',
                                      onPressed: widget.onDiscover,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            ProfileSection(
                              title: 'Previous participation',
                              child: ProfileSurface(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (!_own)
                                      const Text(
                                        'No public participation information available.',
                                      )
                                    else if (_teamsLoading)
                                      const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    else if (_teamsError != null)
                                      const Text(
                                        'Participation history is currently unavailable.',
                                      )
                                    else if (previous.isEmpty)
                                      const Text(
                                        'Your previous hackathons will appear here.',
                                      )
                                    else ...[
                                      for (
                                        int i = 0;
                                        i < previous.length;
                                        i++
                                      ) ...[
                                        if (i > 0) const Divider(),
                                        PreviousParticipationRow(
                                          record: previous[i],
                                        ),
                                      ],
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileTeamDetails extends StatefulWidget {
  const ProfileTeamDetails({super.key, required this.record, this.onDeleted});
  final ProfileParticipation record;

  final VoidCallback? onDeleted;

  @override
  State<ProfileTeamDetails> createState() => _ProfileTeamDetailsState();
}

class _ProfileTeamDetailsState extends State<ProfileTeamDetails> {
  bool _deleting = false;

  Future<void> _delete() async {
    if (_deleting) return;
    final confirmed = await showConfirmActionDialog(
      context,
      title: 'Delete team?',
      message:
          'This removes "${widget.record.team.name}" for anyone who can '
          "see it. This can't be undone.",
      confirmLabel: 'Delete',
    );
    if (!mounted || !confirmed) return;
    setState(() => _deleting = true);
    final success = await HackathonRepository().deleteTeam(
      widget.record.team.id,
    );
    if (!mounted) return;
    if (success) {
      widget.onDeleted?.call();
      Navigator.of(context).pop();
    } else {
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete the team. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final statusLabel = switch (record.status) {
      MembershipStatus.member => 'Member',
      MembershipStatus.requested => 'Requested',
      MembershipStatus.leader => 'Leader',
    };
    return Theme(
      data: ProfileTheme.data,
      child: Scaffold(
        backgroundColor: VectorColors.background,
        body: Column(
          children: [
            VectorHeader.slim(
              title: record.team.name,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            record.event.name,
                            style: ProfileTheme.heading,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ProfileStatusPill(
                          label: statusLabel,
                          requested:
                              record.status == MembershipStatus.requested,
                          leader: record.status == MembershipStatus.leader,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${record.team.members} of ${record.team.maxMembers} members',
                      style: const TextStyle(color: VectorColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Members',
                      style: VectorText.titleMedium.copyWith(
                        color: VectorColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...record.team.membersInfo.map(
                      (member) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ProfileSurface(
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
                                  member.initials,
                                  style: VectorText.titleMedium.copyWith(
                                    color: VectorColors.purpleBrand,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member.name,
                                      style: VectorText.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: VectorColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      member.role,
                                      style: const TextStyle(
                                        color: VectorColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (member.lead) ...[
                                const SizedBox(width: 8),
                                const ProfileStatusPill(
                                  label: 'Lead',
                                  leader: true,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ProfileAction(
                      label: 'View event teams',
                      onPressed: () =>
                          TeamsScreen.open(context, hackathon: record.event),
                    ),
                    if (widget.onDeleted != null) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton.icon(
                          onPressed: _deleting ? null : _delete,
                          icon: _deleting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: VectorColors.error,
                                  ),
                                )
                              : const Icon(
                                  Icons.delete_outline,
                                  color: VectorColors.error,
                                ),
                          label: Text(
                            _deleting ? 'Deleting…' : 'Delete team',
                            style: const TextStyle(color: VectorColors.error),
                          ),
                        ),
                      ),
                    ],
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

Widget profileCard(Widget child) => Material(
  color: VectorColors.surfaceWhite,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(21),
    side: BorderSide(color: VectorColors.hairline),
  ),
  clipBehavior: Clip.antiAlias,
  child: SizedBox(
    width: double.infinity,
    child: Padding(padding: const EdgeInsets.all(16), child: child),
  ),
);

class ProfileDetailPage extends StatelessWidget {
  const ProfileDetailPage({
    super.key,
    required this.title,
    required this.children,
  });
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Theme(
    data: ProfileTheme.data,
    child: Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: VectorColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(padding: const EdgeInsets.all(24), children: children),
    ),
  );
}

class _AddSkillSheet extends StatefulWidget {
  const _AddSkillSheet({required this.existing});
  final List<String> existing;
  @override
  State<_AddSkillSheet> createState() => _AddSkillSheetState();
}

class _AddSkillSheetState extends State<_AddSkillSheet> {
  final _custom = TextEditingController();
  String? _error;
  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  void _choose(String value) {
    final clean = value.trim();
    if (clean.isEmpty) {
      setState(() => _error = 'Enter a skill.');
      return;
    }
    if (widget.existing.any((s) => s.toLowerCase() == clean.toLowerCase())) {
      setState(() => _error = 'This skill is already on your profile.');
      return;
    }
    Navigator.pop(context, clean);
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .6,
        child: ListView(
          children: [
            const Text('Add a skill', style: ProfileTheme.heading),
            const SizedBox(height: 8),
            const Text('Choose a skill or add your own. Up to 6 skills.'),
            ...skillCatalog.entries.map(
              (category) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 8),
                    child: Text(category.key, style: VectorText.titleMedium),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: category.value
                        .where((s) => !widget.existing.contains(s))
                        .map(
                          (s) => ActionChip(
                            label: Text(s),
                            onPressed: () => _choose(s),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _custom,
              maxLength: 60,
              decoration: InputDecoration(
                labelText: 'Custom skill',
                errorText: _error,
              ),
              onSubmitted: _choose,
            ),
            const SizedBox(height: 12),
            ProfileAction(
              label: 'Add skill',
              onPressed: () => _choose(_custom.text),
            ),
          ],
        ),
      ),
    ),
  );
}
