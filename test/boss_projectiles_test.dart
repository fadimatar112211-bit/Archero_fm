import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/boss_projectiles.dart';

void main() {
  group('createBossFanVolley', () {
    test('creates the configured three-shot fan toward the player', () {
      final shots = createBossFanVolley(
        originX: 10,
        originY: 20,
        targetX: 110,
        targetY: 20,
        count: 3,
        speed: 4,
        damage: 7,
      );

      expect(shots, hasLength(3));
      expect(shots.first.velocityY, lessThan(0));
      expect(shots[1].velocityX, closeTo(4, 0.000001));
      expect(shots[1].velocityY, closeTo(0, 0.000001));
      expect(shots.last.velocityY, greaterThan(0));
      for (final shot in shots) {
        expect(shot.x, 10);
        expect(shot.y, 20);
        expect(shot.damage, 7);
        expect(shot.lifetimeTicks, 115);
        expect(
          sqrt(shot.velocityX * shot.velocityX +
              shot.velocityY * shot.velocityY),
          closeTo(4, 0.000001),
        );
      }
    });

    test('single projectile aims directly at target', () {
      final shots = createBossFanVolley(
        originX: 0,
        originY: 0,
        targetX: 0,
        targetY: 10,
        count: 1,
        speed: 3,
        damage: 5,
      );

      expect(shots, hasLength(1));
      expect(shots.single.velocityX, closeTo(0, 0.000001));
      expect(shots.single.velocityY, closeTo(3, 0.000001));
    });

    test('supports custom spread and lifetime', () {
      final shots = createBossFanVolley(
        originX: 0,
        originY: 0,
        targetX: 1,
        targetY: 0,
        count: 2,
        speed: 2,
        damage: 4,
        spreadRadians: 1,
        lifetimeTicks: 40,
      );

      expect(shots.first.velocityY, lessThan(0));
      expect(shots.last.velocityY, greaterThan(0));
      expect(shots.first.lifetimeTicks, 40);
    });

    test('returns no projectiles for invalid input', () {
      expect(createBossFanVolley(
        originX: double.nan,
        originY: 0,
        targetX: 1,
        targetY: 1,
        count: 3,
        speed: 2,
        damage: 4,
      ), isEmpty);
      expect(createBossFanVolley(
        originX: 0,
        originY: 0,
        targetX: 1,
        targetY: 1,
        count: 0,
        speed: 2,
        damage: 4,
      ), isEmpty);
    });
  });
}
