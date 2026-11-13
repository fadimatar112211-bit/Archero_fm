class PlayerMovementResolution {
  const PlayerMovementResolution({
    required this.x,
    required this.y,
    required this.moveTicks,
  });

  final double x;
  final double y;
  final int moveTicks;
}

/// Resolves a drag gesture into a bounded player position and dodge window.
///
/// The threshold and bounds preserve the existing touch-control behavior while
/// keeping movement calculations independent from Flutter widgets.
PlayerMovementResolution resolvePlayerDrag({
  required double currentX,
  required double currentY,
  required double deltaX,
  required double deltaY,
  required double arenaWidth,
  required double arenaHeight,
  required int currentMoveTicks,
  double movementThresholdSquared = 0.25,
  int dodgeTicks = 8,
}) {
  final safeX = currentX.isFinite ? currentX : 22.0;
  final safeY = currentY.isFinite ? currentY : 105.0;
  final safeDeltaX = deltaX.isFinite ? deltaX : 0.0;
  final safeDeltaY = deltaY.isFinite ? deltaY : 0.0;
  final safeWidth = arenaWidth.isFinite && arenaWidth > 0 ? arenaWidth : 44.0;
  final safeHeight = arenaHeight.isFinite && arenaHeight > 0 ? arenaHeight : 140.0;
  final maxX = safeWidth - 22.0 < 22.0 ? 22.0 : safeWidth - 22.0;
  final maxY = safeHeight - 35.0 < 105.0 ? 105.0 : safeHeight - 35.0;
  final safeMovementThreshold = movementThresholdSquared.isFinite &&
          movementThresholdSquared >= 0
      ? movementThresholdSquared
      : 0.25;
  final safeDodgeTicks = dodgeTicks < 0 ? 0 : dodgeTicks;
  final safeCurrentMoveTicks = currentMoveTicks < 0 ? 0 : currentMoveTicks;
  final distanceSquared =
      safeDeltaX * safeDeltaX + safeDeltaY * safeDeltaY;
  final moved = !distanceSquared.isFinite ||
      distanceSquared > safeMovementThreshold;

  return PlayerMovementResolution(
    x: (safeX + safeDeltaX).clamp(22.0, maxX).toDouble(),
    y: (safeY + safeDeltaY).clamp(105.0, maxY).toDouble(),
    moveTicks: moved ? safeDodgeTicks : safeCurrentMoveTicks,
  );
}
