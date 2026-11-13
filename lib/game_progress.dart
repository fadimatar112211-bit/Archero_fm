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
int equippedWeaponId = 0;
int equippedArmorId = 0, equippedHelmetId = 0, equippedRingId = 0, equippedRelicId = 0;
int ownedEquipmentMask = 585;
int globalGems = 0;
int globalKeys = 0;
int globalEquipmentShards = 0;

/// Loads saved progression, falling back to safe defaults if storage is
/// unavailable so a transient persistence failure cannot block game startup.
Future<PlayerProgress> loadProgressOrDefaults() async {
  try {
    return await ProgressStore.loadPlayerProgress();
  } catch (error, stackTrace) {
    GameDiagnostics.record(
      error,
      stackTrace,
      source: 'application_startup',
    );
    return const PlayerProgress(
      coins: 150,
      hpUpgrade: 0,
      atkUpgrade: 0,
      bestStage: 1,
      bestScore: 0,
      equippedWeaponId: 0,
      equippedArmorId: 0, equippedHelmetId: 0, equippedRingId: 0, equippedRelicId: 0,
    );
  }
}

Future<void> saveProgress() async {
  try {
    await ProgressStore.savePlayerProgress(
      PlayerProgress(
        coins: globalCoins,
        hpUpgrade: heroHpUpgrade,
        atkUpgrade: heroAtkUpgrade,
        bestStage: bestStage,
        bestScore: bestScore,
        equippedWeaponId: equippedWeaponId,
        equippedArmorId: equippedArmorId, equippedHelmetId: equippedHelmetId,
        equippedRingId: equippedRingId, equippedRelicId: equippedRelicId,
        ownedEquipmentMask: ownedEquipmentMask,
        gems: globalGems,
        keys: globalKeys,
        equipmentShards: globalEquipmentShards,
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

/// Persists progression without allowing an optional save failure to escape
/// from gameplay callbacks. The underlying save records diagnostics and
/// rethrows so callers that need a strict result can still use [saveProgress].
Future<bool> saveProgressSafely() async {
  try {
    await saveProgress();
    return true;
  } catch (_) {
    return false;
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
