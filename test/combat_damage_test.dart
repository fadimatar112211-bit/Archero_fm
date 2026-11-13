import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/combat_damage.dart';

void main() {
  group('resolveProjectileHit', () {
    test('applies projectile damage when player can be hit', () {
      final result = resolveProjectileHit(
        playerHp: 100,
        projectileDamage: 12,
        isDodging: false,
        canTakeDamage: true,
      );

      expect(result.status, ProjectileHitStatus.damaged);
      expect(result.updatedPlayerHp, 88);
      expect(result.damageApplied, 12);
    });

    test('dodging prevents damage even when invulnerability has elapsed', () {
      final result = resolveProjectileHit(
        playerHp: 100,
        projectileDamage: 12,
        isDodging: true,
        canTakeDamage: true,
      );

      expect(result.status, ProjectileHitStatus.dodged);
      expect(result.updatedPlayerHp, 100);
      expect(result.damageApplied, 0);
    });

    test('active hit cooldown prevents additional damage', () {
      final result = resolveProjectileHit(
        playerHp: 70,
        projectileDamage: 12,
        isDodging: false,
        canTakeDamage: false,
      );

      expect(result.status, ProjectileHitStatus.invulnerable);
      expect(result.updatedPlayerHp, 70);
      expect(result.damageApplied, 0);
    });

    test('uses the legacy fallback damage for non-finite projectile damage', () {
      final result = resolveProjectileHit(
        playerHp: 50,
        projectileDamage: double.nan,
        isDodging: false,
        canTakeDamage: true,
      );

      expect(result.updatedPlayerHp, 44);
      expect(result.damageApplied, 6);
    });


    test('never turns invalid or negative projectile damage into healing', () {
      for (final invalidDamage in [-12.0, double.nan, double.infinity]) {
        final result = resolveProjectileHit(
          playerHp: 50,
          projectileDamage: invalidDamage,
          isDodging: false,
          canTakeDamage: true,
        );
        expect(result.damageApplied, 6);
        expect(result.updatedPlayerHp, 44);
      }
    });

    test('uses zero damage when both projectile and fallback damage are invalid', () {
      final result = resolveProjectileHit(
        playerHp: 50,
        projectileDamage: -1,
        isDodging: false,
        canTakeDamage: true,
        fallbackDamage: double.nan,
      );
      expect(result.damageApplied, 0);
      expect(result.updatedPlayerHp, 50);
    });

    test('supports custom fallback damage', () {
      final result = resolveProjectileHit(
        playerHp: 50,
        projectileDamage: double.infinity,
        isDodging: false,
        canTakeDamage: true,
        fallbackDamage: 9,
      );

      expect(result.updatedPlayerHp, 41);
      expect(result.damageApplied, 9);
    });
  });

  group('resolveAreaAttackHit', () {
    final now = DateTime.utc(2026, 1, 1);

    test('does not hit outside the radius or while dodging', () {
      final outside = resolveAreaAttackHit(
        playerHp: 100, distanceToPlayer: 121, attackRadius: 120,
        damage: 20, isDodging: false, lastDamageAt: null, now: now,
      );
      final dodged = resolveAreaAttackHit(
        playerHp: 100, distanceToPlayer: 50, attackRadius: 120,
        damage: 20, isDodging: true, lastDamageAt: null, now: now,
      );
      expect(outside.status, AreaAttackHitStatus.outOfRange);
      expect(dodged.status, AreaAttackHitStatus.dodged);
      expect(outside.updatedPlayerHp, 100);
      expect(dodged.updatedPlayerHp, 100);
    });

    test('respects invulnerability and applies damage after it expires', () {
      final protected = resolveAreaAttackHit(
        playerHp: 100, distanceToPlayer: 50, attackRadius: 120,
        damage: 20, isDodging: false,
        lastDamageAt: now.subtract(const Duration(milliseconds: 100)),
        now: now,
      );
      final hit = resolveAreaAttackHit(
        playerHp: 100, distanceToPlayer: 50, attackRadius: 120,
        damage: 20, isDodging: false,
        lastDamageAt: now.subtract(const Duration(milliseconds: 260)),
        now: now,
      );
      expect(protected.status, AreaAttackHitStatus.invulnerable);
      expect(protected.updatedPlayerHp, 100);
      expect(hit.status, AreaAttackHitStatus.damaged);
      expect(hit.updatedPlayerHp, 80);
      expect(hit.damageApplied, 20);
      expect(hit.resolvedAt, now);
    });

    test('sanitizes invalid distance, radius, HP, and damage', () {
      final invalid = resolveAreaAttackHit(
        playerHp: double.nan, distanceToPlayer: double.nan,
        attackRadius: 100, damage: 20, isDodging: false,
        lastDamageAt: null, now: now,
      );
      final safe = resolveAreaAttackHit(
        playerHp: double.nan, distanceToPlayer: 10,
        attackRadius: 100, damage: double.infinity, isDodging: false,
        lastDamageAt: null, now: now,
      );
      expect(invalid.status, AreaAttackHitStatus.outOfRange);
      expect(invalid.updatedPlayerHp, 0);
      expect(safe.status, AreaAttackHitStatus.damaged);
      expect(safe.updatedPlayerHp, 0);
      expect(safe.damageApplied, 0);
    });
  });

}
