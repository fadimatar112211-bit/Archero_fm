import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/game_run_state.dart';

void main() {
  group('GameRunState', () {
    test('starts with stable run defaults and requested stage', () {
      final run = GameRunState(initialStage: 7);

      expect(run.stage, 7);
      expect(run.score, 0);
      expect(run.playerX, 180);
      expect(run.playerY, 430);
      expect(run.playerHp, 100);
      expect(run.playerMaxHp, 100);
      expect(run.arenaWidth, 360);
      expect(run.arenaHeight, 640);
      expect(run.specialCooldown, 0);
    });

    test('normalizes an invalid initial stage', () {
      expect(GameRunState(initialStage: 0).stage, 1);
      expect(GameRunState(initialStage: -5).stage, 1);
    });

    test('owns independent mutable entity collections per run', () {
      final first = GameRunState();
      final second = GameRunState();
      first.enemies.add({'hp': 10});
      first.arrows.add({'x': 20.0});
      first.combatEffects.add({'life': 3});

      expect(second.enemies, isEmpty);
      expect(second.arrows, isEmpty);
      expect(second.combatEffects, isEmpty);
    });

    test('stores mutable combat and progression values', () {
      final run = GameRunState();
      run.playerHp = 42;
      run.attackPowerMultiplier = 1.5;
      run.criticalChance = 0.2;
      run.extraArrows = 2;
      run.score = 300;
      run.stage = 4;
      run.playerDeathTicks = 5;

      expect(run.playerHp, 42);
      expect(run.attackPowerMultiplier, 1.5);
      expect(run.criticalChance, 0.2);
      expect(run.extraArrows, 2);
      expect(run.score, 300);
      expect(run.stage, 4);
      expect(run.playerDeathTicks, 5);
    });
  });
}
