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
}


  group('ShopPurchaseCoordinator', () {
    test('persists the complete candidate snapshot before reporting purchase', () async {
      Map<String, int>? persisted;
      final result = await ShopPurchaseCoordinator.purchase(
        kind: UpgradeKind.health,
        coins: 150,
        hpUpgrade: 0,
        atkUpgrade: 15,
        persist: ({required coins, required hpUpgrade, required atkUpgrade}) async {
          persisted = {
            'coins': coins,
            'hpUpgrade': hpUpgrade,
            'atkUpgrade': atkUpgrade,
          };
        },
      );

      expect(result.status, ShopPurchaseStatus.purchased);
      expect(result.succeeded, isTrue);
      expect(result.coins, 100);
      expect(result.hpUpgrade, 25);
      expect(result.atkUpgrade, 15);
      expect(persisted, {'coins': 100, 'hpUpgrade': 25, 'atkUpgrade': 15});
    });

    test('leaves all player values unchanged when persistence fails', () async {
      final result = await ShopPurchaseCoordinator.purchase(
        kind: UpgradeKind.attack,
        coins: 150,
        hpUpgrade: 25,
        atkUpgrade: 0,
        persist: ({required coins, required hpUpgrade, required atkUpgrade}) {
          throw StateError('disk unavailable');
        },
      );

      expect(result.status, ShopPurchaseStatus.persistenceFailed);
      expect(result.succeeded, isFalse);
      expect(result.coins, 150);
      expect(result.hpUpgrade, 25);
      expect(result.atkUpgrade, 0);
      expect(result.error, isA<StateError>());
    });

    test('does not call persistence for insufficient funds or max level', () async {
      var calls = 0;
      Future<void> persist({
        required int coins,
        required int hpUpgrade,
        required int atkUpgrade,
      }) async { calls++; }

      final poor = await ShopPurchaseCoordinator.purchase(
        kind: UpgradeKind.health,
        coins: 49,
        hpUpgrade: 0,
        atkUpgrade: 0,
        persist: persist,
      );
      final maxed = await ShopPurchaseCoordinator.purchase(
        kind: UpgradeKind.health,
        coins: 10000,
        hpUpgrade: 500,
        atkUpgrade: 0,
        persist: persist,
      );

      expect(poor.status, ShopPurchaseStatus.insufficientFunds);
      expect(maxed.status, ShopPurchaseStatus.maxLevel);
      expect(calls, 0);
    });
  });
