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
/// Invalid circles are ignored so malformed combat data cannot create hits.
int? firstOverlappingTargetIndex({
  required double projectileX,
  required double projectileY,
  required List<CombatCircle> targets,
  double projectileRadius = 5,
}) {
  if (!projectileX.isFinite || !projectileY.isFinite) return null;
  final safeProjectileRadius =
      projectileRadius.isFinite && projectileRadius >= 0
          ? projectileRadius
          : 0.0;

  for (var i = targets.length - 1; i >= 0; i--) {
    final target = targets[i];
    if (!target.x.isFinite ||
        !target.y.isFinite ||
        !target.radius.isFinite ||
        target.radius < 0) {
      continue;
    }
    final combinedRadius = target.radius + safeProjectileRadius;
    if (!combinedRadius.isFinite || combinedRadius <= 0) continue;
    final dx = projectileX - target.x;
    final dy = projectileY - target.y;
    final distanceSquared = dx * dx + dy * dy;
    if (distanceSquared.isFinite &&
        distanceSquared < combinedRadius * combinedRadius) {
      return i;
    }
  }
  return null;
}
