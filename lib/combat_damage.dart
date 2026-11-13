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
