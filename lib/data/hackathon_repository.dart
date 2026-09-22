import '../services/supabase_service.dart';
import '../models/hackathon.dart';
import '../models/invitation.dart';
import '../models/member.dart';
import '../models/sent_request.dart';
import '../models/team.dart';
import 'mock_hackathons.dart';

class HackathonRepository {
  static const _timeout = Duration(seconds: 3);

  Future<List<Hackathon>> fetchHackathons() async {
    if (SupabaseService.usesDemoData) {
      return _sortHackathons(
        mockHackathons,
        List<dynamic>.filled(mockHackathons.length, null),
      );
    }

    try {
      final rows = await SupabaseService.client
          .from('hackathons')
          .select()
          .timeout(_timeout);
      final data = (rows as List).cast<Map<String, dynamic>>();
      final hackathons = data.map(Hackathon.fromMap).toList();
      final createdAts = data.map((row) => row['created_at']).toList();
      return _sortHackathons(hackathons, createdAts);
    } catch (_) {
      return _sortHackathons(
        mockHackathons,
        List<dynamic>.filled(mockHackathons.length, null),
      );
    }
  }

  Future<List<Team>> fetchTeams(String hackathonId) async {
    if (SupabaseService.usesDemoData) {
      return mockTeamsFor(hackathonId);
    }

    try {
      final rows = await SupabaseService.client
          .from('teams')
          .select()
          .eq('hackathon_id', hackathonId)
          .timeout(_timeout);
      final data = (rows as List).cast<Map<String, dynamic>>();
      return data.map(Team.fromMap).toList();
    } catch (_) {
      return mockTeamsFor(hackathonId);
    }
  }

  Future<Team?> createTeam({
    required String hackathonId,
    required String name,
    required int maxMembers,
    required List<String> missingRoles,
  }) async {
    const lead = Member(
      initials: 'ME',
      name: 'You',
      role: 'Team lead',
      lead: true,
    );

    if (SupabaseService.usesDemoData) {
      final team = Team(
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        hackathonId: hackathonId,
        name: name,
        members: 1,
        maxMembers: maxMembers,
        memberInitials: const ['ME'],
        missingRoles: missingRoles,
        membersInfo: const [lead],
      );
      addMockTeam(team);
      return team;
    }

    try {
      final row = await SupabaseService.client
          .from('teams')
          .insert({
            'hackathon_id': hackathonId,
            'name': name,
            'members': 1,
            'max_members': maxMembers,
            'member_initials': const ['ME'],
            'missing_roles': missingRoles,
            'members_info': [lead.toMap()],
          })
          .select()
          .single()
          .timeout(_timeout);
      return Team.fromMap(row);
    } catch (_) {
      return null;
    }
  }

  Future<bool> deleteTeam(String teamId) async {
    if (SupabaseService.usesDemoData) {
      removeMockTeam(teamId);
      return true;
    }
    return false;
  }

  Future<bool> sendJoinRequest(String teamId) async {
    if (SupabaseService.usesDemoData) {
      await Future.delayed(const Duration(milliseconds: 400));
      final team = findMockTeamById(teamId);
      if (team != null) {
        addMockSentRequest(
          SentRequest(
            id: 'local-request-${DateTime.now().microsecondsSinceEpoch}',
            teamId: team.id,
            teamName: team.name,
            hackathonId: team.hackathonId,
            hackathonName: mockHackathonNameFor(team.hackathonId),
            status: 'pending',
            createdAt: DateTime.now(),
          ),
        );
      }
      return true;
    }

    try {
      await SupabaseService.client.from('join_requests').insert({
        'team_id': teamId,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<Team>> fetchMyTeams() async {
    if (SupabaseService.usesDemoData) {
      return myMockTeams();
    }

    try {
      final rows = await SupabaseService.client
          .from('teams')
          .select()
          .contains('member_initials', ['ME'])
          .timeout(_timeout);
      final data = (rows as List).cast<Map<String, dynamic>>();
      if (data.isEmpty) return myMockTeams();
      return data.map(Team.fromMap).toList();
    } catch (_) {
      return myMockTeams();
    }
  }

  Future<bool> sendInvitation({
    required Team team,
    required Member member,
  }) async {
    if (SupabaseService.usesDemoData) {
      await Future.delayed(const Duration(milliseconds: 400));
      return true;
    }

    try {
      await SupabaseService.client
          .from('invitations')
          .insert({
            'team_id': team.id,
            'sender_name': 'You',
            'sender_role': 'Team lead',
            'message':
                'Hey ${member.name}, we think your skills as a ${member.role} '
                'would be a great fit for ${team.name} — join us!',
            'status': 'pending',
            'expires_at': DateTime.now()
                .add(const Duration(days: 7))
                .toIso8601String(),
          })
          .timeout(_timeout);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<Invitation>> fetchInvitations() async {
    if (SupabaseService.usesDemoData) {
      return mockInvitations();
    }

    try {
      final rows = await SupabaseService.client
          .from('invitations')
          .select(
            '*, teams(id, name, hackathon_id, '
            'hackathons(id, name, hero_value, hero_caption, event_dates, city))',
          )
          .eq('status', 'pending')
          .order('created_at', ascending: false)
          .timeout(_timeout);
      final data = (rows as List).cast<Map<String, dynamic>>();
      return data.map(Invitation.fromMap).toList();
    } catch (_) {
      return mockInvitations();
    }
  }

  Future<bool> respondToInvitation(String id, String status) async {
    if (SupabaseService.usesDemoData) {
      respondToMockInvitation(id, status);
      return true;
    }

    try {
      await SupabaseService.client
          .from('invitations')
          .update({'status': status})
          .eq('id', id)
          .timeout(_timeout);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<SentRequest>> fetchSentRequests() async {
    if (SupabaseService.usesDemoData) {
      return mockSentRequests();
    }

    try {
      final rows = await SupabaseService.client
          .from('join_requests')
          .select('*, teams(id, name, hackathon_id, hackathons(id, name))')
          .order('created_at', ascending: false)
          .timeout(_timeout);
      final data = (rows as List).cast<Map<String, dynamic>>();
      return data.map(SentRequest.fromMap).toList();
    } catch (_) {
      return mockSentRequests();
    }
  }

  Future<bool> withdrawRequest(String id) async {
    if (SupabaseService.usesDemoData) {
      removeMockSentRequest(id);
      return true;
    }

    try {
      await SupabaseService.client
          .from('join_requests')
          .delete()
          .eq('id', id)
          .timeout(_timeout);
      return true;
    } catch (_) {
      return false;
    }
  }

  List<Hackathon> _sortHackathons(
    List<Hackathon> items,
    List<dynamic> createdAts,
  ) {
    final decorated = List.generate(
      items.length,
      (i) => (hackathon: items[i], createdAt: createdAts[i], index: i),
    );

    decorated.sort((a, b) {
      final pinA = a.hackathon.pinRank;
      final pinB = b.hackathon.pinRank;
      if (pinA != pinB) {
        if (pinA == null) return 1;
        if (pinB == null) return -1;
        final cmp = pinA.compareTo(pinB);
        if (cmp != 0) return cmp;
      }

      if (a.hackathon.isFeatured != b.hackathon.isFeatured) {
        return a.hackathon.isFeatured ? -1 : 1;
      }

      final createdA = a.createdAt;
      final createdB = b.createdAt;
      if (createdA != null && createdB != null) {
        final cmp = createdA.toString().compareTo(createdB.toString());
        if (cmp != 0) return cmp;
      }

      return a.index.compareTo(b.index);
    });

    return decorated.map((d) => d.hackathon).toList();
  }
}
