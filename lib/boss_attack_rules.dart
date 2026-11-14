/// Pure tuning rules for boss-only attacks, separate from regular enemy AI.
class BossAttackRules {
  const BossAttackRules._();

  static double contactDamage({required bool enraged}) =>
      enraged ? 12.0 : 10.0;

  static double areaDamage({required bool enraged}) =>
      enraged ? 20.0 : 15.0;

  static double areaDamageRadius({required bool enraged}) =>
      enraged ? 132.0 : 112.0;

  static const int areaAttackDurationTicks = 32;
  static int areaAttackCooldownTicks({required bool enraged}) =>
      enraged ? 132 : 180;

  static const int contactImpactFrame = 12;
}
