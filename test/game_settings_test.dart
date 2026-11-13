import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:archero_fm/game_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GameSettingsStore.audioEnabled = true;
  });

  test('audio is enabled by default for a new profile', () async {
    SharedPreferences.setMockInitialValues({});
    await GameSettingsStore.load();
    expect(GameSettingsStore.audioEnabled, isTrue);
  });

  test('audio preference persists across settings reloads', () async {
    SharedPreferences.setMockInitialValues({});
    await GameSettingsStore.setAudioEnabled(false);
    GameSettingsStore.audioEnabled = true;

    await GameSettingsStore.load();

    expect(GameSettingsStore.audioEnabled, isFalse);
  });

  test('wrong-typed audio preference safely falls back to enabled', () async {
    SharedPreferences.setMockInitialValues({
      'settings.audio_enabled': 'not-a-bool',
    });

    await GameSettingsStore.load();

    expect(GameSettingsStore.audioEnabled, isTrue);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.containsKey('settings.audio_enabled'), isFalse);
  });
}
