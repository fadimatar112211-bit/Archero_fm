import 'dart:math';

class ProjectileStep {
  final double x;
  final double y;
  final int life;
  final bool hitTarget;
  final bool outOfBounds;

  const ProjectileStep({
    required this.x,
    required this.y,
    required this.life,
    required this.hitTarget,
    required this.outOfBounds,
  });

  bool get shouldRemove => hitTarget || life <= 0 || outOfBounds;
}

/// Advances a projectile by one simulation tick and reports collision/expiry.
ProjectileStep advanceEnemyProjectile({
  required double x,
  required double y,
  required double velocityX,
  required double velocityY,
  required int life,
  required double targetX,
  required double targetY,
  required double arenaWidth,
  required double arenaHeight,
  double hitRadius = 19,
  double boundsPadding = 20,
}) {
  final nextX = x + velocityX;
  final nextY = y + velocityY;
  final nextLife = life - 1;
  final dx = nextX - targetX;
  final dy = nextY - targetY;
  final hit = sqrt(dx * dx + dy * dy) < hitRadius;
  final outside = nextX < -boundsPadding ||
      nextX > arenaWidth + boundsPadding ||
      nextY < -boundsPadding ||
      nextY > arenaHeight + boundsPadding;

  return ProjectileStep(
    x: nextX,
    y: nextY,
    life: nextLife,
    hitTarget: hit,
    outOfBounds: outside,
  );
}
