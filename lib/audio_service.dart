import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

import 'procedural_audio.dart';

/// Owns local game sound playback and keeps one player per sound category.
///
/// Audio is deliberately non-critical: a device/plugin playback failure must
/// never interrupt the game loop.
class GameAudioService {
  static const supportedSounds = <String>{
    'shoot',
    'hit',
    'coin',
    'special',
  };

  final Map<String, AudioPlayer> _players = <String, AudioPlayer>{};
  final Map<String, Uint8List> _wavCache = <String, Uint8List>{};
  bool _disposed = false;

  bool get isDisposed => _disposed;

  Future<void> play(String type) async {
    if (_disposed || !supportedSounds.contains(type)) return;

    try {
      final player = _players.putIfAbsent(type, AudioPlayer.new);
      final wav = _wavCache.putIfAbsent(type, () => buildToneWav(type));
      await player.stop();
      await player.play(BytesSource(wav));
    } catch (_) {
      // Audio is optional; gameplay continues if playback is unavailable.
    }
  }

  /// Releases platform players when the owning application is shut down.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    final players = _players.values.toList(growable: false);
    _players.clear();
    _wavCache.clear();
    await Future.wait(players.map((player) async {
      try {
        await player.dispose();
      } catch (_) {
        // Cleanup failures must not affect application shutdown.
      }
    }));
  }
}
