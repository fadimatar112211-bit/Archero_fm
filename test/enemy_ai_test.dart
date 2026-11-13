import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/enemy_ai.dart';

void main() {
  group('decideEnemyMovement', () {
    test('ranged enemies retreat, hold distance, and approach slowly', () {
      EnemyMovementDecision decide(double distance) => decideEnemyMovement(
            type: 'ranged',
            distanceToPlayer: distance,
            baseAngle: 0,
            enemyX: 0,
            animationTicks: 10,
            bossEnraged: false,
            bossPhaseMovementMultiplier: 1,
          );

      expect(decide(100).angle, closeTo(pi, 0.000001));
      expect(decide(100).speedMultiplier, 1.05);
      expect(decide(160).speedMultiplier, 0.08);
      expect(decide(220).speedMultiplier, 0.72);
    });

    test('runner dash alternates between charge and recovery speeds', () {
      final dash = decideEnemyMovement(
        type: 'runner', distanceToPlayer: 200, baseAngle: 0,
        enemyX: 0, animationTicks: 0, bossEnraged: false,
        bossPhaseMovementMultiplier: 1,
      );
      final recovery = decideEnemyMovement(
        type: 'runner', distanceToPlayer: 200, baseAngle: 0,
        enemyX: 0, animationTicks: 18, bossEnraged: false,
        bossPhaseMovementMultiplier: 1,
      );

      expect(dash.speedMultiplier, 2.35);
      expect(recovery.speedMultiplier, 0.78);
    });

    test('stalker circles and tank advances more slowly', () {
      final stalker = decideEnemyMovement(
        type: 'stalker', distanceToPlayer: 150, baseAngle: 0,
        enemyX: 0, animationTicks: 0, bossEnraged: false,
        bossPhaseMovementMultiplier: 1,
      );
      final tank = decideEnemyMovement(
        type: 'tank', distanceToPlayer: 150, baseAngle: 0,
        enemyX: 0, animationTicks: 0, bossEnraged: false,
        bossPhaseMovementMultiplier: 1,
      );

      expect(stalker.angle, closeTo(0.48, 0.000001));
      expect(stalker.speedMultiplier, 1.12);
      expect(tank.speedMultiplier, 0.82);
    });

    test('normalizes non-finite steering inputs and negative distances', () {
      final ranged = decideEnemyMovement(
        type: 'ranged', distanceToPlayer: double.nan, baseAngle: double.nan,
        enemyX: double.infinity, animationTicks: 10, bossEnraged: false,
        bossPhaseMovementMultiplier: double.nan,
      );
      final stalker = decideEnemyMovement(
        type: 'stalker', distanceToPlayer: -10, baseAngle: double.infinity,
        enemyX: double.nan, animationTicks: 0, bossEnraged: false,
        bossPhaseMovementMultiplier: 1,
      );

      expect(ranged.angle, 0);
      expect(ranged.speedMultiplier, 0.72);
      expect(stalker.angle.isFinite, isTrue);
      expect(stalker.speedMultiplier, 0.72);
    });

    test('boss movement scales by phase and enrage state', () {
      final normal = decideEnemyMovement(
        type: 'boss', distanceToPlayer: 150, baseAngle: 0,
        enemyX: 0, animationTicks: 0, bossEnraged: false,
        bossPhaseMovementMultiplier: 1.2,
      );
      final enraged = decideEnemyMovement(
        type: 'boss', distanceToPlayer: 150, baseAngle: 0,
        enemyX: 0, animationTicks: 0, bossEnraged: true,
        bossPhaseMovementMultiplier: 1.2,
      );

      expect(normal.speedMultiplier, closeTo(3.18, 0.000001));
      expect(enraged.speedMultiplier, closeTo(3.78, 0.000001));
    });
  });
}
