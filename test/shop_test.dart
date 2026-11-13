import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:archero_fm/main.dart';
import 'package:archero_fm/progress_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    ProgressStore.resetForTesting();
    SharedPreferences.setMockInitialValues({});
    globalCoins = 150;
    heroHpUpgrade = 0;
    heroAtkUpgrade = 0;
    bestStage = 1;
    bestScore = 0;
  });

  testWidgets('health purchase deducts coins, upgrades health and persists',
      (tester) async {
    await tester.pumpWidget(const ArcheroSoundApp());

    await tester.tap(find.text('صحة +25 · المستوى 0/20 · 50 عملة'));
    await tester.pumpAndSettle();

    expect(globalCoins, 100);
    expect(heroHpUpgrade, 25);
    expect(find.text('رصيدك: 100'), findsOneWidget);
    expect(find.text('زيادة الصحة الحالية: +25'), findsOneWidget);

  });

  testWidgets('attack purchase deducts coins, upgrades attack and persists',
      (tester) async {
    await tester.pumpWidget(const ArcheroSoundApp());

    final attackLabel = find.text('هجوم +15 · المستوى 0/15 · 70 عملة');
    final attackButton = find.ancestor(
      of: attackLabel,
      matching: find.byType(FilledButton),
    );
    await tester.ensureVisible(attackButton);
    expect(tester.widget<FilledButton>(attackButton).onPressed, isNotNull);
    await tester.tap(attackButton);
    await tester.pumpAndSettle();

    expect(globalCoins, 80);
    expect(heroAtkUpgrade, 15);
    expect(find.text('رصيدك: 80'), findsOneWidget);
    expect(find.text('زيادة الهجوم الحالية: +15'), findsOneWidget);

  });

  testWidgets('purchase is rejected when the player has insufficient coins',
      (tester) async {
    globalCoins = 40;
    await tester.pumpWidget(const ArcheroSoundApp());

    final healthButton = find.text('صحة +25 · المستوى 0/20 · 50 عملة');
    await tester.ensureVisible(healthButton);
    final button = tester.widget<FilledButton>(
      find.ancestor(of: healthButton, matching: find.byType(FilledButton)),
    );

    expect(button.onPressed, isNull);
    expect(globalCoins, 40);
    expect(heroHpUpgrade, 0);
    expect(find.text('رصيدك: 40'), findsOneWidget);

  });
}
