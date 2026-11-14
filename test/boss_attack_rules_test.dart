import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/boss_attack_rules.dart';

void main() {
  group('BossAttackRules contact attack', () {
    test('scales contact damage with enrage', () {
      expect(BossAttackRules.contactDamage(enraged: false), 10);
      expect(BossAttackRules.contactDamage(enraged: true), 12);
      expect(BossAttackRules.contactImpactFrame, 12);
    });
  });

  group('BossAttackRules area attack', () {
    test('scales damage and radius with enrage', () {
      expect(BossAttackRules.areaDamage(enraged: false), 15);
      expect(BossAttackRules.areaDamage(enraged: true), 20);
      expect(BossAttackRules.areaDamageRadius(enraged: false), 112);
      expect(BossAttackRules.areaDamageRadius(enraged: true), 132);
    });

    test('preserves duration and phase-dependent cooldown', () {
      expect(BossAttackRules.areaAttackDurationTicks, 32);
      expect(BossAttackRules.areaAttackCooldownTicks(enraged: false), 180);
      expect(BossAttackRules.areaAttackCooldownTicks(enraged: true), 132);
    });
  });
}
