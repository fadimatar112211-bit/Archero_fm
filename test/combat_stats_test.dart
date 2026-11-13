import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/combat_stats.dart';

void main() {
  group('CombatBalance', () {
    test('critical hit doubles scaled arrow damage', () {
      expect(CombatBalance.arrowDamage(
        baseDamage: 35, attackMultiplier: 1.5,
        criticalChance: 0.15, roll: 0.10,
      ), 105);
    });

    test('normal hit uses attack multiplier only', () {
      expect(CombatBalance.arrowDamage(
        baseDamage: 35, attackMultiplier: 1.5,
        criticalChance: 0.15, roll: 0.90,
      ), 52.5);
    });

    test('shoot speed reduces interval within safe bounds', () {
      expect(CombatBalance.shootIntervalMs(1), 650);
      expect(CombatBalance.shootIntervalMs(1.18), 551);
      expect(CombatBalance.shootIntervalMs(99), 295);
    });

    test('invalid values fail safely', () {
      expect(CombatBalance.arrowDamage(
        baseDamage: double.nan, attackMultiplier: double.infinity,
        criticalChance: 1, roll: 0,
      ), 0);
      expect(CombatBalance.shootIntervalMs(double.nan), 650);
    });
  });
}
