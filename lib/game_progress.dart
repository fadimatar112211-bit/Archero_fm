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

Future<void> playRealSound(String type) => gameAudio.play(type);
