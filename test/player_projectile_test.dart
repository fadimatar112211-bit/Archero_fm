import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/combat_collision.dart';
import 'package:archero_fm/player_projectile.dart';

void main() {
  group('resolvePlayerProjectileStep', () {
    const noTargets = <CombatCircle>[];

    test('advances the projectile by its velocity', () {
      final step = resolvePlayerProjectileStep(
        x: 30, y: 40, velocityX: 7, velocityY: -3,
        arenaWidth: 360, arenaHeight: 640, targets: noTargets,
      );
      expect(step.x, 37);
      expect(step.y, 37);
      expect(step.outOfBounds, isFalse);
      expect(step.hitTargetIndex, isNull);
    });

    test('uses existing arena margins and removes only beyond them', () {
      final atEdge = resolvePlayerProjectileStep(
        x: -19, y: 20, velocityX: -1, velocityY: 0,
        arenaWidth: 360, arenaHeight: 640, targets: noTargets,
      );
      final outside = resolvePlayerProjectileStep(
        x: -20, y: 20, velocityX: -0.01, velocityY: 0,
        arenaWidth: 360, arenaHeight: 640, targets: noTargets,
      );
      expect(atEdge.outOfBounds, isFalse);
      expect(outside.outOfBounds, isTrue);
      expect(outside.hitTargetIndex, isNull);
    });

    test('resolves overlapping targets using established reverse priority', () {
      final step = resolvePlayerProjectileStep(
        x: 50, y: 50, velocityX: 0, velocityY: 0,
        arenaWidth: 360, arenaHeight: 640,
        targets: const [
          CombatCircle(x: 50, y: 50, radius: 20),
          CombatCircle(x: 50, y: 50, radius: 20),
        ],
      );
      expect(step.hitTargetIndex, 1);
    });

    test('does not resolve a hit after projectile leaves the arena', () {
      final step = resolvePlayerProjectileStep(
        x: 359, y: 100, velocityX: 30, velocityY: 0,
        arenaWidth: 360, arenaHeight: 640,
        targets: const [CombatCircle(x: 389, y: 100, radius: 30)],
      );
      expect(step.outOfBounds, isTrue);
      expect(step.hitTargetIndex, isNull);
    });

    test('supports custom projectile radius', () {
      final narrow = resolvePlayerProjectileStep(
        x: 20, y: 20, velocityX: 0, velocityY: 0,
        arenaWidth: 360, arenaHeight: 640,
        targets: const [CombatCircle(x: 30, y: 20, radius: 3)],
      );
      final wide = resolvePlayerProjectileStep(
        x: 20, y: 20, velocityX: 0, velocityY: 0,
        arenaWidth: 360, arenaHeight: 640,
        targets: const [CombatCircle(x: 30, y: 20, radius: 3)],
        projectileRadius: 8,
      );
      expect(narrow.hitTargetIndex, isNull);
      expect(wide.hitTargetIndex, 0);
    });
  });
}
