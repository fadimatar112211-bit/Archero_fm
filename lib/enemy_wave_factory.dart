import 'dart:math';

/// Creates deterministic stage waves independently from the Flutter game UI.
class EnemyWaveFactory {
  EnemyWaveFactory._();

  static List<Map<String, dynamic>> create({
    required int stage,
    required Random random,
  }) {
    final wave = <Map<String, dynamic>>[];
    final safeStage = max(stage, 1);
    final difficultyStep = min(max(safeStage - 1, 0), 20).toDouble();

    if (safeStage % 5 == 0) {
      final bossProgress = min(max(safeStage - 5, 0), 45).toDouble();
      final bossHp = 360.0 + bossProgress * 22;
      wave.add({
        'x': 180.0,
        'y': 105.0,
        'hp': bossHp,
        'maxHp': bossHp,
        'type': 'boss',
        'radius': 36.0,
        'speed': 0.78 + min(difficultyStep, 16) * 0.012,
      });
      return wave;
    }

    final count = min(2 + (safeStage ~/ 2), 7);
    for (var i = 0; i < count; i++) {
      final variant = (i + safeStage) % 4;
      final enemyType = switch (variant) {
        0 => 'runner',
        1 => 'tank',
        2 => 'stalker',
        _ => 'ranged',
      };
      final baseHp = 55.0 + difficultyStep * 10;
      final hp = switch (enemyType) {
        'tank' => baseHp * 1.8,
        'runner' => baseHp * 0.72,
        'stalker' => baseHp * 0.9,
        'ranged' => baseHp * 0.82,
        _ => baseHp,
      };
      final speed = switch (enemyType) {
        'tank' => 0.52 + difficultyStep * 0.008,
        'runner' => 1.25 + difficultyStep * 0.018,
        'stalker' => 0.90 + difficultyStep * 0.014,
        'ranged' => 0.68 + difficultyStep * 0.010,
        _ => 0.76 + difficultyStep * 0.012,
      };
      wave.add({
        'x': 35.0 + random.nextDouble() * 290,
        'y': 90.0 + random.nextDouble() * 190,
        'hp': hp,
        'maxHp': hp,
        'type': enemyType,
        'radius': enemyType == 'tank' ? 23.0 : 19.0,
        'speed': speed,
      });
    }

    return wave;
  }
}
