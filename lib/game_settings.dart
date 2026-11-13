import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight application settings kept separate from player progression.
class GameSettingsStore {
  GameSettingsStore._();

  static const _audioKey = 'settings.audio_enabled';
  static const _vibrationKey = 'settings.vibration_enabled';

  static bool audioEnabled = true;
  static bool vibrationEnabled = true;

  static Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    try {
      audioEnabled = preferences.getBool(_audioKey) ?? true;
    } catch (_) {
      audioEnabled = true;
      try {
        await preferences.remove(_audioKey);
      } catch (_) {}
    }
    try {
      vibrationEnabled = preferences.getBool(_vibrationKey) ?? true;
    } catch (_) {
      vibrationEnabled = true;
      try {
        await preferences.remove(_vibrationKey);
      } catch (_) {}
    }
  }

  static Future<void> setAudioEnabled(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_audioKey, enabled);
    audioEnabled = enabled;
  }

  static Future<void> setVibrationEnabled(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_vibrationKey, enabled);
    vibrationEnabled = enabled;
  }
}
