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
}
