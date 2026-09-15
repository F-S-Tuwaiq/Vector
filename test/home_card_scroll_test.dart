import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector/screens/home_screen.dart';
import 'package:vector/widgets/hackathon_cards.dart';

void main() {
  testWidgets('third card remains below filters after first card collapses', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
    final cards = find.byType(HackathonCard);
    final thirdId = tester.widget<HackathonCard>(cards.at(2)).hackathon.id;
    tester.widget<HackathonCard>(cards.first).onTap!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 340));
    await tester.pumpAndSettle();
    final third = find.byWidgetPredicate(
      (w) => w is HackathonCard && w.hackathon.id == thirdId,
    );
    tester.widget<HackathonCard>(third).onTap!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 340));
    await tester.pumpAndSettle();
    final list = find.byWidgetPredicate(
      (w) => w is ListView && w.scrollDirection == Axis.vertical,
    );
    expect(tester.widget<HackathonCard>(third).isExpanded, isTrue);
    expect(
      tester.getTopLeft(third).dy,
      greaterThanOrEqualTo(tester.getTopLeft(list).dy),
    );
    expect(tester.takeException(), isNull);
  });
}
