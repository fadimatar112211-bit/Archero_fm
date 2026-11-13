import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/achievement_system.dart';

void main() {
  group('Achievement evaluation', () {
    const empty = AchievementStats(
      bestStage: 1,
      totalKills: 0,
      totalBosses: 0,
      totalChests: 0,
      totalRuns: 0,
    );

    test('keeps milestones locked until their actual requirements are met', () {
      final results = evaluateAchievements(stats: empty, claimedMask: 0);
      expect(results, hasLength(10));
      expect(results.every((entry) => !entry.unlocked && !entry.claimable), isTrue);
    });

    test('unlocks all eligible milestones independently of claim state', () {
      const stats = AchievementStats(
        bestStage: 20,
        totalKills: 75,
        totalBosses: 5,
        totalChests: 10,
        totalRuns: 5,
      );
      final results = evaluateAchievements(stats: stats, claimedMask: 0);
      expect(results.every((entry) => entry.unlocked && entry.claimable), isTrue);
    });

    test('claimed rewards cannot be claimed a second time', () {
      const stats = AchievementStats(
        bestStage: 5,
        totalKills: 10,
        totalBosses: 1,
        totalChests: 3,
        totalRuns: 1,
      );
      final mask = achievements
          .where((entry) => entry.isComplete(stats))
          .fold<int>(0, (value, entry) => value | entry.bit);
      final results = evaluateAchievements(stats: stats, claimedMask: mask);
      expect(results.where((entry) => entry.claimable), isEmpty);
      expect(results.where((entry) => entry.claimed), hasLength(4));
    });

    test('uses stable unique bits for every achievement', () {
      final bits = achievements.map((entry) => entry.bit).toSet();
      expect(bits, hasLength(achievements.length));
      expect(achievements.every((entry) => entry.rewardCoins >= 0 &&
          entry.rewardGems >= 0 && entry.rewardShards >= 0), isTrue);
    });
  });
}
