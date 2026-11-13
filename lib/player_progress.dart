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
  });

  final int coins;
  final int hpUpgrade;
  final int atkUpgrade;
  final int bestStage;
  final int bestScore;
  final int equippedWeaponId;
  final int equippedArmorId, equippedHelmetId, equippedRingId, equippedRelicId;

  factory PlayerProgress.fromMap(Map<String, int> values) {
    final weaponId = values['equippedWeaponId'] ?? 0;
    int gearId(String key) { final value = values[key] ?? 0; return value >= 0 && value <= 2 ? value : 0; }
    return PlayerProgress(
      coins: values['coins'] ?? 150,
      hpUpgrade: values['hpUpgrade'] ?? 0,
      atkUpgrade: values['atkUpgrade'] ?? 0,
      bestStage: values['bestStage'] ?? 1,
      bestScore: values['bestScore'] ?? 0,
      equippedWeaponId: weaponId >= 0 && weaponId <= 3 ? weaponId : 0,
      equippedArmorId: gearId('equippedArmorId'),
      equippedHelmetId: gearId('equippedHelmetId'),
      equippedRingId: gearId('equippedRingId'),
      equippedRelicId: gearId('equippedRelicId'),
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
    );
  }
}
