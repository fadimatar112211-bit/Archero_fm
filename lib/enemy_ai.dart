import 'dart:math';

/// Pure movement output for one enemy AI tick.
class EnemyMovementDecision {
  final double angle;
  final double speedMultiplier;

  const EnemyMovementDecision({
    required this.angle,
    required this.speedMultiplier,
  });
}

/// Calculates enemy steering without touching game state or rendering.
///
/// The caller remains responsible for movement-related visual telegraphs.
EnemyMovementDecision decideEnemyMovement({
  required String type,
  required double distanceToPlayer,
  required double baseAngle,
  required double enemyX,
  required int animationTicks,
  required bool bossEnraged,
  required double bossPhaseMovementMultiplier,
}) {
  var angle = baseAngle;
  var multiplier = 1.0;

  if (type == 'ranged') {
    if (distanceToPlayer < 145) {
      angle += pi;
      multiplier = 1.05;
    } else if (distanceToPlayer < 185) {
      multiplier = 0.08;
    } else {
      multiplier = 0.72;
    }
  } else if (type == 'runner') {
    multiplier = animationTicks % 105 < 18 ? 2.35 : 0.78;
  } else if (type == 'stalker') {
    final side = sin(animationTicks * 0.055 + enemyX) >= 0 ? 1.0 : -1.0;
    angle += side * 0.48;
    multiplier = distanceToPlayer < 105 ? 0.72 : 1.12;
  } else if (type == 'boss') {
    multiplier = animationTicks % 180 < 28
        ? (bossEnraged ? 3.15 : 2.65) * bossPhaseMovementMultiplier
        : 0.72;
  } else if (type == 'tank') {
    multiplier = 0.82;
  }

  return EnemyMovementDecision(angle: angle, speedMultiplier: multiplier);
}
