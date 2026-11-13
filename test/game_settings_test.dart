import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:archero_fm/game_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GameSettingsStore.audioEnabled = true;
    GameSettingsStore.vibrationEnabled = true;
  });

  test('audio and vibration are enabled by default for a new profile', () async {
    SharedPreferences.setMockInitialValues({});
    await GameSettingsStore.load();
    expect(GameSettingsStore.audioEnabled, isTrue);
    expect(GameSettingsStore.vibrationEnabled, isTrue);
  });

  test('audio preference persists across settings reloads', () async {
    SharedPreferences.setMockInitialValues({});
    await GameSettingsStore.setAudioEnabled(false);
    GameSettingsStore.audioEnabled = true;

    await GameSettingsStore.load();

    expect(GameSettingsStore.audioEnabled, isFalse);
  });

  test('vibration preference persists across settings reloads', () async {
    SharedPreferences.setMockInitialValues({});
    await GameSettingsStore.setVibrationEnabled(false);
    GameSettingsStore.vibrationEnabled = true;

    await GameSettingsStore.load();

    expect(GameSettingsStore.vibrationEnabled, isFalse);
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

  test('wrong-typed vibration preference safely falls back to enabled', () async {
    SharedPreferences.setMockInitialValues({
      'settings.vibration_enabled': 'not-a-bool',
    });

    await GameSettingsStore.load();

    expect(GameSettingsStore.vibrationEnabled, isTrue);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.containsKey('settings.vibration_enabled'), isFalse);
  });

  test('corrupt audio setting does not discard valid vibration setting', () async {
    SharedPreferences.setMockInitialValues({
      'settings.audio_enabled': 'invalid',
      'settings.vibration_enabled': false,
    });

    await GameSettingsStore.load();

    expect(GameSettingsStore.audioEnabled, isTrue);
    expect(GameSettingsStore.vibrationEnabled, isFalse);
  });
}
