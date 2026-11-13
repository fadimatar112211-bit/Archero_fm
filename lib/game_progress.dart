import 'package:flutter/foundation.dart' show visibleForTesting;

import 'audio_service.dart';
import 'game_diagnostics.dart';
import 'player_progress.dart';
import 'progress_store.dart';

// Persistent player progression shared by the menu and active game session.
int globalCoins = 150;
int heroHpUpgrade = 0;
int heroAtkUpgrade = 0;
int bestStage = 1;
int bestScore = 0;

Future<void> saveProgress() async {
  try {
    await ProgressStore.savePlayerProgress(
      PlayerProgress(
        coins: globalCoins,
        hpUpgrade: heroHpUpgrade,
        atkUpgrade: heroAtkUpgrade,
        bestStage: bestStage,
        bestScore: bestScore,
      ),
    );
  } catch (error, stackTrace) {
    GameDiagnostics.record(
      error,
      stackTrace,
      source: 'progress_save',
    );
    rethrow;
  }
}

final GameAudioService gameAudio = GameAudioService();

@visibleForTesting
Future<void> Function(String)? playSoundOverrideForTesting;

Future<void> playRealSound(String type) async {
  final override = playSoundOverrideForTesting;
  if (override != null) {
    await override(type);
    return;
  }
  await gameAudio.play(type);
}
