/// Pure combat rules for enemy attacks.
///
/// This module owns attack tuning values so they can be reviewed and tested
/// without constructing Flutter widgets or advancing the game loop.
class EnemyAttackRules {
  const EnemyAttackRules._();

  static double contactDamage({required String enemyType}) {
    return switch (enemyType) {
      'tank' => 8.0,
      'stalker' => 6.0,
      'runner' => 4.0,
      _ => 5.0,
    };
  }

  static const int attackDurationTicks = 16;
  static const int attackCooldownTicks = 76;
  static const int attackImpactFrame = 8;

  static double attackRange({required double enemyRadius}) =>
      23 + enemyRadius + 24;

  static double impactRange({required double enemyRadius}) =>
      23 + enemyRadius + 14;
}


enum EnemyContactHitStatus {
  notReady,
  dodged,
  invulnerable,
  damaged,
}

class EnemyContactHitResolution {
  const EnemyContactHitResolution({
    required this.status,
    required this.damageApplied,
    this.resolvedAt,
  });

  final EnemyContactHitStatus status;
  final double damageApplied;
  final DateTime? resolvedAt;
}

/// Resolves the impact frame of a contact attack independently of the game UI.
///
/// Invulnerability leaves the attack unresolved so the existing game loop can
/// retry the impact on the next tick. A dodge or successful hit consumes it.
EnemyContactHitResolution resolveEnemyContactHit({
  required String enemyType,
  required int attackTicks,
  required int impactFrame,
  required bool hitAlreadyResolved,
  required double distanceToPlayer,
  required double impactRange,
  required bool playerIsDodging,
  required DateTime? lastDamageAt,
  DateTime? now,
  required double damage,
  int invulnerabilityMs = 220,
}) {
  if (enemyType == 'ranged' ||
      attackTicks != impactFrame ||
      hitAlreadyResolved ||
      !distanceToPlayer.isFinite ||
      distanceToPlayer < 0 ||
      !impactRange.isFinite ||
      impactRange < 0 ||
      distanceToPlayer > impactRange) {
    return const EnemyContactHitResolution(
      status: EnemyContactHitStatus.notReady,
      damageApplied: 0,
    );
  }

  if (playerIsDodging) {
    return const EnemyContactHitResolution(
      status: EnemyContactHitStatus.dodged,
      damageApplied: 0,
    );
  }

  // Resolve wall-clock time only for a genuine impact, not once per enemy
  // on every simulation tick. The timestamp is returned for atomic state use.
  final resolvedAt = now ?? DateTime.now();
  final canTakeDamage = lastDamageAt == null ||
      resolvedAt.difference(lastDamageAt).inMilliseconds >= invulnerabilityMs;
  if (!canTakeDamage) {
    return const EnemyContactHitResolution(
      status: EnemyContactHitStatus.invulnerable,
      damageApplied: 0,
    );
  }

  final safeDamage = damage.isFinite && damage > 0 ? damage : 0.0;
  return EnemyContactHitResolution(
    status: EnemyContactHitStatus.damaged,
    damageApplied: safeDamage,
    resolvedAt: resolvedAt,
  );
}
