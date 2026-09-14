import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';
import '../models/hackathon.dart';
import '../models/member.dart';
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
