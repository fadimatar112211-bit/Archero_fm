import 'combat_collision.dart';

class PlayerProjectileStep {
  const PlayerProjectileStep({
    required this.x,
    required this.y,
    required this.outOfBounds,
    required this.hitTargetIndex,
  });

  final double x;
  final double y;
  final bool outOfBounds;
  final int? hitTargetIndex;
}

PlayerProjectileStep resolvePlayerProjectileStep({
  required double x,
  required double y,
  required double velocityX,
  required double velocityY,
  required double arenaWidth,
  required double arenaHeight,
  required List<CombatCircle> targets,
  double projectileRadius = 5,
}) {
  final nextX = x + velocityX;
  final nextY = y + velocityY;
  final outOfBounds = nextX < -20 ||
      nextX > arenaWidth + 20 ||
      nextY < -20 ||
      nextY > arenaHeight + 20;
  if (outOfBounds) {
    return PlayerProjectileStep(
      x: nextX,
      y: nextY,
      outOfBounds: true,
      hitTargetIndex: null,
    );
  }
  return PlayerProjectileStep(
    x: nextX,
    y: nextY,
    outOfBounds: false,
    hitTargetIndex: firstOverlappingTargetIndex(
      projectileX: nextX,
      projectileY: nextY,
      targets: targets,
      projectileRadius: projectileRadius,
    ),
  );
}
