import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailVerificationRequired implements Exception {
  const EmailVerificationRequired();

  @override
  String toString() => 'Enter the verification code sent to your email.';
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
    );
    isConfigured = true;
  }

  // ============================================================
  // CLIENT
  // ============================================================

  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser =>
      isConfigured ? client.auth.currentUser : null;

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

  static Future<void> resendSignupCode(String email) async {
    await client.auth.resend(type: OtpType.signup, email: email.trim());
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
    await client.storage.from('certificates').remove([storagePath]);

    await client.from('skill_certificates').delete().eq('id', certificateId);
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
