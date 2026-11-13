import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/special_room_dialog.dart';
import 'package:archero_fm/special_room_system.dart';

void main() {
  testWidgets('special room dialog presents all four destinations', (tester) async {
    SpecialRoomType? selected;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () async {
            selected = await showDialog<SpecialRoomType>(
              context: context,
              builder: (_) => const SpecialRoomChoiceDialog(),
            );
          },
          child: const Text('open'),
        ),
      )),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('غرفة الكنز'), findsOneWidget);
    expect(find.text('متجر التاجر'), findsOneWidget);
    expect(find.text('ملاذ العلاج'), findsOneWidget);
    expect(find.text('غرفة التحدي'), findsOneWidget);
    await tester.tap(find.text('غرفة التحدي'));
    await tester.pumpAndSettle();
    expect(selected, SpecialRoomType.challenge);
  });

  testWidgets('merchant dialog exposes paid attack and healing choices', (tester) async {
    MerchantPurchase? selected;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () async {
            selected = await showDialog<MerchantPurchase>(
              context: context,
              builder: (_) => const MerchantRoomDialog(coins: 100),
            );
          },
          child: const Text('open'),
        ),
      )),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('تعزيز الهجوم +15% · 80 عملة'), findsOneWidget);
    expect(find.text('جرعة علاج +30% صحة · 50 عملة'), findsOneWidget);
    await tester.tap(find.text('تعزيز الهجوم +15% · 80 عملة'));
    await tester.pumpAndSettle();
    expect(selected, MerchantPurchase.attackBoost);
  });
}
