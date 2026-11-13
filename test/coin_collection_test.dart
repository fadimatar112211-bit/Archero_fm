import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/coin_collection.dart';

void main() {
  group('resolveCoinCollection', () {
    test('collects only coins strictly inside the pickup radius', () {
      final result = resolveCoinCollection(
        playerX: 10,
        playerY: 10,
        coins: const [
          CoinPosition(x: 10, y: 10),
          CoinPosition(x: 12, y: 13),
          CoinPosition(x: 16, y: 10),
          CoinPosition(x: 10, y: 17),
        ],
        pickupRadius: 5,
        rewardPerCoin: 10,
      );

      expect(result.collectedIndices, [1, 0]);
      expect(result.collectedCount, 2);
      expect(result.reward, 20);
      expect(result.collectedAny, isTrue);
    });

    test('returns no reward when no coins are in range', () {
      final result = resolveCoinCollection(
        playerX: 0,
        playerY: 0,
        coins: const [CoinPosition(x: 20, y: 0)],
        pickupRadius: 10,
        rewardPerCoin: 10,
      );

      expect(result.collectedIndices, isEmpty);
      expect(result.reward, 0);
      expect(result.collectedAny, isFalse);
    });

    test('rounds reward per coin, matching the existing economy behavior', () {
      final result = resolveCoinCollection(
        playerX: 0,
        playerY: 0,
        coins: const [
          CoinPosition(x: 1, y: 0),
          CoinPosition(x: 0, y: 1),
          CoinPosition(x: -1, y: 0),
        ],
        pickupRadius: 2,
        rewardPerCoin: 10.4,
      );

      expect(result.collectedCount, 3);
      expect(result.reward, 30);
    });

    test('ignores non-finite positions and malformed coin coordinates', () {
      final result = resolveCoinCollection(
        playerX: double.nan,
        playerY: 0,
        coins: const [CoinPosition(x: 0, y: 0)],
        pickupRadius: 20,
        rewardPerCoin: 10,
      );
      final malformedCoins = resolveCoinCollection(
        playerX: 0,
        playerY: 0,
        coins: const [
          CoinPosition(x: double.nan, y: 0),
          CoinPosition(x: 0, y: double.infinity),
          CoinPosition(x: 1, y: 1),
        ],
        pickupRadius: 5,
        rewardPerCoin: 10,
      );
      expect(result.collectedIndices, isEmpty);
      expect(result.reward, 0);
      expect(malformedCoins.collectedIndices, [2]);
      expect(malformedCoins.reward, 10);
    });

    test('normalizes invalid pickup radii and reward values', () {
      final invalidRadius = resolveCoinCollection(
        playerX: 0,
        playerY: 0,
        coins: const [CoinPosition(x: 0, y: 0)],
        pickupRadius: double.nan,
        rewardPerCoin: 10,
      );
      final invalidReward = resolveCoinCollection(
        playerX: 0,
        playerY: 0,
        coins: const [CoinPosition(x: 1, y: 0)],
        pickupRadius: 2,
        rewardPerCoin: double.nan,
      );
      expect(invalidRadius.collectedIndices, isEmpty);
      expect(invalidReward.collectedIndices, [0]);
      expect(invalidReward.reward, 0);
    });

    test('supports expanded pickup radius and world-scaled rewards', () {
      final result = resolveCoinCollection(
        playerX: 0,
        playerY: 0,
        coins: const [
          CoinPosition(x: 40, y: 0),
          CoinPosition(x: 45, y: 0),
        ],
        pickupRadius: 46,
        rewardPerCoin: 13,
      );

      expect(result.collectedIndices, [1, 0]);
      expect(result.reward, 26);
    });
  });
}
