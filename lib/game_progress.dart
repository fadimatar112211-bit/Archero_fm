import 'game_diagnostics.dart';
import 'progress_store.dart';

int globalCoins = 150;
int heroHpUpgrade = 0;
int heroAtkUpgrade = 0;
int bestStage = 1;
int bestScore = 0;

Future<void> initializeGameProgress() async {
  GameDiagnostics.install();

  late final Map<String, int> progress;
  try {
    progress = await ProgressStore.load();
  } catch (error, stackTrace) {
    GameDiagnostics.record('progress.load', error, stackTrace);
    progress = ProgressStore.defaults;
  }

  globalCoins = progress['coins']!;
  heroHpUpgrade = progress['hpUpgrade']!;
  heroAtkUpgrade = progress['atkUpgrade']!;
  bestStage = progress['bestStage']!;
  bestScore = progress['bestScore']!;
}

Future<void> saveProgress() async {
  try {
    await ProgressStore.save(
      coins: globalCoins,
      hpUpgrade: heroHpUpgrade,
      atkUpgrade: heroAtkUpgrade,
      bestStage: bestStage,
      bestScore: bestScore,
    );
  } catch (error, stackTrace) {
    GameDiagnostics.record('progress.save', error, stackTrace);
    rethrow;
  }
}

/// Injectable persistence boundary for purchase rollback tests and platform adapters.
Future<void> Function() progressSaveOperation = saveProgress;
