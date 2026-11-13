import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/player_projectiles.dart';

void main() {
  group('advancePlayerProjectile', () {
    test('advances arrow by its velocity without removing it', () {
      final step = advancePlayerProjectile(
        x: 100,
        y: 200,
        velocityX: 4.5,
        velocityY: -3,
        arenaWidth: 360,
        arenaHeight: 640,
      );

      expect(step.x, 104.5);
      expect(step.y, 197);
      expect(step.shouldRemove, isFalse);
    });

    test('keeps arrows inside the existing 20 pixel margin', () {
      final step = advancePlayerProjectile(
        x: 1,
        y: 1,
        velocityX: -20,
        velocityY: 0,
        arenaWidth: 360,
        arenaHeight: 640,
      );

      expect(step.x, -19);
      expect(step.shouldRemove, isFalse);
    });

    test('removes arrows beyond every arena edge', () {
      final cases = [
        (x: -21.0, y: 100.0, vx: 0.0, vy: 0.0),
        (x: 381.0, y: 100.0, vx: 0.0, vy: 0.0),
        (x: 100.0, y: -21.0, vx: 0.0, vy: 0.0),
        (x: 100.0, y: 661.0, vx: 0.0, vy: 0.0),
      ];

      for (final value in cases) {
        final step = advancePlayerProjectile(
          x: value.x,
          y: value.y,
          velocityX: value.vx,
          velocityY: value.vy,
          arenaWidth: 360,
          arenaHeight: 640,
        );
        expect(step.shouldRemove, isTrue);
      }
    });

    test('removes projectiles with non-finite next positions', () {
      final step = advancePlayerProjectile(
        x: 100,
        y: 100,
        velocityX: double.infinity,
        velocityY: 0,
        arenaWidth: 360,
        arenaHeight: 640,
      );
      expect(step.shouldRemove, isTrue);
    });
  });
}
