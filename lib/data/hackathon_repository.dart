import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';
import '../models/hackathon.dart';
import '../models/invitation.dart';
import '../models/member.dart';
import '../models/sent_request.dart';
import '../models/team.dart';
import 'mock_hackathons.dart';

/// Data access for hackathons/teams. Falls back to bundled mock data
/// whenever Supabase isn't configured (`.env` still has placeholder
/// values) or whenever a live call fails/times out — this is a no-auth
/// mock app and the Home screen must never surface an error.
class HackathonRepository {
  static const _timeout = Duration(seconds: 3);

  Future<List<Hackathon>> fetchHackathons() async {
    if (!Env.isConfigured) {
      return _sortHackathons(
        mockHackathons,
        List<dynamic>.filled(mockHackathons.length, null),
      );
    }

    try {
      final rows = await Supabase.instance.client
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
    if (!Env.isConfigured) {
      return mockTeamsFor(hackathonId);
    }

    try {
      final rows = await Supabase.instance.client
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

  /// Creates a new team as the current user (always "Team lead"), with
  /// [hackathonId]/[name]/[maxMembers]/[missingRoles] from the create-team
  /// form. Returns the created [Team], or `null` on failure. In mock mode
  /// the team is appended locally so the flow still demos end to end.
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

    if (!Env.isConfigured) {
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
      final row = await Supabase.instance.client
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

  /// Deletes a team the current user owns. Mock mode only for now — there
  /// is no live-backend path yet, so this returns `false` when Supabase
  /// is configured rather than silently doing nothing.
  Future<bool> deleteTeam(String teamId) async {
    if (!Env.isConfigured) {
      removeMockTeam(teamId);
      return true;
    }
    return false;
  }

  /// Sends a join request for [teamId].
  ///
  /// In mock mode (Supabase not configured) there is nothing to actually
  /// persist. To keep the demo flow working end to end — the UI shows a
  /// "request sent" dialog only when this returns `true` — mock mode
  /// simulates a short network delay and reports success rather than
  /// failing outright. This is a judgment call for the no-auth mock app,
  /// not something spelled out in the contract.
  Future<bool> sendJoinRequest(String teamId) async {
    if (!Env.isConfigured) {
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
      await Supabase.instance.client
          .from('join_requests')
          .insert({'team_id': teamId});
      return true;
    } catch (_) {
      return false;
    }
  }

  /// The current user's own teams, for the "send invite" team picker.
  Future<List<Team>> fetchMyTeams() async {
    if (!Env.isConfigured) {
      return myMockTeams();
    }

    try {
      final rows = await Supabase.instance.client
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

  /// Sends an invitation for [member] to join [team]. Returns success.
  ///
  /// Mock mode mirrors [sendJoinRequest]'s judgment call: there is nothing
  /// to persist, so it simulates a short network delay and reports success
  /// so the UI's confirmation step still demos end to end.
  Future<bool> sendInvitation({
    required Team team,
    required Member member,
  }) async {
    if (!Env.isConfigured) {
      await Future.delayed(const Duration(milliseconds: 400));
      return true;
    }

    try {
      await Supabase.instance.client.from('invitations').insert({
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
      }).timeout(_timeout);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // INVITES TAB — invitations + sent requests
  // ============================================================

  /// Pending invitations for the current user, newest first.
  Future<List<Invitation>> fetchInvitations() async {
    if (!Env.isConfigured) {
      return mockInvitations();
    }

    try {
      final rows = await Supabase.instance.client
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

  /// Accepts or declines invitation [id]. Returns success.
  Future<bool> respondToInvitation(String id, String status) async {
    if (!Env.isConfigured) {
      respondToMockInvitation(id, status);
      return true;
    }

    try {
      await Supabase.instance.client
          .from('invitations')
          .update({'status': status})
          .eq('id', id)
          .timeout(_timeout);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// All join requests the current user has sent, newest first.
  Future<List<SentRequest>> fetchSentRequests() async {
    if (!Env.isConfigured) {
      return mockSentRequests();
    }

    try {
      final rows = await Supabase.instance.client
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

  /// Withdraws a pending sent request. Returns success.
  Future<bool> withdrawRequest(String id) async {
    if (!Env.isConfigured) {
      removeMockSentRequest(id);
      return true;
    }

    try {
      await Supabase.instance.client
          .from('join_requests')
          .delete()
          .eq('id', id)
          .timeout(_timeout);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Sorts hackathons by `pin_rank` ascending (nulls last), then
  /// `is_featured` descending, then `created_at` ascending, using the
  /// original list position as a final, stable tiebreaker (mock rows have
  /// no `created_at`, and `List.sort` isn't guaranteed stable in general,
  /// so we decorate-sort-undecorate with the index explicitly).
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
