import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/hero_rules.dart';

void main() {
  group('createHeroRunStats', () {
    test('applies permanent upgrades to the base hero', () {
      final stats = createHeroRunStats(
        heroType: 1,
        hpUpgrade: 25,
        attackUpgrade: 3,
      );

      expect(stats.playerHp, 125);
      expect(stats.playerMaxHp, 125);
      expect(stats.playerSpeed, 3.5);
      expect(stats.attackPowerMultiplier, 1.24);
      expect(stats.extraArrows, 0);
    });

    test('applies flame hero health bonus without changing attack upgrades', () {
      final stats = createHeroRunStats(
        heroType: 2,
        hpUpgrade: 10,
        attackUpgrade: 2,
      );

      expect(stats.playerHp, 160);
      expect(stats.playerMaxHp, 160);
      expect(stats.playerSpeed, 3.5);
      expect(stats.attackPowerMultiplier, 1.16);
      expect(stats.extraArrows, 0);
    });

    test('applies shadow hero movement speed', () {
      final stats = createHeroRunStats(
        heroType: 3,
        hpUpgrade: 0,
        attackUpgrade: 0,
      );

      expect(stats.playerHp, 100);
      expect(stats.playerMaxHp, 100);
      expect(stats.playerSpeed, 5.2);
      expect(stats.attackPowerMultiplier, 1);
      expect(stats.extraArrows, 0);
    });

    test('applies storm hero bonus arrow', () {
      final stats = createHeroRunStats(
        heroType: 4,
        hpUpgrade: 5,
        attackUpgrade: 1,
      );

      expect(stats.playerHp, 105);
      expect(stats.playerMaxHp, 105);
      expect(stats.playerSpeed, 3.5);
      expect(stats.attackPowerMultiplier, 1.08);
      expect(stats.extraArrows, 1);
    });

    test('unknown hero types retain safe base stats and upgrades', () {
      final stats = createHeroRunStats(
        heroType: 99,
        hpUpgrade: 7,
        attackUpgrade: 4,
      );

      expect(stats.playerHp, 107);
      expect(stats.playerMaxHp, 107);
      expect(stats.playerSpeed, 3.5);
      expect(stats.attackPowerMultiplier, 1.32);
      expect(stats.extraArrows, 0);
    });
  });
}
