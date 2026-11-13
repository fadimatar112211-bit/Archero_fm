import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/combat_targeting.dart';
import 'package:archero_fm/player_attack.dart';

void main() {
  group('createPlayerArrowVolley', () {
    test('creates one aimed arrow with the existing projectile speed', () {
      final volley = createPlayerArrowVolley(
        origin: const CombatPoint(100, 200),
        target: const CombatPoint(100, 100),
        extraArrows: 0,
      );

      expect(volley, hasLength(1));
      expect(volley.single.origin, const CombatPoint(100, 200));
      expect(volley.single.velocity.x, closeTo(0, 0.000001));
      expect(volley.single.velocity.y, closeTo(-8.5, 0.000001));
    });

    test('creates the configured count and alternating spread angles', () {
      final volley = createPlayerArrowVolley(
        origin: const CombatPoint(0, 0),
        target: const CombatPoint(100, 0),
        extraArrows: 3,
      );

      expect(volley, hasLength(4));
      final angles = volley
          .map((arrow) => math.atan2(
                arrow.velocity.dy,
                arrow.velocity.dx,
              ))
          .toList();
      expect(angles[0], closeTo(0, 0.000001));
      expect(angles[1], closeTo(0.20, 0.000001));
      expect(angles[2], closeTo(-0.20, 0.000001));
      expect(angles[3], closeTo(0.20, 0.000001));
    });

    test('supports custom speed and spread angle', () {
      final volley = createPlayerArrowVolley(
        origin: const CombatPoint(0, 0),
        target: const CombatPoint(0, 1),
        extraArrows: 1,
        projectileSpeed: 12,
        spreadAngle: 0.3,
      );

      expect(volley, hasLength(2));
      expect(volley[0].velocity.dy, closeTo(12, 0.000001));
      expect(volley[1].velocity.dx, closeTo(-12 * math.sin(0.3), 0.000001));
    });

    test('returns an empty volley for a non-positive shot count', () {
      final volley = createPlayerArrowVolley(
        origin: const CombatPoint(0, 0),
        target: const CombatPoint(10, 0),
        extraArrows: -1,
      );
      expect(volley, isEmpty);
    });
  });
}
