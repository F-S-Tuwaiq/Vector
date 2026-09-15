import '../models/hackathon.dart';
import '../models/invitation.dart';
import '../models/member.dart';
import '../models/sent_request.dart';
import '../models/team.dart';

/// Fixed mock hackathon ids, kept stable so they can be cross-referenced
/// with [mockTeamsFor] and used in manual testing / the integration pass.
const List<Hackathon> mockHackathons = [
  Hackathon(
    id: 'saif',
    name: 'SAIF — Security & Innovation Fair',
    field: 'Security',
    organizer: 'Ministry of Interior × Tuwaiq Academy (GSTS)',
    heroValue: '5M',
    heroCaption: 'SAR in prizes',
    city: 'Riyadh',
    eventDates: 'Nov 19–21',
    status: 'open',
    isFeatured: true,
    pinRank: 1,
    detail:
        'Global competition · AI, cybersecurity, digital forensics · under the patronage of the Crown Prince',
    website: 'https://saifair.sa',
  ),
  Hackathon(
    id: 'ai-disability',
    name: 'AI for Disability Hackathon',
    field: 'AI',
    organizer: 'King Salman Center for Disability Research',
    heroValue: '220K',
    heroCaption: 'SAR in prizes',
    city: 'Riyadh',
    eventDates: 'Oct 11–13',
    status: 'open',
    isFeatured: true,
    pinRank: null,
    detail: null,
    website: 'https://hackathon.kscdr.org',
  ),
  Hackathon(
    id: 'agentx',
    name: 'AgentX Hackathon',
    field: 'AI',
    organizer: 'Saudi digital ecosystem',
    heroValue: '250+',
    heroCaption: 'Saudi talents',
    city: 'Riyadh',
    eventDates: null,
    status: 'open',
    isFeatured: false,
    pinRank: null,
    detail: 'Agentic AI · hiring and investment tracks',
    website: 'https://www.agentx.sa',
  ),
  Hackathon(
    id: 'gov-eservices',
    name: 'Government E-Services Hackathon 2026',
    field: 'GovTech',
    organizer: 'Ejad Tech',
    heroValue: '4',
    heroCaption: 'challenge tracks',
    city: 'Remote',
    eventDates: null,
    status: 'open',
    isFeatured: true,
    pinRank: null,
    detail:
        'Fully remote · register solo and get matched to a team · up to 7 members',
    website: 'https://hackathon.prx.ejadtech.sa',
  ),
  Hackathon(
    id: 'tanmiyathon',
    name: 'Tanmiyathon 2026',
    field: 'GovTech',
    organizer: 'University of Jeddah',
    heroValue: '15',
    heroCaption: 'Sep — reg. deadline',
    city: 'Jeddah',
    eventDates: null,
    status: 'closing_soon',
    isFeatured: false,
    pinRank: null,
    detail: 'Makkah-region development challenges',
    website: null,
  ),
  Hackathon(
    id: 'energy',
    name: 'Energy Hackathon',
    field: 'Energy',
    organizer: 'Ministry of Energy',
    heroValue: '1st',
    heroCaption: 'edition',
    city: 'Riyadh',
    eventDates: 'Oct 7–9',
    status: 'open',
    isFeatured: true,
    pinRank: null,
    detail: '1st edition · KAPSARC · alongside the World Petroleum Congress',
    website: null,
  ),
  Hackathon(
    id: 'sidf',
    name: 'SIDF Industry Hackathon',
    field: 'Industry',
    organizer: 'Saudi Industrial Development Fund',
    heroValue: '3',
    heroCaption: 'in-person days',
    city: 'Riyadh',
    eventDates: null,
    status: 'tba',
    isFeatured: true,
    pinRank: null,
    detail: 'Teams of 2–5 · Saudi team leader required',
    website: null,
  ),
];

/// Builds the same 3 mock teams for a given [hackathonId].
List<Team> _standardTeams(String hackathonId) => [
      Team(
        id: '$hackathonId-elite',
        hackathonId: hackathonId,
        name: 'Team Elite',
        members: 3,
        maxMembers: 5,
        memberInitials: const ['SA', 'MK', 'NH'],
        missingRoles: const ['UI/UX Designer', 'Flutter Developer'],
        membersInfo: const [
          Member(
            initials: 'SA',
            name: 'Sara Alqahtani',
            role: 'Backend Developer',
            skills: ['Python', 'PostgreSQL'],
            city: 'Riyadh',
            hackathons: 3,
            lead: true,
          ),
          Member(
            initials: 'MK',
            name: 'Mohammed Alkhalaf',
            role: 'Data Analyst',
            skills: ['SQL', 'Tableau'],
            city: 'Jeddah',
            hackathons: 2,
          ),
          Member(
            initials: 'NH',
            name: 'Nora Alharbi',
            role: 'Product Manager',
            skills: ['Figma', 'Notion'],
            city: 'Riyadh',
            hackathons: 4,
          ),
        ],
      ),
      Team(
        id: '$hackathonId-pioneers',
        hackathonId: hackathonId,
        name: 'The Pioneers',
        members: 4,
        maxMembers: 5,
        memberInitials: const ['AR', 'LT', 'JS', 'FA'],
        missingRoles: const ['Data Analyst'],
        membersInfo: const [
          Member(
            initials: 'AR',
            name: 'Abdullah Alrashid',
            role: 'Backend Developer',
            skills: ['Node.js', 'AWS'],
            city: 'Riyadh',
            hackathons: 5,
            lead: true,
          ),
          Member(
            initials: 'LT',
            name: 'Layla Tamimi',
            role: 'UI/UX Designer',
            skills: ['Figma', 'Illustrator'],
            city: 'Dammam',
            hackathons: 2,
          ),
          Member(
            initials: 'JS',
            name: 'Jana Alsulaiman',
            role: 'Flutter Developer',
            skills: ['Dart', 'Flutter'],
            city: 'Riyadh',
            hackathons: 3,
          ),
          Member(
            initials: 'FA',
            name: 'Faisal Alamri',
            role: 'Marketer',
            skills: ['SEO', 'Content'],
            city: 'Jeddah',
            hackathons: 1,
          ),
        ],
      ),
      Team(
        id: '$hackathonId-crushers',
        hackathonId: hackathonId,
        name: 'Code Crushers',
        members: 2,
        maxMembers: 5,
        memberInitials: const ['OM', 'RK'],
        missingRoles: const ['Backend Developer', 'Designer', 'Marketer'],
        membersInfo: const [
          Member(
            initials: 'OM',
            name: 'Omar Alghamdi',
            role: 'Flutter Developer',
            skills: ['Dart', 'Firebase'],
            city: 'Riyadh',
            hackathons: 6,
            lead: true,
          ),
          Member(
            initials: 'RK',
            name: 'Reem Alkhattab',
            role: 'UI/UX Designer',
            skills: ['Figma', 'Sketch'],
            city: 'Khobar',
            hackathons: 2,
          ),
        ],
      ),
    ];

/// Mock teams keyed by hackathon id. Only featured hackathons get seeded
/// teams; the rest have an empty list (no teams looking for members yet).
final Map<String, List<Team>> _mockTeamsByHackathon = {
  'saif': _standardTeams('saif'),
  'ai-disability': _standardTeams('ai-disability'),
  'agentx': const [],
  'gov-eservices': _standardTeams('gov-eservices'),
  'tanmiyathon': const [],
  'energy': _standardTeams('energy'),
  'sidf': _standardTeams('sidf'),
};

/// Returns the mock teams for [hackathonId], or an empty list if unknown.
List<Team> mockTeamsFor(String hackathonId) {
  return _mockTeamsByHackathon[hackathonId] ?? const [];
}

/// Appends a locally-created team so the create-team flow still demos
/// end to end when Supabase isn't configured.
void addMockTeam(Team team) {
  _mockTeamsByHackathon[team.hackathonId] = [
    ...mockTeamsFor(team.hackathonId),
    team,
  ];
}

/// Finds a mock team by id across every hackathon, or `null`.
Team? findMockTeamById(String teamId) {
  for (final teams in _mockTeamsByHackathon.values) {
    for (final team in teams) {
      if (team.id == teamId) return team;
    }
  }
  return null;
}

/// The mock hackathon's name for [hackathonId], or the first hackathon's
/// name if unknown (defensive fallback — never surfaces empty text).
String mockHackathonNameFor(String hackathonId) {
  return mockHackathons
      .firstWhere(
        (h) => h.id == hackathonId,
        orElse: () => mockHackathons.first,
      )
      .name;
}

final DateTime _now = DateTime.now();

/// Seeded pending invitations, mirroring the live `invitations` table.
final List<Invitation> _mockInvitations = [
  Invitation(
    id: 'invite-1',
    teamId: 'saif-elite',
    teamName: 'Team Elite',
    hackathonId: 'saif',
    hackathonName: 'SAIF — Security & Innovation Fair',
    hackathonHero: '5M SAR',
    hackathonDates: 'Nov 19–21',
    hackathonCity: 'Riyadh',
    senderName: 'Sara Alqahtani',
    senderRole: 'Team lead',
    message:
        "We need a backend dev who can start now — you're exactly the "
        'profile we\'re missing.',
    expiresAt: _now.add(const Duration(hours: 46)),
    status: 'pending',
    createdAt: _now.subtract(const Duration(hours: 3)),
  ),
  Invitation(
    id: 'invite-2',
    teamId: 'ai-disability-pioneers',
    teamName: 'The Pioneers',
    hackathonId: 'ai-disability',
    hackathonName: 'AI for Disability Hackathon',
    hackathonHero: '220K SAR',
    hackathonDates: 'Oct 11–13',
    hackathonCity: 'Riyadh',
    senderName: 'Abdullah Alrashid',
    senderRole: 'Team lead',
    message: 'Loved your portfolio — join us for AI for Disability!',
    expiresAt: _now.add(const Duration(days: 5)),
    status: 'pending',
    createdAt: _now.subtract(const Duration(days: 1)),
  ),
];

/// Seeded sent requests, mirroring the live `join_requests` table.
final List<SentRequest> _mockSentRequests = [
  SentRequest(
    id: 'sent-1',
    teamId: 'energy-crushers',
    teamName: 'Code Crushers',
    hackathonId: 'energy',
    hackathonName: 'Energy Hackathon',
    status: 'accepted',
    createdAt: _now.subtract(const Duration(days: 2)),
  ),
  SentRequest(
    id: 'sent-2',
    teamId: 'gov-eservices-pioneers',
    teamName: 'The Pioneers',
    hackathonId: 'gov-eservices',
    hackathonName: 'Government E-Services Hackathon 2026',
    status: 'declined',
    createdAt: _now.subtract(const Duration(hours: 6)),
  ),
];

/// Pending invitations, newest first.
List<Invitation> mockInvitations() {
  final pending = _mockInvitations.where((i) => i.status == 'pending').toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return pending;
}

/// Updates a mock invitation's status in place (accept/decline).
void respondToMockInvitation(String id, String status) {
  final index = _mockInvitations.indexWhere((inv) => inv.id == id);
  if (index != -1) {
    _mockInvitations[index] = _mockInvitations[index].copyWith(
      status: status,
    );
  }
}

/// All sent requests (any status), newest first.
List<SentRequest> mockSentRequests() {
  final all = List<SentRequest>.from(_mockSentRequests)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return all;
}

/// Appends a locally-created sent request so `sendJoinRequest` shows up in
/// the Sent tab immediately, even without Supabase configured.
void addMockSentRequest(SentRequest request) {
  _mockSentRequests.insert(0, request);
}

/// Removes a mock sent request (withdraw).
void removeMockSentRequest(String id) {
  _mockSentRequests.removeWhere((r) => r.id == id);
}
