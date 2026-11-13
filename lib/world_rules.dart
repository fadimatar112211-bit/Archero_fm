class WorldRules {
  final int worldId;
  final double enemyHealthMultiplier;
  final double enemySpeedMultiplier;
  final double coinRewardMultiplier;

  const WorldRules({
    required this.worldId,
    required this.enemyHealthMultiplier,
    required this.enemySpeedMultiplier,
    required this.coinRewardMultiplier,
  });

  static const forest = WorldRules(
    worldId: 1,
    enemyHealthMultiplier: 1,
    enemySpeedMultiplier: 1,
    coinRewardMultiplier: 1,
  );
  static const volcano = WorldRules(
    worldId: 2,
    enemyHealthMultiplier: 1.10,
    enemySpeedMultiplier: 1.05,
    coinRewardMultiplier: 1.15,
  );
  static const ice = WorldRules(
    worldId: 3,
    enemyHealthMultiplier: 1.05,
    enemySpeedMultiplier: 0.90,
    coinRewardMultiplier: 1.10,
  );
  static const desert = WorldRules(
    worldId: 4,
    enemyHealthMultiplier: 1,
    enemySpeedMultiplier: 1.12,
    coinRewardMultiplier: 1.20,
  );
  static const shadows = WorldRules(
    worldId: 5,
    enemyHealthMultiplier: 1.15,
    enemySpeedMultiplier: 1.08,
    coinRewardMultiplier: 1.25,
  );
  static const citadel = WorldRules(
    worldId: 6,
    enemyHealthMultiplier: 1.20,
    enemySpeedMultiplier: 1,
    coinRewardMultiplier: 1.35,
  );

  static const all = [
    forest,
    volcano,
    ice,
    desert,
    shadows,
    citadel,
  ];

  /// Coins granted for collecting one dropped coin in this world.
  int get pickupCoinReward => (10 * coinRewardMultiplier).round();

  /// Coins granted by the stage mystery chest in this world.
  int get mysteryChestReward => (75 * coinRewardMultiplier).round();

  static WorldRules forStage(int stage) {
    final safeStage = stage < 1 ? 1 : stage;
    final worldIndex = ((safeStage - 1) ~/ 10).clamp(0, all.length - 1);
    return all[worldIndex];
  }
}
