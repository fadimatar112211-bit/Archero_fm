import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/enemy_spawn.dart';

void main() {
  group('createEnemyWave', () {
    test('creates only regular enemy archetypes, including on boss-stage numbers', () {
      final enemies = createEnemyWave(
        stage: 5,
        arenaWidth: 400,
        arenaHeight: 700,
        enemySpeedMultiplier: 1,
        random: Random(1),
      );

      expect(enemies, hasLength(4));
      expect(enemies.every((enemy) => enemy['type'] != 'boss'), isTrue);
      expect(enemies.every((enemy) => enemy['hp'] > 0), isTrue);
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

    test('normalizes invalid stage, arena, and speed multiplier inputs', () {
      final enemies = createEnemyWave(
        stage: -5,
        arenaWidth: double.nan,
        arenaHeight: double.infinity,
        enemySpeedMultiplier: double.nan,
        random: Random(9),
      );
      expect(enemies, hasLength(2));
      for (final enemy in enemies) {
        expect((enemy['x'] as double).isFinite, isTrue);
        expect((enemy['y'] as double).isFinite, isTrue);
        expect(enemy['hp'], greaterThan(0));
        expect(enemy['speed'], greaterThan(0));
      }
    });
 
  });
}
