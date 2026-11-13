import 'dart:math';

/// A small immutable point used by combat targeting calculations.
class CombatPoint {
  final double x;
  final double y;

  const CombatPoint(this.x, this.y);
}

/// Returns the index of the closest target, preserving the first target on ties.
///
/// Invalid coordinates are ignored. Returns null when no usable target exists.
int? nearestTargetIndex({
  required CombatPoint origin,
  required List<CombatPoint> targets,
}) {
  if (!origin.x.isFinite || !origin.y.isFinite) return null;

  var bestIndex;
  var bestDistance = double.infinity;
  for (var i = 0; i < targets.length; i++) {
    final target = targets[i];
    if (!target.x.isFinite || !target.y.isFinite) continue;
    final dx = target.x - origin.x;
    final dy = target.y - origin.y;
    final distance = dx * dx + dy * dy;
    if (distance < bestDistance) {
      bestDistance = distance;
      bestIndex = i;
    }
  }
  return bestIndex as int?;
}

/// Calculates a projectile velocity aimed at [target] from [origin].
CombatPoint aimedProjectileVelocity({
  required CombatPoint origin,
  required CombatPoint target,
  required double speed,
  double angleOffset = 0,
}) {
  if (!origin.x.isFinite ||
      !origin.y.isFinite ||
      !target.x.isFinite ||
      !target.y.isFinite ||
      !speed.isFinite ||
      speed <= 0 ||
      !angleOffset.isFinite) {
    return const CombatPoint(0, 0);
  }

  final angle = atan2(target.y - origin.y, target.x - origin.x) +
      angleOffset;
  return CombatPoint(cos(angle) * speed, sin(angle) * speed);
}
