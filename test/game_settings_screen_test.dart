import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:archero_fm/game_settings.dart';
import 'package:archero_fm/game_settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('settings screen exposes audio and vibration switches', (tester) async {
    SharedPreferences.setMockInitialValues({});
    GameSettingsStore.audioEnabled = true;
    GameSettingsStore.vibrationEnabled = true;

    await tester.pumpWidget(
      const MaterialApp(home: GameSettingsScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('أصوات اللعبة'), findsOneWidget);
    expect(find.text('الاهتزاز'), findsOneWidget);
    expect(find.byType(SwitchListTile), findsNWidgets(2));

    await tester.tap(find.byType(SwitchListTile).last);
    await tester.pumpAndSettle();

    expect(GameSettingsStore.vibrationEnabled, isFalse);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('settings.vibration_enabled'), isFalse);
  });
}
