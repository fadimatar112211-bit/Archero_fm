import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:archero_fm/main.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    globalCoins = 150;
    heroHpUpgrade = 0;
    heroAtkUpgrade = 0;
    bestStage = 1;
    bestScore = 0;
  });

  testWidgets('health purchase deducts coins and upgrades health',
      (tester) async {
    await tester.pumpWidget(const ArcheroSoundApp());

    await tester.tap(find.text('صحة +25 (50)'));
    await tester.pumpAndSettle();

    expect(globalCoins, 100);
    expect(heroHpUpgrade, 25);
    expect(find.text('رصيدك: 100'), findsOneWidget);
    expect(find.text('زيادة الصحة الحالية: +25'), findsOneWidget);

  });

  testWidgets('attack purchase deducts coins and upgrades attack',
      (tester) async {
    await tester.pumpWidget(const ArcheroSoundApp());

    final attackButton = find.text('هجوم +15 (70)');
    await tester.ensureVisible(attackButton);
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

    await tester.tap(find.text('صحة +25 (50)'));
    await tester.pumpAndSettle();

    expect(globalCoins, 40);
    expect(heroHpUpgrade, 0);
    expect(find.text('رصيدك: 40'), findsOneWidget);
    expect(find.text('عملاتك لا تكفي لشراء ترقية الصحة.'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('coins'), isNull);
    expect(prefs.getInt('hpUpgrade'), isNull);
  });
}
