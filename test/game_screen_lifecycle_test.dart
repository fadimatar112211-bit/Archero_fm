import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/main.dart';

void main() {
  testWidgets('game screen initializes and disposes its timed resources',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: GameScreen(heroType: 1),
    ));
    await tester.pump(const Duration(milliseconds: 32));

    expect(find.byType(GameScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
