import 'dart:math';

import 'boss_attack_rules.dart';
import 'boss_combat.dart';
import 'boss_movement.dart';
import 'boss_projectiles.dart';

/// Result of one deterministic boss simulation tick.
class BossSystemUpdate {
  const BossSystemUpdate({
    required this.phase,
    required this.enraged,
    required this.phaseChanged,
    required this.volleyCooldown,
    required this.projectiles,
    required this.attackTicks,
    required this.attackCooldown,
    required this.areaAttackTicks,
    required this.areaHitDone,
    required this.areaAttackStarted,
    required this.areaImpactTriggered,
    required this.showPeriodicTell,
    required this.distanceToPlayer,
    required this.movement,
  });

  final int phase;
  final bool enraged;
  final bool phaseChanged;
  final int volleyCooldown;
  final List<BossProjectileSpec> projectiles;
  final int attackTicks;
  final int attackCooldown;
  final int areaAttackTicks;
  final bool areaHitDone;
  final bool areaAttackStarted;
  final bool areaImpactTriggered;
  final bool showPeriodicTell;
  final double distanceToPlayer;
  final BossMovementDecision movement;
}

/// Owns boss phase transitions, attack scheduling, movement and projectile
/// creation. UI effects and player HP mutation remain in the game coordinator.
class BossSystem {
  const BossSystem._();

  static BossSystemUpdate advance({
    required double x,
    required double y,
    required double hp,
    required double maxHp,
    required double playerX,
    required double playerY,
    required int animationTicks,
    required int previousPhase,
    required int volleyCooldown,
    required int attackTicks,
    required int attackCooldown,
    required int areaAttackTicks,
    required bool areaHitDone,
  }) {
    final dx = playerX - x;
    final dy = playerY - y;
    final distance = dx.isFinite && dy.isFinite
        ? sqrt(dx * dx + dy * dy)
        : double.infinity;
    final angle = dx.isFinite && dy.isFinite ? atan2(dy, dx) : 0.0;
    final phase = BossCombat.phaseForHealth(hp: hp, maxHp: maxHp);
    final config = BossCombat.configForPhase(phase);
    final enraged = phase == 3;
    var nextVolleyCooldown = volleyCooldown;
    var nextAttackTicks = attackTicks > 0 ? attackTicks - 1 : 0;
    var nextAttackCooldown = attackCooldown > 0 ? attackCooldown - 1 : 0;
    var nextAreaAttackTicks = areaAttackTicks > 0 ? areaAttackTicks - 1 : 0;
    var nextAreaHitDone = areaHitDone;
    var areaAttackStarted = false;
    var areaImpactTriggered = false;
    var projectiles = <BossProjectileSpec>[];

    if (phase >= 2) {
      if (nextVolleyCooldown > 0) nextVolleyCooldown--;
      if (nextVolleyCooldown == 0 && distance <= 320) {
        projectiles = createBossFanVolley(
          originX: x,
          originY: y,
          targetX: playerX,
          targetY: playerY,
          count: config.volleyCount,
          speed: config.projectileSpeed,
          damage: config.projectileDamage,
        );
        nextVolleyCooldown = config.volleyCooldownTicks;
      }
    }

    if (distance <= 220 &&
        nextAreaAttackTicks == 0 &&
        nextAttackCooldown == 0) {
      nextAreaAttackTicks = BossAttackRules.areaAttackDurationTicks;
      nextAttackCooldown = BossAttackRules.areaAttackCooldownTicks(
        enraged: enraged,
      );
      nextAreaHitDone = false;
      areaAttackStarted = true;
    }

    if (nextAreaAttackTicks == 8 && !nextAreaHitDone) {
      nextAreaHitDone = true;
      areaImpactTriggered = true;
    }

    final movement = decideBossMovement(
      baseAngle: angle,
      animationTicks: animationTicks,
      enraged: enraged,
      phaseMovementMultiplier: config.movementMultiplier,
    );

    return BossSystemUpdate(
      phase: phase,
      enraged: enraged,
      phaseChanged: phase != previousPhase,
      volleyCooldown: nextVolleyCooldown,
      projectiles: List.unmodifiable(projectiles),
      attackTicks: nextAttackTicks,
      attackCooldown: nextAttackCooldown,
      areaAttackTicks: nextAreaAttackTicks,
      areaHitDone: nextAreaHitDone,
      areaAttackStarted: areaAttackStarted,
      areaImpactTriggered: areaImpactTriggered,
      showPeriodicTell: animationTicks % 180 == 0,
      distanceToPlayer: distance,
      movement: movement,
    );
  }
}
