import 'dart:math';

class CombatCircle {
  final double x;
  final double y;
  final double radius;

  const CombatCircle({
    required this.x,
    required this.y,
    required this.radius,
  });
}

/// Returns the first colliding target using the game's established
/// reverse-list priority (last target in the list wins overlapping hits).
int? firstOverlappingTargetIndex({
  required double projectileX,
  required double projectileY,
  required List<CombatCircle> targets,
  double projectileRadius = 5,
}) {
  for (var i = targets.length - 1; i >= 0; i--) {
    final target = targets[i];
    final dx = projectileX - target.x;
    final dy = projectileY - target.y;
    if (sqrt(dx * dx + dy * dy) < target.radius + projectileRadius) {
      return i;
    }
  }
  return null;
}
