enum ProjectileHitStatus {
  dodged,
  damaged,
  invulnerable,
}

class ProjectileHitResolution {
  final ProjectileHitStatus status;
  final double updatedPlayerHp;
  final double damageApplied;

  const ProjectileHitResolution({
    required this.status,
    required this.updatedPlayerHp,
    required this.damageApplied,
  });
}

/// Resolves a projectile collision without depending on Flutter or game state.
ProjectileHitResolution resolveProjectileHit({
  required double playerHp,
  required double projectileDamage,
  required bool isDodging,
  required bool canTakeDamage,
  double fallbackDamage = 6.0,
}) {
  if (isDodging) {
    return ProjectileHitResolution(
      status: ProjectileHitStatus.dodged,
      updatedPlayerHp: playerHp,
      damageApplied: 0,
    );
  }

  if (!canTakeDamage) {
    return ProjectileHitResolution(
      status: ProjectileHitStatus.invulnerable,
      updatedPlayerHp: playerHp,
      damageApplied: 0,
    );
  }

  final safeFallback = fallbackDamage.isFinite && fallbackDamage > 0
      ? fallbackDamage
      : 0.0;
  final damage = projectileDamage.isFinite && projectileDamage > 0
      ? projectileDamage
      : safeFallback;
  return ProjectileHitResolution(
    status: ProjectileHitStatus.damaged,
    updatedPlayerHp: playerHp - damage,
    damageApplied: damage,
  );
}

enum AreaAttackHitStatus { outOfRange, dodged, invulnerable, damaged }

class AreaAttackHitResolution {
  const AreaAttackHitResolution({
    required this.status,
    required this.updatedPlayerHp,
    required this.damageApplied,
    this.resolvedAt,
  });

  final AreaAttackHitStatus status;
  final double updatedPlayerHp;
  final double damageApplied;
  final DateTime? resolvedAt;
}

/// Resolves a timed area hit using the same 260ms protection window as
/// enemy projectiles. The clock is sampled only for an in-range, non-dodged hit.
AreaAttackHitResolution resolveAreaAttackHit({
  required double playerHp,
  required double distanceToPlayer,
  required double attackRadius,
  required double damage,
  required bool isDodging,
  required DateTime? lastDamageAt,
  DateTime? now,
  int invulnerabilityMs = 260,
}) {
  final safeHp = playerHp.isFinite ? playerHp : 0.0;
  if (!distanceToPlayer.isFinite ||
      distanceToPlayer < 0 ||
      !attackRadius.isFinite ||
      attackRadius < 0 ||
      distanceToPlayer > attackRadius) {
    return AreaAttackHitResolution(
      status: AreaAttackHitStatus.outOfRange,
      updatedPlayerHp: safeHp,
      damageApplied: 0,
    );
  }
  if (isDodging) {
    return AreaAttackHitResolution(
      status: AreaAttackHitStatus.dodged,
      updatedPlayerHp: safeHp,
      damageApplied: 0,
    );
  }

  final resolvedAt = now ?? DateTime.now();
  final canTakeDamage = lastDamageAt == null ||
      resolvedAt.difference(lastDamageAt).inMilliseconds >= invulnerabilityMs;
  if (!canTakeDamage) {
    return AreaAttackHitResolution(
      status: AreaAttackHitStatus.invulnerable,
      updatedPlayerHp: safeHp,
      damageApplied: 0,
    );
  }

  final safeDamage = damage.isFinite && damage > 0 ? damage : 0.0;
  return AreaAttackHitResolution(
    status: AreaAttackHitStatus.damaged,
    updatedPlayerHp: safeHp - safeDamage,
    damageApplied: safeDamage,
    resolvedAt: resolvedAt,
  );
}
