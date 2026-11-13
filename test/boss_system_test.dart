import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/boss_system.dart';
import 'package:archero_fm/boss_attack_rules.dart';
import 'package:archero_fm/combat_damage.dart';

void main() {
  group('BossSystem.advance', () {
    test('transitions phases and creates the configured enrage volley', () {
      final update = BossSystem.advance(
        x: 100, y: 100, hp: 30, maxHp: 100,
        playerX: 200, playerY: 100,
        animationTicks: 1, previousPhase: 2,
        volleyCooldown: 1, attackTicks: 0, attackCooldown: 50,
        areaAttackTicks: 0, areaHitDone: false,
      );

      expect(update.phase, 3);
      expect(update.enraged, isTrue);
      expect(update.phaseChanged, isTrue);
      expect(update.projectiles, hasLength(5));
      expect(update.volleyCooldown, 105);
      expect(update.projectiles.every((shot) => shot.damage == 8), isTrue);
    });

    test('starts an area attack and schedules one impact at tick eight', () {
      final started = BossSystem.advance(
        x: 100, y: 100, hp: 80, maxHp: 100,
        playerX: 250, playerY: 100,
        animationTicks: 2, previousPhase: 1,
        volleyCooldown: 90, attackTicks: 0, attackCooldown: 1,
        areaAttackTicks: 0, areaHitDone: false,
      );

      expect(started.areaAttackStarted, isTrue);
      expect(started.areaAttackTicks, 32);
      expect(started.attackCooldown, 180);
      expect(started.areaImpactTriggered, isFalse);

      final impact = BossSystem.advance(
        x: 100, y: 100, hp: 80, maxHp: 100,
        playerX: 250, playerY: 100,
        animationTicks: 3, previousPhase: 1,
        volleyCooldown: started.volleyCooldown,
        attackTicks: started.attackTicks,
        attackCooldown: started.attackCooldown,
        areaAttackTicks: 9,
        areaHitDone: false,
      );

      expect(impact.areaAttackTicks, 8);
      expect(impact.areaImpactTriggered, isTrue);
      expect(impact.areaHitDone, isTrue);
    });

    test('boss area impact damages the player while dodge and invulnerability protect', () {
      final now = DateTime.utc(2026, 11, 14);
      final update = BossSystem.advance(
        x: 100, y: 100, hp: 30, maxHp: 100,
        playerX: 200, playerY: 100,
        animationTicks: 10, previousPhase: 3,
        volleyCooldown: 90, attackTicks: 0, attackCooldown: 1,
        areaAttackTicks: 9, areaHitDone: false,
      );

      expect(update.enraged, isTrue);
      expect(update.areaImpactTriggered, isTrue);
      final damage = BossAttackRules.areaDamage(enraged: update.enraged);
      final radius = BossAttackRules.areaDamageRadius(enraged: update.enraged);
      final hit = resolveAreaAttackHit(
        playerHp: 100,
        distanceToPlayer: update.distanceToPlayer,
        attackRadius: radius,
        damage: damage,
        isDodging: false,
        lastDamageAt: null,
        now: now,
      );
      expect(hit.status, AreaAttackHitStatus.damaged);
      expect(hit.updatedPlayerHp, 80);

      final dodged = resolveAreaAttackHit(
        playerHp: 100,
        distanceToPlayer: update.distanceToPlayer,
        attackRadius: radius,
        damage: damage,
        isDodging: true,
        lastDamageAt: null,
        now: now,
      );
      expect(dodged.status, AreaAttackHitStatus.dodged);
      expect(dodged.updatedPlayerHp, 100);

      final protected = resolveAreaAttackHit(
        playerHp: 100,
        distanceToPlayer: update.distanceToPlayer,
        attackRadius: radius,
        damage: damage,
        isDodging: false,
        lastDamageAt: now.subtract(const Duration(milliseconds: 100)),
        now: now,
      );
      expect(protected.status, AreaAttackHitStatus.invulnerable);
      expect(protected.updatedPlayerHp, 100);
    });

    test('does not start area attacks outside range or repeat a resolved impact', () {
      final outside = BossSystem.advance(
        x: 100, y: 100, hp: 100, maxHp: 100,
        playerX: 500, playerY: 100,
        animationTicks: 180, previousPhase: 1,
        volleyCooldown: 90, attackTicks: 0, attackCooldown: 0,
        areaAttackTicks: 0, areaHitDone: false,
      );
      expect(outside.areaAttackStarted, isFalse);
      expect(outside.showPeriodicTell, isTrue);

      final resolved = BossSystem.advance(
        x: 100, y: 100, hp: 100, maxHp: 100,
        playerX: 200, playerY: 100,
        animationTicks: 4, previousPhase: 1,
        volleyCooldown: 90, attackTicks: 0, attackCooldown: 1,
        areaAttackTicks: 9, areaHitDone: true,
      );
      expect(resolved.areaImpactTriggered, isFalse);
    });
  });
}
