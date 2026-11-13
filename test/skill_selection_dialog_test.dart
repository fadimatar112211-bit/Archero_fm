import 'package:archero_fm/skill_selection_dialog.dart';
import 'package:archero_fm/skill_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows skill details and returns the selected skill', (tester) async {
    SkillId? selected;
    const offers = [
      SkillOption(
        id: SkillId.criticalStrike,
        title: 'ضربة حرجة',
        description: 'فرصة 15% لإحداث ضرر مضاعف.',
        rarity: SkillRarity.rare,
      ),
      SkillOption(
        id: SkillId.extraArrow,
        title: 'وابل السهام',
        description: 'سهم إضافي في كل هجمة.',
        rarity: SkillRarity.common,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                selected = await showSkillSelectionDialog(context, offers);
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('ضربة حرجة'), findsOneWidget);
    expect(find.text('فرصة 15% لإحداث ضرر مضاعف.'), findsOneWidget);
    expect(find.text('نادرة'), findsOneWidget);
    expect(find.text('عادية'), findsOneWidget);

    await tester.tap(find.text('وابل السهام'));
    await tester.pumpAndSettle();

    expect(selected, SkillId.extraArrow);
    expect(find.text('✨ اختر مهارة للمرحلة القادمة'), findsNothing);
  });
}
