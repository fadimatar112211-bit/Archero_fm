/// Pure movement decision for a boss actor, independent from regular enemy AI.
class BossMovementDecision {
  const BossMovementDecision({required this.angle, required this.speedMultiplier});
  final double angle;
  final double speedMultiplier;
}

BossMovementDecision decideBossMovement({
  required double baseAngle,
  required int animationTicks,
  required bool enraged,
  required double phaseMovementMultiplier,
}) {
  final angle = baseAngle.isFinite ? baseAngle : 0.0;
  final phaseMultiplier = phaseMovementMultiplier.isFinite && phaseMovementMultiplier >= 0
      ? phaseMovementMultiplier : 1.0;
  final multiplier = animationTicks % 180 < 28
      ? (enraged ? 3.15 : 2.65) * phaseMultiplier : 0.72;
  return BossMovementDecision(
    angle: angle,
    speedMultiplier: multiplier.isFinite && multiplier >= 0 ? multiplier : 1.0,
  );
}
