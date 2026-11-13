import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/boss_combat.dart';
import 'package:archero_fm/boss_projectiles.dart';
import 'package:archero_fm/combat_damage.dart';
import 'package:archero_fm/combat_collision.dart';
import 'package:archero_fm/enemy_hit_resolution.dart';
import 'package:archero_fm/game_run_lifecycle.dart';
import 'package:archero_fm/player_movement.dart';
import 'package:archero_fm/player_projectiles.dart';

/// Deterministic gameplay scenarios built from the same pure resolvers used
/// by GameScreen. These tests verify outcomes, not merely that controls exist.
void main() {
  group('measured gameplay scenarios', () {
    test('touch drag changes player coordinates and opens dodge window', () {
      const startX = 180.0;
      const startY = 430.0;
      final moved = resolvePlayerDrag(
        currentX: startX,
        currentY: startY,
        deltaX: 48,
        deltaY: -32,
        arenaWidth: 360,
        arenaHeight: 640,
        currentMoveTicks: 0,
      );

      expect(moved.x, 228);
      expect(moved.y, 398);
      expect(moved.moveTicks, greaterThan(0));
    });

    test('player arrow advances, collides with enemy, and applies critical damage', () {
      const enemy = CombatCircle(x: 110, y: 100, radius: 18);
      final projectile = advancePlayerProjectile(
        x: 100,
        y: 100,
        velocityX: 8,
        velocityY: 0,
        arenaWidth: 360,
        arenaHeight: 640,
        targets: const [enemy],
      );

      expect(projectile.shouldRemove, isFalse);
      expect(projectile.hitTargetIndex, 0);

      final hit = resolveEnemyHit(
        currentHp: 100,
        baseDamage: 30,
        attackMultiplier: 1.5,
        criticalChance: 0.25,
        criticalRoll: 0.1,
        isBoss: false,
      );
      expect(hit.isCritical, isTrue);
      expect(hit.damageApplied, 90);
      expect(hit.updatedHp, 10);
      expect(hit.isDefeated, isFalse);
      expect(hit.dropsCoin, isFalse);
    });

    test('lethal enemy hit awards defeat score and coin drop exactly once', () {
      final hit = resolveEnemyHit(
        currentHp: 40,
        baseDamage: 30,
        attackMultiplier: 1,
        criticalChance: 0,
        criticalRoll: 1,
        isBoss: false,
      );
      expect(hit.isDefeated, isFalse);
      expect(hit.updatedHp, 10);
      expect(hit.dropsCoin, isFalse);
      expect(hit.scoreAward, 0);

      final lethal = resolveEnemyHit(
        currentHp: 25,
        baseDamage: 30,
        attackMultiplier: 1,
        criticalChance: 0,
        criticalRoll: 1,
        isBoss: false,
      );
      expect(lethal.isDefeated, isTrue);
      expect(lethal.dropsCoin, isTrue);
      expect(lethal.scoreAward, 20);
    });

    test('enemy projectile reduces player HP while dodge and invulnerability protect', () {
      final hit = resolveProjectileHit(
        playerHp: 100,
        projectileDamage: 12,
        isDodging: false,
        canTakeDamage: true,
      );
      expect(hit.status, ProjectileHitStatus.damaged);
      expect(hit.updatedPlayerHp, 88);

      final dodged = resolveProjectileHit(
        playerHp: hit.updatedPlayerHp,
        projectileDamage: 12,
        isDodging: true,
        canTakeDamage: true,
      );
      expect(dodged.status, ProjectileHitStatus.dodged);
      expect(dodged.updatedPlayerHp, 88);

      final protected = resolveProjectileHit(
        playerHp: hit.updatedPlayerHp,
        projectileDamage: 12,
        isDodging: false,
        canTakeDamage: false,
      );
      expect(protected.status, ProjectileHitStatus.invulnerable);
      expect(protected.updatedPlayerHp, 88);
    });

    test('lethal damage advances run through dying to terminal game over', () {
      var hp = 9.0;
      final hit = resolveProjectileHit(
        playerHp: hp,
        projectileDamage: 12,
        isDodging: false,
        canTakeDamage: true,
      );
      hp = hit.updatedPlayerHp;
      expect(hp, lessThanOrEqualTo(0));

      final lifecycle = GameRunLifecycle();
      expect(lifecycle.beginPlayerDeath(), isTrue);
      expect(lifecycle.isPlayerDying, isTrue);
      expect(lifecycle.canAdvanceGameClock, isTrue);
      expect(lifecycle.canPerformActions, isFalse);
      expect(lifecycle.finishRun(), isTrue);
      expect(lifecycle.isGameOver, isTrue);
      expect(lifecycle.canAdvanceGameClock, isFalse);
    });

    test('boss health thresholds change phases and unlock stronger volleys', () {
      expect(BossCombat.phaseForHealth(hp: 80, maxHp: 100), 1);
      expect(BossCombat.phaseForHealth(hp: 60, maxHp: 100), 2);
      expect(BossCombat.phaseForHealth(hp: 30, maxHp: 100), 3);

      final phaseTwo = BossCombat.configForPhase(2);
      final phaseThree = BossCombat.configForPhase(3);
      expect(phaseTwo.volleyCount, 3);
      expect(phaseThree.volleyCount, 5);
      expect(phaseThree.projectileDamage, greaterThan(phaseTwo.projectileDamage));

      final volley = createBossFanVolley(
        originX: 180,
        originY: 100,
        targetX: 180,
        targetY: 500,
        count: phaseThree.volleyCount,
        speed: phaseThree.projectileSpeed,
        damage: phaseThree.projectileDamage,
      );
      expect(volley, hasLength(5));
      expect(volley.every((shot) => shot.damage == 8), isTrue);
      expect(volley.first.velocityX, lessThan(0));
      expect(volley.last.velocityX, greaterThan(0));
    });
  });
}
