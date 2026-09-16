import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector/widgets/brand_loader/brand_full_screen_loader.dart';
import 'package:vector/widgets/brand_loader/v_logo_animation.dart';
import 'package:vector/widgets/brand_loader/v_logo_painter.dart';

void main() {
  for (final sequence in VLogoSequence.values) {
    testWidgets('${sequence.name} stops on the requested strokes', (
      tester,
    ) async {
      var completions = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: VLogoAnimation(
              size: 120,
              sequence: sequence,
              onComplete: () => completions++,
            ),
          ),
        ),
      );
      await tester.pump(sequence.duration);
      await tester.pump(const Duration(seconds: 4));
      final paint = tester.widget<CustomPaint>(
        find.byWidgetPredicate(
          (widget) => widget is CustomPaint && widget.painter is VLogoPainter,
        ),
      );
      final painter = paint.painter! as VLogoPainter;
      expect(painter.whiteReveal, 1);
      expect(painter.orangeReveal, sequence == VLogoSequence.oneV ? 1 : 0);
      expect(completions, 1);
    });
  }

  testWidgets('blurs the source page until the fetch completes', (
    tester,
  ) async {
    final ready = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                await runWithBrandFullScreenLoader(context, () => ready.future);
                if (!context.mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(body: Text('Cards ready')),
                  ),
                );
              },
              child: const Text('Current page'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Current page'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Current page'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(find.byType(VLogoAnimation), findsOneWidget);
    expect(find.text('Cards ready'), findsNothing);
    expect(tester.takeException(), isNull);
    ready.complete();
    await tester.pumpAndSettle();
    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.text('Cards ready'), findsOneWidget);
  });
}
