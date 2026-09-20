import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailVerificationRequired implements Exception {
  const EmailVerificationRequired();

  @override
  String toString() =>
      'Open the confirmation link sent to your email, then return to Vector.';
}

class BackendNotConfigured implements Exception {
  const BackendNotConfigured();

  @override
  String toString() =>
      "This demo isn't connected to a live account system yet. "
      'Try Continue as Guest instead.';
}

class SupabaseService {
  // ============================================================
  // SUPABASE CONFIG
  // ============================================================

  static String get supabaseUrl => dotenv.env['SUPABASE_URL']?.trim() ?? '';

  static String get supabasePublishableKey =>
      dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';

  /// Whether [initialize] actually configured a live Supabase client.
  /// False while `.env` still holds placeholder/missing credentials —
  /// the app should still run and land on the login screen in that
  /// case, it just can't authenticate against a real backend yet.
  static bool isConfigured = false;

  // ============================================================
  // INITIALIZE SUPABASE
  // ============================================================

  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
    final uri = Uri.tryParse(supabaseUrl);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        supabasePublishableKey.isEmpty ||
        supabasePublishableKey == 'PASTE_ANON_KEY_HERE') {
      // No real credentials yet - skip Supabase setup instead of
      // crashing on startup. Set SUPABASE_URL and SUPABASE_ANON_KEY in
      // .env to enable real sign-in.
      return;
    }
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabasePublishableKey,
      authOptions: const FlutterAuthClientOptions(
        persistSession: true,
        autoRefreshToken: true,
      ),
    );
    isConfigured = true;
  }

  // ============================================================
  // CLIENT
  // ============================================================

  static SupabaseClient get client {
    if (!isConfigured) throw const BackendNotConfigured();
    return Supabase.instance.client;
  }

  static User? get currentUser => isConfigured ? client.auth.currentUser : null;

  static bool get isLoggedIn => currentUser != null;

  // ============================================================
  // SIGN IN
  // ============================================================

  static Future<void> signIn(String email, String password) async {
    try {
      await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (error) {
      if (error.code == 'email_not_confirmed') {
        throw const EmailVerificationRequired();
      }
      rethrow;
    }
  }

  static Future<void> verifySignupCode(String email, String code) async {
    final response = await client.auth.verifyOTP(
      email: email.trim(),
      token: code.trim(),
      type: OtpType.email,
    );
    if (response.session == null) {
      throw const EmailVerificationRequired();
    }
  }

  static const confirmationRedirectUrl =
      'https://vector-email-confirmation.shammalbinni.chatgpt.site';

  static Future<void> resendSignupCode(String email) async {
    await client.auth.resend(
      type: OtpType.signup,
      email: email.trim(),
      emailRedirectTo: confirmationRedirectUrl,
    );
  }

  // ============================================================
  // CREATE ACCOUNT
  // ============================================================

  static Future<void> createAccount({
    required String fullName,
    required String email,
    required String password,
    String? github,
    String? linkedin,
    required List<String> skills,
    required Map<String, List<XFile>> certificates,
  }) async {
    // ----------------------------------------------------------
    // 1. CREATE USER IN SUPABASE AUTH
    // ----------------------------------------------------------

    // Signing in first also resumes a verified or partially saved account.
    late final AuthResponse authResponse;
    try {
      authResponse = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (error) {
      if (error.code == 'email_not_confirmed') {
        throw const EmailVerificationRequired();
      }
      if (error.code != 'invalid_credentials') rethrow;
      authResponse = await client.auth.signUp(
        emailRedirectTo: confirmationRedirectUrl,
        email: email.trim(),
        password: password,
        data: {'full_name': fullName.trim()},
      );
    }

    final User? user = authResponse.user;

    if (user == null) {
      throw Exception('Account could not be created.');
    }

    // Your current signup flow immediately writes to
    // RLS-protected tables, so it needs an authenticated session.
    if (authResponse.session == null) {
      throw const EmailVerificationRequired();
    }

    final String userId = user.id;

    // ----------------------------------------------------------
    // 2. CREATE PROFILE
    // ----------------------------------------------------------

    await client.from('profiles').upsert({
      'id': userId,
      'full_name': fullName.trim(),
      'github': _optionalString(github),
      'linkedin': _optionalString(linkedin),
    });

    // ----------------------------------------------------------
    // 3. CREATE EACH SKILL
    // ----------------------------------------------------------

    for (final String skill in skills) {
      final String cleanSkill = skill.trim();

      if (cleanSkill.isEmpty) {
        continue;
      }

      final Map<String, dynamic> insertedSkill = await client
          .from('user_skills')
          .upsert({
            'user_id': userId,
            'skill': cleanSkill,
          }, onConflict: 'user_id,skill')
          .select('id')
          .single();

      final int skillId = insertedSkill['id'] as int;

      // --------------------------------------------------------
      // 4. UPLOAD CERTIFICATES ATTACHED TO THIS SKILL
      // --------------------------------------------------------

      final List<XFile> files = certificates[skill] ?? <XFile>[];

      for (final XFile file in files) {
        await _uploadCertificate(userId: userId, skillId: skillId, file: file);
      }
    }
  }

  // ============================================================
  // UPLOAD CERTIFICATE
  // ============================================================

  static Future<void> _uploadCertificate({
    required String userId,
    required int skillId,
    required XFile file,
  }) async {
    final Uint8List bytes = await file.readAsBytes();

    final String safeName = _safeFileName(file.name);

    final String uniqueName = '${sha256.convert(bytes)}_$safeName';

    // Example:
    // USER_ID / SKILL_ID / certificate.pdf
    final String storagePath = '$userId/$skillId/$uniqueName';

    final existing = await client
        .from('skill_certificates')
        .select('id')
        .eq('user_id', userId)
        .eq('storage_path', storagePath)
        .limit(1);
    if (existing.isNotEmpty) return;

    // Upload actual PDF/image to Supabase Storage.
    try {
      await client.storage
          .from('certificates')
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(
              upsert: false,
              contentType: _contentTypeForFile(file.name),
            ),
          );
    } on StorageException catch (error) {
      // A previous upload may have succeeded before its metadata save failed.
      if (error.statusCode != '409' && error.error != 'Duplicate') rethrow;
    }

    // Save certificate information in database.
    await client.from('skill_certificates').insert({
      'user_id': userId,
      'skill_id': skillId,
      'file_name': file.name,
      'storage_path': storagePath,
    });
  }

  static String get _profileUserId {
    final user = currentUser;
    if (user == null) throw StateError('Sign in to edit your profile.');
    return user.id;
  }

  static Future<Map<String, dynamic>> loadProfile() async {
    final id = _profileUserId;
    final results = await Future.wait([
      client.from('profiles').select().eq('id', id).maybeSingle(),
      client
          .from('user_skills')
          .select('id,skill')
          .eq('user_id', id)
          .order('id'),
      client
          .from('skill_certificates')
          .select('id,skill_id,file_name,storage_path')
          .eq('user_id', id)
          .order('id'),
    ]);
    return {
      'profile': results[0] ?? <String, dynamic>{},
      'skills': results[1],
      'certificates': results[2],
    };
  }

  static Future<void> saveProfile({
    required String fullName,
    String? github,
    String? linkedin,
    String? headline,
    String? about,
    String? availability,
  }) async {
    if (fullName.trim().isEmpty) throw ArgumentError('Enter your name.');
    await client.from('profiles').upsert({
      'id': _profileUserId,
      'full_name': fullName.trim(),
      'github': _optionalString(github),
      'linkedin': _optionalString(linkedin),
    });
    // These optional presentation fields use auth metadata; no assumed DB columns.
    if (headline != null || about != null || availability != null) {
      await client.auth.updateUser(
        UserAttributes(
          data: {
            if (headline != null) 'headline': headline.trim(),
            if (about != null) 'about': about.trim(),
            if (availability != null) 'availability': availability.trim(),
          },
        ),
      );
    }
  }

  static Future<void> saveProfileAbout(String about) async {
    final id = _profileUserId;
    final profile = await client
        .from('profiles')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (profile?.containsKey('about') == true) {
      await client
          .from('profiles')
          .update({'about': about.trim()})
          .eq('id', id);
    } else {
      await client.auth.updateUser(
        UserAttributes(data: {'about': about.trim()}),
      );
    }
  }

  static Future<void> addProfileSkill(String skill) async {
    final clean = skill.trim();
    if (clean.isEmpty) throw ArgumentError('Enter a skill.');
    await client.from('user_skills').upsert({
      'user_id': _profileUserId,
      'skill': clean,
    }, onConflict: 'user_id,skill');
  }

  static Future<void> attachProfileCertificate({
    required int skillId,
    required XFile file,
    int maxBytes = 10 * 1024 * 1024,
  }) async {
    final extension = file.name.split('.').last.toLowerCase();
    if (!['pdf', 'png', 'jpg', 'jpeg'].contains(extension)) {
      throw ArgumentError('Choose a PDF, PNG or JPG file.');
    }
    if (await file.length() > maxBytes) {
      throw ArgumentError(
        'Choose a file smaller than ${maxBytes ~/ (1024 * 1024)} MB.',
      );
    }
    final id = _profileUserId;
    await client
        .from('user_skills')
        .select('id')
        .eq('user_id', id)
        .eq('id', skillId)
        .single();
    final existing = await client
        .from('skill_certificates')
        .select('id')
        .eq('user_id', id)
        .eq('skill_id', skillId);
    if (existing.length >= 3) {
      throw StateError('Each skill can have up to 3 certificates.');
    }
    await _uploadCertificate(userId: id, skillId: skillId, file: file);
  }

  static Future<void> removeProfileSkill(
    Map<String, dynamic> skill,
    List<Map<String, dynamic>> attachments,
  ) async {
    final userId = _profileUserId;
    final skillId = skill['id'] as int;
    await client
        .from('skill_certificates')
        .delete()
        .eq('user_id', userId)
        .eq('skill_id', skillId);
    try {
      await client
          .from('user_skills')
          .delete()
          .eq('user_id', userId)
          .eq('id', skillId);
    } catch (_) {
      // Compensate if the parent deletion is rejected. Never delete file bytes.
      await restoreProfileAttachments(attachments, skillId: skillId);
      rethrow;
    }
  }

  static Future<void> restoreProfileAttachments(
    List<Map<String, dynamic>> attachments, {
    required int skillId,
  }) async {
    final userId = _profileUserId;
    if (attachments.isEmpty) return;
    await client
        .from('skill_certificates')
        .upsert(
          attachments
              .map(
                (attachment) => {
                  'id': attachment['id'],
                  'user_id': userId,
                  'skill_id': skillId,
                  'file_name': attachment['file_name'],
                  'storage_path': attachment['storage_path'],
                },
              )
              .toList(),
          onConflict: 'id',
        );
  }

  static Future<void> restoreProfileSkill(
    Map<String, dynamic> skill,
    List<Map<String, dynamic>> attachments,
  ) async {
    await client.from('user_skills').upsert({
      'id': skill['id'],
      'user_id': _profileUserId,
      'skill': skill['skill'],
    }, onConflict: 'id');
    await restoreProfileAttachments(attachments, skillId: skill['id'] as int);
  }

  static Future<String> profileAttachmentUrl(int certificateId) async {
    // Resolve the path from an authorized association, never from caller input.
    final record = await client
        .from('skill_certificates')
        .select('storage_path')
        .eq('user_id', _profileUserId)
        .eq('id', certificateId)
        .single();
    return client.storage
        .from('certificates')
        .createSignedUrl(record['storage_path'] as String, 60);
  }

  // ============================================================
  // SIGN OUT
  // ============================================================

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // ============================================================
  // DELETE CERTIFICATE
  // Useful later for profile editing.
  // ============================================================

  static Future<void> deleteCertificate({
    required int certificateId,
    required String storagePath,
  }) async {
    // Unlink only. Storage may be shared, and Undo needs the original bytes.
    await client
        .from('skill_certificates')
        .delete()
        .eq('user_id', _profileUserId)
        .eq('id', certificateId)
        .eq('storage_path', storagePath);
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static String? _optionalString(String? value) {
    if (value == null) {
      return null;
    }

    final String cleaned = value.trim();

    if (cleaned.isEmpty) {
      return null;
    }

    return cleaned;
  }

  static String _safeFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
  }

  static String? _contentTypeForFile(String fileName) {
    final String lower = fileName.toLowerCase();

    if (lower.endsWith('.pdf')) {
      return 'application/pdf';
    }

    if (lower.endsWith('.png')) {
      return 'image/png';
    }

    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }

    return null;
  }
}
