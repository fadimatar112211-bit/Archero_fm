import 'game_progress.dart';

class AchievementStats {
  const AchievementStats({
    required this.bestStage,
    required this.totalKills,
    required this.totalBosses,
    required this.totalChests,
    required this.totalRuns,
  });

  final int bestStage, totalKills, totalBosses, totalChests, totalRuns;
}

class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardCoins,
    required this.rewardGems,
    required this.rewardShards,
    required this.isComplete,
  });

  final int id;
  final String title, description;
  final int rewardCoins, rewardGems, rewardShards;
  final bool Function(AchievementStats stats) isComplete;

  int get bit => 1 << id;
}

const achievements = <AchievementDefinition>[
  AchievementDefinition(id: 0, title: 'أول انتصار', description: 'اقضِ على 10 أعداء.', rewardCoins: 80, rewardGems: 0, rewardShards: 0, isComplete: _tenKills),
  AchievementDefinition(id: 1, title: 'صياد الأعداء', description: 'اقضِ على 50 عدواً.', rewardCoins: 150, rewardGems: 2, rewardShards: 0, isComplete: _fiftyKills),
  AchievementDefinition(id: 2, title: 'إسقاط العملاق', description: 'اهزم أول زعيم.', rewardCoins: 100, rewardGems: 1, rewardShards: 0, isComplete: _oneBoss),
  AchievementDefinition(id: 3, title: 'كاسر الزعماء', description: 'اهزم 5 زعماء.', rewardCoins: 250, rewardGems: 5, rewardShards: 0, isComplete: _fiveBosses),
  AchievementDefinition(id: 4, title: 'جامع الصناديق', description: 'افتح 3 صناديق مكافآت.', rewardCoins: 100, rewardGems: 0, rewardShards: 2, isComplete: _threeChests),
  AchievementDefinition(id: 5, title: 'باحث الكنوز', description: 'افتح 10 صناديق مكافآت.', rewardCoins: 200, rewardGems: 5, rewardShards: 5, isComplete: _tenChests),
  AchievementDefinition(id: 6, title: 'مستكشف العوالم', description: 'وصل إلى المرحلة 5.', rewardCoins: 120, rewardGems: 1, rewardShards: 0, isComplete: _stageFive),
  AchievementDefinition(id: 7, title: 'محارب مخضرم', description: 'وصل إلى المرحلة 10.', rewardCoins: 300, rewardGems: 5, rewardShards: 0, isComplete: _stageTen),
  AchievementDefinition(id: 8, title: 'أسطورة الساحة', description: 'وصل إلى المرحلة 20.', rewardCoins: 600, rewardGems: 10, rewardShards: 3, isComplete: _stageTwenty),
  AchievementDefinition(id: 9, title: 'لا يستسلم', description: 'أكمل 5 جولات.', rewardCoins: 180, rewardGems: 2, rewardShards: 3, isComplete: _fiveRuns),
];

bool _tenKills(AchievementStats s) => s.totalKills >= 10;
bool _fiftyKills(AchievementStats s) => s.totalKills >= 50;
bool _oneBoss(AchievementStats s) => s.totalBosses >= 1;
bool _fiveBosses(AchievementStats s) => s.totalBosses >= 5;
bool _threeChests(AchievementStats s) => s.totalChests >= 3;
bool _tenChests(AchievementStats s) => s.totalChests >= 10;
bool _stageFive(AchievementStats s) => s.bestStage >= 5;
bool _stageTen(AchievementStats s) => s.bestStage >= 10;
bool _stageTwenty(AchievementStats s) => s.bestStage >= 20;
bool _fiveRuns(AchievementStats s) => s.totalRuns >= 5;

class AchievementProgress {
  const AchievementProgress(this.definition, {required this.unlocked, required this.claimed});

  final AchievementDefinition definition;
  final bool unlocked, claimed;
  bool get claimable => unlocked && !claimed;
}

AchievementStats currentAchievementStats({
  required int bestStage,
  required int totalKills,
  required int totalBosses,
  required int totalChests,
  required int totalRuns,
}) => AchievementStats(
  bestStage: bestStage,
  totalKills: totalKills,
  totalBosses: totalBosses,
  totalChests: totalChests,
  totalRuns: totalRuns,
);

List<AchievementProgress> evaluateAchievements({
  required AchievementStats stats,
  required int claimedMask,
}) => [
  for (final definition in achievements)
    AchievementProgress(
      definition,
      unlocked: definition.isComplete(stats),
      claimed: (claimedMask & definition.bit) != 0,
    ),
];

int get claimedAchievementCount => achievements
    .where((achievement) => (claimedAchievementsMask & achievement.bit) != 0)
    .length;
