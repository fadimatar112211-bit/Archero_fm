import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/world_progression.dart';

void main() {
  group('WorldStageProgression', () {
    test('a new profile unlocks only the first stage and first world', () {
      const progression = WorldStageProgression(bestStage: 1);

      expect(progression.maxUnlockedStage, 1);
      expect(progression.maxUnlockedWorld, 1);
      expect(progression.isStageUnlocked(1), isTrue);
      expect(progression.isStageUnlocked(2), isFalse);
      expect(progression.isWorldUnlocked(1), isTrue);
      expect(progression.isWorldUnlocked(2), isFalse);
    });

    test('clearing a world boss unlocks the next world first stage', () {
      const progression = WorldStageProgression(bestStage: 11);

      expect(progression.isStageUnlocked(10), isTrue);
      expect(progression.isStageUnlocked(11), isTrue);
      expect(progression.isStageUnlocked(12), isFalse);
      expect(progression.isWorldUnlocked(2), isTrue);
      expect(progression.isWorldUnlocked(3), isFalse);
      expect(progression.maxUnlockedWorld, 2);
    });

    test('unlocks only stages up to the saved best stage within a world', () {
      const progression = WorldStageProgression(bestStage: 27);

      expect(progression.maxUnlockedWorld, 3);
      expect(progression.stagesForWorld(3), List<int>.generate(10, (i) => i + 21));
      expect(progression.isStageUnlocked(27), isTrue);
      expect(progression.isStageUnlocked(28), isFalse);
      expect(progression.isStageUnlocked(30), isFalse);
      expect(progression.isStageUnlocked(31), isFalse);
    });

    test('caps progression at the final stage and rejects invalid IDs', () {
      const progression = WorldStageProgression(bestStage: 999);

      expect(progression.maxUnlockedStage, 60);
      expect(progression.maxUnlockedWorld, 6);
      expect(progression.isStageUnlocked(60), isTrue);
      expect(progression.isStageUnlocked(61), isFalse);
      expect(progression.isWorldUnlocked(7), isFalse);
      expect(() => progression.stagesForWorld(0), throwsRangeError);
    });

    test('normalizes invalid low saved progress to the first stage', () {
      const progression = WorldStageProgression(bestStage: -5);

      expect(progression.maxUnlockedStage, 1);
      expect(progression.maxUnlockedWorld, 1);
      expect(progression.isStageUnlocked(0), isFalse);
    });
  });
}
