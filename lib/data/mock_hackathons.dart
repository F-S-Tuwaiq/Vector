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
    detail:
        '4 tracks: assistive tech, health & rehab, education, Hajj & Umrah services',
    website: 'https://hackathon.kscdr.org',
  ),
  Hackathon(
    id: 'agentx',
    name: 'AgentX Hackathon',
    field: 'AI',
    organizer: 'Ministry of Communications and Information Technology (MCIT)',
    heroValue: '60K',
    heroCaption: 'SAR in prizes',
    city: 'Eastern Region',
    eventDates: 'Oct 11–14',
    status: 'open',
    isFeatured: false,
    pinRank: null,
    detail:
        'Agentic AI · Energy, Logistics, CX & Sustainability tracks · job placement with 70+ employers',
    website: 'https://www.agentx.sa',
  ),
  Hackathon(
    id: 'gov-eservices',
    name: 'Government E-Services Hackathon 2026',
    field: 'GovTech',
    organizer: 'General Directorate of Passports (Ministry of Interior)',
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
    organizer: 'University of Jeddah · Makkah Region Emirate',
    heroValue: '15',
    heroCaption: 'Sep — reg. deadline',
    city: 'Jeddah',
    eventDates: 'Nov 18–19',
    status: 'closing_soon',
    isFeatured: false,
    pinRank: null,
    detail:
        '5 tracks: urban planning, social development, economy, sustainability, human capacity',
    website: 'https://conferences.uj.edu.sa/tanmiyathon/index.html',
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
    detail:
        '1st edition · "Ignite Your Ideas" · KAPSARC · alongside the World Petroleum Congress',
    website: 'https://hackathon.moenergy.gov.sa',
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

/// SAIF's 3 mock teams. `saif-elite`'s lead (Sara Alqahtani) is also the
/// sender of a seeded invitation, so keep that id/name/team pairing.
List<Team> _saifTeams() => const [
  Team(
    id: 'saif-elite',
    hackathonId: 'saif',
    name: 'Team Elite',
    members: 3,
    maxMembers: 5,
    memberInitials: ['SA', 'MK', 'NH'],
    missingRoles: ['UI/UX Designer', 'Flutter Developer'],
    membersInfo: [
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
    id: 'saif-pioneers',
    hackathonId: 'saif',
    name: 'The Pioneers',
    members: 4,
    maxMembers: 5,
    memberInitials: ['KA', 'HS', 'TG', 'LZ'],
    missingRoles: ['Marketer'],
    membersInfo: [
      Member(
        initials: 'KA',
        name: 'Khalid Alotaibi',
        role: 'Backend Developer',
        skills: ['Node.js', 'PostgreSQL'],
        city: 'Riyadh',
        hackathons: 4,
        lead: true,
      ),
      Member(
        initials: 'HS',
        name: 'Haifa Alsubaie',
        role: 'UI/UX Designer',
        skills: ['Figma', 'Adobe XD'],
        city: 'Jeddah',
        hackathons: 2,
      ),
      Member(
        initials: 'TG',
        name: 'Turki Alghamdi',
        role: 'Flutter Developer',
        skills: ['Dart', 'Firebase'],
        city: 'Dammam',
        hackathons: 3,
      ),
      Member(
        initials: 'LZ',
        name: 'Lama Alzahrani',
        role: 'Data Analyst',
        skills: ['SQL', 'Power BI'],
        city: 'Riyadh',
        hackathons: 1,
      ),
    ],
  ),
  Team(
    id: 'saif-crushers',
    hackathonId: 'saif',
    name: 'Code Crushers',
    members: 2,
    maxMembers: 5,
    memberInitials: ['YA', 'DQ'],
    missingRoles: ['Backend Developer', 'Designer', 'Marketer'],
    membersInfo: [
      Member(
        initials: 'YA',
        name: 'Yousef Alharthi',
        role: 'Flutter Developer',
        skills: ['Flutter', 'Dart'],
        city: 'Khobar',
        hackathons: 5,
        lead: true,
      ),
      Member(
        initials: 'DQ',
        name: 'Dana Alqahtani',
        role: 'UI/UX Designer',
        skills: ['Sketch', 'Figma'],
        city: 'Riyadh',
        hackathons: 2,
      ),
    ],
  ),
];

/// AI for Disability's 3 mock teams. `ai-disability-pioneers`'s lead
/// (Abdullah Alrashid) is also the sender of a seeded invitation, so
/// keep that id/name/team pairing.
List<Team> _aiDisabilityTeams() => const [
  Team(
    id: 'ai-disability-elite',
    hackathonId: 'ai-disability',
    name: 'Team Elite',
    members: 3,
    maxMembers: 5,
    memberInitials: ['FS', 'MO', 'RD'],
    missingRoles: ['UI/UX Designer', 'Flutter Developer'],
    membersInfo: [
      Member(
        initials: 'FS',
        name: 'Fahad Alshehri',
        role: 'Backend Developer',
        skills: ['Python', 'Django'],
        city: 'Riyadh',
        hackathons: 4,
        lead: true,
      ),
      Member(
        initials: 'MO',
        name: 'Maha Alotaibi',
        role: 'Data Analyst',
        skills: ['SQL', 'Tableau'],
        city: 'Jeddah',
        hackathons: 2,
      ),
      Member(
        initials: 'RD',
        name: 'Rakan Aldosari',
        role: 'Product Manager',
        skills: ['Notion', 'Jira'],
        city: 'Riyadh',
        hackathons: 3,
      ),
    ],
  ),
  Team(
    id: 'ai-disability-pioneers',
    hackathonId: 'ai-disability',
    name: 'The Pioneers',
    members: 4,
    maxMembers: 5,
    memberInitials: ['AR', 'LT', 'JS', 'FA'],
    missingRoles: ['Data Analyst'],
    membersInfo: [
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
    id: 'ai-disability-crushers',
    hackathonId: 'ai-disability',
    name: 'Code Crushers',
    members: 2,
    maxMembers: 5,
    memberInitials: ['BG', 'AH'],
    missingRoles: ['Backend Developer', 'Designer', 'Marketer'],
    membersInfo: [
      Member(
        initials: 'BG',
        name: 'Bandar Alghamdi',
        role: 'Flutter Developer',
        skills: ['Dart', 'Firebase'],
        city: 'Makkah',
        hackathons: 6,
        lead: true,
      ),
      Member(
        initials: 'AH',
        name: 'Alanoud Alharbi',
        role: 'UI/UX Designer',
        skills: ['Figma', 'Sketch'],
        city: 'Madinah',
        hackathons: 2,
      ),
    ],
  ),
];

/// Government E-Services's 3 mock teams. `gov-eservices-pioneers` is
/// also referenced (by id/name only) by a seeded sent request.
List<Team> _govEservicesTeams() => const [
  Team(
    id: 'gov-eservices-elite',
    hackathonId: 'gov-eservices',
    name: 'Team Elite',
    members: 3,
    maxMembers: 5,
    memberInitials: ['MQ', 'SM', 'AZ'],
    missingRoles: ['UI/UX Designer', 'Flutter Developer'],
    membersInfo: [
      Member(
        initials: 'MQ',
        name: 'Majed Alqahtani',
        role: 'Backend Developer',
        skills: ['Java', 'Spring'],
        city: 'Riyadh',
        hackathons: 3,
        lead: true,
      ),
      Member(
        initials: 'SM',
        name: 'Shatha Almalki',
        role: 'Data Analyst',
        skills: ['Python', 'Excel'],
        city: 'Abha',
        hackathons: 2,
      ),
      Member(
        initials: 'AZ',
        name: 'Abdulrahman Alzahrani',
        role: 'Product Manager',
        skills: ['Figma', 'Notion'],
        city: 'Riyadh',
        hackathons: 4,
      ),
    ],
  ),
  Team(
    id: 'gov-eservices-pioneers',
    hackathonId: 'gov-eservices',
    name: 'The Pioneers',
    members: 4,
    maxMembers: 5,
    memberInitials: ['NA', 'RA', 'IO', 'WG'],
    missingRoles: ['Data Analyst'],
    membersInfo: [
      Member(
        initials: 'NA',
        name: 'Nawaf Alharbi',
        role: 'Backend Developer',
        skills: ['Node.js', 'MongoDB'],
        city: 'Riyadh',
        hackathons: 5,
        lead: true,
      ),
      Member(
        initials: 'RA',
        name: 'Reema Alsubaie',
        role: 'UI/UX Designer',
        skills: ['Figma', 'Illustrator'],
        city: 'Jeddah',
        hackathons: 3,
      ),
      Member(
        initials: 'IO',
        name: 'Ibrahim Alotaibi',
        role: 'Flutter Developer',
        skills: ['Dart', 'Flutter'],
        city: 'Buraidah',
        hackathons: 2,
      ),
      Member(
        initials: 'WG',
        name: 'Wejdan Alghamdi',
        role: 'Marketer',
        skills: ['SEO', 'Content'],
        city: 'Taif',
        hackathons: 1,
      ),
    ],
  ),
  Team(
    id: 'gov-eservices-crushers',
    hackathonId: 'gov-eservices',
    name: 'Code Crushers',
    members: 2,
    maxMembers: 5,
    memberInitials: ['SQ', 'GH'],
    missingRoles: ['Backend Developer', 'Designer', 'Marketer'],
    membersInfo: [
      Member(
        initials: 'SQ',
        name: 'Sultan Alqahtani',
        role: 'Flutter Developer',
        skills: ['Dart', 'Firebase'],
        city: 'Riyadh',
        hackathons: 4,
        lead: true,
      ),
      Member(
        initials: 'GH',
        name: 'Ghadeer Alharthi',
        role: 'UI/UX Designer',
        skills: ['Sketch', 'Figma'],
        city: 'Khobar',
        hackathons: 2,
      ),
    ],
  ),
];

/// Energy's 3 mock teams. `energy-crushers` is also referenced (by
/// id/name only) by a seeded sent request.
List<Team> _energyTeams() => const [
  Team(
    id: 'energy-elite',
    hackathonId: 'energy',
    name: 'Team Elite',
    members: 3,
    maxMembers: 5,
    memberInitials: ['TA', 'NM', 'HZ'],
    missingRoles: ['UI/UX Designer', 'Flutter Developer'],
    membersInfo: [
      Member(
        initials: 'TA',
        name: 'Talal Alshahrani',
        role: 'Backend Developer',
        skills: ['Python', 'FastAPI'],
        city: 'Riyadh',
        hackathons: 5,
        lead: true,
      ),
      Member(
        initials: 'NM',
        name: 'Nouf Almutairi',
        role: 'Data Analyst',
        skills: ['SQL', 'Tableau'],
        city: 'Jubail',
        hackathons: 2,
      ),
      Member(
        initials: 'HZ',
        name: 'Hassan Alzahrani',
        role: 'Product Manager',
        skills: ['Jira', 'Notion'],
        city: 'Riyadh',
        hackathons: 3,
      ),
    ],
  ),
  Team(
    id: 'energy-pioneers',
    hackathonId: 'energy',
    name: 'The Pioneers',
    members: 4,
    maxMembers: 5,
    memberInitials: ['AQ', 'JO', 'MH', 'AG'],
    missingRoles: ['Data Analyst'],
    membersInfo: [
      Member(
        initials: 'AQ',
        name: 'Abdulaziz Alqarni',
        role: 'Backend Developer',
        skills: ['Node.js', 'AWS'],
        city: 'Riyadh',
        hackathons: 6,
        lead: true,
      ),
      Member(
        initials: 'JO',
        name: 'Jawaher Alotaibi',
        role: 'UI/UX Designer',
        skills: ['Figma', 'Adobe XD'],
        city: 'Yanbu',
        hackathons: 2,
      ),
      Member(
        initials: 'MH',
        name: 'Meshal Alharbi',
        role: 'Flutter Developer',
        skills: ['Dart', 'Flutter'],
        city: 'Riyadh',
        hackathons: 3,
      ),
      Member(
        initials: 'AG',
        name: 'Aljohara Alghamdi',
        role: 'Marketer',
        skills: ['SEO', 'Analytics'],
        city: 'Jeddah',
        hackathons: 1,
      ),
    ],
  ),
  Team(
    id: 'energy-crushers',
    hackathonId: 'energy',
    name: 'Code Crushers',
    members: 2,
    maxMembers: 5,
    memberInitials: ['OM', 'RK'],
    missingRoles: ['Backend Developer', 'Designer', 'Marketer'],
    membersInfo: [
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

/// SIDF's 3 mock teams.
List<Team> _sidfTeams() => const [
  Team(
    id: 'sidf-elite',
    hackathonId: 'sidf',
    name: 'Team Elite',
    members: 3,
    maxMembers: 5,
    memberInitials: ['WA', 'AA', 'NB'],
    missingRoles: ['UI/UX Designer', 'Flutter Developer'],
    membersInfo: [
      Member(
        initials: 'WA',
        name: 'Waleed Alsulami',
        role: 'Backend Developer',
        skills: ['Python', 'PostgreSQL'],
        city: 'Riyadh',
        hackathons: 4,
        lead: true,
      ),
      Member(
        initials: 'AA',
        name: 'Amal Alqahtani',
        role: 'Data Analyst',
        skills: ['Excel', 'Power BI'],
        city: 'Dammam',
        hackathons: 2,
      ),
      Member(
        initials: 'NB',
        name: 'Naif Almalki',
        role: 'Product Manager',
        skills: ['Notion', 'Trello'],
        city: 'Riyadh',
        hackathons: 3,
      ),
    ],
  ),
  Team(
    id: 'sidf-pioneers',
    hackathonId: 'sidf',
    name: 'The Pioneers',
    members: 4,
    maxMembers: 5,
    memberInitials: ['AZ', 'RG', 'SO', 'DA'],
    missingRoles: ['Data Analyst'],
    membersInfo: [
      Member(
        initials: 'AZ',
        name: 'Ahmed Alzahrani',
        role: 'Backend Developer',
        skills: ['Java', 'Spring'],
        city: 'Riyadh',
        hackathons: 5,
        lead: true,
      ),
      Member(
        initials: 'RG',
        name: 'Rana Alghamdi',
        role: 'UI/UX Designer',
        skills: ['Figma', 'Sketch'],
        city: 'Jeddah',
        hackathons: 2,
      ),
      Member(
        initials: 'SO',
        name: 'Saud Alotaibi',
        role: 'Flutter Developer',
        skills: ['Dart', 'Flutter'],
        city: 'Hail',
        hackathons: 3,
      ),
      Member(
        initials: 'DA',
        name: 'Deema Alharbi',
        role: 'Marketer',
        skills: ['Content', 'SEO'],
        city: 'Riyadh',
        hackathons: 1,
      ),
    ],
  ),
  Team(
    id: 'sidf-crushers',
    hackathonId: 'sidf',
    name: 'Code Crushers',
    members: 2,
    maxMembers: 5,
    memberInitials: ['FQ', 'HA'],
    missingRoles: ['Backend Developer', 'Designer', 'Marketer'],
    membersInfo: [
      Member(
        initials: 'FQ',
        name: 'Fares Alqahtani',
        role: 'Flutter Developer',
        skills: ['Dart', 'Firebase'],
        city: 'Riyadh',
        hackathons: 4,
        lead: true,
      ),
      Member(
        initials: 'HA',
        name: 'Hind Alsubaie',
        role: 'UI/UX Designer',
        skills: ['Figma', 'Illustrator'],
        city: 'Khobar',
        hackathons: 2,
      ),
    ],
  ),
];

/// Mock teams keyed by hackathon id. Only featured hackathons get seeded
/// teams; the rest have an empty list (no teams looking for members yet).
/// Every seeded member across every hackathon is a distinct person —
/// none of them are reused between hackathons — so a teammate's profile
/// never shows the same "team" duplicated once per hackathon.
/// The current user owns none of these by default — a fresh guest has
/// to create their own team, same as a real new user would.
Map<String, List<Team>> _seedTeamsByHackathon() => {
  'saif': _saifTeams(),
  'ai-disability': _aiDisabilityTeams(),
  'agentx': const [],
  'gov-eservices': _govEservicesTeams(),
  'tanmiyathon': const [],
  'energy': _energyTeams(),
  'sidf': _sidfTeams(),
};

Map<String, List<Team>> _mockTeamsByHackathon = _seedTeamsByHackathon();

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

/// Removes a team the current user owns (see "Delete team" on their
/// profile) from whichever hackathon it belongs to.
void removeMockTeam(String teamId) {
  for (final hackathonId in _mockTeamsByHackathon.keys.toList()) {
    _mockTeamsByHackathon[hackathonId] = mockTeamsFor(
      hackathonId,
    ).where((t) => t.id != teamId).toList();
  }
}

/// The current user's own teams — the ones with 'ME' in
/// [Team.memberInitials], i.e. created locally via `createTeam`. Reads
/// straight from [_mockTeamsByHackathon], so this always matches what
/// the Teams screen shows for each hackathon.
List<Team> myMockTeams() => [
  for (final teams in _mockTeamsByHackathon.values)
    for (final team in teams)
      if (team.memberInitials.contains('ME')) team,
];

/// Finds a mock team by id across every hackathon, or `null`.
Team? findMockTeamById(String teamId) {
  for (final teams in _mockTeamsByHackathon.values) {
    for (final team in teams) {
      if (team.id == teamId) return team;
    }
  }
  return null;
}

/// Every team (across every hackathon) with a member matching [initials]
/// and [name] — used to show a teammate's *real* teams on their own
/// profile instead of a generic placeholder, since [Member] itself
/// carries no team/hackathon reference back to where it came from.
List<Team> mockTeamsForMember(String initials, String name) => [
  for (final teams in _mockTeamsByHackathon.values)
    for (final team in teams)
      if (team.membersInfo.any(
        (m) => m.initials == initials && m.name == name,
      ))
        team,
];

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

/// Builds the 2 seeded pending invitations, mirroring the live
/// `invitations` table, with timestamps relative to right now.
List<Invitation> _seedInvitations() {
  final now = DateTime.now();
  return [
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
          "We're missing a Flutter developer and a UI/UX designer — saw "
          "you've got both on your profile. Exactly what Team Elite needs.",
      expiresAt: now.add(const Duration(hours: 46)),
      status: 'pending',
      createdAt: now.subtract(const Duration(hours: 3)),
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
      message:
          "Your public speaking skill caught our eye — we need someone "
          'who can own the demo-day pitch. Join us for AI for Disability!',
      expiresAt: now.add(const Duration(days: 5)),
      status: 'pending',
      createdAt: now.subtract(const Duration(days: 1)),
    ),
  ];
}

List<Invitation> _mockInvitations = _seedInvitations();

/// Builds the 2 seeded sent requests, mirroring the live `join_requests`
/// table, with timestamps relative to right now.
List<SentRequest> _seedSentRequests() {
  final now = DateTime.now();
  return [
    SentRequest(
      id: 'sent-1',
      teamId: 'energy-crushers',
      teamName: 'Code Crushers',
      hackathonId: 'energy',
      hackathonName: 'Energy Hackathon',
      status: 'accepted',
      createdAt: now.subtract(const Duration(days: 2)),
    ),
    SentRequest(
      id: 'sent-2',
      teamId: 'gov-eservices-pioneers',
      teamName: 'The Pioneers',
      hackathonId: 'gov-eservices',
      hackathonName: 'Government E-Services Hackathon 2026',
      status: 'declined',
      createdAt: now.subtract(const Duration(hours: 6)),
    ),
  ];
}

List<SentRequest> _mockSentRequests = _seedSentRequests();

/// Resets every guest-mutable mock store (teams, invitations, sent
/// requests) back to its seeded defaults. Called every time a guest
/// session starts, so "Continue as Guest" always shows the same demo
/// data — regardless of what an earlier guest session in this same app
/// run created, joined, accepted, declined, or deleted.
void resetGuestMockData() {
  _mockTeamsByHackathon = _seedTeamsByHackathon();
  _mockInvitations = _seedInvitations();
  _mockSentRequests = _seedSentRequests();
}

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
