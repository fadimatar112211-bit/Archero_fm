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

  group('resolveEnemyContactHit', () {
    final now = DateTime.utc(2026, 1, 1);

    test('only resolves a contact hit on its configured impact frame', () {
      final result = resolveEnemyContactHit(
        enemyType: 'runner',
        attackTicks: 7,
        impactFrame: 8,
        hitAlreadyResolved: false,
        distanceToPlayer: 30,
        impactRange: 55,
        playerIsDodging: false,
        lastDamageAt: null,
        now: now,
        damage: 4,
      );

      expect(result.status, EnemyContactHitStatus.notReady);
      expect(result.damageApplied, 0);
    });

    test('consumes the impact when the player dodges', () {
      final result = resolveEnemyContactHit(
        enemyType: 'tank',
        attackTicks: 8,
        impactFrame: 8,
        hitAlreadyResolved: false,
        distanceToPlayer: 50,
        impactRange: 55,
        playerIsDodging: true,
        lastDamageAt: null,
        now: now,
        damage: 8,
      );

      expect(result.status, EnemyContactHitStatus.dodged);
      expect(result.damageApplied, 0);
    });

    test('keeps an impact pending during the invulnerability window', () {
      final result = resolveEnemyContactHit(
        enemyType: 'stalker',
        attackTicks: 8,
        impactFrame: 8,
        hitAlreadyResolved: false,
        distanceToPlayer: 50,
        impactRange: 55,
        playerIsDodging: false,
        lastDamageAt: now.subtract(const Duration(milliseconds: 100)),
        now: now,
        damage: 6,
      );

      expect(result.status, EnemyContactHitStatus.invulnerable);
      expect(result.damageApplied, 0);
    });

    test('applies archetype damage after invulnerability expires', () {
      final result = resolveEnemyContactHit(
        enemyType: 'tank',
        attackTicks: 8,
        impactFrame: 8,
        hitAlreadyResolved: false,
        distanceToPlayer: 50,
        impactRange: 55,
        playerIsDodging: false,
        lastDamageAt: now.subtract(const Duration(milliseconds: 220)),
        now: now,
        damage: 8,
      );

      expect(result.status, EnemyContactHitStatus.damaged);
      expect(result.damageApplied, 8);
    });

    test('rejects ranged, distant, and already-resolved contacts', () {
      for (final input in [
        {'type': 'ranged', 'distance': 20.0, 'done': false},
        {'type': 'runner', 'distance': 80.0, 'done': false},
        {'type': 'runner', 'distance': 20.0, 'done': true},
      ]) {
        final result = resolveEnemyContactHit(
          enemyType: input['type']! as String,
          attackTicks: 8,
          impactFrame: 8,
          hitAlreadyResolved: input['done']! as bool,
          distanceToPlayer: input['distance']! as double,
          impactRange: 55,
          playerIsDodging: false,
          lastDamageAt: null,
          now: now,
          damage: 5,
        );
        expect(result.status, EnemyContactHitStatus.notReady);
      }
    });
  });
}
