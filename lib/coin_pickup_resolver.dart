import 'dart:math';

/// Pure proximity check for collecting dropped coins.
class CoinPickupResolver {
  CoinPickupResolver._();

  static bool isCollected({
    required double playerX,
    required double playerY,
    required double coinX,
    required double coinY,
    double pickupRadius = 34,
  }) {
    final dx = playerX - coinX;
    final dy = playerY - coinY;
    return sqrt(dx * dx + dy * dy) < pickupRadius;
  }
}
