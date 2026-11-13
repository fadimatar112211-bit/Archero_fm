import 'combat_collision.dart';

class PlayerProjectileStep {
  const PlayerProjectileStep({
    required this.x,
    required this.y,
    required this.shouldRemove,
    required this.hitTargetIndex,
  });

  final double x;
  final double y;
  final bool shouldRemove;
  final int? hitTargetIndex;
}

/// Advances a player arrow by one game tick and reports arena-bound expiry.
PlayerProjectileStep advancePlayerProjectile({
  required double x,
  required double y,
  required double velocityX,
  required double velocityY,
  required double arenaWidth,
  required double arenaHeight,
  double margin = 20,
  List<CombatCircle> targets = const [],
  double projectileRadius = 5,
}) {
  final nextX = x + velocityX;
  final nextY = y + velocityY;
  final safeWidth = arenaWidth.isFinite && arenaWidth > 0 ? arenaWidth : 0.0;
  final safeHeight = arenaHeight.isFinite && arenaHeight > 0 ? arenaHeight : 0.0;
  final safeMargin = margin.isFinite && margin >= 0 ? margin : 20.0;
  final shouldRemove = !nextX.isFinite ||
      !nextY.isFinite ||
      nextX < -safeMargin ||
      nextX > safeWidth + safeMargin ||
      nextY < -safeMargin ||
      nextY > safeHeight + safeMargin;

  return PlayerProjectileStep(
    x: nextX,
    y: nextY,
    shouldRemove: shouldRemove,
  );
}
