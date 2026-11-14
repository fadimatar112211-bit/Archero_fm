import 'dart:math';

/// Builds a volley aimed at the nearest living target, without UI dependencies.
class ArrowVolleyFactory {
  ArrowVolleyFactory._();

  static List<Map<String, dynamic>> create({
    required List<Map<String, dynamic>> enemies,
    required double playerX,
    required double playerY,
    int extraArrows = 0,
  }) {
    if (enemies.isEmpty) return const [];

    final target = enemies.reduce((a, b) {
      final ax = (a['x'] as num).toDouble() - playerX;
      final ay = (a['y'] as num).toDouble() - playerY;
      final bx = (b['x'] as num).toDouble() - playerX;
      final by = (b['y'] as num).toDouble() - playerY;
      return ax * ax + ay * ay <= bx * bx + by * by ? a : b;
    });
    final angle = atan2(
      (target['y'] as num).toDouble() - playerY,
      (target['x'] as num).toDouble() - playerX,
    );

    final totalShots = 1 + (extraArrows < 0 ? 0 : extraArrows);
    return List<Map<String, dynamic>>.generate(totalShots, (index) {
      final spread = index == 0 ? 0.0 : (index.isOdd ? 0.20 : -0.20);
      return {
        'x': playerX,
        'y': playerY,
        'vx': cos(angle + spread) * 8.5,
        'vy': sin(angle + spread) * 8.5,
      };
    }, growable: false);
  }
}
