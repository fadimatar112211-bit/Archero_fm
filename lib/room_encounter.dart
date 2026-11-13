import 'dart:math';

import 'boss_spawn.dart';
import 'enemy_spawn.dart';
import 'room_flow.dart';

typedef RoomActor = Map<String, dynamic>;

/// Builds the actor roster for a room without depending on Flutter widgets.
///
/// Room routing decides whether a stage is a boss or combat room; the
/// corresponding spawn system remains responsible for actor-specific stats.
class RoomEncounterFactory {
  const RoomEncounterFactory._();

  static List<RoomActor> create({
    required int stage,
    required double arenaWidth,
    required double arenaHeight,
    required double enemySpeedMultiplier,
    required Random random,
  }) {
    final room = RoomFlow.forStage(stage);
    if (room.isBoss) {
      return [
        createBossForStage(
          stage: room.stage,
          arenaWidth: arenaWidth,
          arenaHeight: arenaHeight,
          enemySpeedMultiplier: enemySpeedMultiplier,
        ),
      ];
    }
    return createEnemyWave(
      stage: room.stage,
      arenaWidth: arenaWidth,
      arenaHeight: arenaHeight,
      enemySpeedMultiplier: enemySpeedMultiplier,
      random: random,
    );
  }

  /// Adds the existing two-actor challenge reinforcement roster.
  ///
  /// Both current and maximum HP are scaled together so the health bar
  /// continues to represent the actor's actual remaining-health ratio.
  static List<RoomActor> createChallengeReinforcements({
    required int currentStage,
    required double arenaWidth,
    required double arenaHeight,
    required double enemySpeedMultiplier,
    required Random random,
  }) {
    final reinforcements = create(
      stage: currentStage + 2,
      arenaWidth: arenaWidth,
      arenaHeight: arenaHeight,
      enemySpeedMultiplier: enemySpeedMultiplier * 1.12,
      random: random,
    ).take(2);

    return reinforcements.map((actor) {
      final reinforced = Map<String, dynamic>.from(actor);
      final hp = reinforced['hp'];
      final maxHp = reinforced['maxHp'];
      if (hp is num) reinforced['hp'] = hp.toDouble() * 1.2;
      if (maxHp is num) reinforced['maxHp'] = maxHp.toDouble() * 1.2;
      return reinforced;
    }).toList(growable: false);
  }
}
