import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vector/widgets/signup_code_dialog.dart';

import 'package:file_selector/file_selector.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vector/services/supabase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/shared_preferences'),
        (call) async => call.method == 'getAll' ? <String, Object>{} : true,
      );
  final user = {
    'id': '11111111-1111-4111-8111-111111111111',
    'aud': 'authenticated',
    'email': 'test@example.com',
    'created_at': '2026-01-01T00:00:00Z',
    'app_metadata': <String, dynamic>{},
    'user_metadata': <String, dynamic>{},
  };
  late List<http.Request> requests;
  late bool verified;
  late bool unconfirmed;
  var omitSession = false;
  var existingSignup = false;

  setUp(() async {
    requests = [];
    verified = false;
    omitSession = false;
    existingSignup = false;
    unconfirmed = false;
    SupabaseService.isConfigured = true;
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      publishableKey: 'test-key',
      debug: false,
      authOptions: const FlutterAuthClientOptions(
        persistSession: false,
        detectSessionInUri: false,
        autoRefreshToken: false,
        authFlowType: AuthFlowType.implicit,
      ),
      httpClient: MockClient((request) async {
        requests.add(request);
        final path = request.url.path;
        if (path == '/auth/v1/token') {
          if (omitSession) {
            return http.Response(jsonEncode({'user': user}), 200);
          }
          if (!verified) {
            return http.Response(
              jsonEncode({
                'error_code': unconfirmed
                    ? 'email_not_confirmed'
                    : 'invalid_credentials',
                'msg': 'Invalid login credentials',
              }),
              400,
            );
          }
          return http.Response(
            jsonEncode({
              'access_token': 'test-token',
              'refresh_token': 'test-refresh',
              'token_type': 'bearer',
              'expires_in': 3600,
              'user': user,
            }),
            200,
          );
        }
        if (path == '/auth/v1/verify') {
          final body = jsonDecode(request.body);
          if (body['token'] != '123456') {
            return http.Response(
              jsonEncode({'error_code': 'otp_expired', 'msg': 'Invalid code'}),
              403,
            );
          }
          verified = true;
          return http.Response(
            jsonEncode({
              'access_token': 'test-token',
              'refresh_token': 'test-refresh',
              'token_type': 'bearer',
              'expires_in': 3600,
              'user': user,
            }),
            200,
          );
        }
        if (path == '/auth/v1/resend') {
          return http.Response('{}', 200);
        }
        if (path == '/auth/v1/signup') {
          return http.Response(
            jsonEncode({...user, if (existingSignup) 'identities': []}),
            200,
          );
        }
        if (path == '/rest/v1/profiles') {
          if (request.method == 'GET') {
            return http.Response(
              '{"id":"${user['id']}","full_name":"Test User"}',
              200,
              request: request,
              headers: {'content-type': 'application/json'},
            );
          }
          return http.Response('', 204, request: request);
        }
        if (path == '/rest/v1/skill_certificates') {
          return http.Response(
            '[{"id":7,"skill_id":1,"file_name":"dart.pdf","storage_path":"user/1/dart.pdf"}]',
            200,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }
        if (path == '/rest/v1/user_skills') {
          if (request.method == 'GET') {
            return http.Response(
              '[{"id":1,"skill":"Dart"},{"id":2,"skill":"Custom signup skill"}]',
              200,
              request: request,
              headers: {'content-type': 'application/json'},
            );
          }
          return http.Response(
            '{"id":1}',
            201,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }
        throw StateError('Unexpected request: $path');
      }),
    );
  });

  tearDown(() async {
    SupabaseService.isConfigured = false;
    await Supabase.instance.dispose();
  });

  test('sign in rejects an auth response without a session', () async {
    omitSession = true;
    await expectLater(
      SupabaseService.signIn('test@example.com', 'test-password'),
      throwsA(isA<AuthException>()),
    );
    expect(SupabaseService.isLoggedIn, isFalse);
  });

  Future<void> submit({bool resume = false}) => SupabaseService.createAccount(
    resumeAfterVerification: resume,
    fullName: 'Test User',
    email: 'test@example.com',
    password: 'test-password',
    skills: ['Dart'],
    certificates: {},
  );

  test('new signup never silently signs into an existing account', () async {
    verified = true;
    existingSignup = true;
    await expectLater(submit(), throwsA(isA<AuthException>()));
    expect(requests.map((r) => r.url.path), ['/auth/v1/signup']);
    expect(SupabaseService.isLoggedIn, isFalse);
  });

  test('waits for email verification before database writes', () async {
    await expectLater(submit(), throwsA(isA<EmailVerificationRequired>()));
    expect(requests.any((r) => r.url.path.startsWith('/rest/')), isFalse);
  });

  test('resumes after verification and saves profile and skills', () async {
    await expectLater(submit(), throwsA(isA<EmailVerificationRequired>()));
    requests.clear();
    await SupabaseService.verifySignupCode('test@example.com', '123456');
    await submit(resume: true);
    expect(requests.any((r) => r.url.path == '/auth/v1/signup'), isFalse);
    final profile = requests.singleWhere(
      (r) => r.url.path == '/rest/v1/profiles',
    );
    expect(jsonDecode(profile.body)['id'], user['id']);
    final skill = requests.singleWhere(
      (r) => r.url.path == '/rest/v1/user_skills',
    );
    expect(jsonDecode(skill.body)['user_id'], user['id']);
    expect(skill.url.queryParameters['on_conflict'], 'user_id,skill');
  });
  test(
    'confirmation link resumes signup without sending another email',
    () async {
      unconfirmed = true;
      await expectLater(
        submit(resume: true),
        throwsA(isA<EmailVerificationRequired>()),
      );
      expect(requests.any((r) => r.url.path == '/auth/v1/signup'), isFalse);
      verified = true;
      requests.clear();
      await SupabaseService.signIn('test@example.com', 'test-password');
      await submit(resume: true);
      expect(requests.any((r) => r.url.path == '/rest/v1/profiles'), isTrue);
      expect(
        requests.any(
          (r) =>
              r.url.path == '/auth/v1/signup' ||
              r.url.path == '/auth/v1/resend',
        ),
        isFalse,
      );
    },
  );

  test('signup and resend both use the HTTPS confirmation page', () async {
    await expectLater(submit(), throwsA(isA<EmailVerificationRequired>()));
    await SupabaseService.resendSignupCode('test@example.com');
    final emails = requests.where(
      (r) => r.url.path == '/auth/v1/signup' || r.url.path == '/auth/v1/resend',
    );
    expect(emails, hasLength(2));
    for (final request in emails) {
      expect(
        request.url.queryParameters['redirect_to'],
        SupabaseService.confirmationRedirectUrl,
      );
    }
  });

  testWidgets(
    'email dialog checks confirmation without resending or requiring OTP',
    (tester) async {
      unconfirmed = true;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showDialog<bool>(
                  context: context,
                  builder: (_) => const SignupCodeDialog(
                    email: 'test@example.com',
                    password: 'test-password',
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      await tester.tap(find.text("I've confirmed my email"));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Your email is not confirmed yet.'),
        findsOneWidget,
      );
      expect(requests.every((r) => r.url.path == '/auth/v1/token'), isTrue);
      verified = true;
      await tester.tap(find.text("I've confirmed my email"));
      await tester.pumpAndSettle();
      expect(find.byType(SignupCodeDialog), findsNothing);
      expect(SupabaseService.isLoggedIn, isTrue);
    },
  );

  test('unconfirmed login requests code verification', () async {
    unconfirmed = true;
    await expectLater(
      SupabaseService.signIn('test@example.com', 'test-password'),
      throwsA(isA<EmailVerificationRequired>()),
    );
    expect(SupabaseService.isLoggedIn, isFalse);
  });

  test('invalid OTP does not establish a session', () async {
    await expectLater(
      SupabaseService.verifySignupCode('test@example.com', '000000'),
      throwsA(isA<AuthException>()),
    );
    expect(SupabaseService.isLoggedIn, isFalse);
  });

  test('OTP verification uses the email token type and trims input', () async {
    await SupabaseService.verifySignupCode(' test@example.com ', ' 123456 ');
    final body = jsonDecode(requests.single.body);
    expect(body['email'], 'test@example.com');
    expect(body['token'], '123456');
    expect(body['type'], 'email');
    expect(SupabaseService.isLoggedIn, isTrue);
  });

  test(
    'profile loads exact signup skills and user-scoped certificates',
    () async {
      await SupabaseService.verifySignupCode('test@example.com', '123456');
      requests.clear();
      final result = await SupabaseService.loadProfile();
      expect((result['profile'] as Map)['full_name'], 'Test User');
      expect((result['skills'] as List).map((s) => s['skill']), [
        'Dart',
        'Custom signup skill',
      ]);
      expect((result['certificates'] as List).single['skill_id'], 1);
      for (final request in requests) {
        final column = request.url.path.endsWith('/profiles')
            ? 'id'
            : 'user_id';
        expect(request.url.queryParameters[column], 'eq.${user['id']}');
      }
    },
  );

  test('adding a skill preserves existing skills with an upsert', () async {
    await SupabaseService.verifySignupCode('test@example.com', '123456');
    requests.clear();
    await SupabaseService.addProfileSkill(' Flutter ');
    final request = requests.single;
    expect(request.method, 'POST');
    expect(jsonDecode(request.body), {
      'user_id': user['id'],
      'skill': 'Flutter',
    });
    expect(request.url.queryParameters['on_conflict'], 'user_id,skill');
  });

  test('evidence rejects unsupported files and oversized files before network writes', () async {
    await SupabaseService.verifySignupCode('test@example.com', '123456');
    requests.clear();
    await expectLater(
      SupabaseService.attachProfileCertificate(
        skillId: 1,
        file: XFile.fromData(Uint8List(1), path: '/tmp/file.exe'),
      ),
      throwsArgumentError,
    );
    await expectLater(
      SupabaseService.attachProfileCertificate(
        skillId: 1,
        file: XFile.fromData(Uint8List(11), path: '/tmp/file.pdf'),
        maxBytes: 10,
      ),
      throwsArgumentError,
    );
    expect(requests, isEmpty);
  });

  test(
    'unlink evidence is scoped to owner and never deletes storage bytes',
    () async {
      await SupabaseService.verifySignupCode('test@example.com', '123456');
      requests.clear();
      await SupabaseService.deleteCertificate(
        certificateId: 7,
        storagePath: 'shared/evidence.pdf',
      );
      expect(requests.length, 1);
      expect(requests.single.method, 'DELETE');
      expect(requests.single.url.path, '/rest/v1/skill_certificates');
      expect(
        requests.single.url.queryParameters['user_id'],
        'eq.${user['id']}',
      );
      expect(requests.single.url.queryParameters['id'], 'eq.7');
    },
  );

  test(
    'remove skill unlinks evidence and Undo restores original association IDs',
    () async {
      await SupabaseService.verifySignupCode('test@example.com', '123456');
      requests.clear();
      final skill = <String, dynamic>{'id': 1, 'skill': 'Dart'};
      final files = <Map<String, dynamic>>[
        {'id': 7, 'file_name': 'dart.pdf', 'storage_path': 'shared/dart.pdf'},
      ];
      await SupabaseService.removeProfileSkill(skill, files);
      expect(requests.map((r) => r.method), ['DELETE', 'DELETE']);
      await SupabaseService.restoreProfileSkill(skill, files);
      final restored = jsonDecode(requests.last.body) as List;
      expect(restored.single['skill_id'], 1);
      expect(restored.single['id'], 7);
      expect(restored.single['storage_path'], 'shared/dart.pdf');
      expect(requests.any((r) => r.url.path.startsWith('/storage/')), isFalse);
    },
  );

  test('resends a signup confirmation code', () async {
    await SupabaseService.resendSignupCode(' test@example.com ');
    final body = jsonDecode(requests.single.body);
    expect(body['email'], 'test@example.com');
    expect(body['type'], 'signup');
  });
}
