import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/hero_rules.dart';

void main() {
  group('createHeroRunStats', () {
    test('creates balanced base hero stats with permanent upgrades', () {
      final stats = createHeroRunStats(
        heroType: 1,
        hpUpgrade: 10,
        attackUpgrade: 3,
      );

      expect(stats.playerHp, 110);
      expect(stats.playerMaxHp, 110);
      expect(stats.playerSpeed, 3.5);
      expect(stats.attackPowerMultiplier, closeTo(1.24, 0.000001));
      expect(stats.extraArrows, 0);
    });

    test('applies flame hero bonus health after permanent health upgrades', () {
      final stats = createHeroRunStats(
        heroType: 2,
        hpUpgrade: 12,
        attackUpgrade: 0,
      );

      expect(stats.playerHp, 162);
      expect(stats.playerMaxHp, 162);
      expect(stats.playerSpeed, 3.5);
      expect(stats.extraArrows, 0);
    });

    test('applies shadow hero movement speed', () {
      final stats = createHeroRunStats(
        heroType: 3,
        hpUpgrade: 0,
        attackUpgrade: 2,
      );

      expect(stats.playerSpeed, 5.2);
      expect(stats.attackPowerMultiplier, 1.16);
      expect(stats.playerHp, 100);
    });

    test('applies storm hero additional arrow', () {
      final stats = createHeroRunStats(
        heroType: 4,
        hpUpgrade: 5,
        attackUpgrade: 1,
      );

      expect(stats.extraArrows, 1);
      expect(stats.playerHp, 105);
      expect(stats.attackPowerMultiplier, 1.08);
    });

    test('unknown hero ids use balanced defaults', () {
      final stats = createHeroRunStats(
        heroType: 99,
        hpUpgrade: 0,
        attackUpgrade: 0,
      );

      expect(stats.playerHp, 100);
      expect(stats.playerSpeed, 3.5);
      expect(stats.extraArrows, 0);
      expect(stats.attackPowerMultiplier, 1);
    });
  });
}
