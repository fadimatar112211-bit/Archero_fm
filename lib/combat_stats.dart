/// Pure combat calculations kept separate so balancing can be tested without widgets.
class CombatBalance {
  const CombatBalance._();

  static double arrowDamage({
    required double baseDamage,
    required double attackMultiplier,
    required double criticalChance,
    required double roll,
  }) {
    final safeBase = baseDamage.isFinite ? baseDamage.clamp(0.0, 1000000.0) : 0.0;
    final safeAttack = attackMultiplier.isFinite
        ? attackMultiplier.clamp(0.0, 100.0)
        : 0.0;
    final safeChance = criticalChance.isFinite
        ? criticalChance.clamp(0.0, 1.0)
        : 0.0;
    final critical = roll.isFinite && roll >= 0 && roll < safeChance;
    return safeBase * safeAttack * (critical ? 2.0 : 1.0);
  }

  static int shootIntervalMs(double attackSpeedMultiplier) {
    final safeSpeed = attackSpeedMultiplier.isFinite
        ? attackSpeedMultiplier.clamp(1.0, 2.2)
        : 1.0;
    return (650 / safeSpeed).round().clamp(220, 650);
  }
}
