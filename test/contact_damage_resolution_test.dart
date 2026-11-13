import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/combat_damage.dart';

void main() {
  group('resolveEnemyContactHit', () {
    test('uses the established damage for each enemy archetype', () {
      final expected = <String, double>{
        'boss': 10,
        'tank': 8,
        'stalker': 6,
        'runner': 4,
        'ranged': 5,
        'unknown': 5,
      };
      for (final entry in expected.entries) {
        final result = resolveEnemyContactHit(
          playerHp: 100,
          enemyType: entry.key,
          bossEnraged: false,
          isDodging: false,
          canTakeDamage: true,
        );
        expect(result.status, ContactHitStatus.damaged);
        expect(result.damageApplied, entry.value, reason: entry.key);
        expect(result.updatedPlayerHp, 100 - entry.value, reason: entry.key);
      }
    });

    test('enraged boss contact damage is increased', () {
      final result = resolveEnemyContactHit(
        playerHp: 100,
        enemyType: 'boss',
        bossEnraged: true,
        isDodging: false,
        canTakeDamage: true,
      );
      expect(result.damageApplied, 12);
      expect(result.updatedPlayerHp, 88);
    });

    test('dodge takes priority over active invulnerability cooldown', () {
      final result = resolveEnemyContactHit(
        playerHp: 50,
        enemyType: 'tank',
        bossEnraged: false,
        isDodging: true,
        canTakeDamage: false,
      );
      expect(result.status, ContactHitStatus.dodged);
      expect(result.updatedPlayerHp, 50);
      expect(result.damageApplied, 0);
    });

    test('cooldown blocks contact damage', () {
      final result = resolveEnemyContactHit(
        playerHp: 50,
        enemyType: 'runner',
        bossEnraged: false,
        isDodging: false,
        canTakeDamage: false,
      );
      expect(result.status, ContactHitStatus.invulnerable);
      expect(result.updatedPlayerHp, 50);
      expect(result.damageApplied, 0);
    });
  });

  group('resolveBossAreaHit', () {
    test('applies normal and enraged blast damage', () {
      final normal = resolveBossAreaHit(
        playerHp: 100,
        distanceToPlayer: 112,
        isDodging: false,
        bossEnraged: false,
      );
      final enraged = resolveBossAreaHit(
        playerHp: 100,
        distanceToPlayer: 132,
        isDodging: false,
        bossEnraged: true,
      );
      expect(normal.damageApplied, 15);
      expect(normal.updatedPlayerHp, 85);
      expect(enraged.damageApplied, 20);
      expect(enraged.updatedPlayerHp, 80);
    });

    test('uses inclusive blast radius boundaries', () {
      expect(
        resolveBossAreaHit(
          playerHp: 100,
          distanceToPlayer: 112.001,
          isDodging: false,
          bossEnraged: false,
        ).status,
        ContactHitStatus.outsideRange,
      );
      expect(
        resolveBossAreaHit(
          playerHp: 100,
          distanceToPlayer: 132,
          isDodging: false,
          bossEnraged: true,
        ).status,
        ContactHitStatus.damaged,
      );
    });

    test('dodging avoids blast damage', () {
      final result = resolveBossAreaHit(
        playerHp: 73,
        distanceToPlayer: 90,
        isDodging: true,
        bossEnraged: true,
      );
      expect(result.status, ContactHitStatus.dodged);
      expect(result.updatedPlayerHp, 73);
      expect(result.damageApplied, 0);
    });

    test('players outside blast radius are unaffected', () {
      final result = resolveBossAreaHit(
        playerHp: 73,
        distanceToPlayer: 150,
        isDodging: false,
        bossEnraged: false,
      );
      expect(result.status, ContactHitStatus.outsideRange);
      expect(result.updatedPlayerHp, 73);
    });
  });
}
