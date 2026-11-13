import 'dart:math';

import 'world_rules.dart';

/// Creates a boss actor independently from regular enemy wave generation.
Map<String, dynamic> createBossForStage({
  required int stage,
  required double arenaWidth,
  required double arenaHeight,
  required double enemySpeedMultiplier,
}) {
  final safeStage = max(stage, 1);
  final safeWidth = arenaWidth.isFinite && arenaWidth >= 48
      ? arenaWidth
      : 360.0;
  final safeHeight = arenaHeight.isFinite && arenaHeight >= 140
      ? arenaHeight
      : 640.0;
  final safeEnemySpeedMultiplier = enemySpeedMultiplier.isFinite &&
          enemySpeedMultiplier >= 0
      ? enemySpeedMultiplier
      : 1.0;
  final difficultyStep = min(max(safeStage - 1, 0), 20).toDouble();
  final worldRules = WorldRules.forStage(safeStage);
  final bossProgress = min(max(safeStage - 5, 0), 45).toDouble();
  final bossHp =
      (360.0 + bossProgress * 22) * worldRules.enemyHealthMultiplier;

  return {
    'x': safeWidth / 2,
    'y': safeHeight * 0.16,
    'hp': bossHp,
    'maxHp': bossHp,
    'type': 'boss',
    'radius': 36.0,
    'speed': (0.78 + min(difficultyStep, 16) * 0.012) *
        safeEnemySpeedMultiplier *
        worldRules.enemySpeedMultiplier,
    'bossPhase': 1,
    'bossVolleyCooldown': 90,
  };
}
