import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/stage_flow.dart';

void main() {
  group('StageFlow.complete', () {
    test('advances exactly one stage after completion', () {
      final result = StageFlow.complete(3);

      expect(result.completedStage, 3);
      expect(result.nextStage, 4);
    });

    test('awards a mystery chest after odd-numbered stages', () {
      expect(
        StageFlow.complete(1).reward,
        StageRewardType.mysteryChest,
      );
      expect(
        StageFlow.complete(3).reward,
        StageRewardType.mysteryChest,
      );
    });

    test('offers a skill choice after even-numbered stages', () {
      expect(
        StageFlow.complete(2).reward,
        StageRewardType.skillChoice,
      );
      expect(
        StageFlow.complete(4).reward,
        StageRewardType.skillChoice,
      );
    });

    test('normalizes invalid stage numbers before advancing', () {
      final result = StageFlow.complete(0);

      expect(result.completedStage, 1);
      expect(result.nextStage, 2);
      expect(result.reward, StageRewardType.mysteryChest);
    });
  });
  group('resolveStageCompletion', () {
    test('heals without exceeding max HP and advances best stage', () {
      final result = resolveStageCompletion(currentStage: 6, playerHp: 90, playerMaxHp: 100, bestStage: 4, healingReward: 35);
      expect(result.advance.nextStage, 7);
      expect(result.updatedPlayerHp, 100);
      expect(result.healingApplied, 10);
      expect(result.updatedBestStage, 7);
    });
    test('normalizes non-finite health and invalid healing safely', () {
      final result = resolveStageCompletion(currentStage: 2, playerHp: double.nan, playerMaxHp: double.infinity, bestStage: 8, healingReward: double.infinity);
      expect(result.updatedPlayerHp, 0);
      expect(result.healingApplied, 0);
      expect(result.updatedBestStage, 8);
    });
    test('handles health above maximum and negative healing reward', () {
      final result = resolveStageCompletion(currentStage: 1, playerHp: 150, playerMaxHp: 100, bestStage: 1, healingReward: -20);
      expect(result.updatedPlayerHp, 100);
      expect(result.healingApplied, 0);
    });
  });

}
