import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/boss_movement.dart';

void main() {
  group('decideBossMovement', () {
    test('scales boss charge movement by phase and enrage state', () {
      final normal = decideBossMovement(baseAngle: 0, animationTicks: 0, enraged: false, phaseMovementMultiplier: 1.2);
      final enraged = decideBossMovement(baseAngle: 0, animationTicks: 0, enraged: true, phaseMovementMultiplier: 1.2);
      expect(normal.speedMultiplier, closeTo(3.18, 0.000001));
      expect(enraged.speedMultiplier, closeTo(3.78, 0.000001));
    });

    test('uses recovery speed outside the charge window', () {
      final movement = decideBossMovement(baseAngle: 0.5, animationTicks: 28, enraged: true, phaseMovementMultiplier: 2);
      expect(movement.angle, 0.5);
      expect(movement.speedMultiplier, 0.72);
    });

    test('normalizes invalid angle and phase multiplier', () {
      final movement = decideBossMovement(baseAngle: double.nan, animationTicks: 0, enraged: false, phaseMovementMultiplier: double.nan);
      expect(movement.angle, 0);
      expect(movement.speedMultiplier, closeTo(2.65, 0.000001));
    });
  });
}
