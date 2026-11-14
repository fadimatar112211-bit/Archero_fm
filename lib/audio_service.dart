import 'package:audioplayers/audioplayers.dart';

import 'game_diagnostics.dart';

/// Owns the game's audio output so UI and combat code do not depend on
/// audioplayers directly. Sound failures are intentionally non-fatal.
class GameAudio {
  GameAudio._();

  static final AudioPlayer _player = AudioPlayer();

  static const Map<String, String> _soundUrls = {
    'shoot': 'https://www.soundjay.com/buttons/sounds/button-16.mp3',
    'hit': 'https://www.soundjay.com/buttons/sounds/button-3.mp3',
    'coin': 'https://www.soundjay.com/buttons/sounds/button-7.mp3',
    'special': 'https://www.soundjay.com/buttons/sounds/beep-07.mp3',
  };

  static Future<void> play(String type) async {
    final url = _soundUrls[type];
    if (url == null) return;

    try {
      await _player.stop();
      await _player.play(UrlSource(url));
    } catch (error, stackTrace) {
      GameDiagnostics.record('audio.play', error, stackTrace);
      // Gameplay must remain available when audio or network access fails.
    }
  }

  static Future<void> dispose() async {
    try {
      await _player.dispose();
    } catch (error, stackTrace) {
      GameDiagnostics.record('audio.dispose', error, stackTrace);
      // Cleanup must not interrupt screen teardown.
    }
  }
}

/// Compatibility entry point used by existing gameplay systems.
Future<void> playRealSound(String type) => GameAudio.play(type);
