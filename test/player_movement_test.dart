import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/player_movement.dart';

void main() {
  group('resolvePlayerDrag', () {
    test('applies drag deltas and starts the existing dodge window', () {
      final result = resolvePlayerDrag(
        currentX: 180,
        currentY: 430,
        deltaX: 12,
        deltaY: -7,
        arenaWidth: 360,
        arenaHeight: 640,
        currentMoveTicks: 2,
      );

      expect(result.x, 192);
      expect(result.y, 423);
      expect(result.moveTicks, 8);
    });

    test('clamps the player inside the horizontal and vertical arena bounds', () {
      final result = resolvePlayerDrag(
        currentX: 30,
        currentY: 120,
        deltaX: -100,
        deltaY: 900,
        arenaWidth: 360,
        arenaHeight: 640,
        currentMoveTicks: 0,
      );

      expect(result.x, 22);
      expect(result.y, 605);
      expect(result.moveTicks, 8);
    });

    test('keeps the existing dodge window for sub-threshold movement', () {
      final result = resolvePlayerDrag(
        currentX: 180,
        currentY: 430,
        deltaX: 0.2,
        deltaY: 0.2,
        arenaWidth: 360,
        arenaHeight: 640,
        currentMoveTicks: 3,
      );

      expect(result.x, closeTo(180.2, 0.000001));
      expect(result.y, closeTo(430.2, 0.000001));
      expect(result.moveTicks, 3);
    });

    test('handles undersized arenas without inverted clamp ranges', () {
      final result = resolvePlayerDrag(
        currentX: 0,
        currentY: 0,
        deltaX: 0,
        deltaY: 0,
        arenaWidth: 20,
        arenaHeight: 80,
        currentMoveTicks: 0,
      );

      expect(result.x, 22);
      expect(result.y, 105);
    });

    test('normalizes non-finite gesture and position values', () {
      final result = resolvePlayerDrag(
        currentX: double.nan,
        currentY: double.infinity,
        deltaX: double.nan,
        deltaY: double.infinity,
        arenaWidth: 360,
        arenaHeight: 640,
        currentMoveTicks: 4,
      );

      expect(result.x, 22);
      expect(result.y, 105);
      expect(result.moveTicks, 4);
    });
  });
}
