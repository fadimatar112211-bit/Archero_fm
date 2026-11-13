import 'dart:math';

enum RewardChestType { supply, relic }

class ChestDefinition {
  const ChestDefinition({
    required this.type,
    required this.name,
    required this.keyCost,
    required this.minCoins,
    required this.maxCoins,
    required this.minGems,
    required this.maxGems,
    required this.minShards,
    required this.maxShards,
  });

  final RewardChestType type;
  final String name;
  final int keyCost;
  final int minCoins, maxCoins;
  final int minGems, maxGems;
  final int minShards, maxShards;

  ChestReward roll(Random random) => ChestReward(
    coins: _roll(random, minCoins, maxCoins),
    gems: _roll(random, minGems, maxGems),
    equipmentShards: _roll(random, minShards, maxShards),
  );

  static int _roll(Random random, int min, int max) =>
      min + random.nextInt(max - min + 1);
}

const chestDefinitions = <ChestDefinition>[
  ChestDefinition(
    type: RewardChestType.supply,
    name: 'صندوق الإمدادات',
    keyCost: 1,
    minCoins: 80,
    maxCoins: 140,
    minGems: 1,
    maxGems: 2,
    minShards: 2,
    maxShards: 4,
  ),
  ChestDefinition(
    type: RewardChestType.relic,
    name: 'صندوق الآثار',
    keyCost: 2,
    minCoins: 120,
    maxCoins: 190,
    minGems: 2,
    maxGems: 4,
    minShards: 5,
    maxShards: 8,
  ),
];

class ChestReward {
  const ChestReward({
    required this.coins,
    required this.gems,
    required this.equipmentShards,
  });

  final int coins;
  final int gems;
  final int equipmentShards;
}

enum ResourceTransactionStatus {
  completed,
  insufficientCoins,
  insufficientGems,
  insufficientKeys,
  persistenceFailed,
}

class ResourceTransaction {
  const ResourceTransaction({
    required this.status,
    required this.coins,
    required this.gems,
    required this.keys,
    required this.equipmentShards,
    this.reward,
  });

  final ResourceTransactionStatus status;
  final int coins, gems, keys, equipmentShards;
  final ChestReward? reward;

  bool get completed => status == ResourceTransactionStatus.completed;
}

typedef PersistResourceWallet = Future<void> Function({
  required int coins,
  required int gems,
  required int keys,
  required int equipmentShards,
});

Future<ResourceTransaction> purchaseChestKey({
  required int coins,
  required int gems,
  required int keys,
  required int equipmentShards,
  required PersistResourceWallet persist,
}) async {
  const cost = 180;
  if (coins < cost) {
    return ResourceTransaction(
      status: ResourceTransactionStatus.insufficientCoins,
      coins: coins,
      gems: gems,
      keys: keys,
      equipmentShards: equipmentShards,
    );
  }
  final nextCoins = coins - cost;
  final nextKeys = keys + 1;
  try {
    await persist(
      coins: nextCoins,
      gems: gems,
      keys: nextKeys,
      equipmentShards: equipmentShards,
    );
  } catch (_) {
    return ResourceTransaction(
      status: ResourceTransactionStatus.persistenceFailed,
      coins: coins,
      gems: gems,
      keys: keys,
      equipmentShards: equipmentShards,
    );
  }
  return ResourceTransaction(
    status: ResourceTransactionStatus.completed,
    coins: nextCoins,
    gems: gems,
    keys: nextKeys,
    equipmentShards: equipmentShards,
  );
}

Future<ResourceTransaction> purchaseChestKeyWithGems({
  required int coins,
  required int gems,
  required int keys,
  required int equipmentShards,
  required PersistResourceWallet persist,
}) async {
  const cost = 5;
  if (gems < cost) {
    return ResourceTransaction(
      status: ResourceTransactionStatus.insufficientGems,
      coins: coins,
      gems: gems,
      keys: keys,
      equipmentShards: equipmentShards,
    );
  }
  final nextGems = gems - cost;
  final nextKeys = keys + 1;
  try {
    await persist(
      coins: coins,
      gems: nextGems,
      keys: nextKeys,
      equipmentShards: equipmentShards,
    );
  } catch (_) {
    return ResourceTransaction(
      status: ResourceTransactionStatus.persistenceFailed,
      coins: coins,
      gems: gems,
      keys: keys,
      equipmentShards: equipmentShards,
    );
  }
  return ResourceTransaction(
    status: ResourceTransactionStatus.completed,
    coins: coins,
    gems: nextGems,
    keys: nextKeys,
    equipmentShards: equipmentShards,
  );
}

Future<ResourceTransaction> openRewardChest({
  required ChestDefinition chest,
  required int coins,
  required int gems,
  required int keys,
  required int equipmentShards,
  required Random random,
  required PersistResourceWallet persist,
}) async {
  if (keys < chest.keyCost) {
    return ResourceTransaction(
      status: ResourceTransactionStatus.insufficientKeys,
      coins: coins,
      gems: gems,
      keys: keys,
      equipmentShards: equipmentShards,
    );
  }

  final reward = chest.roll(random);
  final nextCoins = coins + reward.coins;
  final nextGems = gems + reward.gems;
  final nextKeys = keys - chest.keyCost;
  final nextShards = equipmentShards + reward.equipmentShards;
  try {
    await persist(
      coins: nextCoins,
      gems: nextGems,
      keys: nextKeys,
      equipmentShards: nextShards,
    );
  } catch (_) {
    return ResourceTransaction(
      status: ResourceTransactionStatus.persistenceFailed,
      coins: coins,
      gems: gems,
      keys: keys,
      equipmentShards: equipmentShards,
    );
  }
  return ResourceTransaction(
    status: ResourceTransactionStatus.completed,
    coins: nextCoins,
    gems: nextGems,
    keys: nextKeys,
    equipmentShards: nextShards,
    reward: reward,
  );
}
