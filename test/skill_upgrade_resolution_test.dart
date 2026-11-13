import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/skill_system.dart';

SkillRuntimeStats baseline({
  int extraArrows = 0,
  double attackPowerMultiplier = 1,
  double playerHp = 60,
  double playerMaxHp = 100,
  double enemySpeedMultiplier = 1,
  double coinPickupRadius = 34,
  double criticalChance = 0,
  double attackSpeedMultiplier = 1,
}) => SkillRuntimeStats(
  extraArrows: extraArrows,
  attackPowerMultiplier: attackPowerMultiplier,
  playerHp: playerHp,
  playerMaxHp: playerMaxHp,
  enemySpeedMultiplier: enemySpeedMultiplier,
  coinPickupRadius: coinPickupRadius,
  criticalChance: criticalChance,
  attackSpeedMultiplier: attackSpeedMultiplier,
);

void main() {
  group('applySkillUpgrade', () {
    test('applies each numeric upgrade with existing balance values', () {
      expect(applySkillUpgrade(current: baseline(), choice: SkillId.extraArrow)
          .stats.extraArrows, 1);
      expect(applySkillUpgrade(current: baseline(), choice: SkillId.attackPower)
          .stats.attackPowerMultiplier, 1.25);
      expect(applySkillUpgrade(current: baseline(), choice: SkillId.healing)
          .stats.playerHp, 100);
      final vitality = applySkillUpgrade(
        current: baseline(playerHp: 60),
        choice: SkillId.vitality,
      ).stats;
      expect(vitality.playerMaxHp, 125);
      expect(vitality.playerHp, 85);
      expect(applySkillUpgrade(current: baseline(), choice: SkillId.frostAura)
          .stats.enemySpeedMultiplier, 0.9);
      expect(applySkillUpgrade(current: baseline(), choice: SkillId.coinMagnet)
          .stats.coinPickupRadius, closeTo(49.3, 0.0001));
      expect(applySkillUpgrade(current: baseline(), choice: SkillId.criticalStrike)
          .stats.criticalChance, 0.15);
      expect(applySkillUpgrade(current: baseline(), choice: SkillId.swiftHands)
          .stats.attackSpeedMultiplier, 1.18);
    });

    test('healing never exceeds maximum health', () {
      final result = applySkillUpgrade(
        current: baseline(playerHp: 95, playerMaxHp: 100),
        choice: SkillId.healing,
      );
      expect(result.stats.playerHp, 100);
    });

    test('critical chance and attack speed respect their caps', () {
      final critical = applySkillUpgrade(
        current: baseline(criticalChance: 0.7),
        choice: SkillId.criticalStrike,
      );
      final speed = applySkillUpgrade(
        current: baseline(attackSpeedMultiplier: 2.1),
        choice: SkillId.swiftHands,
      );
      expect(critical.stats.criticalChance, 0.75);
      expect(speed.stats.attackSpeedMultiplier, 2.2);
    });

    test('only attack speed upgrade requests shoot loop restart', () {
      final swift = applySkillUpgrade(
        current: baseline(),
        choice: SkillId.swiftHands,
      );
      final power = applySkillUpgrade(
        current: baseline(),
        choice: SkillId.attackPower,
      );
      expect(swift.requiresAttackLoopRestart, isTrue);
      expect(power.requiresAttackLoopRestart, isFalse);
    });

    test('null selection preserves every stat', () {
      final current = baseline(
        extraArrows: 2,
        attackPowerMultiplier: 1.5,
        playerHp: 43,
        playerMaxHp: 120,
        enemySpeedMultiplier: 0.8,
        coinPickupRadius: 70,
        criticalChance: 0.3,
        attackSpeedMultiplier: 1.6,
      );
      final result = applySkillUpgrade(current: current, choice: null);
      expect(result.stats.extraArrows, current.extraArrows);
      expect(result.stats.attackPowerMultiplier, current.attackPowerMultiplier);
      expect(result.stats.playerHp, current.playerHp);
      expect(result.stats.playerMaxHp, current.playerMaxHp);
      expect(result.stats.enemySpeedMultiplier, current.enemySpeedMultiplier);
      expect(result.stats.coinPickupRadius, current.coinPickupRadius);
      expect(result.stats.criticalChance, current.criticalChance);
      expect(result.stats.attackSpeedMultiplier, current.attackSpeedMultiplier);
      expect(result.requiresAttackLoopRestart, isFalse);
    });
  });
}
