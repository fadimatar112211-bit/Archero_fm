import 'dart:math';

import 'world_rules.dart';
import 'room_flow.dart';

/// Builds the initial enemy roster for a stage without touching widget state.
///
/// Randomness is injected so callers can keep their existing random stream and
/// tests can reproduce exact waves.
List<Map<String, dynamic>> createEnemyWave({
  required int stage,
  required double arenaWidth,
  required double arenaHeight,
  required double enemySpeedMultiplier,
  required Random random,
}) {
  final difficultyStep = min(max(stage - 1, 0), 20).toDouble();
  final worldRules = WorldRules.forStage(stage);

  if (RoomFlow.forStage(stage).isBoss) {
    final bossProgress = min(max(stage - 5, 0), 45).toDouble();
    final bossHp =
        (360.0 + bossProgress * 22) * worldRules.enemyHealthMultiplier;
    return [
      {
        'x': arenaWidth / 2,
        'y': arenaHeight * 0.16,
        'hp': bossHp,
        'maxHp': bossHp,
        'type': 'boss',
        'radius': 36.0,
        'speed': (0.78 + min(difficultyStep, 16) * 0.012) *
            enemySpeedMultiplier *
            worldRules.enemySpeedMultiplier,
        'bossPhase': 1,
        'bossVolleyCooldown': 90,
      },
    ];
  }

  final count = min(2 + (stage ~/ 2), 7);
  return List.generate(count, (index) {
    final variant = (index + stage) % 4;
    final String enemyType = switch (variant) {
      0 => 'runner',
      1 => 'tank',
      2 => 'stalker',
      _ => 'ranged',
    };
    final baseHp = 55.0 + difficultyStep * 10;
    final baseVariantHp = switch (enemyType) {
      'tank' => baseHp * 1.8,
      'runner' => baseHp * 0.72,
      'stalker' => baseHp * 0.9,
      'ranged' => baseHp * 0.82,
      _ => baseHp,
    };
    final hp = baseVariantHp * worldRules.enemyHealthMultiplier;
    final speed = switch (enemyType) {
      'tank' => 0.52 + difficultyStep * 0.008,
      'runner' => 1.25 + difficultyStep * 0.018,
      'stalker' => 0.90 + difficultyStep * 0.014,
      'ranged' => 0.68 + difficultyStep * 0.010,
      _ => 0.76 + difficultyStep * 0.012,
    };

    return {
      'x': 24.0 + random.nextDouble() * max(1.0, arenaWidth - 48.0),
      'y': arenaHeight * (0.14 + random.nextDouble() * 0.26),
      'hp': hp,
      'maxHp': hp,
      'type': enemyType,
      'radius': enemyType == 'tank' ? 23.0 : 19.0,
      'speed': speed *
          enemySpeedMultiplier *
          worldRules.enemySpeedMultiplier,
    };
  });
}
