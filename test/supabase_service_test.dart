import 'dart:convert';

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

  setUp(() async {
    requests = [];
    verified = false;
    unconfirmed = false;
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
          return http.Response(jsonEncode(user), 200);
        }
        if (path == '/rest/v1/profiles')
          return http.Response('', 204, request: request);
        if (path == '/rest/v1/user_skills') {
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

  tearDown(() async => Supabase.instance.dispose());

  Future<void> submit() => SupabaseService.createAccount(
    fullName: 'Test User',
    email: 'test@example.com',
    password: 'test-password',
    skills: ['Dart'],
    certificates: {},
  );

  test('waits for email verification before database writes', () async {
    await expectLater(submit(), throwsA(isA<EmailVerificationRequired>()));
    expect(requests.any((r) => r.url.path.startsWith('/rest/')), isFalse);
  });

  test('resumes after verification and saves profile and skills', () async {
    await expectLater(submit(), throwsA(isA<EmailVerificationRequired>()));
    requests.clear();
    await SupabaseService.verifySignupCode('test@example.com', '123456');
    await submit();
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

  test('resends a signup confirmation code', () async {
    await SupabaseService.resendSignupCode(' test@example.com ');
    final body = jsonDecode(requests.single.body);
    expect(body['email'], 'test@example.com');
    expect(body['type'], 'signup');
  });
}
