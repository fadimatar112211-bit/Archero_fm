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
/// Invalid motion or arena data expires the projectile instead of allowing a
/// NaN/infinite position to poison subsequent collision calculations.
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
  final validMotion = x.isFinite &&
      y.isFinite &&
      velocityX.isFinite &&
      velocityY.isFinite &&
      nextX.isFinite &&
      nextY.isFinite;
  final validTarget = targetX.isFinite && targetY.isFinite;
  final validArena = arenaWidth.isFinite &&
      arenaHeight.isFinite &&
      arenaWidth >= 0 &&
      arenaHeight >= 0;
  final safePadding =
      boundsPadding.isFinite && boundsPadding >= 0 ? boundsPadding : 20.0;
  final safeHitRadius = hitRadius.isFinite && hitRadius >= 0 ? hitRadius : 0.0;
  final invalid = !validMotion || !validTarget || !validArena;

  final dx = validMotion && validTarget ? nextX - targetX : double.infinity;
  final dy = validMotion && validTarget ? nextY - targetY : double.infinity;
  final distanceSquared = dx * dx + dy * dy;
  final hit = !invalid &&
      distanceSquared.isFinite &&
      distanceSquared < safeHitRadius * safeHitRadius;
  final outside = invalid ||
      nextX < -safePadding ||
      nextX > arenaWidth + safePadding ||
      nextY < -safePadding ||
      nextY > arenaHeight + safePadding;

  return ProjectileStep(
    x: nextX,
    y: nextY,
    life: nextLife,
    hitTarget: hit,
    outOfBounds: outside,
  );
}
