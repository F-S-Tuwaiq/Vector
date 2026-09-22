class SentRequest {
  final String id;
  final String teamId;
  final String teamName;
  final String hackathonId;
  final String hackathonName;
  final String status;
  final DateTime createdAt;

  const SentRequest({
    required this.id,
    required this.teamId,
    required this.teamName,
    required this.hackathonId,
    required this.hackathonName,
    required this.status,
    required this.createdAt,
  });

  String get teamInitial => teamName.isEmpty ? '?' : teamName[0].toUpperCase();

  factory SentRequest.fromMap(Map<String, dynamic> map) {
    final team = map['teams'] as Map<String, dynamic>?;
    final hackathon = team?['hackathons'] as Map<String, dynamic>?;
    return SentRequest(
      id: map['id'] as String? ?? '',
      teamId: map['team_id'] as String? ?? '',
      teamName: team?['name'] as String? ?? '',
      hackathonId: hackathon?['id'] as String? ?? '',
      hackathonName: hackathon?['name'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
