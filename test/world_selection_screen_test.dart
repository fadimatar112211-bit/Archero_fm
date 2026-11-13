import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:archero_fm/game_progress.dart';
import 'package:archero_fm/world_selection_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    bestStage = 11;
  });

  testWidgets('shows the newly unlocked world and selected continue stage',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: WorldSelectionScreen(heroType: 1, heroName: 'الرامي المتوازن'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('البركان الملتهب'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);
    expect(find.text('الاختيار الحالي: العالم 2 — المرحلة 11'), findsOneWidget);
  });

  testWidgets('locked stage cannot replace the selected unlocked stage',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: WorldSelectionScreen(heroType: 1, heroName: 'الرامي المتوازن'),
      ),
    );
    await tester.pumpAndSettle();

    final lockedStage = find.text('12');
    await tester.ensureVisible(lockedStage);
    await tester.tap(lockedStage);
    await tester.pump();

    expect(find.text('الاختيار الحالي: العالم 2 — المرحلة 11'), findsOneWidget);
  });
}
