import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight application settings kept separate from player progression.
class GameSettingsStore {
  GameSettingsStore._();

  static const _audioKey = 'settings.audio_enabled';
  static bool audioEnabled = true;

  static Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    try {
      audioEnabled = preferences.getBool(_audioKey) ?? true;
    } catch (_) {
      // A malformed optional setting falls back to the safe default.
      audioEnabled = true;
      try {
        await preferences.remove(_audioKey);
      } catch (_) {}
    }
  }

  static Future<void> setAudioEnabled(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_audioKey, enabled);
    audioEnabled = enabled;
  }
}
