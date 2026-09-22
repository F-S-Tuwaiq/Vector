class Invitation {
  final String id;
  final String teamId;
  final String teamName;
  final String hackathonId;
  final String hackathonName;
  final String hackathonHero;
  final String? hackathonDates;
  final String hackathonCity;
  final String senderName;
  final String senderRole;
  final String message;
  final DateTime expiresAt;
  final String status;
  final DateTime createdAt;

  const Invitation({
    required this.id,
    required this.teamId,
    required this.teamName,
    required this.hackathonId,
    required this.hackathonName,
    required this.hackathonHero,
    this.hackathonDates,
    required this.hackathonCity,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.expiresAt,
    required this.status,
    required this.createdAt,
  });

  String get teamInitial => teamName.isEmpty ? '?' : teamName[0].toUpperCase();

  Invitation copyWith({String? status}) => Invitation(
    id: id,
    teamId: teamId,
    teamName: teamName,
    hackathonId: hackathonId,
    hackathonName: hackathonName,
    hackathonHero: hackathonHero,
    hackathonDates: hackathonDates,
    hackathonCity: hackathonCity,
    senderName: senderName,
    senderRole: senderRole,
    message: message,
    expiresAt: expiresAt,
    status: status ?? this.status,
    createdAt: createdAt,
  );

  factory Invitation.fromMap(Map<String, dynamic> map) {
    final team = map['teams'] as Map<String, dynamic>?;
    final hackathon = team?['hackathons'] as Map<String, dynamic>?;
    final heroValue = hackathon?['hero_value'] as String? ?? '';
    final heroCaption = hackathon?['hero_caption'] as String? ?? '';
    return Invitation(
      id: map['id'] as String? ?? '',
      teamId: map['team_id'] as String? ?? '',
      teamName: team?['name'] as String? ?? '',
      hackathonId: hackathon?['id'] as String? ?? '',
      hackathonName: hackathon?['name'] as String? ?? '',
      hackathonHero: '$heroValue $heroCaption'.trim(),
      hackathonDates: hackathon?['event_dates'] as String?,
      hackathonCity: hackathon?['city'] as String? ?? '',
      senderName: map['sender_name'] as String? ?? '',
      senderRole: map['sender_role'] as String? ?? '',
      message: map['message'] as String? ?? '',
      expiresAt:
          DateTime.tryParse(map['expires_at'] as String? ?? '') ??
          DateTime.now(),
      status: map['status'] as String? ?? 'pending',
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
