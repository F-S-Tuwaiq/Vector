class Member {
  final String initials;
  final String name;
  final String role;
  final List<String> skills;
  final String city;
  final int hackathons;
  final bool lead;

  const Member({
    required this.initials,
    required this.name,
    required this.role,
    this.skills = const [],
    this.city = '',
    this.hackathons = 0,
    this.lead = false,
  });

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      initials: map['initials'] as String? ?? '',
      name: map['name'] as String? ?? '',
      role: map['role'] as String? ?? '',
      skills:
          (map['skills'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      city: map['city'] as String? ?? '',
      hackathons: map['hackathons'] as int? ?? 0,
      lead: map['lead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'initials': initials,
    'name': name,
    'role': role,
    'skills': skills,
    'city': city,
    'hackathons': hackathons,
    'lead': lead,
  };
}
