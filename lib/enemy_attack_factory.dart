import 'dart:math';

/// Builds enemy projectiles independently from the game update loop.
class EnemyAttackFactory {
  EnemyAttackFactory._();

  static Map<String, dynamic> rangedProjectile({
    required double enemyX,
    required double enemyY,
    required double targetX,
    required double targetY,
    double speed = 3.8,
    double damage = 6.0,
    int lifetime = 110,
  }) {
    final angle = atan2(targetY - enemyY, targetX - enemyX);
    return {
      'x': enemyX,
      'y': enemyY,
      'vx': cos(angle) * speed,
      'vy': sin(angle) * speed,
      'damage': damage,
      'life': lifetime,
    };
  }
}
