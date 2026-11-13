import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/shop_economy.dart';

void main() {
  group('ShopEconomy.health', () {
    test('increases cost with each purchased level', () {
      expect(ShopEconomy.health(0).cost, 50);
      expect(ShopEconomy.health(25).cost, 75);
      expect(ShopEconomy.health(50).cost, 100);
    });

    test('checks affordability and caps health upgrades', () {
      final first = ShopEconomy.health(0);
      expect(first.canPurchase(49), isFalse);
      expect(first.canPurchase(50), isTrue);

      final maxed = ShopEconomy.health(500);
      expect(maxed.isMaxed, isTrue);
      expect(maxed.canPurchase(10000), isFalse);
    });
  });

  group('ShopEconomy.attack', () {
    test('increases cost with each purchased level', () {
      expect(ShopEconomy.attack(0).cost, 70);
      expect(ShopEconomy.attack(15).cost, 105);
      expect(ShopEconomy.attack(30).cost, 140);
    });

    test('checks affordability and caps attack upgrades', () {
      final first = ShopEconomy.attack(0);
      expect(first.canPurchase(69), isFalse);
      expect(first.canPurchase(70), isTrue);

      final maxed = ShopEconomy.attack(225);
      expect(maxed.isMaxed, isTrue);
      expect(maxed.canPurchase(10000), isFalse);
    });
  });

  test('upgrade levels derive from persisted upgrade values', () {
    expect(ShopEconomy.health(75).level, 3);
    expect(ShopEconomy.attack(60).level, 4);
  });
  group('commitUpgradePurchase', () {
    test('persists the proposed purchase before returning success', () async {
      var persistedCoins = -1;
      var persistedUpgrade = -1;
      final result = await commitUpgradePurchase(
        upgrade: ShopEconomy.health(0), currentCoins: 100, currentUpgradeValue: 0,
        persist: (coins, upgradeValue) async { persistedCoins = coins; persistedUpgrade = upgradeValue; },
      );
      expect(result.status, ShopPurchaseStatus.purchased);
      expect(result.remainingCoins, 50);
      expect(result.updatedUpgradeValue, 25);
      expect(persistedCoins, 50);
      expect(persistedUpgrade, 25);
    });
    test('leaves the purchase unapplied when persistence fails', () async {
      var attempted = false;
      const coins = 100;
      const upgradeValue = 0;
      final result = await commitUpgradePurchase(
        upgrade: ShopEconomy.health(upgradeValue), currentCoins: coins, currentUpgradeValue: upgradeValue,
        persist: (_, __) async { attempted = true; throw StateError('storage unavailable'); },
      );
      expect(attempted, isTrue);
      expect(result.status, ShopPurchaseStatus.persistenceFailed);
      expect(result.remainingCoins, coins);
      expect(result.updatedUpgradeValue, upgradeValue);
    });
    test('does not call persistence for unaffordable or maxed upgrades', () async {
      var calls = 0;
      Future<void> persist(int _, int __) async { calls++; }
      final poor = await commitUpgradePurchase(
        upgrade: ShopEconomy.health(0), currentCoins: 10, currentUpgradeValue: 0, persist: persist,
      );
      final maxed = await commitUpgradePurchase(
        upgrade: ShopEconomy.health(500), currentCoins: 10000, currentUpgradeValue: 500, persist: persist,
      );
      expect(poor.status, ShopPurchaseStatus.insufficientFunds);
      expect(maxed.status, ShopPurchaseStatus.maxLevel);
      expect(calls, 0);
    });
  });

}
