import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/enemy_wave_factory.dart';

void main() {
  test('every fifth stage generates one scaled boss', () {
    final wave = EnemyWaveFactory.create(stage: 5, random: Random(1));

    expect(wave, hasLength(1));
    expect(wave.single['type'], 'boss');
    expect(wave.single['hp'], 360.0);
    expect(wave.single['maxHp'], wave.single['hp']);
  });

  test('regular stages generate a bounded mixed enemy wave', () {
    final wave = EnemyWaveFactory.create(stage: 3, random: Random(7));

    expect(wave, hasLength(3));
    expect(wave.map((enemy) => enemy['type']).toSet(),
        containsAll(<String>{'ranged', 'runner', 'tank'}));
    for (final enemy in wave) {
      expect(enemy['hp'], greaterThan(0));
      expect(enemy['speed'], greaterThan(0));
      expect(enemy['x'], inInclusiveRange(35.0, 325.0));
      expect(enemy['y'], inInclusiveRange(90.0, 280.0));
    }
  });

  test('invalid stage numbers safely produce the first regular wave', () {
    final wave = EnemyWaveFactory.create(stage: 0, random: Random(1));
    expect(wave, hasLength(2));
    expect(wave.every((enemy) => enemy['type'] != 'boss'), isTrue);
  });
}
