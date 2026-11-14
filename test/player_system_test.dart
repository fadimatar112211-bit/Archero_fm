import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/player_system.dart';

void main() {
  group('PlayerSystem boundary', () {
    test('resolves hero profile and initial run stats', () {
      final profile = PlayerSystem.profileForHero(3);
      final stats = PlayerSystem.createRunStats(
        heroType: 3,
        hpUpgrade: 10,
        attackUpgrade: 2,
      );

      expect(profile.id, 3);
      expect(stats.playerHp, 110);
      expect(stats.playerSpeed, 5.2);
      expect(stats.attackPowerMultiplier, 1.16);
    });

    test('resolves bounded drag and dodge movement', () {
      final movement = PlayerSystem.resolveDrag(
        currentX: 180,
        currentY: 430,
        deltaX: 48,
        deltaY: -32,
        arenaWidth: 360,
        arenaHeight: 640,
        currentMoveTicks: 0,
      );

      expect(movement.x, 228);
      expect(movement.y, 398);
      expect(movement.moveTicks, 8);
    });

    test('selects nearest target and creates the configured arrow volley', () {
      final targetIndex = PlayerSystem.nearestTargetIndex(
        originX: 100,
        originY: 100,
        targets: const [
          PlayerTarget(x: 250, y: 100),
          PlayerTarget(x: 110, y: 100),
        ],
      );
      final volley = PlayerSystem.createArrowVolley(
        originX: 100,
        originY: 100,
        targetX: 110,
        targetY: 100,
        extraArrows: 1,
        projectileSpeed: 8,
        spreadAngle: 0.2,
      );

      expect(targetIndex, 1);
      expect(volley, hasLength(2));
      expect(volley.first.x, 100);
      expect(volley.first.y, 100);
      expect(volley.first.velocityX, closeTo(8, 0.0001));
      expect(volley.first.velocityY, closeTo(0, 0.0001));
    });

    test('advances player arrow and reports target collision', () {
      final update = PlayerSystem.advanceArrow(
        x: 100,
        y: 100,
        velocityX: 8,
        velocityY: 0,
        arenaWidth: 360,
        arenaHeight: 640,
        targets: const [PlayerTarget(x: 110, y: 100, radius: 5)],
      );

      expect(update.x, 108);
      expect(update.y, 100);
      expect(update.shouldRemove, isFalse);
      expect(update.hitTargetIndex, 0);
    });
  });
}
