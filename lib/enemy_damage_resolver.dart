/// Resolves a projectile hit against an enemy without depending on widgets.
class EnemyDamageResolver {
  EnemyDamageResolver._();

  static String effectFor(String enemyType) => switch (enemyType) {
    'tank' => 'metalHit',
    'stalker' => 'shadowHit',
    'runner' => 'sparkHit',
    'boss' => 'bossHit',
    _ => 'impact',
  };

  /// Applies damage and returns true when the enemy has been defeated.
  static bool applyDamage({
    required Map<String, dynamic> enemy,
    required double damage,
  }) {
    final currentHp = (enemy['hp'] as num).toDouble();
    enemy['hitTicks'] = 9;
    final remainingHp = currentHp - damage;
    enemy['hp'] = remainingHp;
    return remainingHp <= 0;
  }
}
