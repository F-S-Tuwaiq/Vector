import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vector/data/hackathon_repository.dart';
import 'package:vector/data/profile_repository.dart';
import 'package:vector/services/guest_session.dart';
import 'package:vector/services/supabase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/shared_preferences'),
        (call) async => call.method == 'getAll' ? <String, Object>{} : true,
      );
  final repository = HackathonRepository();
  late List<http.Request> requests;

  setUp(() async {
    requests = [];
    GuestSession.end();
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      publishableKey: 'test-key',
      debug: false,
      authOptions: const FlutterAuthClientOptions(
        persistSession: false,
        detectSessionInUri: false,
        autoRefreshToken: false,
      ),
      httpClient: MockClient((request) async {
        requests.add(request);
        return http.Response(
          jsonEncode({
            'access_token': 'test-token',
            'refresh_token': 'test-refresh',
            'token_type': 'bearer',
            'expires_in': 3600,
            'user': {
              'id': '11111111-1111-4111-8111-111111111111',
              'aud': 'authenticated',
              'email': 'test@example.com',
              'created_at': '2026-01-01T00:00:00Z',
              'app_metadata': <String, dynamic>{},
              'user_metadata': <String, dynamic>{},
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    SupabaseService.isConfigured = true;
  });

  tearDown(() async {
    GuestSession.end();
    SupabaseService.isConfigured = false;
    await Supabase.instance.dispose();
  });

  test('configured backend receives no guest reads or writes', () async {
    GuestSession.start();
    final events = await repository.fetchHackathons();
    final event = events.first;
    final initialTeams = await repository.fetchTeams(event.id);
    final team = await repository.createTeam(
      hackathonId: event.id,
      name: 'Only on this device',
      maxMembers: 4,
      missingRoles: ['Designer'],
    );
    expect(team, isNotNull);
    expect(
      await repository.fetchTeams(event.id),
      hasLength(initialTeams.length + 1),
    );
    expect(
      (await repository.fetchMyTeams()).map((t) => t.id),
      contains(team!.id),
    );
    expect(await repository.sendJoinRequest(initialTeams.first.id), isTrue);
    final sent = await repository.fetchSentRequests();
    expect(await repository.withdrawRequest(sent.first.id), isTrue);
    expect(
      await repository.sendInvitation(
        team: team,
        member: initialTeams.first.membersInfo.first,
      ),
      isTrue,
    );
    final invitations = await repository.fetchInvitations();
    expect(invitations, isNotEmpty);
    expect(
      await repository.respondToInvitation(invitations.first.id, 'accepted'),
      isTrue,
    );
    final participation = await const DemoProfileRepository().participations();
    expect(participation.map((p) => p.team.id), contains(team.id));
    expect(await repository.deleteTeam(team.id), isTrue);
    expect(
      (await repository.fetchTeams(event.id)).map((t) => t.id),
      isNot(contains(team.id)),
    );
    expect(requests, isEmpty);
  });

  test(
    'new guest starts with the same seed and no previous guest changes',
    () async {
      GuestSession.start();
      final event = (await repository.fetchHackathons()).first;
      final seed = (await repository.fetchTeams(event.id))
          .map((t) => t.id)
          .toList();
      final invitations = (await repository.fetchInvitations())
          .map((i) => i.id)
          .toList();
      await repository.createTeam(
        hackathonId: event.id,
        name: 'Private demo team',
        maxMembers: 3,
        missingRoles: [],
      );
      await repository.respondToInvitation(invitations.first, 'declined');
      await repository.sendJoinRequest(seed.first);
      GuestSession.start();
      expect((await repository.fetchTeams(event.id)).map((t) => t.id), seed);
      expect(
        (await repository.fetchInvitations()).map((i) => i.id),
        invitations,
      );
      expect(
        (await repository.fetchSentRequests()).any(
          (r) => r.id.startsWith('local-'),
        ),
        isFalse,
      );
      expect(requests, isEmpty);
    },
  );

  test(
    'guest mode blocks a restored real account from database access',
    () async {
      await SupabaseService.signIn('test@example.com', 'password');
      expect(SupabaseService.isLoggedIn, isTrue);
      requests.clear();
      GuestSession.start();
      expect(SupabaseService.currentUser, isNull);
      expect(SupabaseService.isLoggedIn, isFalse);
      expect(() => SupabaseService.client, throwsStateError);
      await expectLater(
        SupabaseService.saveProfileAbout('Demo edit'),
        throwsStateError,
      );
      await repository.fetchHackathons();
      await SupabaseService.signOut();
      expect(GuestSession.isActive, isFalse);
      expect(requests, isEmpty);
    },
  );
}
