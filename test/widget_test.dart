import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/main.dart';

void main() {
  testWidgets('main menu renders and offers hero selection', (tester) async {
    await tester.pumpWidget(const ArcheroSoundApp());
    expect(find.text('ARCHERO: SOUND EDITION'), findsOneWidget);
    expect(find.text('اختيار البطل واللعب'), findsOneWidget);
  });

  testWidgets('main menu adapts to phone and tablet viewports', (tester) async {
    const sizes = <Size>[
      Size(360, 640),
      Size(390, 844),
      Size(800, 1280),
    ];
    for (final size in sizes) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(const ArcheroSoundApp());
      await tester.pump();
      expect(find.text('اختيار البطل واللعب'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
