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
  List<SkillId> selectedSkills = const [],
  Set<SkillSynergyId> activeSynergies = const {},
}) => SkillRuntimeStats(
  extraArrows: extraArrows,
  attackPowerMultiplier: attackPowerMultiplier,
  playerHp: playerHp,
  playerMaxHp: playerMaxHp,
  enemySpeedMultiplier: enemySpeedMultiplier,
  coinPickupRadius: coinPickupRadius,
  criticalChance: criticalChance,
  attackSpeedMultiplier: attackSpeedMultiplier,
  selectedSkills: selectedSkills,
  activeSynergies: activeSynergies,
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

    test('activates storm volley synergy once when extra arrow and swift hands combine', () {
      final first = applySkillUpgrade(
        current: baseline(selectedSkills: [SkillId.extraArrow]),
        choice: SkillId.swiftHands,
      );
      expect(first.stats.activeSynergies, contains(SkillSynergyId.stormVolley));
      expect(first.stats.attackSpeedMultiplier, closeTo(1.298, 0.0001));
      expect(first.requiresAttackLoopRestart, isTrue);

      final second = applySkillUpgrade(
        current: first.stats,
        choice: SkillId.extraArrow,
      );
      expect(second.stats.attackSpeedMultiplier, first.stats.attackSpeedMultiplier);
      expect(second.stats.activeSynergies, contains(SkillSynergyId.stormVolley));
    });

    test('shatterpoint synergy adds critical chance without exceeding its cap', () {
      final result = applySkillUpgrade(
        current: baseline(
          criticalChance: 0.3,
          selectedSkills: [SkillId.frostAura],
        ),
        choice: SkillId.criticalStrike,
      );
      expect(result.stats.criticalChance, closeTo(0.5, 1e-10));
      expect(result.stats.activeSynergies, contains(SkillSynergyId.shatterpoint));
    });

    test('treasure heart synergy increases maximum and current health', () {
      final result = applySkillUpgrade(
        current: baseline(
          playerHp: 60,
          playerMaxHp: 100,
          selectedSkills: [SkillId.coinMagnet],
        ),
        choice: SkillId.vitality,
      );
      expect(result.stats.playerMaxHp, 140);
      expect(result.stats.playerHp, 100);
      expect(result.stats.activeSynergies, contains(SkillSynergyId.treasureHeart));
    });

    test('synergy resolver requires both distinct skills', () {
      expect(resolveSkillSynergies([SkillId.extraArrow]), isEmpty);
      expect(
        resolveSkillSynergies([SkillId.extraArrow, SkillId.swiftHands]),
        {SkillSynergyId.stormVolley},
      );
    });
  });
}
