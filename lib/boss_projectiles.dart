import 'dart:math';

import 'enemy_projectile_motion.dart';

/// Immutable data for one projectile in a boss fan volley.
class BossProjectileSpec {
  final double x;
  final double y;
  final double velocityX;
  final double velocityY;
  final double damage;
  final int lifetimeTicks;

  const BossProjectileSpec({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.damage,
    required this.lifetimeTicks,
  });
}

/// Builds the same evenly-spaced fan used by the boss phases.
///
/// The default spread matches the existing in-game volley (0.78 radians).
List<BossProjectileSpec> createBossFanVolley({
  required double originX,
  required double originY,
  required double targetX,
  required double targetY,
  required int count,
  required double speed,
  required double damage,
  int lifetimeTicks = 115,
  double spreadRadians = 0.78,
}) {
  if (count <= 0 ||
      !originX.isFinite ||
      !originY.isFinite ||
      !targetX.isFinite ||
      !targetY.isFinite ||
      !speed.isFinite ||
      !damage.isFinite ||
      !spreadRadians.isFinite) {
    return const [];
  }

  final safeSpeed = speed.clamp(0.0, 1000.0).toDouble();
  final safeDamage = damage.clamp(0.0, 1000000.0).toDouble();
  final safeLife = lifetimeTicks.clamp(1, 100000).toInt();
  final baseAngle = atan2(targetY - originY, targetX - originX);

  return List<BossProjectileSpec>.generate(count, (index) {
    final offset = count == 1
        ? 0.0
        : (index / (count - 1) - 0.5) * spreadRadians;
    final angle = baseAngle + offset;
    return BossProjectileSpec(
      x: originX,
      y: originY,
      velocityX: cos(angle) * safeSpeed,
      velocityY: sin(angle) * safeSpeed,
      damage: safeDamage,
      lifetimeTicks: safeLife,
    );
  }, growable: false);
}

/// Advances one boss-owned projectile using the shared collision geometry.
ProjectileStep advanceBossProjectile({
  required double x,
  required double y,
  required double velocityX,
  required double velocityY,
  required int life,
  required double targetX,
  required double targetY,
  required double arenaWidth,
  required double arenaHeight,
}) {
  return advanceEnemyProjectile(
    x: x,
    y: y,
    velocityX: velocityX,
    velocityY: velocityY,
    life: life,
    targetX: targetX,
    targetY: targetY,
    arenaWidth: arenaWidth,
    arenaHeight: arenaHeight,
  );
}
