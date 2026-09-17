import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector/screens/forgot_password_screen.dart';
import 'package:vector/screens/log_in_screen.dart';
import 'package:vector/screens/settings_screen.dart';
import 'package:vector/widgets/confirm_action_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final family in ['Manrope', 'Cormorant Garamond']) {
      final loader = FontLoader(family)
        ..addFont(
          rootBundle.load('assets/fonts/${family.replaceAll(' ', '')}.ttf'),
        );
      await loader.load();
    }
  });
  testWidgets(
    'forgot password validates email and completes without auth setup',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: const LogInScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Forgot password?'));
      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      await tester.ensureVisible(find.text('Reset password'));
      await tester.tap(find.text('Reset password'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid email.'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.ensureVisible(find.text('Reset password'));
      await tester.tap(find.text('Reset password'));
      await tester.pumpAndSettle();
      expect(
        find.text('Check your email to reset your password.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Back to sign in'));
      await tester.pumpAndSettle();
      expect(find.byType(LogInScreen), findsOneWidget);
    },
  );

  testWidgets('cancel logout keeps settings open', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SettingsScreen(profile: {})),
    );
    await tester.scrollUntilVisible(find.text('Log Out'), 300);
    await tester.tap(find.text('Log Out'));
    await tester.pumpAndSettle();
    expect(find.text('Are you sure you want to log out?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.byType(LogInScreen), findsNothing);
  });

  testWidgets('confirmation requires an explicit positive action', (
    tester,
  ) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showConfirmActionDialog(
                  context,
                  title: 'Withdraw request?',
                  message: 'Are you sure?',
                  confirmLabel: 'Withdraw',
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(result, false);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Withdraw'));
    await tester.pumpAndSettle();
    expect(result, true);
  });
}
