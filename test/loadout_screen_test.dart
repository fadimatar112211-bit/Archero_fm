import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:archero_fm/game_progress.dart';
import 'package:archero_fm/loadout_screen.dart';
import 'package:archero_fm/progress_store.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    ProgressStore.resetForTesting();
    equippedWeaponId = 0;
    equippedArmorId = 0;
    equippedHelmetId = 0;
    equippedRingId = 0;
    equippedRelicId = 0;
    ownedEquipmentMask = 585;
  });

  testWidgets('loadout screen shows equipped gear and weapon characteristics',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoadoutScreen()));

    expect(find.text('تجهيزات البطل'), findsOneWidget);
    expect(find.text('القوس المتوازن'), findsOneWidget);
    expect(find.textContaining('قوة الضرر'), findsOneWidget);
    expect(find.textContaining('درع الرحّالة'), findsOneWidget);
    expect(find.textContaining('إجمالي تأثير المعدات'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('changing weapon persists the selected loadout', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoadoutScreen()));

    await tester.tap(find.byType(DropdownButtonFormField<int>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('القوس النابض').last);
    await tester.pumpAndSettle();

    expect(equippedWeaponId, 1);
    expect((await ProgressStore.loadPlayerProgress()).equippedWeaponId, 1);
    expect(find.text('تم حفظ التجهيز الجديد بنجاح.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
