import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/boss_spawn.dart';

void main() {
  group('createBossForStage', () {
    test('creates the established boss actor independently from enemy waves', () {
      final boss = createBossForStage(
        stage: 5,
        arenaWidth: 400,
        arenaHeight: 700,
        enemySpeedMultiplier: 1,
      );

      expect(boss['type'], 'boss');
      expect(boss['x'], 200);
      expect(boss['y'], 112);
      expect(boss['hp'], 360);
      expect(boss['maxHp'], 360);
      expect(boss['radius'], 36);
      expect(boss['speed'], closeTo(0.828, 0.000001));
      expect(boss['bossPhase'], 1);
      expect(boss['bossVolleyCooldown'], 90);
    });

    test('scales boss health and speed with world and stage progression', () {
      final boss = createBossForStage(
        stage: 15,
        arenaWidth: 360,
        arenaHeight: 640,
        enemySpeedMultiplier: 1.3,
      );

      expect(boss['hp'], 638);
      expect(boss['speed'], closeTo(1.29402, 0.000001));
    });

    test('normalizes invalid arena and speed inputs', () {
      final boss = createBossForStage(
        stage: -5,
        arenaWidth: double.nan,
        arenaHeight: double.infinity,
        enemySpeedMultiplier: double.nan,
      );

      expect(boss['x'], 180);
      expect(boss['y'], 102.4);
      expect(boss['hp'], greaterThan(0));
      expect(boss['speed'], greaterThan(0));
    });
  });
}
