import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector/screens/home_screen.dart';
import 'package:vector/screens/teams_screen.dart';
import 'package:vector/widgets/hackathon_cards.dart';

void main() {
  for (final height in [600.0, 900.0]) {
    testWidgets('team navigation fits during every frame at height $height', (
      tester,
    ) async {
      tester.view.physicalSize = Size(390, height);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();
      tester
          .widget<HackathonCard>(find.byType(HackathonCard).first)
          .onArrowTap!();
      for (var frame = 0; frame < 35; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.takeException(), isNull);
      }
      expect(find.byType(TeamsScreen), findsOneWidget);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
