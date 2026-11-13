import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/boss_combat.dart';

void main() {
  group('BossCombat.phaseForHealth', () {
    test('starts in phase one above 65 percent health', () {
      expect(BossCombat.phaseForHealth(hp: 100, maxHp: 100), 1);
      expect(BossCombat.phaseForHealth(hp: 66, maxHp: 100), 1);
    });

    test('enters phase two at 65 percent health', () {
      expect(BossCombat.phaseForHealth(hp: 65, maxHp: 100), 2);
      expect(BossCombat.phaseForHealth(hp: 36, maxHp: 100), 2);
    });

    test('enters enrage phase at 35 percent health', () {
      expect(BossCombat.phaseForHealth(hp: 35, maxHp: 100), 3);
      expect(BossCombat.phaseForHealth(hp: 0, maxHp: 100), 3);
    });

    test('handles invalid maximum health safely', () {
      expect(BossCombat.phaseForHealth(hp: 0, maxHp: 0), 3);
      expect(BossCombat.phaseForHealth(hp: 100, maxHp: -1), 3);
    });
  });

  group('BossCombat.configForPhase', () {
    test('phase one has no projectile volley', () {
      final config = BossCombat.configForPhase(1);
      expect(config.volleyCount, 0);
      expect(config.projectileDamage, 0);
    });

    test('later phases increase pressure and retain readable volley sizes', () {
      final phaseTwo = BossCombat.configForPhase(2);
      final phaseThree = BossCombat.configForPhase(3);

      expect(phaseTwo.volleyCount, 3);
      expect(phaseThree.volleyCount, 5);
      expect(phaseThree.projectileSpeed, greaterThan(phaseTwo.projectileSpeed));
      expect(phaseThree.projectileDamage, greaterThan(phaseTwo.projectileDamage));
      expect(
        phaseThree.movementMultiplier,
        greaterThan(phaseTwo.movementMultiplier),
      );
    });

    test('phase values are clamped to supported range', () {
      expect(BossCombat.configForPhase(0).phase, 1);
      expect(BossCombat.configForPhase(99).phase, 3);
    });
  });
}
