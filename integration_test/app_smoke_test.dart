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
  });
}
