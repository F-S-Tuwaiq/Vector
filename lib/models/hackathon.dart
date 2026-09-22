class Hackathon {
  final String id;
  final String name;
  final String field;
  final String heroValue;
  final String heroCaption;
  final String city;
  final String? organizer;
  final String? eventDates;
  final String? detail;
  final String? website;

  final String status;
  final bool isFeatured;
  final int? pinRank;

  const Hackathon({
    required this.id,
    required this.name,
    required this.field,
    required this.heroValue,
    required this.heroCaption,
    required this.city,
    required this.status,
    this.isFeatured = false,
    this.pinRank,
    this.organizer,
    this.eventDates,
    this.detail,
    this.website,
  });

  factory Hackathon.fromMap(Map<String, dynamic> map) {
    return Hackathon(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      field: map['field'] as String? ?? '',
      heroValue: map['hero_value'] as String? ?? '',
      heroCaption: map['hero_caption'] as String? ?? '',
      city: map['city'] as String? ?? '',
      status: map['status'] as String? ?? 'tba',
      isFeatured: map['is_featured'] as bool? ?? false,
      pinRank: map['pin_rank'] as int?,
      organizer: map['organizer'] as String?,
      eventDates: map['event_dates'] as String?,
      detail: map['detail'] as String?,
      website: map['website'] as String?,
    );
  }
}
