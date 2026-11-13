import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/enemy_hit_resolution.dart';

void main() {
  group('resolveEnemyHit', () {
    test('applies normal scaled damage without critical bonus', () {
      final result = resolveEnemyHit(
        currentHp: 100,
        baseDamage: 35,
        attackMultiplier: 1.5,
        criticalChance: 0.15,
        criticalRoll: 0.9,
        isBoss: false,
      );

      expect(result.damageApplied, 52.5);
      expect(result.updatedHp, 47.5);
      expect(result.isCritical, isFalse);
      expect(result.isDefeated, isFalse);
      expect(result.scoreAward, 0);
      expect(result.dropsCoin, isFalse);
    });

    test('preserves the existing critical hit double damage', () {
      final result = resolveEnemyHit(
        currentHp: 100,
        baseDamage: 35,
        attackMultiplier: 1.5,
        criticalChance: 0.15,
        criticalRoll: 0.1,
        isBoss: false,
      );

      expect(result.isCritical, isTrue);
      expect(result.damageApplied, 105);
      expect(result.updatedHp, -5);
      expect(result.isDefeated, isTrue);
      expect(result.scoreAward, 20);
      expect(result.dropsCoin, isTrue);
    });

    test('applies boss damage reduction and boss defeat reward', () {
      final result = resolveEnemyHit(
        currentHp: 20,
        baseDamage: 48,
        attackMultiplier: 1,
        criticalChance: 0,
        criticalRoll: 1,
        isBoss: true,
        bossDamageMultiplier: 0.65,
      );

      expect(result.damageApplied, closeTo(31.2, 0.000001));
      expect(result.isDefeated, isTrue);
      expect(result.scoreAward, 150);
      expect(result.dropsCoin, isTrue);
    });

    test('supports non-critical special skill damage on regular enemies', () {
      final result = resolveEnemyHit(
        currentHp: 100,
        baseDamage: 42,
        attackMultiplier: 1,
        criticalChance: 0,
        criticalRoll: 0,
        isBoss: false,
      );

      expect(result.damageApplied, 42);
      expect(result.isCritical, isFalse);
      expect(result.updatedHp, 58);
    });

    test('does not award defeat rewards while the enemy survives', () {
      final result = resolveEnemyHit(
        currentHp: 100,
        baseDamage: 10,
        attackMultiplier: 1,
        criticalChance: 0,
        criticalRoll: 1,
        isBoss: true,
      );

      expect(result.isDefeated, isFalse);
      expect(result.scoreAward, 0);
      expect(result.dropsCoin, isFalse);
    });
  });
}
