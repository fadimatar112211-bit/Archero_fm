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
