import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/player_progress.dart';

void main() {
  group('PlayerProgress', () {
    test('provides safe defaults for a new player', () {
      const progress = PlayerProgress();
      expect(progress.toMap(), {
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
      });
    });

    test('round-trips all persistent progression fields', () {
      const original = PlayerProgress(
        coins: 275,
        hpUpgrade: 50,
        atkUpgrade: 30,
        bestStage: 8,
        bestScore: 1240,
        equippedWeaponId: 2,
        equippedArmorId: 1,
        equippedHelmetId: 2,
        equippedRingId: 1,
        equippedRelicId: 2,
        unlockedHeroesMask: 15,
      );
      expect(PlayerProgress.fromMap(original.toMap()).toMap(), original.toMap());
    });

    test('fills absent fields with defaults', () {
      final progress = PlayerProgress.fromMap({'coins': 20, 'bestStage': 3});
      expect(progress.coins, 20);
      expect(progress.hpUpgrade, 0);
      expect(progress.atkUpgrade, 0);
      expect(progress.bestStage, 3);
      expect(progress.bestScore, 0);
      expect(progress.equippedWeaponId, 0);
      expect(progress.ownedEquipmentMask, 585);
      expect(progress.unlockedHeroesMask, 1);
    });

    test('round-trips gem key and equipment shard balances', () {
      const original = PlayerProgress(gems: 23, keys: 4, equipmentShards: 17);
      final restored = PlayerProgress.fromMap(original.toMap());
      expect(restored.gems, 23);
      expect(restored.keys, 4);
      expect(restored.equipmentShards, 17);
    });

    test('normalizes negative resource balances to zero', () {
      final progress = PlayerProgress.fromMap({
        'gems': -5,
        'keys': -2,
        'equipmentShards': -9,
      });
      expect(progress.gems, 0);
      expect(progress.keys, 0);
      expect(progress.equipmentShards, 0);
    });

    test('legacy equipped items are retained as owned during migration', () {
      final progress = PlayerProgress.fromMap({
        'equippedArmorId': 2,
        'equippedHelmetId': 1,
      });
      expect(progress.equippedArmorId, 2);
      expect(progress.ownedEquipmentMask & (1 << 2), isNonZero);
      expect(progress.ownedEquipmentMask & (1 << 4), isNonZero);
    });

    test('normalizes unlocked hero masks and always retains the starter hero', () {
      expect(PlayerProgress.fromMap({'unlockedHeroesMask': 15}).unlockedHeroesMask, 15);
      expect(PlayerProgress.fromMap({'unlockedHeroesMask': 0}).unlockedHeroesMask, 1);
      expect(PlayerProgress.fromMap({'unlockedHeroesMask': 99}).unlockedHeroesMask, 15);
      expect(PlayerProgress.fromMap({'unlockedHeroesMask': -3}).unlockedHeroesMask, 1);
    });

    test('copyWith updates selected values without mutating original', () {
      const original = PlayerProgress(coins: 150, bestStage: 2);
      final updated = original.copyWith(coins: 220, bestScore: 500, equippedWeaponId: 3);
      expect(updated.coins, 220);
      expect(updated.bestStage, 2);
      expect(updated.bestScore, 500);
      expect(updated.equippedWeaponId, 3);
      expect(original.coins, 150);
      expect(original.bestScore, 0);
    });
  });
}
