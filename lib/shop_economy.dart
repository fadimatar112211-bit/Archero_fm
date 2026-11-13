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


class ShopPurchaseResult {
  const ShopPurchaseResult({
    required this.remainingCoins,
    required this.updatedUpgradeValue,
    required this.purchased,
  });

  final int remainingCoins;
  final int updatedUpgradeValue;
  final bool purchased;
}

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

enum ShopPurchaseStatus {
  purchased,
  insufficientFunds,
  maxLevel,
  persistenceFailed,
}

class ShopPurchaseCommit {
  const ShopPurchaseCommit({
    required this.status,
    required this.remainingCoins,
    required this.updatedUpgradeValue,
  });

  final ShopPurchaseStatus status;
  final int remainingCoins;
  final int updatedUpgradeValue;

  bool get purchased => status == ShopPurchaseStatus.purchased;
}

/// Persists the proposed balances before the caller commits them to live state.
/// A failed write therefore leaves the in-memory purchase unapplied.
Future<ShopPurchaseCommit> commitUpgradePurchase({
  required ShopUpgradeInfo upgrade,
  required int currentCoins,
  required int currentUpgradeValue,
  required Future<void> Function(int coins, int upgradeValue) persist,
}) async {
  final preview = purchaseUpgrade(
    upgrade: upgrade,
    currentCoins: currentCoins,
    currentUpgradeValue: currentUpgradeValue,
  );
  if (!preview.purchased) {
    return ShopPurchaseCommit(
      status: upgrade.isMaxed
          ? ShopPurchaseStatus.maxLevel
          : ShopPurchaseStatus.insufficientFunds,
      remainingCoins: currentCoins,
      updatedUpgradeValue: currentUpgradeValue,
    );
  }

  try {
    await persist(preview.remainingCoins, preview.updatedUpgradeValue);
  } catch (_) {
    return ShopPurchaseCommit(
      status: ShopPurchaseStatus.persistenceFailed,
      remainingCoins: currentCoins,
      updatedUpgradeValue: currentUpgradeValue,
    );
  }

  return ShopPurchaseCommit(
    status: ShopPurchaseStatus.purchased,
    remainingCoins: preview.remainingCoins,
    updatedUpgradeValue: preview.updatedUpgradeValue,
  );
}
