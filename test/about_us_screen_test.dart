import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector/screens/settings_screen.dart';
import 'package:vector/screens/about_us_screen.dart';

void main() {
  testWidgets(
    'settings opens About us and story fits narrow screens with large text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.6)),
            child: child!,
          ),
          home: const SettingsScreen(profile: {}),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('About us'), 300);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('About us'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('About us'));
      await tester.pumpAndSettle();
      expect(find.byType(AboutUsScreen), findsOneWidget);
      await tester.ensureVisible(find.text('Sham'));
      await tester.pumpAndSettle();
      expect(find.text('Imam Mohammed Ibn Saud University'), findsOneWidget);
      expect(find.text('King Saud University'), findsOneWidget);
      expect(find.text('Fatimah'), findsOneWidget);
      await tester.ensureVisible(find.text('Made in Saudi Arabia'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
    },
  );
}
