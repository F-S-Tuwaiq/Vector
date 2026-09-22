import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector/data/profile_repository.dart';
import 'package:vector/models/hackathon.dart';
import 'package:vector/models/member.dart';
import 'package:vector/models/team.dart';
import 'package:vector/screens/profile_screen.dart';
import 'package:vector/widgets/profile_widgets.dart';
import 'package:vector/widgets/member_sheet.dart';

class TestProfileRepository extends ProfileRepository {
  final skills = <Map<String, dynamic>>[
    {'id': 1, 'skill': 'UI/UX design'},
    {'id': 2, 'skill': 'Flutter'},
  ];
  final certificates = <Map<String, dynamic>>[
    {
      'id': 10,
      'skill_id': 1,
      'file_name': 'design-foundations-certificate.pdf',
      'storage_path': 'private/design.pdf',
    },
  ];
  String about =
      'I turn thoughtful ideas into useful, welcoming experiences. I enjoy building with curious people and learning along the way.';
  String name = 'Fatimah';
  String github = 'github.com/fatimah';
  String linkedin = 'linkedin.com/in/fatimah';
  bool failUpload = false;
  int? uploadedSkill;
  Completer<void>? uploadGate;
  @override
  Future<Map<String, dynamic>> load() async => {
    'profile': {
      'full_name': name,
      'headline': 'Product designer & Flutter developer',
      'availability': 'Open to joining a team',
      'github': github,
      'linkedin': linkedin,
      'about': about,
    },
    'skills': skills.map(Map<String, dynamic>.from).toList(),
    'certificates': certificates.map(Map<String, dynamic>.from).toList(),
  };
  @override
  Future<List<ProfileParticipation>> participations() async => [
    participation('current', 'Pixel Pioneers', false, MembershipStatus.member),
    participation('pending', 'Neural Nexus', false, MembershipStatus.requested),
    participation('past', 'Green Spark', true, MembershipStatus.member),
  ];
  @override
  Future<void> saveIdentity({
    required String name,
    required String github,
    required String linkedin,
  }) async {
    this.name = name;
    this.github = github;
    this.linkedin = linkedin;
  }

  @override
  Future<void> saveAbout(String about) async {
    this.about = about;
  }

  @override
  Future<String> attachmentUrl(int id) async =>
      'https://example.com/evidence.pdf';
  @override
  Future<void> addSkill(String skill) async {
    skills.add({'id': 3, 'skill': skill});
  }

  @override
  Future<void> attach(int skillId, XFile file, int maxBytes) async {
    uploadedSkill = skillId;
    if (uploadGate != null) await uploadGate!.future;
    if (failUpload) throw StateError('Upload failed');
    certificates.add({
      'id': 11,
      'skill_id': skillId,
      'file_name': file.name,
      'storage_path': 'private/new.pdf',
    });
  }

  @override
  Future<void> removeAttachment(Map<String, dynamic> attachment) async {
    certificates.removeWhere((a) => a['id'] == attachment['id']);
  }

  @override
  Future<void> removeSkill(
    Map<String, dynamic> skill,
    List<Map<String, dynamic>> attachments,
  ) async {
    certificates.removeWhere((a) => a['skill_id'] == skill['id']);
    skills.removeWhere((s) => s['id'] == skill['id']);
  }

  @override
  Future<void> restoreAttachment(
    Map<String, dynamic> skill,
    Map<String, dynamic> attachment,
  ) async {
    certificates.add(attachment);
  }

  @override
  Future<void> restoreSkill(
    Map<String, dynamic> skill,
    List<Map<String, dynamic>> attachments,
  ) async {
    skills.add(skill);
    certificates.addAll(attachments);
  }
}

ProfileParticipation participation(
  String id,
  String name,
  bool completed,
  MembershipStatus status,
) => ProfileParticipation(
  id: id,
  team: Team(
    id: id,
    hackathonId: 'event',
    name: name,
    members: 4,
    maxMembers: 5,
  ),
  event: const Hackathon(
    id: 'event',
    name: 'Tuwaiq Hackathon',
    field: 'Design',
    heroValue: '',
    heroCaption: '',
    city: 'Riyadh',
    status: 'open',
  ),
  status: status,
  role: 'UI/UX designer',
  date: '2026',
  completed: completed,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    for (final family in ['Manrope', 'Cormorant Garamond']) {
      final loader = FontLoader(family)
        ..addFont(
          rootBundle.load('assets/fonts/${family.replaceAll(' ', '')}.ttf'),
        );
      await loader.load();
    }
  });
  Future<void> pump(
    WidgetTester tester,
    TestProfileRepository repo, {
    double scale = 1,
    EvidencePicker? picker,
    bool editing = true,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(
          body: RepaintBoundary(
            key: const Key('capture'),
            child: ProfileScreen(
              repository: repo,
              pickEvidence: picker,
              onDiscover: () {},
            ),
          ),
          bottomNavigationBar: const SizedBox(
            height: 72,
            child: Center(child: Text('Navigation')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (editing) {
      await tester.ensureVisible(find.byTooltip('Edit skills & evidence'));
      await tester.tap(find.byTooltip('Edit skills & evidence'));
      await tester.pumpAndSettle();
    }
  }

  Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'one X menu; attachment removal preserves skill; Undo restores association',
    (tester) async {
      final repo = TestProfileRepository();
      await pump(tester, repo);
      final manage = find.byTooltip('Manage UI/UX design');
      await reveal(tester, manage);
      await tester.tap(manage);
      await tester.pumpAndSettle();
      expect(find.text('Remove attachment'), findsOneWidget);
      expect(find.text('Remove skill'), findsOneWidget);
      await tester.tap(find.text('Remove attachment'));
      await tester.pumpAndSettle();
      expect(repo.skills.length, 2);
      expect(repo.certificates, isEmpty);
      expect(find.text('UI/UX design'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(repo.certificates.single['skill_id'], 1);
      expect(
        find.textContaining('design-foundations-certificate.pdf'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'bare X removes skill directly; attached skill removal and Undo restore both',
    (tester) async {
      final repo = TestProfileRepository();
      await pump(tester, repo);
      await reveal(tester, find.byTooltip('Manage Flutter'));
      await tester.tap(find.byTooltip('Manage Flutter'));
      await tester.pumpAndSettle();
      expect(find.text('Remove attachment'), findsNothing);
      expect(repo.skills.length, 1);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(repo.skills.length, 2);
      await reveal(tester, find.byTooltip('Manage UI/UX design'));
      await tester.tap(find.byTooltip('Manage UI/UX design'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove skill'));
      await tester.pumpAndSettle();
      expect(repo.certificates, isEmpty);
      expect(find.text('UI/UX design'), findsNothing);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(repo.skills.any((s) => s['id'] == 1), isTrue);
      expect(repo.certificates.single['skill_id'], 1);
    },
  );

  testWidgets('upload targets the right skill and waits for persistence', (
    tester,
  ) async {
    final repo = TestProfileRepository()..uploadGate = Completer<void>();
    await pump(
      tester,
      repo,
      picker: () async => XFile.fromData(
        Uint8List.fromList([1, 2, 3]),
        name: 'flutter.pdf',
        path: '/tmp/flutter.pdf',
      ),
    );
    final row = find.byKey(const ValueKey('skill-2'));
    final attach = find.descendant(
      of: row,
      matching: find.text('Attach evidence'),
    );
    await reveal(tester, attach);
    await tester.tap(attach);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(repo.uploadedSkill, 2);
    expect(find.text('Uploading flutter.pdf…'), findsOneWidget);
    expect(find.text('Evidence uploaded.'), findsNothing);
    repo.uploadGate!.complete();
    await tester.pumpAndSettle();
    expect(repo.certificates.last['skill_id'], 2);
    expect(
      find.descendant(
        of: row,
        matching: find.textContaining('flutter.pdf · PDF'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('failed uploads show error without adding evidence', (
    tester,
  ) async {
    final repo = TestProfileRepository()..failUpload = true;
    await pump(
      tester,
      repo,
      picker: () async => XFile.fromData(
        Uint8List.fromList([1]),
        name: 'flutter.pdf',
        path: '/tmp/flutter.pdf',
      ),
    );
    final attach = find.descendant(
      of: find.byKey(const ValueKey('skill-2')),
      matching: find.text('Attach evidence'),
    );
    await reveal(tester, attach);
    await tester.tap(attach);
    await tester.pumpAndSettle();
    expect(repo.certificates.length, 1);
    expect(find.text('Evidence uploaded.'), findsNothing);
    expect(
      find.text('Could not save this change. Please try again.'),
      findsWidgets,
    );
  });

  testWidgets(
    'continuous scrolling, large text, distinct participation and keyboard',
    (tester) async {
      final repo = TestProfileRepository();
      repo.skills[0]['skill'] = 'A very long skill name that wraps gracefully';
      repo.certificates[0]['file_name'] = '${'a' * 100}.pdf';
      await pump(tester, repo, scale: 2);
      tester.view.physicalSize = const Size(320, 740);
      await tester.pumpAndSettle();
      await reveal(tester, find.byType(PreviousParticipationRow).last);
      expect(tester.takeException(), isNull);
      expect(tester.getBottomLeft(find.byType(ProfileHeader)).dy, lessThan(0));
      expect(
        tester.getBottomLeft(find.byType(PreviousParticipationRow).last).dy,
        lessThan(tester.getTopLeft(find.text('Navigation')).dy),
      );
      expect(find.byType(ProfileTeamRow), findsNWidgets(2));
      final teamSurfaces = tester
          .widgetList<ProfileSurface>(
            find.ancestor(
              of: find.byType(ProfileTeamRow),
              matching: find.byType(ProfileSurface),
            ),
          )
          .toSet();
      expect(teamSurfaces.length, 2);
      expect(find.byType(PreviousParticipationRow), findsOneWidget);
      await reveal(tester, find.text('Add skill'));
      await tester.tap(find.text('Add skill'));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('pencils edit each section and skills controls start hidden', (
    tester,
  ) async {
    final repo = TestProfileRepository();
    await pump(tester, repo, editing: false);
    expect(find.byType(AttachmentMenu), findsNothing);
    expect(find.text('Attach evidence'), findsNothing);
    expect(find.text('Add skill'), findsNothing);
    expect(find.text('Edit profile'), findsNothing);
    expect(find.byTooltip('Back'), findsNothing);
    await reveal(tester, find.byTooltip('Edit name and links'));
    await tester.tap(find.byTooltip('Edit name and links'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(3));
    await tester.enterText(
      find.widgetWithText(TextField, 'Name'),
      'Fatimah Updated',
    );
    await tester.tap(find.byType(ProfileAction));
    await tester.pumpAndSettle();
    expect(find.text('Fatimah Updated'), findsOneWidget);
    await reveal(tester, find.byTooltip('Edit About'));
    await tester.tap(find.byTooltip('Edit About'));
    await tester.pumpAndSettle();
    final aboutField = tester.widget<TextField>(find.byType(TextField));
    expect(aboutField.controller!.text, repo.about);
    final amendedAbout = '${repo.about} I also enjoy mentoring.';
    await tester.enterText(find.byType(TextField), amendedAbout);
    await tester.tap(find.byType(ProfileAction));
    await tester.pumpAndSettle();
    expect(find.text(amendedAbout), findsOneWidget);
    await reveal(
      tester,
      find.textContaining('design-foundations-certificate.pdf'),
    );
    await tester.tap(find.textContaining('design-foundations-certificate.pdf'));
    await tester.pumpAndSettle();
    expect(find.text('Open PDF'), findsOneWidget);
    await tester.tap(find.byTooltip('Close preview'));
    await tester.pumpAndSettle();
    await reveal(tester, find.byTooltip('Edit skills & evidence'));
    await tester.tap(find.byTooltip('Edit skills & evidence'));
    await tester.pumpAndSettle();
    expect(find.byType(AttachmentMenu), findsNWidgets(2));
  });

  testWidgets('Undo notification expires and editing unlocks', (tester) async {
    await pump(tester, TestProfileRepository());
    await reveal(tester, find.byTooltip('Manage Flutter'));
    await tester.tap(find.byTooltip('Manage Flutter'));
    await tester.pumpAndSettle();
    expect(find.text('Skill removed.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();
    expect(find.text('Skill removed.'), findsNothing);
    await reveal(tester, find.byTooltip('Done editing skills'));
    await tester.tap(find.byTooltip('Done editing skills'));
    await tester.pumpAndSettle();
    expect(find.byType(AttachmentMenu), findsNothing);
  });

  for (final lead in [false, true]) {
    testWidgets('member sheet keeps live team membership (lead=$lead)', (
      tester,
    ) async {
      final member = Member(
        initials: 'SA',
        name: 'Sarah Alqahtani',
        role: 'Designer',
        lead: lead,
      );
      final event = Hackathon.fromMap({
        'id': 'live-event-uuid',
        'name': 'Live Hackathon',
      });
      final team = Team(
        id: 'live-team-uuid',
        hackathonId: event.id,
        name: 'Live Team',
        members: 1,
        maxMembers: 5,
        membersInfo: [member],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showMemberSheet(
                  context,
                  member,
                  team: team,
                  hackathon: event,
                ),
                child: const Text('Open member'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open member'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View full profile'));
      await tester.pumpAndSettle();
      final rows = tester
          .widgetList<ProfileTeamRow>(find.byType(ProfileTeamRow))
          .toList();
      expect(rows, hasLength(1));
      expect(rows.single.record.team.id, team.id);
      expect(rows.single.record.event.id, event.id);
      expect(
        rows.single.record.status,
        lead ? MembershipStatus.leader : MembershipStatus.member,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('other profiles expose public skills without private controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileScreen(
          member: Member(
            initials: 'F',
            name: 'Fatimah',
            role: 'Designer',
            skills: ['UI/UX design'],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('UI/UX design'), findsOneWidget);
    expect(find.byType(AttachmentMenu), findsNothing);
    expect(find.text('Add skill'), findsNothing);
    expect(find.text('Attach evidence'), findsNothing);
    expect(find.text('Edit profile'), findsNothing);
    expect(find.byTooltip('Settings'), findsNothing);
  });

  testWidgets('profile preview and settings route', (tester) async {
    await pump(tester, TestProfileRepository(), editing: false);
    if (Platform.environment['VECTOR_CAPTURE_PROFILE'] == '1') {
      final boundary = tester.firstRenderObject<RenderRepaintBoundary>(
        find.byKey(const Key('capture')),
      );
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File('/tmp/vector-profile-preview.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Personal Information'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(ProfileHeader), findsOneWidget);
  });
}
