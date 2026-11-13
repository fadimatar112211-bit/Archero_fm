import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:archero_fm/progress_store.dart';
import 'package:archero_fm/player_progress.dart';

class _FailingProgressPreferences implements ProgressPreferences {
  _FailingProgressPreferences(this.values, {this.failKey});
  final Map<String, int> values;
  String? failKey;
  bool _hasFailed = false;
  @override
  int? getInt(String key) => values[key];
  @override
  Future<bool> setInt(String key, int value) async {
    if (!_hasFailed && key == failKey) { _hasFailed = true; return false; }
    values[key] = value;
    return true;
  }
}
class _DelayedProgressPreferences implements ProgressPreferences {
  final Map<String, int> values = {};
  final Completer<void> firstWriteStarted = Completer<void>();
  final Completer<void> releaseWrites = Completer<void>();

  @override
  int? getInt(String key) => values[key];

  @override
  Future<bool> setInt(String key, int value) async {
    if (!firstWriteStarted.isCompleted) {
      firstWriteStarted.complete();
      await releaseWrites.future;
    }
    values[key] = value;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    ProgressStore.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(ProgressStore.resetForTesting);

  test('loads safe defaults for a new player', () async {
    expect(await ProgressStore.load(), {
      'coins': 150,
      'hpUpgrade': 0,
      'atkUpgrade': 0,
      'bestStage': 1,
      'bestScore': 0,
      'equippedWeaponId': 0,
        'equippedArmorId': 0,
        'equippedHelmetId': 0,
        'equippedRingId': 0,
        'equippedRelicId': 0,
        'ownedEquipmentMask': 585,
        'gems': 0,
        'keys': 0,
        'equipmentShards': 0,
        'unlockedHeroesMask': 1,
      'totalKills': 0,
      'totalBosses': 0,
      'totalChests': 0,
      'totalRuns': 0,
      'claimedAchievementsMask': 0,
    });
  });

  test('saves and restores all progression values', () async {
    await ProgressStore.save(
      coins: 275,
      hpUpgrade: 50,
      atkUpgrade: 30,
      bestStage: 8,
      bestScore: 1240,
    );

    expect(await ProgressStore.load(), {
      'coins': 275,
      'hpUpgrade': 50,
      'atkUpgrade': 30,
      'bestStage': 8,
      'bestScore': 1240,
      'equippedWeaponId': 0,
        'equippedArmorId': 0,
        'equippedHelmetId': 0,
        'equippedRingId': 0,
        'equippedRelicId': 0,
        'ownedEquipmentMask': 585,
        'gems': 0,
        'keys': 0,
        'equipmentShards': 0,
        'unlockedHeroesMask': 1,
      'totalKills': 0,
      'totalBosses': 0,
      'totalChests': 0,
      'totalRuns': 0,
      'claimedAchievementsMask': 0,
    });
  });

  test('serializes overlapping saves as complete snapshots', () async {
    final firstSave = ProgressStore.save(
      coins: 200,
      hpUpgrade: 25,
      atkUpgrade: 15,
      bestStage: 4,
      bestScore: 400,
    );
    final secondSave = ProgressStore.save(
      coins: 315,
      hpUpgrade: 50,
      atkUpgrade: 30,
      bestStage: 9,
      bestScore: 950,
    );

    await Future.wait([firstSave, secondSave]);

    expect(await ProgressStore.load(), {
      'coins': 315,
      'hpUpgrade': 50,
      'atkUpgrade': 30,
      'bestStage': 9,
      'bestScore': 950,
      'equippedWeaponId': 0,
        'equippedArmorId': 0,
        'equippedHelmetId': 0,
        'equippedRingId': 0,
        'equippedRelicId': 0,
        'ownedEquipmentMask': 585,
        'gems': 0,
        'keys': 0,
        'equipmentShards': 0,
        'unlockedHeroesMask': 1,
      'totalKills': 0,
      'totalBosses': 0,
      'totalChests': 0,
      'totalRuns': 0,
      'claimedAchievementsMask': 0,
    });
  });

  test('loads wait for an in-flight complete snapshot write', () async {
    final preferences = _DelayedProgressPreferences();
    ProgressStore.setPreferencesProviderForTesting(() async => preferences);

    final save = ProgressStore.save(
      coins: 444,
      hpUpgrade: 25,
      atkUpgrade: 15,
      bestStage: 7,
      bestScore: 900,
    );
    await preferences.firstWriteStarted.future;

    var loadCompleted = false;
    final load = ProgressStore.load().then((snapshot) {
      loadCompleted = true;
      return snapshot;
    });
    await Future<void>.delayed(Duration.zero);
    expect(loadCompleted, isFalse);

    preferences.releaseWrites.complete();
    await save;
    final snapshot = await load;
    expect(snapshot['coins'], 444);
    expect(snapshot['bestStage'], 7);
    expect(snapshot['bestScore'], 900);
  });

  test('normalizes invalid negative progression values', () async {
    SharedPreferences.setMockInitialValues({
      'coins': -40,
      'hpUpgrade': -5,
      'atkUpgrade': -2,
      'bestStage': 0,
      'bestScore': -100,
    });

    expect(await ProgressStore.load(), {
      'coins': 0,
      'hpUpgrade': 0,
      'atkUpgrade': 0,
      'bestStage': 1,
      'bestScore': 0,
      'equippedWeaponId': 0,
        'equippedArmorId': 0,
        'equippedHelmetId': 0,
        'equippedRingId': 0,
        'equippedRelicId': 0,
        'ownedEquipmentMask': 585,
        'gems': 0,
        'keys': 0,
        'equipmentShards': 0,
        'unlockedHeroesMask': 1,
      'totalKills': 0,
      'totalBosses': 0,
      'totalChests': 0,
      'totalRuns': 0,
      'claimedAchievementsMask': 0,
    });
  });

  test('recovers a wrong-typed field without discarding other valid progress', () async {
    SharedPreferences.setMockInitialValues({
      'coins': 875,
      'bestStage': 'corrupted-stage-value',
      'gems': 42,
      'totalKills': 91,
    });

    final recovered = await ProgressStore.loadPlayerProgress();
    expect(recovered.coins, 875);
    expect(recovered.bestStage, 1);
    expect(recovered.gems, 42);
    expect(recovered.totalKills, 91);
  });

  test('does not persist negative values supplied by callers', () async {
    await ProgressStore.save(
      coins: -10,
      hpUpgrade: -1,
      atkUpgrade: -3,
      bestStage: -8,
      bestScore: -20,
    );

    expect(await ProgressStore.load(), {
      'coins': 0,
      'hpUpgrade': 0,
      'atkUpgrade': 0,
      'bestStage': 1,
      'bestScore': 0,
      'equippedWeaponId': 0,
        'equippedArmorId': 0,
        'equippedHelmetId': 0,
        'equippedRingId': 0,
        'equippedRelicId': 0,
        'ownedEquipmentMask': 585,
        'gems': 0,
        'keys': 0,
        'equipmentShards': 0,
        'unlockedHeroesMask': 1,
      'totalKills': 0,
      'totalBosses': 0,
      'totalChests': 0,
      'totalRuns': 0,
      'claimedAchievementsMask': 0,
    });
  });

  test('loads and saves the typed player progress snapshot', () async {
    const snapshot = PlayerProgress(
      coins: 420,
      hpUpgrade: 75,
      atkUpgrade: 45,
      bestStage: 12,
      bestScore: 2300,
      gems: 31,
      keys: 2,
      equipmentShards: 14,
      unlockedHeroesMask: 15,
    );

    await ProgressStore.savePlayerProgress(snapshot);
    expect((await ProgressStore.loadPlayerProgress()).toMap(), snapshot.toMap());
  });

  test('rolls back a partially failed snapshot and keeps the queue usable', () async {
    final initial = <String, int>{'coins': 200, 'hpUpgrade': 10, 'atkUpgrade': 5, 'bestStage': 3, 'bestScore': 90, 'equippedWeaponId': 0, 'equippedArmorId': 0, 'equippedHelmetId': 0, 'equippedRingId': 0, 'equippedRelicId': 0, 'ownedEquipmentMask': 585, 'gems': 0, 'keys': 0, 'equipmentShards': 0, 'unlockedHeroesMask': 1, 'totalKills': 0, 'totalBosses': 0, 'totalChests': 0, 'totalRuns': 0, 'claimedAchievementsMask': 0};
    final preferences = _FailingProgressPreferences(Map<String, int>.from(initial), failKey: 'atkUpgrade');
    ProgressStore.setPreferencesProviderForTesting(() async => preferences);
    await expectLater(
      ProgressStore.save(coins: 999, hpUpgrade: 80, atkUpgrade: 70, bestStage: 12, bestScore: 5000),
      throwsA(isA<StateError>()),
    );
    expect(preferences.values, initial);
    await ProgressStore.save(coins: 250, hpUpgrade: 20, atkUpgrade: 15, bestStage: 4, bestScore: 150);
    expect(preferences.values, {'coins': 250, 'hpUpgrade': 20, 'atkUpgrade': 15, 'bestStage': 4, 'bestScore': 150, 'equippedWeaponId': 0, 'equippedArmorId': 0, 'equippedHelmetId': 0, 'equippedRingId': 0, 'equippedRelicId': 0, 'ownedEquipmentMask': 585, 'gems': 0, 'keys': 0, 'equipmentShards': 0, 'unlockedHeroesMask': 1, 'totalKills': 0, 'totalBosses': 0, 'totalChests': 0, 'totalRuns': 0, 'claimedAchievementsMask': 0});
  });

  test('persists equipped weapon with the progression snapshot', () async {
    await ProgressStore.save(coins:300,hpUpgrade:25,atkUpgrade:15,bestStage:4,bestScore:600,equippedWeaponId:2,equippedArmorId:1,equippedHelmetId:2,equippedRingId:1,equippedRelicId:2,ownedEquipmentMask:585 | (1<<1) | (1<<5) | (1<<7) | (1<<11), gems: 7, keys: 3, equipmentShards: 12);
    final p = await ProgressStore.loadPlayerProgress();
    expect(p.equippedWeaponId,2); expect(p.equippedArmorId,1); expect(p.equippedHelmetId,2); expect(p.equippedRingId,1); expect(p.equippedRelicId,2); expect(p.ownedEquipmentMask,585 | (1<<1) | (1<<5) | (1<<7) | (1<<11)); expect(p.gems,7); expect(p.keys,3); expect(p.equipmentShards,12);
  });
  test('persists and restores the unlocked equipment mask', () async {
    const mask = 585 | (1 << 1) | (1 << 5) | (1 << 7);
    await ProgressStore.save(
      coins: 300, hpUpgrade: 25, atkUpgrade: 15, bestStage: 4, bestScore: 600,
      equippedArmorId: 1, ownedEquipmentMask: mask,
    );
    expect((await ProgressStore.loadPlayerProgress()).ownedEquipmentMask, mask);
  });

  test('persists and normalizes unlocked hero progression', () async {
    await ProgressStore.save(
      coins: 300, hpUpgrade: 25, atkUpgrade: 15, bestStage: 4, bestScore: 600,
      unlockedHeroesMask: 15,
    );
    expect((await ProgressStore.loadPlayerProgress()).unlockedHeroesMask, 15);
    await ProgressStore.save(
      coins: 300, hpUpgrade: 25, atkUpgrade: 15, bestStage: 4, bestScore: 600,
      unlockedHeroesMask: 0,
    );
    expect((await ProgressStore.loadPlayerProgress()).unlockedHeroesMask, 1);
  });

  test('round-trips achievement counters and claimed reward bits', () async {
    await ProgressStore.save(
      coins: 500, hpUpgrade: 25, atkUpgrade: 15, bestStage: 12, bestScore: 900,
      totalKills: 120, totalBosses: 4, totalChests: 6, totalRuns: 8,
      claimedAchievementsMask: 0x155,
    );
    final progress = await ProgressStore.loadPlayerProgress();
    expect(progress.totalKills, 120);
    expect(progress.totalBosses, 4);
    expect(progress.totalChests, 6);
    expect(progress.totalRuns, 8);
    expect(progress.claimedAchievementsMask, 0x155);
  });

  test('normalizes unknown equipped weapon IDs to the default', () async {
    await ProgressStore.save(coins:300,hpUpgrade:25,atkUpgrade:15,bestStage:4,bestScore:600,equippedWeaponId:99,equippedArmorId:99,equippedHelmetId:-1,equippedRingId:99,equippedRelicId:-1);
    final p = await ProgressStore.loadPlayerProgress();
    expect(p.equippedWeaponId,0); expect(p.equippedArmorId,0); expect(p.equippedHelmetId,0); expect(p.equippedRingId,0); expect(p.equippedRelicId,0);
  });
}
