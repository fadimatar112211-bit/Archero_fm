import 'dart:math';

/// Pure movement output for one regular enemy AI tick.
class EnemyMovementDecision {
  final double angle;
  final double speedMultiplier;

  const EnemyMovementDecision({required this.angle, required this.speedMultiplier});
}

/// Calculates regular enemy steering without touching game state or rendering.
EnemyMovementDecision decideEnemyMovement({
  required String type,
  required double distanceToPlayer,
  required double baseAngle,
  required double enemyX,
  required int animationTicks,
}) {
  var angle = baseAngle.isFinite ? baseAngle : 0.0;
  final safeDistance = distanceToPlayer.isFinite ? max(0.0, distanceToPlayer) : double.infinity;
  final safeEnemyX = enemyX.isFinite ? enemyX : 0.0;
  var multiplier = 1.0;

  if (type == 'ranged') {
    if (safeDistance < 145) { angle += pi; multiplier = 1.05; }
    else if (safeDistance < 185) { multiplier = 0.08; }
    else { multiplier = 0.72; }
  } else if (type == 'runner') {
    multiplier = animationTicks % 105 < 18 ? 2.35 : 0.78;
  } else if (type == 'stalker') {
    final side = sin(animationTicks * 0.055 + safeEnemyX) >= 0 ? 1.0 : -1.0;
    angle += side * 0.48;
    multiplier = safeDistance < 105 ? 0.72 : 1.12;
  } else if (type == 'tank') { multiplier = 0.82; }

  if (!angle.isFinite) angle = 0.0;
  if (!multiplier.isFinite || multiplier < 0) multiplier = 1.0;
  return EnemyMovementDecision(angle: angle, speedMultiplier: multiplier);
}
