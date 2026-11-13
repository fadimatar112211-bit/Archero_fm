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
