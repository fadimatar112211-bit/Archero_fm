import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/special_room_system.dart';

void main() {
  group('special room options', () {
    test('offers four distinct destination types', () {
      expect(specialRoomOptions.map((option) => option.type).toSet(),
          SpecialRoomType.values.toSet());
    });
  });

  group('merchant purchases', () {
    test('attack purchase spends 80 coins and applies a 15 percent run buff', () {
      final result = resolveMerchantPurchase(
        purchase: MerchantPurchase.attackBoost,
        coins: 100,
        hp: 50,
        maxHp: 100,
        attackMultiplier: 1,
      );
      expect(result.purchased, isTrue);
      expect(result.remainingCoins, 20);
      expect(result.updatedAttackMultiplier, 1.15);
      expect(result.updatedHp, 50);
    });

    test('healing potion spends 50 coins and heals up to max HP', () {
      final result = resolveMerchantPurchase(
        purchase: MerchantPurchase.healingPotion,
        coins: 80,
        hp: 90,
        maxHp: 100,
        attackMultiplier: 1.2,
      );
      expect(result.purchased, isTrue);
      expect(result.remainingCoins, 30);
      expect(result.updatedHp, 100);
      expect(result.updatedAttackMultiplier, 1.2);
    });

    test('insufficient funds do not mutate any values', () {
      final result = resolveMerchantPurchase(
        purchase: MerchantPurchase.attackBoost,
        coins: 79,
        hp: 40,
        maxHp: 100,
        attackMultiplier: 1,
      );
      expect(result.purchased, isFalse);
      expect(result.remainingCoins, 79);
      expect(result.updatedHp, 40);
      expect(result.updatedAttackMultiplier, 1);
    });

    test('invalid health values are normalized for healing', () {
      final result = resolveMerchantPurchase(
        purchase: MerchantPurchase.healingPotion,
        coins: 50,
        hp: double.nan,
        maxHp: 100,
        attackMultiplier: 1,
      );
      expect(result.updatedHp, 30);
    });
  });
}
