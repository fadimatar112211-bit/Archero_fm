import 'combat_stats.dart';

/// Pure result for damage dealt to an enemy by a player attack.
class EnemyHitResolution {
  final double updatedHp;
  final double damageApplied;
  final bool isCritical;
  final bool isDefeated;
  final bool dropsCoin;
  final int scoreAward;

  const EnemyHitResolution({
    required this.updatedHp,
    required this.damageApplied,
    required this.isCritical,
    required this.isDefeated,
    required this.dropsCoin,
    required this.scoreAward,
  });
}

/// Resolves player damage and defeat rewards without Flutter/game-state effects.
///
/// Callers retain responsibility for animations, sounds, removing entities,
/// and adding the returned score/coin rewards to the live game state.
EnemyHitResolution resolveEnemyHit({
  required double currentHp,
  required double baseDamage,
  required double attackMultiplier,
  required double criticalChance,
  required double criticalRoll,
  required bool isBoss,
  double bossDamageMultiplier = 1,
  double criticalMultiplier = 2,
  int normalDefeatScore = 20,
  int bossDefeatScore = 150,
}) {
  final safeBossMultiplier = bossDamageMultiplier.isFinite
      ? bossDamageMultiplier.clamp(0.0, 100.0).toDouble()
      : 1.0;
  final safeCriticalMultiplier = criticalMultiplier.isFinite
      ? criticalMultiplier.clamp(1.0, 10.0).toDouble()
      : 2.0;
  final adjustedBaseDamage = baseDamage * (isBoss ? safeBossMultiplier : 1);
  final isCritical = criticalRoll.isFinite &&
      criticalRoll >= 0 &&
      criticalRoll < (criticalChance.isFinite
          ? criticalChance.clamp(0.0, 1.0)
          : 0.0);
  final damage = CombatBalance.arrowDamage(
    baseDamage: adjustedBaseDamage,
    attackMultiplier: attackMultiplier *
        (isCritical ? safeCriticalMultiplier / 2 : 1),
    criticalChance: criticalChance,
    // Preserve the pre-rolled critical decision while reusing safe scaling.
    roll: isCritical ? 0 : 1,
  );
  final updatedHp = currentHp - damage;
  final defeated = updatedHp <= 0;

  return EnemyHitResolution(
    updatedHp: updatedHp,
    damageApplied: damage,
    isCritical: isCritical,
    isDefeated: defeated,
    dropsCoin: defeated,
    scoreAward: defeated
        ? (isBoss ? bossDefeatScore : normalDefeatScore)
        : 0,
  );
}
