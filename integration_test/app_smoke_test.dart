import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:archero_fm/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android app launches into the main menu', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(432, 960);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ArcheroSoundApp());
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('ARCHERO · SOUND EDITION'), findsOneWidget);
    expect(find.textContaining('رصيدك:'), findsOneWidget);

    // Walk through the real onboarding route and enter a playable stage.
    await tester.tap(find.text('اختيار البطل واللعب'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('اختر بطلك الأسطوري'), findsOneWidget);
    await tester.tap(find.textContaining('الرامي المتوازن'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('اختر العالم والمرحلة'), findsOneWidget);
    await tester.tap(find.text('ابدأ المرحلة 1'));
    await tester.pump(const Duration(milliseconds: 700));

    // The arena should be live and expose its pause control.
    await tester.pump(const Duration(seconds: 2));
    expect(find.byIcon(Icons.pause), findsOneWidget);
    expect(find.byKey(const ValueKey('game-arena-gesture')), findsOneWidget);

    // Exercise touch movement and the active-skill control on the emulator.
    await tester.drag(
      find.byKey(const ValueKey('game-arena-gesture')),
      const Offset(72, -54),
      touchSlopY: 2,
    );
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.text('المهارة الخاصة'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  });
}
