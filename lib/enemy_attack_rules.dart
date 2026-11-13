/// Pure combat rules for enemy attacks.
///
/// This module owns attack tuning values so they can be reviewed and tested
/// without constructing Flutter widgets or advancing the game loop.
class EnemyAttackRules {
  const EnemyAttackRules._();

  static double contactDamage({
    required String enemyType,
    required bool bossEnraged,
  }) {
    return switch (enemyType) {
      'boss' => bossEnraged ? 12.0 : 10.0,
      'tank' => 8.0,
      'stalker' => 6.0,
      'runner' => 4.0,
      _ => 5.0,
    };
  }

  static double bossAreaDamage({required bool bossEnraged}) =>
      bossEnraged ? 20.0 : 15.0;

  static double bossAreaRadius({required bool bossEnraged}) =>
      bossEnraged ? 132.0 : 112.0;

  static int attackDurationTicks({required bool isBoss}) =>
      isBoss ? 32 : 16;

  static int attackCooldownTicks({
    required bool isBoss,
    required bool bossEnraged,
  }) {
    if (isBoss) return bossEnraged ? 132 : 180;
    return 76;
  }

  static int attackImpactFrame({required bool isBoss}) =>
      isBoss ? 12 : 8;

  static double attackRange({required double enemyRadius}) =>
      23 + enemyRadius + 24;

  static double impactRange({required double enemyRadius}) =>
      23 + enemyRadius + 14;
}
