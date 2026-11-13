enum UpgradeKind { health, attack }

class ShopUpgradeInfo {
  final UpgradeKind kind;
  final int level;
  final int cost;
  final int increase;
  final int maxLevel;

  const ShopUpgradeInfo({
    required this.kind,
    required this.level,
    required this.cost,
    required this.increase,
    required this.maxLevel,
  });

  bool get isMaxed => level >= maxLevel;
  bool canPurchase(int coins) => !isMaxed && coins >= cost;
}

class ShopEconomy {
  const ShopEconomy._();

  static const int healthStep = 25;
  static const int attackStep = 15;
  static const int maxHealthLevel = 20;
  static const int maxAttackLevel = 15;

  static ShopUpgradeInfo health(int currentUpgrade) {
    final level = (currentUpgrade ~/ healthStep).clamp(0, maxHealthLevel);
    return ShopUpgradeInfo(
      kind: UpgradeKind.health,
      level: level,
      cost: 50 + level * 25,
      increase: healthStep,
      maxLevel: maxHealthLevel,
    );
  }

  static ShopUpgradeInfo attack(int currentUpgrade) {
    final level = (currentUpgrade ~/ attackStep).clamp(0, maxAttackLevel);
    return ShopUpgradeInfo(
      kind: UpgradeKind.attack,
      level: level,
      cost: 70 + level * 35,
      increase: attackStep,
      maxLevel: maxAttackLevel,
    );
  }
}


/// Result of attempting to purchase one permanent shop upgrade.
class ShopPurchaseResult {
  final int remainingCoins;
  final int updatedUpgradeValue;
  final bool purchased;

  const ShopPurchaseResult({
    required this.remainingCoins,
    required this.updatedUpgradeValue,
    required this.purchased,
  });
}

/// Applies an upgrade purchase atomically without mutating global game state.
ShopPurchaseResult purchaseUpgrade({
  required ShopUpgradeInfo upgrade,
  required int currentCoins,
  required int currentUpgradeValue,
}) {
  if (!upgrade.canPurchase(currentCoins)) {
    return ShopPurchaseResult(
      remainingCoins: currentCoins,
      updatedUpgradeValue: currentUpgradeValue,
      purchased: false,
    );
  }
  return ShopPurchaseResult(
    remainingCoins: currentCoins - upgrade.cost,
    updatedUpgradeValue: currentUpgradeValue + upgrade.increase,
    purchased: true,
  );
}
