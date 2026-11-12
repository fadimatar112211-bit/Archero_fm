import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/main.dart';

void main() {
  testWidgets('main menu renders and offers hero selection', (tester) async {
    await tester.pumpWidget(const ArcheroSoundApp());
    expect(find.text('ARCHERO: SOUND EDITION'), findsOneWidget);
    expect(find.text('اختيار البطل واللعب'), findsOneWidget);
  });
}
