import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/hero_rules.dart';

void main() {
  group('HeroProfile', () {
    test('defines unique active and passive abilities for every hero', () {
      expect(HeroProfile.all, hasLength(4));
      expect(
        HeroProfile.all.map((profile) => profile.activeSkillName).toSet(),
        hasLength(4),
      );
      expect(
        HeroProfile.all.map((profile) => profile.passiveSkillName).toSet(),
        hasLength(4),
      );
      for (final profile in HeroProfile.all) {
        expect(profile.activeSkillDescription, isNotEmpty);
        expect(profile.passiveSkillDescription, isNotEmpty);
      }
    });

    test('unknown hero ids safely use the balanced profile', () {
      expect(HeroProfile.forType(0), HeroProfile.balanced);
      expect(HeroProfile.forType(99), HeroProfile.balanced);
    });
  });

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
      expect(stats.criticalChance, 0.05);
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
