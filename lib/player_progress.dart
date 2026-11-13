class PlayerProgress {
  const PlayerProgress({
    this.coins = 150,
    this.hpUpgrade = 0,
    this.atkUpgrade = 0,
    this.bestStage = 1,
    this.bestScore = 0,
  });

  final int coins;
  final int hpUpgrade;
  final int atkUpgrade;
  final int bestStage;
  final int bestScore;

  factory PlayerProgress.fromMap(Map<String, int> values) {
    return PlayerProgress(
      coins: values['coins'] ?? 150,
      hpUpgrade: values['hpUpgrade'] ?? 0,
      atkUpgrade: values['atkUpgrade'] ?? 0,
      bestStage: values['bestStage'] ?? 1,
      bestScore: values['bestScore'] ?? 0,
    );
  }

  Map<String, int> toMap() => {
    'coins': coins,
    'hpUpgrade': hpUpgrade,
    'atkUpgrade': atkUpgrade,
    'bestStage': bestStage,
    'bestScore': bestScore,
  };

  PlayerProgress copyWith({
    int? coins,
    int? hpUpgrade,
    int? atkUpgrade,
    int? bestStage,
    int? bestScore,
  }) {
    return PlayerProgress(
      coins: coins ?? this.coins,
      hpUpgrade: hpUpgrade ?? this.hpUpgrade,
      atkUpgrade: atkUpgrade ?? this.atkUpgrade,
      bestStage: bestStage ?? this.bestStage,
      bestScore: bestScore ?? this.bestScore,
    );
  }
}
