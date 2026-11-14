import 'dart:ui' show Offset;

import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/player_movement.dart';

void main() {
  test('movement applies the drag delta while inside the arena', () {
    final result = PlayerMovement.applyDelta(
      position: const Offset(100, 200),
      delta: const Offset(12, -8),
      minX: 22,
      maxX: 338,
      minY: 105,
      maxY: 605,
    );

    expect(result, const Offset(112, 192));
  });

  test('movement clamps the player to all arena edges', () {
    final result = PlayerMovement.applyDelta(
      position: const Offset(30, 120),
      delta: const Offset(-100, 900),
      minX: 22,
      maxX: 338,
      minY: 105,
      maxY: 605,
    );

    expect(result, const Offset(22, 605));
  });

  test('narrow layouts never produce an invalid clamp range', () {
    final result = PlayerMovement.applyDelta(
      position: const Offset(20, 20),
      delta: Offset.zero,
      minX: 22,
      maxX: 10,
      minY: 105,
      maxY: 80,
    );

    expect(result, const Offset(22, 105));
  });
}
