import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/combat_targeting.dart';

void main() {
  group('nearestTargetIndex', () {
    test('selects the closest target independent of list ordering', () {
      expect(
        nearestTargetIndex(
          origin: const CombatPoint(0, 0),
          targets: const [
            CombatPoint(8, 0),
            CombatPoint(2, 0),
            CombatPoint(4, 0),
          ],
        ),
        1,
      );
    });

    test('keeps the first target when distances are equal', () {
      expect(
        nearestTargetIndex(
          origin: const CombatPoint(0, 0),
          targets: const [
            CombatPoint(-3, 0),
            CombatPoint(3, 0),
          ],
        ),
        0,
      );
    });

    test('returns null for empty or invalid target collections', () {
      expect(
        nearestTargetIndex(
          origin: const CombatPoint(0, 0),
          targets: const [],
        ),
        isNull,
      );
      expect(
        nearestTargetIndex(
          origin: const CombatPoint(0, 0),
          targets: [CombatPoint(double.nan, 1)],
        ),
        isNull,
      );
    });
  });

  group('aimedProjectileVelocity', () {
    test('aims at the target with the requested projectile speed', () {
      final velocity = aimedProjectileVelocity(
        origin: const CombatPoint(1, 1),
        target: const CombatPoint(4, 5),
        speed: 10,
      );

      expect(velocity.x, closeTo(6, 0.000001));
      expect(velocity.y, closeTo(8, 0.000001));
    });

    test('applies a spread angle to the projectile direction', () {
      final velocity = aimedProjectileVelocity(
        origin: const CombatPoint(0, 0),
        target: const CombatPoint(10, 0),
        speed: 5,
        angleOffset: pi / 2,
      );

      expect(velocity.x, closeTo(0, 0.000001));
      expect(velocity.y, closeTo(5, 0.000001));
    });

    test('returns a safe zero velocity for invalid input', () {
      expect(
        aimedProjectileVelocity(
          origin: const CombatPoint(0, 0),
          target: const CombatPoint(1, 1),
          speed: double.nan,
        ),
        const CombatPoint(0, 0),
      );
    });
  });
}
