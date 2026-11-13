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

  final damage = projectileDamage.isFinite ? projectileDamage : fallbackDamage;
  return ProjectileHitResolution(
    status: ProjectileHitStatus.damaged,
    updatedPlayerHp: playerHp - damage,
    damageApplied: damage,
  );
}

enum ContactHitStatus {
  outsideRange,
  dodged,
  damaged,
  invulnerable,
}

class ContactHitResolution {
  const ContactHitResolution({
    required this.status,
    required this.updatedPlayerHp,
    required this.damageApplied,
  });

  final ContactHitStatus status;
  final double updatedPlayerHp;
  final double damageApplied;
}

/// Resolves melee/contact damage while keeping timing and effects in the game
/// loop. Damage values preserve the existing enemy balance.
ContactHitResolution resolveEnemyContactHit({
  required double playerHp,
  required String enemyType,
  required bool bossEnraged,
  required bool isDodging,
  required bool canTakeDamage,
}) {
  if (isDodging) {
    return ContactHitResolution(
      status: ContactHitStatus.dodged,
      updatedPlayerHp: playerHp,
      damageApplied: 0,
    );
  }
  if (!canTakeDamage) {
    return ContactHitResolution(
      status: ContactHitStatus.invulnerable,
      updatedPlayerHp: playerHp,
      damageApplied: 0,
    );
  }

  final damage = switch (enemyType) {
    'boss' => bossEnraged ? 12.0 : 10.0,
    'tank' => 8.0,
    'stalker' => 6.0,
    'runner' => 4.0,
    _ => 5.0,
  };
  return ContactHitResolution(
    status: ContactHitStatus.damaged,
    updatedPlayerHp: playerHp - damage,
    damageApplied: damage,
  );
}

class BossAreaHitResolution {
  const BossAreaHitResolution({
    required this.status,
    required this.updatedPlayerHp,
    required this.damageApplied,
  });

  final ContactHitStatus status;
  final double updatedPlayerHp;
  final double damageApplied;
}

/// Resolves the boss radial blast after the caller confirms its impact frame.
/// Blast range boundaries are inclusive, matching the current encounter.
BossAreaHitResolution resolveBossAreaHit({
  required double playerHp,
  required double distanceToPlayer,
  required bool isDodging,
  required bool bossEnraged,
}) {
  final radius = bossEnraged ? 132.0 : 112.0;
  if (distanceToPlayer > radius) {
    return BossAreaHitResolution(
      status: ContactHitStatus.outsideRange,
      updatedPlayerHp: playerHp,
      damageApplied: 0,
    );
  }
  if (isDodging) {
    return BossAreaHitResolution(
      status: ContactHitStatus.dodged,
      updatedPlayerHp: playerHp,
      damageApplied: 0,
    );
  }
  final damage = bossEnraged ? 20.0 : 15.0;
  return BossAreaHitResolution(
    status: ContactHitStatus.damaged,
    updatedPlayerHp: playerHp - damage,
    damageApplied: damage,
  );
}
