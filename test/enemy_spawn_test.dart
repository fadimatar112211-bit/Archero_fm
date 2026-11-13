import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/enemy_spawn.dart';

void main() {
  group('createEnemyWave', () {
    test('creates the established boss setup on every fifth stage', () {
      final enemies = createEnemyWave(
        stage: 5,
        arenaWidth: 400,
        arenaHeight: 700,
        enemySpeedMultiplier: 1,
        random: Random(1),
      );

      expect(enemies, hasLength(1));
      expect(enemies.single['type'], 'boss');
      expect(enemies.single['x'], 200);
      expect(enemies.single['y'], 112);
      expect(enemies.single['hp'], 360);
      expect(enemies.single['maxHp'], 360);
      expect(enemies.single['radius'], 36);
      expect(enemies.single['speed'], closeTo(0.828, 0.000001));
      expect(enemies.single['bossPhase'], 1);
      expect(enemies.single['bossVolleyCooldown'], 90);
    });

    test('creates the same regular wave for the same random seed', () {
      List<Map<String, dynamic>> wave(int seed) => createEnemyWave(
            stage: 2,
            arenaWidth: 360,
            arenaHeight: 640,
            enemySpeedMultiplier: 1.2,
            random: Random(seed),
          );

      final first = wave(42);
      final second = wave(42);

      expect(first, hasLength(3));
      expect(second, first);
      expect(first.map((enemy) => enemy['type']).toList(),
          ['stalker', 'ranged', 'runner']);
      for (final enemy in first) {
        expect(enemy['hp'], greaterThan(0));
        expect(enemy['maxHp'], enemy['hp']);
        expect(enemy['x'], inInclusiveRange(24, 336));
        expect(enemy['y'], inInclusiveRange(89.6, 256));
        expect(enemy['radius'], anyOf(19.0, 23.0));
        expect(enemy['speed'], greaterThan(0));
      }
    });

    test('applies world scaling and caps regular wave size', () {
      final enemies = createEnemyWave(
        stage: 22,
        arenaWidth: 500,
        arenaHeight: 800,
        enemySpeedMultiplier: 1.1,
        random: Random(7),
      );

      expect(enemies, hasLength(7));
      expect(enemies.every((enemy) => enemy['hp'] > 0), isTrue);
      expect(enemies.every((enemy) => enemy['speed'] > 0), isTrue);
    });

    test('scales boss health and speed with world and stage progression', () {
      final boss = createEnemyWave(
        stage: 15,
        arenaWidth: 360,
        arenaHeight: 640,
        enemySpeedMultiplier: 1.3,
        random: Random(3),
      ).single;

      expect(boss['hp'], 638);
      expect(boss['speed'], closeTo(1.2285, 0.000001));
    });
  });
}
