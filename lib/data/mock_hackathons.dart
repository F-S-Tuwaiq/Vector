import '../models/hackathon.dart';
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
      ),
      Team(
        id: '$hackathonId-pioneers',
        hackathonId: hackathonId,
        name: 'The Pioneers',
        members: 4,
        maxMembers: 5,
        memberInitials: const ['AR', 'LT', 'JS', 'FA'],
        missingRoles: const ['Data Analyst'],
      ),
      Team(
        id: '$hackathonId-crushers',
        hackathonId: hackathonId,
        name: 'Code Crushers',
        members: 2,
        maxMembers: 5,
        memberInitials: const ['OM', 'RK'],
        missingRoles: const ['Backend Developer', 'Designer', 'Marketer'],
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
