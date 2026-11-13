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

typedef PersistShopSnapshot = Future<void> Function({
  required int coins,
  required int hpUpgrade,
  required int atkUpgrade,
});

enum ShopPurchaseStatus { purchased, insufficientFunds, maxLevel, persistenceFailed }

class ShopPurchaseResult {
  const ShopPurchaseResult({
    required this.status,
    required this.coins,
    required this.hpUpgrade,
    required this.atkUpgrade,
    this.error,
  });

  final ShopPurchaseStatus status;
  final int coins;
  final int hpUpgrade;
  final int atkUpgrade;
  final Object? error;

  bool get succeeded => status == ShopPurchaseStatus.purchased;
}

/// Persists a candidate shop snapshot before callers publish it to live state.
/// A failed write therefore cannot charge the player only in memory.
class ShopPurchaseCoordinator {
  const ShopPurchaseCoordinator._();

  static Future<ShopPurchaseResult> purchase({
    required UpgradeKind kind,
    required int coins,
    required int hpUpgrade,
    required int atkUpgrade,
    required PersistShopSnapshot persist,
  }) async {
    final info = kind == UpgradeKind.health
        ? ShopEconomy.health(hpUpgrade)
        : ShopEconomy.attack(atkUpgrade);

    ShopPurchaseStatus? rejected;
    if (info.isMaxed) {
      rejected = ShopPurchaseStatus.maxLevel;
    } else if (coins < info.cost) {
      rejected = ShopPurchaseStatus.insufficientFunds;
    }
    if (rejected != null) {
      return ShopPurchaseResult(
        status: rejected,
        coins: coins,
        hpUpgrade: hpUpgrade,
        atkUpgrade: atkUpgrade,
      );
    }

    final nextCoins = coins - info.cost;
    final nextHp = hpUpgrade +
        (kind == UpgradeKind.health ? info.increase : 0);
    final nextAtk = atkUpgrade +
        (kind == UpgradeKind.attack ? info.increase : 0);
    try {
      await persist(
        coins: nextCoins,
        hpUpgrade: nextHp,
        atkUpgrade: nextAtk,
      );
    } catch (error) {
      return ShopPurchaseResult(
        status: ShopPurchaseStatus.persistenceFailed,
        coins: coins,
        hpUpgrade: hpUpgrade,
        atkUpgrade: atkUpgrade,
        error: error,
      );
    }

    return ShopPurchaseResult(
      status: ShopPurchaseStatus.purchased,
      coins: nextCoins,
      hpUpgrade: nextHp,
      atkUpgrade: nextAtk,
    );
  }
}
