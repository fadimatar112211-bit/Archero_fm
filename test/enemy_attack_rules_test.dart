import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/enemy_attack_rules.dart';

void main() {
  group('EnemyAttackRules.contactDamage', () {
    test('preserves distinct contact damage for each enemy archetype', () {
      expect(EnemyAttackRules.contactDamage(enemyType: 'boss', bossEnraged: false), 10);
      expect(EnemyAttackRules.contactDamage(enemyType: 'boss', bossEnraged: true), 12);
      expect(EnemyAttackRules.contactDamage(enemyType: 'tank', bossEnraged: false), 8);
      expect(EnemyAttackRules.contactDamage(enemyType: 'stalker', bossEnraged: false), 6);
      expect(EnemyAttackRules.contactDamage(enemyType: 'runner', bossEnraged: false), 4);
      expect(EnemyAttackRules.contactDamage(enemyType: 'ranged', bossEnraged: false), 5);
    });
  });

  group('EnemyAttackRules boss area attack', () {
    test('scales damage and radius when the boss is enraged', () {
      expect(EnemyAttackRules.bossAreaDamage(bossEnraged: false), 15);
      expect(EnemyAttackRules.bossAreaDamage(bossEnraged: true), 20);
      expect(EnemyAttackRules.bossAreaRadius(bossEnraged: false), 112);
      expect(EnemyAttackRules.bossAreaRadius(bossEnraged: true), 132);
    });
  });

  group('EnemyAttackRules attack timing and ranges', () {
    test('preserves boss and regular enemy attack timing', () {
      expect(EnemyAttackRules.attackDurationTicks(isBoss: true), 32);
      expect(EnemyAttackRules.attackDurationTicks(isBoss: false), 16);
      expect(EnemyAttackRules.attackCooldownTicks(isBoss: true, bossEnraged: false), 180);
      expect(EnemyAttackRules.attackCooldownTicks(isBoss: true, bossEnraged: true), 132);
      expect(EnemyAttackRules.attackCooldownTicks(isBoss: false, bossEnraged: false), 76);
      expect(EnemyAttackRules.attackImpactFrame(isBoss: true), 12);
      expect(EnemyAttackRules.attackImpactFrame(isBoss: false), 8);
    });

    test('derives attack and impact ranges from enemy radius', () {
      expect(EnemyAttackRules.attackRange(enemyRadius: 18), 65);
      expect(EnemyAttackRules.impactRange(enemyRadius: 18), 55);
    });
  });
}
