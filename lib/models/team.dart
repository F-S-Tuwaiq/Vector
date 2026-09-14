import 'member.dart';

/// A team looking for members within a given hackathon.
class Team {
  final String id;
  final String hackathonId;
  final String name;
  final int members;
  final int maxMembers;
  final List<String> memberInitials;
  final List<String> missingRoles;
  final List<Member> membersInfo;

  const Team({
    required this.id,
    required this.hackathonId,
    required this.name,
    required this.members,
    required this.maxMembers,
    this.memberInitials = const [],
    this.missingRoles = const [],
    this.membersInfo = const [],
  });

  /// Parses a Supabase row (snake_case columns) into a [Team].
  ///
  /// Postgres `text[]` columns come back over JSON as `List<dynamic>`, so
  /// each element is defensively coerced to `String`.
  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'] as String? ?? '',
      hackathonId: map['hackathon_id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      members: map['members'] as int? ?? 0,
      maxMembers: map['max_members'] as int? ?? 0,
      memberInitials: (map['member_initials'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      missingRoles: (map['missing_roles'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      membersInfo: (map['members_info'] as List?)
              ?.map((e) => Member.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
