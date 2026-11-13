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
}
