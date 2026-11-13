import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/enemy_projectile_motion.dart';

void main() {
  group('advanceEnemyProjectile', () {
    test('advances position and decreases lifetime by one tick', () {
      final step = advanceEnemyProjectile(
        x: 10, y: 20, velocityX: 3, velocityY: -2, life: 8,
        targetX: 100, targetY: 100, arenaWidth: 300, arenaHeight: 500,
      );
      expect(step.x, 13);
      expect(step.y, 18);
      expect(step.life, 7);
      expect(step.hitTarget, isFalse);
      expect(step.shouldRemove, isFalse);
    });

    test('detects a hit at the updated position', () {
      final step = advanceEnemyProjectile(
        x: 0, y: 0, velocityX: 4, velocityY: 0, life: 8,
        targetX: 20, targetY: 0, arenaWidth: 300, arenaHeight: 500,
      );
      expect(step.hitTarget, isTrue);
      expect(step.shouldRemove, isTrue);
    });

    test('expires projectiles with invalid motion, target, or arena data', () {
      final invalidMotion = advanceEnemyProjectile(
        x: 10, y: 10, velocityX: double.nan, velocityY: 0, life: 5,
        targetX: 100, targetY: 100, arenaWidth: 300, arenaHeight: 500,
      );
      final invalidTarget = advanceEnemyProjectile(
        x: 10, y: 10, velocityX: 0, velocityY: 0, life: 5,
        targetX: double.infinity, targetY: 100,
        arenaWidth: 300, arenaHeight: 500,
      );
      final invalidArena = advanceEnemyProjectile(
        x: 10, y: 10, velocityX: 0, velocityY: 0, life: 5,
        targetX: 100, targetY: 100,
        arenaWidth: double.nan, arenaHeight: 500,
      );
      expect(invalidMotion.shouldRemove, isTrue);
      expect(invalidTarget.shouldRemove, isTrue);
      expect(invalidArena.shouldRemove, isTrue);
      expect(invalidMotion.hitTarget, isFalse);
    });

    test('normalizes negative hit radius and bounds padding', () {
      final step = advanceEnemyProjectile(
        x: 10, y: 10, velocityX: 0, velocityY: 0, life: 5,
        targetX: 10, targetY: 10, arenaWidth: 300, arenaHeight: 500,
        hitRadius: -10, boundsPadding: -5,
      );
      expect(step.hitTarget, isFalse);
      expect(step.shouldRemove, isFalse);
    });

    test('expires projectiles at zero life and outside arena bounds', {
      final expired = advanceEnemyProjectile(
        x: 10, y: 10, velocityX: 0, velocityY: 0, life: 1,
        targetX: 200, targetY: 200, arenaWidth: 300, arenaHeight: 500,
      );
      final outside = advanceEnemyProjectile(
        x: 321, y: 10, velocityX: 0, velocityY: 0, life: 5,
        targetX: 200, targetY: 200, arenaWidth: 300, arenaHeight: 500,
      );
      expect(expired.life, 0);
      expect(expired.shouldRemove, isTrue);
      expect(outside.outOfBounds, isTrue);
      expect(outside.shouldRemove, isTrue);
    });
  });
}
