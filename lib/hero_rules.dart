class HeroRunStats {
  const HeroRunStats({
    required this.playerHp,
    required this.playerMaxHp,
    required this.playerSpeed,
    required this.attackPowerMultiplier,
    required this.extraArrows,
  });

  final double playerHp;
  final double playerMaxHp;
  final double playerSpeed;
  final double attackPowerMultiplier;
  final int extraArrows;
}

/// Builds the initial combat stats for a selected hero, including permanent
/// account upgrades. Values preserve the current in-game hero balance.
HeroRunStats createHeroRunStats({
  required int heroType,
  required int hpUpgrade,
  required int attackUpgrade,
}) {
  var playerMaxHp = 100.0 + hpUpgrade;
  var playerSpeed = 3.5;
  var attackPowerMultiplier = 1.0 + attackUpgrade * 0.08;
  var extraArrows = 0;

  switch (heroType) {
    case 2:
      playerMaxHp += 50;
    case 3:
      playerSpeed = 5.2;
    case 4:
      extraArrows = 1;
  }

  return HeroRunStats(
    playerHp: playerMaxHp,
    playerMaxHp: playerMaxHp,
    playerSpeed: playerSpeed,
    attackPowerMultiplier: attackPowerMultiplier,
    extraArrows: extraArrows,
  );
}
