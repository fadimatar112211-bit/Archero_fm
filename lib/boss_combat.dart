class BossPhaseConfig {
  final int phase;
  final double movementMultiplier;
  final int volleyCount;
  final int volleyCooldownTicks;
  final double projectileSpeed;
  final double projectileDamage;

  const BossPhaseConfig({
    required this.phase,
    required this.movementMultiplier,
    required this.volleyCount,
    required this.volleyCooldownTicks,
    required this.projectileSpeed,
    required this.projectileDamage,
  });
}

class BossCombat {
  const BossCombat._();

  static int phaseForHealth({
    required double hp,
    required double maxHp,
  }) {
    if (maxHp <= 0) return 3;
    final ratio = (hp / maxHp).clamp(0.0, 1.0);
    if (ratio <= 0.35) return 3;
    if (ratio <= 0.65) return 2;
    return 1;
  }

  static BossPhaseConfig configForPhase(int phase) {
    return switch (phase.clamp(1, 3)) {
      1 => const BossPhaseConfig(
          phase: 1,
          movementMultiplier: 1.0,
          volleyCount: 0,
          volleyCooldownTicks: 0,
          projectileSpeed: 0,
          projectileDamage: 0,
        ),
      2 => const BossPhaseConfig(
          phase: 2,
          movementMultiplier: 1.12,
          volleyCount: 3,
          volleyCooldownTicks: 132,
          projectileSpeed: 3.1,
          projectileDamage: 7,
        ),
      _ => const BossPhaseConfig(
          phase: 3,
          movementMultiplier: 1.28,
          volleyCount: 5,
          volleyCooldownTicks: 105,
          projectileSpeed: 3.7,
          projectileDamage: 8,
        ),
    };
  }
}
