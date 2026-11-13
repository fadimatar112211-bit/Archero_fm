import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/resource_economy.dart';

void main() {
  group('chest key purchases', () {
    test('spends 180 coins and persists the additional key first', () async {
      Map<String, int>? persisted;
      final result = await purchaseChestKey(
        coins: 250,
        gems: 3,
        keys: 1,
        equipmentShards: 8,
        persist: ({required coins, required gems, required keys, required equipmentShards}) async {
          persisted = {
            'coins': coins,
            'gems': gems,
            'keys': keys,
            'equipmentShards': equipmentShards,
          };
        },
      );
      expect(result.status, ResourceTransactionStatus.completed);
      expect(result.coins, 70);
      expect(result.keys, 2);
      expect(persisted, {'coins': 70, 'gems': 3, 'keys': 2, 'equipmentShards': 8});
    });

    test('does not spend when coins are insufficient', () async {
      var calls = 0;
      final result = await purchaseChestKey(
        coins: 179,
        gems: 2,
        keys: 0,
        equipmentShards: 0,
        persist: ({required coins, required gems, required keys, required equipmentShards}) async { calls++; },
      );
      expect(result.status, ResourceTransactionStatus.insufficientCoins);
      expect(result.coins, 179);
      expect(result.keys, 0);
      expect(calls, 0);
    });

    test('keeps the old wallet if persistence fails', () async {
      final result = await purchaseChestKey(
        coins: 300,
        gems: 2,
        keys: 1,
        equipmentShards: 4,
        persist: ({required coins, required gems, required keys, required equipmentShards}) async {
          throw StateError('storage failed');
        },
      );
      expect(result.status, ResourceTransactionStatus.persistenceFailed);
      expect(result.coins, 300);
      expect(result.keys, 1);
    });
  });

  group('reward chests', () {
    test('supply chest consumes one key and grants bounded rewards', () async {
      Map<String, int>? persisted;
      final result = await openRewardChest(
        chest: chestDefinitions.first,
        coins: 50,
        gems: 1,
        keys: 2,
        equipmentShards: 3,
        random: Random(7),
        persist: ({required coins, required gems, required keys, required equipmentShards}) async {
          persisted = {
            'coins': coins,
            'gems': gems,
            'keys': keys,
            'equipmentShards': equipmentShards,
          };
        },
      );
      expect(result.status, ResourceTransactionStatus.completed);
      expect(result.keys, 1);
      expect(result.reward!.coins, inInclusiveRange(80, 140));
      expect(result.reward!.gems, inInclusiveRange(1, 2));
      expect(result.reward!.equipmentShards, inInclusiveRange(2, 4));
      expect(persisted, {
        'coins': result.coins,
        'gems': result.gems,
        'keys': result.keys,
        'equipmentShards': result.equipmentShards,
      });
    });

    test('relic chest requires and consumes two keys', () async {
      final result = await openRewardChest(
        chest: chestDefinitions.last,
        coins: 0,
        gems: 0,
        keys: 2,
        equipmentShards: 0,
        random: Random(3),
        persist: ({required coins, required gems, required keys, required equipmentShards}) async {},
      );
      expect(result.status, ResourceTransactionStatus.completed);
      expect(result.keys, 0);
      expect(result.reward!.equipmentShards, inInclusiveRange(5, 8));
      expect(result.reward!.gems, inInclusiveRange(2, 4));
    });

    test('does not open a chest without enough keys or call persistence', () async {
      var calls = 0;
      final result = await openRewardChest(
        chest: chestDefinitions.last,
        coins: 20,
        gems: 1,
        keys: 1,
        equipmentShards: 2,
        random: Random(1),
        persist: ({required coins, required gems, required keys, required equipmentShards}) async { calls++; },
      );
      expect(result.status, ResourceTransactionStatus.insufficientKeys);
      expect(result.keys, 1);
      expect(result.reward, isNull);
      expect(calls, 0);
    });

    test('does not consume keys or grant rewards when save fails', () async {
      final result = await openRewardChest(
        chest: chestDefinitions.first,
        coins: 20,
        gems: 1,
        keys: 1,
        equipmentShards: 2,
        random: Random(2),
        persist: ({required coins, required gems, required keys, required equipmentShards}) async {
          throw StateError('storage failed');
        },
      );
      expect(result.status, ResourceTransactionStatus.persistenceFailed);
      expect(result.coins, 20);
      expect(result.gems, 1);
      expect(result.keys, 1);
      expect(result.equipmentShards, 2);
      expect(result.reward, isNull);
    });
  });
}
