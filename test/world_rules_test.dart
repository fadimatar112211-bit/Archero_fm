import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/world_rules.dart';

void main() {
  group('WorldRules.forStage', () {
    test('maps each ten-stage block to its world', () {
      expect(WorldRules.forStage(1).worldId, 1);
      expect(WorldRules.forStage(10).worldId, 1);
      expect(WorldRules.forStage(11).worldId, 2);
      expect(WorldRules.forStage(20).worldId, 2);
      expect(WorldRules.forStage(21).worldId, 3);
      expect(WorldRules.forStage(60).worldId, 6);
    });

    test('normalizes early stages and caps progression at final world', () {
      expect(WorldRules.forStage(0).worldId, 1);
      expect(WorldRules.forStage(-5).worldId, 1);
      expect(WorldRules.forStage(61).worldId, 6);
      expect(WorldRules.forStage(1000).worldId, 6);
    });

    test('worlds have distinct difficulty and reward profiles', () {
      final rules = WorldRules.all;

      expect(rules, hasLength(6));
      expect(rules.map((rule) => rule.worldId).toSet(), hasLength(6));
      expect(rules.map((rule) => rule.enemyHealthMultiplier).toSet().length,
          greaterThan(1));
      expect(rules.map((rule) => rule.enemySpeedMultiplier).toSet().length,
          greaterThan(1));
      expect(rules.map((rule) => rule.coinRewardMultiplier).toSet().length,
          greaterThan(1));
    });

    test('all multipliers remain positive and bounded', () {
      for (final rule in WorldRules.all) {
        expect(rule.enemyHealthMultiplier, inInclusiveRange(0.5, 2.0));
        expect(rule.enemySpeedMultiplier, inInclusiveRange(0.5, 2.0));
        expect(rule.coinRewardMultiplier, inInclusiveRange(1.0, 1.5));
      }
    });
  });
  
  test('calculates scaled pickup and mystery chest rewards', () {
    expect(WorldRules.forest.pickupCoinReward, 10);
    expect(WorldRules.forest.mysteryChestReward, 75);
    expect(WorldRules.volcano.pickupCoinReward, 12);
    expect(WorldRules.volcano.mysteryChestReward, 86);
    expect(WorldRules.citadel.pickupCoinReward, 14);
    expect(WorldRules.citadel.mysteryChestReward, 101);
  });
}
