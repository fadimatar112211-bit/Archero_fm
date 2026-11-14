import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/coin_pickup_resolver.dart';

void main() {
  test('coin is collected inside pickup radius', () {
    expect(
      CoinPickupResolver.isCollected(
        playerX: 100,
        playerY: 100,
        coinX: 120,
        coinY: 110,
      ),
      isTrue,
    );
  });

  test('coin is not collected outside pickup radius', () {
    expect(
      CoinPickupResolver.isCollected(
        playerX: 100,
        playerY: 100,
        coinX: 140,
        coinY: 100,
      ),
      isFalse,
    );
  });

  test('pickup radius can be configured', () {
    expect(
      CoinPickupResolver.isCollected(
        playerX: 0,
        playerY: 0,
        coinX: 10,
        coinY: 0,
        pickupRadius: 8,
      ),
      isFalse,
    );
  });
}
