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
  });

  final int coins;
  final int hpUpgrade;
  final int atkUpgrade;
  final int bestStage;
  final int bestScore;
  final int equippedWeaponId;
  final int equippedArmorId, equippedHelmetId, equippedRingId, equippedRelicId;
  final int ownedEquipmentMask;

  factory PlayerProgress.fromMap(Map<String, int> values) {
    final weaponId = values['equippedWeaponId'] ?? 0;
    int gearId(String key) { final value = values[key] ?? 0; return value >= 0 && value <= 2 ? value : 0; }
    final armorId = gearId('equippedArmorId');
    final helmetId = gearId('equippedHelmetId');
    final ringId = gearId('equippedRingId');
    final relicId = gearId('equippedRelicId');
    var ownedMask = (values['ownedEquipmentMask'] ?? 585).clamp(0, 4095);
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
    'ownedEquipmentMask': ownedEquipmentMask,
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
    );
  }
}
