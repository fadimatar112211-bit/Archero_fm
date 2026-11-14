import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/room_encounter.dart';

void main() {
  group('RoomEncounterFactory', () {
    test('routes boss rooms to the boss spawner only', () {
      final actors = RoomEncounterFactory.create(
        stage: 5,
        arenaWidth: 360,
        arenaHeight: 640,
        enemySpeedMultiplier: 1,
        random: Random(1),
      );

      expect(actors, hasLength(1));
      expect(actors.single['type'], 'boss');
      expect(actors.single['hp'], actors.single['maxHp']);
    });

    test('routes combat rooms to deterministic regular enemy waves', () {
      List<Map<String, dynamic>> spawn() => RoomEncounterFactory.create(
            stage: 4,
            arenaWidth: 360,
            arenaHeight: 640,
            enemySpeedMultiplier: 1,
            random: Random(7),
          );

      final first = spawn();
      final second = spawn();
      expect(first, isNotEmpty);
      expect(first.every((actor) => actor['type'] != 'boss'), isTrue);
      expect(first, second);
    });

    test('scales challenge reinforcement health consistently', () {
      final actors = RoomEncounterFactory.createChallengeReinforcements(
        currentStage: 1,
        arenaWidth: 360,
        arenaHeight: 640,
        enemySpeedMultiplier: 1,
        random: Random(4),
      );

      expect(actors, hasLength(2));
      for (final actor in actors) {
        expect(actor['hp'], closeTo((actor['maxHp'] as double), 1e-9));
        expect(actor['hp'], greaterThan(0));
      }
    });

    test('preserves boss reinforcement routing for challenge stages', () {
      final actors = RoomEncounterFactory.createChallengeReinforcements(
        currentStage: 3,
        arenaWidth: 360,
        arenaHeight: 640,
        enemySpeedMultiplier: 1,
        random: Random(4),
      );
      expect(actors, hasLength(1));
      expect(actors.single['type'], 'boss');
    });
  });
}
