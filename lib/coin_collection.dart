import 'dart:math';

class CoinPosition {
  const CoinPosition({required this.x, required this.y});

  final double x;
  final double y;
}

class CoinCollectionResult {
  const CoinCollectionResult({
    required this.collectedIndices,
    required this.reward,
  });

  /// Indices are returned from highest to lowest so callers can safely remove
  /// entries from a mutable list without shifting indices that remain.
  final List<int> collectedIndices;
  final int reward;

  int get collectedCount => collectedIndices.length;

  bool get collectedAny => collectedIndices.isNotEmpty;
}

/// Resolves which coins are within pickup range and their total reward.
///
/// Each coin is rounded individually to preserve the existing economy rules.
CoinCollectionResult resolveCoinCollection({
  required double playerX,
  required double playerY,
  required List<CoinPosition> coins,
  required double pickupRadius,
  required double rewardPerCoin,
}) {
  final collectedIndices = <int>[];
  var reward = 0;

  for (var index = coins.length - 1; index >= 0; index--) {
    final dx = playerX - coins[index].x;
    final dy = playerY - coins[index].y;
    if (sqrt(dx * dx + dy * dy) < pickupRadius) {
      collectedIndices.add(index);
      reward += rewardPerCoin.round();
    }
  }

  return CoinCollectionResult(
    collectedIndices: collectedIndices,
    reward: reward,
  );
}
