import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/stage_flow.dart';

void main() {
  group('resolveStageCompletion', () {
    test('advances stage and updates best stage with healing', () {
      final result = resolveStageCompletion(
        currentStage: 4,
        playerHp: 60,
        playerMaxHp: 100,
        bestStage: 3,
      );

      expect(result.advance.completedStage, 4);
      expect(result.advance.nextStage, 5);
      expect(result.advance.reward, StageRewardType.skillChoice);
      expect(result.updatedBestStage, 5);
      expect(result.updatedPlayerHp, 95);
      expect(result.healingApplied, 35);
    });

    test('caps healing at maximum health', () {
      final result = resolveStageCompletion(
        currentStage: 1,
        playerHp: 90,
        playerMaxHp: 100,
        bestStage: 8,
      );

      expect(result.updatedPlayerHp, 100);
      expect(result.healingApplied, 10);
      expect(result.updatedBestStage, 8);
    });

    test('normalizes invalid stage and health inputs safely', () {
      final result = resolveStageCompletion(
        currentStage: 0,
        playerHp: double.nan,
        playerMaxHp: 120,
        bestStage: 0,
      );

      expect(result.advance.completedStage, 1);
      expect(result.advance.nextStage, 2);
      expect(result.updatedBestStage, 2);
      expect(result.updatedPlayerHp, 35);
      expect(result.healingApplied, 35);
    });

    test('handles invalid max health and healing values', () {
      final result = resolveStageCompletion(
        currentStage: 2,
        playerHp: 40,
        playerMaxHp: double.infinity,
        bestStage: 2,
        healingReward: double.nan,
      );

      expect(result.updatedPlayerHp, 0);
      expect(result.healingApplied, 0);
      expect(result.updatedBestStage, 3);
    });

    test('supports custom healing reward', () {
      final result = resolveStageCompletion(
        currentStage: 2,
        playerHp: 40,
        playerMaxHp: 100,
        bestStage: 1,
        healingReward: 12,
      );

      expect(result.updatedPlayerHp, 52);
      expect(result.healingApplied, 12);
    });
  });
}
