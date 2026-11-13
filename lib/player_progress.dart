class PlayerProgress {
  const PlayerProgress({
    this.coins = 150,
    this.hpUpgrade = 0,
    this.atkUpgrade = 0,
    this.bestStage = 1,
    this.bestScore = 0,
    this.equippedWeaponId = 0,
    this.equippedArmorId = 0,
    this.equippedHelmetId = 0,
    this.equippedRingId = 0,
    this.equippedRelicId = 0,
    this.ownedEquipmentMask = 585,
    this.gems = 0,
    this.keys = 0,
    this.equipmentShards = 0,
    this.unlockedHeroesMask = 1,
    this.totalKills = 0,
    this.totalBosses = 0,
    this.totalChests = 0,
    this.totalRuns = 0,
    this.claimedAchievementsMask = 0,
  });

  final int coins;
  final int hpUpgrade;
  final int atkUpgrade;
  final int bestStage;
  final int bestScore;
  final int equippedWeaponId;
  final int equippedArmorId, equippedHelmetId, equippedRingId, equippedRelicId;
  final int ownedEquipmentMask;
  final int gems;
  final int keys;
  final int equipmentShards;
  final int unlockedHeroesMask;
  final int totalKills, totalBosses, totalChests, totalRuns;
  final int claimedAchievementsMask;


  int get effectiveOwnedEquipmentMask {
    var mask = ownedEquipmentMask.clamp(0, 4095).toInt();
    if (equippedArmorId >= 0 && equippedArmorId <= 2) mask |= 1 << equippedArmorId;
    if (equippedHelmetId >= 0 && equippedHelmetId <= 2) mask |= 1 << (3 + equippedHelmetId);
    if (equippedRingId >= 0 && equippedRingId <= 2) mask |= 1 << (6 + equippedRingId);
    if (equippedRelicId >= 0 && equippedRelicId <= 2) mask |= 1 << (9 + equippedRelicId);
    return mask;
  }

  factory PlayerProgress.fromMap(Map<String, int> values) {
    final weaponId = values['equippedWeaponId'] ?? 0;
    int gearId(String key) { final value = values[key] ?? 0; return value >= 0 && value <= 2 ? value : 0; }
    final armorId = gearId('equippedArmorId');
    final helmetId = gearId('equippedHelmetId');
    final ringId = gearId('equippedRingId');
    final relicId = gearId('equippedRelicId');
    var ownedMask = (values['ownedEquipmentMask'] ?? 585).clamp(0, 4095).toInt();
    ownedMask |= 1 << armorId;
    ownedMask |= 1 << (3 + helmetId);
    ownedMask |= 1 << (6 + ringId);
    ownedMask |= 1 << (9 + relicId);
    return PlayerProgress(
      coins: values['coins'] ?? 150,
      hpUpgrade: values['hpUpgrade'] ?? 0,
      atkUpgrade: values['atkUpgrade'] ?? 0,
      bestStage: values['bestStage'] ?? 1,
      bestScore: values['bestScore'] ?? 0,
      equippedWeaponId: weaponId >= 0 && weaponId <= 3 ? weaponId : 0,
      equippedArmorId: armorId,
      equippedHelmetId: helmetId,
      equippedRingId: ringId,
      equippedRelicId: relicId,
      ownedEquipmentMask: ownedMask,
      gems: (values['gems'] ?? 0).clamp(0, 999999).toInt(),
      keys: (values['keys'] ?? 0).clamp(0, 999999).toInt(),
      equipmentShards: (values['equipmentShards'] ?? 0).clamp(0, 999999).toInt(),
      unlockedHeroesMask: ((values['unlockedHeroesMask'] ?? 1).clamp(0, 15).toInt() | 1),
      totalKills: (values['totalKills'] ?? 0).clamp(0, 999999999).toInt(),
      totalBosses: (values['totalBosses'] ?? 0).clamp(0, 999999999).toInt(),
      totalChests: (values['totalChests'] ?? 0).clamp(0, 999999999).toInt(),
      totalRuns: (values['totalRuns'] ?? 0).clamp(0, 999999999).toInt(),
      claimedAchievementsMask: (values['claimedAchievementsMask'] ?? 0).clamp(0, 65535).toInt(),
    );
  }

  Map<String, int> toMap() => {
    'coins': coins,
    'hpUpgrade': hpUpgrade,
    'atkUpgrade': atkUpgrade,
    'bestStage': bestStage,
    'bestScore': bestScore,
    'equippedWeaponId': equippedWeaponId,
    'equippedArmorId': equippedArmorId,
    'equippedHelmetId': equippedHelmetId,
    'equippedRingId': equippedRingId,
    'equippedRelicId': equippedRelicId,
    'ownedEquipmentMask': effectiveOwnedEquipmentMask,
    'gems': gems,
    'keys': keys,
    'equipmentShards': equipmentShards,
    'unlockedHeroesMask': unlockedHeroesMask | 1,
    'totalKills': totalKills,
    'totalBosses': totalBosses,
    'totalChests': totalChests,
    'totalRuns': totalRuns,
    'claimedAchievementsMask': claimedAchievementsMask,
  };

  PlayerProgress copyWith({
    int? coins,
    int? hpUpgrade,
    int? atkUpgrade,
    int? bestStage,
    int? bestScore,
    int? equippedWeaponId,
    int? equippedArmorId,
    int? equippedHelmetId,
    int? equippedRingId,
    int? equippedRelicId,
    int? ownedEquipmentMask,
    int? gems,
    int? keys,
    int? equipmentShards,
    int? unlockedHeroesMask,
    int? totalKills,
    int? totalBosses,
    int? totalChests,
    int? totalRuns,
    int? claimedAchievementsMask,
  }) {
    return PlayerProgress(
      coins: coins ?? this.coins,
      hpUpgrade: hpUpgrade ?? this.hpUpgrade,
      atkUpgrade: atkUpgrade ?? this.atkUpgrade,
      bestStage: bestStage ?? this.bestStage,
      bestScore: bestScore ?? this.bestScore,
      equippedWeaponId: equippedWeaponId ?? this.equippedWeaponId,
      equippedArmorId: equippedArmorId ?? this.equippedArmorId,
      equippedHelmetId: equippedHelmetId ?? this.equippedHelmetId,
      equippedRingId: equippedRingId ?? this.equippedRingId,
      equippedRelicId: equippedRelicId ?? this.equippedRelicId,
      ownedEquipmentMask: ownedEquipmentMask ?? this.ownedEquipmentMask,
      gems: gems ?? this.gems,
      keys: keys ?? this.keys,
      equipmentShards: equipmentShards ?? this.equipmentShards,
      unlockedHeroesMask: unlockedHeroesMask ?? this.unlockedHeroesMask,
      totalKills: totalKills ?? this.totalKills,
      totalBosses: totalBosses ?? this.totalBosses,
      totalChests: totalChests ?? this.totalChests,
      totalRuns: totalRuns ?? this.totalRuns,
      claimedAchievementsMask: claimedAchievementsMask ?? this.claimedAchievementsMask,
    );
  }
}
