import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/combat_collision.dart';

void main() {
  group('firstOverlappingTargetIndex', () {
    test('returns null when there are no targets or no collision', () {
      expect(firstOverlappingTargetIndex(
        projectileX: 0, projectileY: 0, targets: const [],
      ), isNull);
      expect(firstOverlappingTargetIndex(
        projectileX: 0, projectileY: 0,
        targets: const [CombatCircle(x: 50, y: 50, radius: 10)],
      ), isNull);
    });

    test('detects overlap using target and projectile radii', () {
      expect(firstOverlappingTargetIndex(
        projectileX: 14, projectileY: 0,
        targets: const [CombatCircle(x: 0, y: 0, radius: 10)],
      ), 0);
    });

    test('preserves reverse iteration priority for overlapping targets', () {
      expect(firstOverlappingTargetIndex(
        projectileX: 0, projectileY: 0,
        targets: const [
          CombatCircle(x: 0, y: 0, radius: 10),
          CombatCircle(x: 1, y: 0, radius: 10),
        ],
      ), 1);
    });

    test('ignores invalid projectile coordinates and malformed targets', () {
      const targets = [
        CombatCircle(x: double.nan, y: 0, radius: 10),
        CombatCircle(x: 0, y: 0, radius: double.infinity),
        CombatCircle(x: 0, y: 0, radius: -5),
      ];
      expect(firstOverlappingTargetIndex(
        projectileX: 0, projectileY: 0, targets: targets,
      ), isNull);
      expect(firstOverlappingTargetIndex(
        projectileX: double.infinity, projectileY: 0,
        targets: const [CombatCircle(x: 0, y: 0, radius: 10)],
      ), isNull);
    });

    test('normalizes an invalid projectile radius without false collisions', () {
      expect(firstOverlappingTargetIndex(
        projectileX: 12, projectileY: 0,
        targets: const [CombatCircle(x: 0, y: 0, radius: 10)],
        projectileRadius: double.nan,
      ), isNull);
    });

    test('supports a custom projectile radius', () {
      expect(firstOverlappingTargetIndex(
        projectileX: 14, projectileY: 0,
        targets: const [CombatCircle(x: 0, y: 0, radius: 10)],
        projectileRadius: 2,
      ), isNull);
    });
  });
}
