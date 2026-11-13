import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/shop_economy.dart';

void main() {
  group('commitUpgradePurchase', () {
    test('persists before returning a committed purchase', () async {
      var persistedCoins = -1;
      var persistedUpgrade = -1;
      final result = await commitUpgradePurchase(
        upgrade: ShopEconomy.health(0),
        currentCoins: 120,
        currentUpgradeValue: 0,
        persist: (coins, upgrade) async {
          persistedCoins = coins;
          persistedUpgrade = upgrade;
        },
      );

      expect(result.status, ShopPurchaseStatus.purchased);
      expect(result.remainingCoins, 70);
      expect(result.updatedUpgradeValue, 25);
      expect(persistedCoins, 70);
      expect(persistedUpgrade, 25);
    });

    test('does not commit a purchase when persistence fails', () async {
      final result = await commitUpgradePurchase(
        upgrade: ShopEconomy.attack(0),
        currentCoins: 100,
        currentUpgradeValue: 15,
        persist: (_, __) async => throw StateError('disk unavailable'),
      );

      expect(result.status, ShopPurchaseStatus.persistenceFailed);
      expect(result.purchased, isFalse);
      expect(result.remainingCoins, 100);
      expect(result.updatedUpgradeValue, 15);
    });

    test('does not persist rejected purchases', () async {
      var called = false;
      final result = await commitUpgradePurchase(
        upgrade: ShopEconomy.health(0),
        currentCoins: 49,
        currentUpgradeValue: 0,
        persist: (_, __) async {
          called = true;
        },
      );

      expect(result.status, ShopPurchaseStatus.insufficientFunds);
      expect(called, isFalse);
      expect(result.remainingCoins, 49);
      expect(result.updatedUpgradeValue, 0);
    });
  });
}
