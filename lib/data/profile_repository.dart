import 'package:file_selector/file_selector.dart';

import '../models/hackathon.dart';
import '../models/team.dart';
import 'hackathon_repository.dart';
import '../services/supabase_service.dart';

/// Supply only authenticated records. The current teams API has neither a
/// user membership relation nor participation history, so no demo fallback.
typedef ParticipationLoader = Future<List<ProfileParticipation>> Function(
  String userId,
);

enum MembershipStatus { member, requested, leader }

class ProfileParticipation {
  const ProfileParticipation({
    required this.id,
    required this.team,
    required this.event,
    required this.status,
    this.role,
    this.date,
    this.completed = false,
    this.isPreview = false,
  });
  final String id;
  final Team team;
  final Hackathon event;
  final MembershipStatus status;
  final String? role;
  final String? date;
  final bool completed;
  final bool isPreview;
}

class ProfileRepository {
  const ProfileRepository({this.participationLoader});
  final ParticipationLoader? participationLoader;
  Future<Map<String, dynamic>> load() => SupabaseService.loadProfile();
  Future<void> saveIdentity({
    required String name,
    required String github,
    required String linkedin,
  }) => SupabaseService.saveProfile(
    fullName: name,
    github: github,
    linkedin: linkedin,
  );
  Future<void> saveAbout(String about) =>
      SupabaseService.saveProfileAbout(about);
  Future<void> addSkill(String skill) => SupabaseService.addProfileSkill(skill);
  Future<void> attach(int skillId, XFile file, int maxBytes) =>
      SupabaseService.attachProfileCertificate(
        skillId: skillId,
        file: file,
        maxBytes: maxBytes,
      );
  Future<void> removeAttachment(Map<String, dynamic> attachment) =>
      SupabaseService.deleteCertificate(
        certificateId: attachment['id'] as int,
        storagePath: attachment['storage_path'] as String,
      );
  Future<void> removeSkill(
    Map<String, dynamic> skill,
    List<Map<String, dynamic>> attachments,
  ) => SupabaseService.removeProfileSkill(skill, attachments);
  Future<void> restoreAttachment(
    Map<String, dynamic> skill,
    Map<String, dynamic> attachment,
  ) => SupabaseService.restoreProfileAttachments([
    attachment,
  ], skillId: skill['id'] as int);
  Future<void> restoreSkill(
    Map<String, dynamic> skill,
    List<Map<String, dynamic>> attachments,
  ) => SupabaseService.restoreProfileSkill(skill, attachments);
  Future<String> attachmentUrl(int id) =>
      SupabaseService.profileAttachmentUrl(id);
  Future<List<ProfileParticipation>> participations() async {
    final loader = participationLoader;
    if (loader == null) {
      final events = await HackathonRepository().fetchHackathons();
      if (events.isEmpty) return [];
      return List.generate(2, (index) {
        final event = events[index % events.length];
        final name = index == 0 ? 'Pixel Pioneers' : 'Neural Nexus';
        return ProfileParticipation(
          id: 'preview-$index',
          team: Team(
            id: 'preview-$index',
            hackathonId: event.id,
            name: name,
            members: index == 0 ? 4 : 3,
            maxMembers: 5,
          ),
          event: event,
          status: index == 0
              ? MembershipStatus.member
              : MembershipStatus.requested,
          isPreview: true,
        );
      });
    }
    final user = SupabaseService.currentUser;
    if (user == null) throw StateError('Sign in to load your teams.');
    final records = await loader(user.id);
    // A pending request is not a completed participation or a membership.
    return records
        .where((r) => !(r.completed && r.status == MembershipStatus.requested))
        .toList();
  }
}
