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
    });
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
    });
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
    });
  });

  test('loads and saves the typed player progress snapshot', () async {
    const snapshot = PlayerProgress(
      coins: 420,
      hpUpgrade: 75,
      atkUpgrade: 45,
      bestStage: 12,
      bestScore: 2300,
    );

    await ProgressStore.savePlayerProgress(snapshot);
    expect((await ProgressStore.loadPlayerProgress()).toMap(), snapshot.toMap());
  });

  test('rolls back a partially failed snapshot and keeps the queue usable', () async {
    final initial = <String, int>{'coins': 200, 'hpUpgrade': 10, 'atkUpgrade': 5, 'bestStage': 3, 'bestScore': 90, 'equippedWeaponId': 0, 'equippedArmorId': 0, 'equippedHelmetId': 0, 'equippedRingId': 0, 'equippedRelicId': 0, 'ownedEquipmentMask': 585, 'gems': 0, 'keys': 0, 'equipmentShards': 0};
    final preferences = _FailingProgressPreferences(Map<String, int>.from(initial), failKey: 'atkUpgrade');
    ProgressStore.setPreferencesProviderForTesting(() async => preferences);
    await expectLater(
      ProgressStore.save(coins: 999, hpUpgrade: 80, atkUpgrade: 70, bestStage: 12, bestScore: 5000),
      throwsA(isA<StateError>()),
    );
    expect(preferences.values, initial);
    await ProgressStore.save(coins: 250, hpUpgrade: 20, atkUpgrade: 15, bestStage: 4, bestScore: 150);
    expect(preferences.values, {'coins': 250, 'hpUpgrade': 20, 'atkUpgrade': 15, 'bestStage': 4, 'bestScore': 150, 'equippedWeaponId': 0, 'equippedArmorId': 0, 'equippedHelmetId': 0, 'equippedRingId': 0, 'equippedRelicId': 0, 'ownedEquipmentMask': 585, 'gems': 0, 'keys': 0, 'equipmentShards': 0});
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

  test('normalizes unknown equipped weapon IDs to the default', () async {
    await ProgressStore.save(coins:300,hpUpgrade:25,atkUpgrade:15,bestStage:4,bestScore:600,equippedWeaponId:99,equippedArmorId:99,equippedHelmetId:-1,equippedRingId:99,equippedRelicId:-1);
    final p = await ProgressStore.loadPlayerProgress();
    expect(p.equippedWeaponId,0); expect(p.equippedArmorId,0); expect(p.equippedHelmetId,0); expect(p.equippedRingId,0); expect(p.equippedRelicId,0);
  });
}
