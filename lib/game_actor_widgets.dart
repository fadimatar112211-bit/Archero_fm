import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'game_painters.dart';
import 'game_render_rules.dart';

typedef GameActorData = Map<String, dynamic>;

class CoinSpriteWidget extends StatelessWidget {
  const CoinSpriteWidget({super.key, required this.coin});

  final GameActorData coin;

  @override
  Widget build(BuildContext context) => Positioned(
        left: (coin['x'] as double) - 10,
        top: (coin['y'] as double) - 10,
        child: const Text('🪙', style: TextStyle(fontSize: 20)),
      );
}

class PlayerArrowSpriteWidget extends StatelessWidget {
  const PlayerArrowSpriteWidget({super.key, required this.arrow});

  final GameActorData arrow;

  @override
  Widget build(BuildContext context) => Positioned(
        left: (arrow['x'] as double) - 5,
        top: (arrow['y'] as double) - 5,
        child: Transform.rotate(
          angle: math.atan2(
            arrow['vy'] as double,
            arrow['vx'] as double,
          ),
          child: const CustomPaint(
            size: Size(25, 12),
            painter: ArrowSpritePainter(),
          ),
        ),
      );
}

class EnemyProjectileSpriteWidget extends StatelessWidget {
  const EnemyProjectileSpriteWidget({
    super.key,
    required this.projectile,
    required this.animationTicks,
  });

  final GameActorData projectile;
  final int animationTicks;

  @override
  Widget build(BuildContext context) => Positioned(
        left: (projectile['x'] as double) - 11,
        top: (projectile['y'] as double) - 11,
        child: Transform.rotate(
          angle: animationTicks * .16,
          child: const CustomPaint(
            size: Size(22, 22),
            painter: RangedProjectilePainter(),
          ),
        ),
      );
}

class EnemyActorWidget extends StatelessWidget {
  const EnemyActorWidget({
    super.key,
    required this.enemy,
    required this.animationTicks,
  });

  final GameActorData enemy;
  final int animationTicks;

  @override
  Widget build(BuildContext context) {
    final radius = enemy['radius'] as double;
    final enemyType = enemy['type'] as String;
    final isBoss = enemyType == 'boss';
    final enemyColor = switch (enemyType) {
      'ranged' => Colors.cyan,
      'runner' => Colors.orange,
      'tank' => Colors.blueGrey,
      'stalker' => Colors.purple,
      'boss' => Colors.deepPurple,
      _ => Colors.red,
    };
    final walkPhase = (enemy['walkPhase'] as double?) ?? 0.0;
    final enemyPhase = walkPhase + (enemy['x'] as double) * 0.03;
    final enemyAttacking =
        ((enemy['attackTicks'] as int?) ?? 0) > 0 ||
        (isBoss && ((enemy['areaAttackTicks'] as int?) ?? 0) > 0);
    final enemyHit = ((enemy['hitTicks'] as int?) ?? 0) > 0;
    final gait = math.sin(walkPhase * 1.8);
    final gaitBounce = math.cos(walkPhase * 3.6).abs();
    final gaitStrength = enemyType == 'tank' || enemyType == 'boss' ? 0.45 : 1.0;
    final attackLean = enemyAttacking
        ? (enemyType == 'boss' ? -0.16 : -0.24)
        : gait * 0.045 * gaitStrength;
    final hpRatio = normalizedHealthRatio(
      current: (enemy['hp'] as double?) ?? 0,
      maximum: (enemy['maxHp'] as double?) ?? 0,
    );

    return Positioned(
      left: (enemy['x'] as double) - radius,
      top: (enemy['y'] as double) - radius,
      child: Column(
        children: [
          Container(
            width: radius * 2,
            height: 5,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: hpRatio,
              child: Container(
                decoration: BoxDecoration(
                  color: isBoss ? Colors.purpleAccent : enemyColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          SizedBox(
            width: radius * 2,
            height: radius * 2,
            child: Transform.translate(
              offset: Offset(
                enemyAttacking ? -3.5 : math.sin(enemyPhase).abs() * -2.0,
                (math.sin(enemyPhase * 1.35) * 1.5 -
                        gaitBounce * 1.15 * gaitStrength) *
                    (enemyAttacking ? 0.45 : 1.0),
              ),
              child: Transform.rotate(
                angle: enemyHit ? 0.10 * math.sin(enemyPhase * 5) : attackLean,
                child: Transform.scale(
                  scale: (1 +
                          gaitBounce * 0.018 * gaitStrength +
                          math.sin(enemyPhase) * 0.012) *
                      (enemyAttacking ? 1.06 : 1.0) *
                      (enemyHit ? 0.96 : 1.0),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (isBoss)
                        CustomPaint(
                          painter: BossAuraPainter(
                            phase: animationTicks * .045,
                            attacking: enemyAttacking,
                          ),
                        )
                      else
                        CustomPaint(
                          painter: EnemyAuraPainter(
                            type: enemyType,
                            phase: enemyPhase,
                            attacking: enemyAttacking,
                            hit: enemyHit,
                          ),
                        ),
                      SpriteSheetFrame(
                        asset: enemyType == 'ranged'
                            ? 'assets/spritesheets/enemy_ranged.svg'
                            : enemyType == 'boss'
                                ? (enemyAttacking
                                    ? 'assets/spritesheets/boss_attack.svg'
                                    : 'assets/spritesheets/boss_walk.svg')
                                : enemyAttacking && enemyType == 'runner'
                                    ? 'assets/spritesheets/enemy_runner_attack.svg'
                                    : enemyAttacking &&
                                            enemyType != 'stalker' &&
                                            enemyType != 'tank' &&
                                            enemyType != 'ranged'
                                        ? 'assets/spritesheets/enemy_melee_attack.svg'
                                        : enemyAttacking && enemyType == 'stalker'
                                            ? 'assets/spritesheets/enemy_stalker_attack.svg'
                                            : enemyAttacking && enemyType == 'tank'
                                                ? 'assets/spritesheets/enemy_tank_attack.svg'
                                                : enemyType == 'runner'
                                                    ? 'assets/spritesheets/enemy_runner.svg'
                                                    : enemyType == 'stalker'
                                                        ? 'assets/spritesheets/enemy_stalker.svg'
                                                        : enemyType == 'tank'
                                                            ? 'assets/spritesheets/enemy_tank.svg'
                                                            : 'assets/spritesheets/enemy_melee.svg',
                        frameCount: 4,
                        frameIndex: enemyAttacking
                            ? (animationTicks ~/ 2) % 4
                            : (walkPhase * 1.8).floor() % 4,
                      ),
                      if (enemyHit)
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.32),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DefeatedEnemySpriteWidget extends StatelessWidget {
  const DefeatedEnemySpriteWidget({super.key, required this.sprite});

  final GameActorData sprite;

  @override
  Widget build(BuildContext context) {
    final life = sprite['life'] as int;
    final size = sprite['boss'] == true ? 104.0 : 66.0;
    return Positioned(
      left: (sprite['x'] as double) - size / 2,
      top: (sprite['y'] as double) - size / 2,
      width: size,
      height: size,
      child: Opacity(
        opacity: (life / 24).clamp(0.0, 1.0),
        child: SpriteSheetFrame(
          asset: sprite['boss'] == true
              ? 'assets/spritesheets/boss_death.svg'
              : sprite['type'] == 'runner'
                  ? 'assets/spritesheets/enemy_runner_death.svg'
                  : sprite['type'] == 'tank'
                      ? 'assets/spritesheets/enemy_tank_death.svg'
                      : sprite['type'] == 'stalker'
                          ? 'assets/spritesheets/enemy_stalker_death.svg'
                          : 'assets/spritesheets/enemy_death.svg',
          frameCount: 4,
          frameIndex: ((24 - life) ~/ 6).clamp(0, 3),
        ),
      ),
    );
  }
}

class CombatEffectSpriteWidget extends StatelessWidget {
  const CombatEffectSpriteWidget({super.key, required this.effect});

  final GameActorData effect;

  @override
  Widget build(BuildContext context) {
    final life = effect['life'] as int;
    final type = effect['type'] as String;
    final radius = type == 'bossTell' || type == 'bossBurst'
        ? 112.0
        : ((type == 'defeat' || type == 'playerHit') ? 42.0 : 29.0);
    final duration = type == 'bossTell'
        ? 32
        : type == 'bossBurst'
            ? 24
            : (type == 'impact' || type.endsWith('Hit') || type == 'enemyAttack')
                ? (type == 'enemyAttack' ? 12 : 16)
                : 25;

    return Positioned(
      left: (effect['x'] as double) - radius,
      top: (effect['y'] as double) - radius,
      child: CustomPaint(
        size: Size(radius * 2, radius * 2),
        painter: CombatEffectPainter(
          type: type,
          progress: (1 - life / duration).clamp(0.0, 1.0),
        ),
      ),
    );
  }
}

class PlayerActorSpriteWidget extends StatelessWidget {
  const PlayerActorSpriteWidget({
    super.key,
    required this.x,
    required this.y,
    required this.heroSpritePrefix,
    required this.animationTicks,
    required this.heroAttackTicks,
    required this.playerMoveTicks,
    required this.playerDying,
    required this.playerDeathTicks,
  });

  final double x;
  final double y;
  final String heroSpritePrefix;
  final int animationTicks;
  final int heroAttackTicks;
  final int playerMoveTicks;
  final bool playerDying;
  final int playerDeathTicks;

  @override
  Widget build(BuildContext context) => Positioned(
        left: x - 21,
        top: y - 21,
        child: SizedBox(
          width: 58,
          height: 58,
          child: Transform.translate(
            offset: Offset(
              heroAttackTicks > 0 ? 3.0 : 0.0,
              math.sin(animationTicks * 0.13).abs() * -2.4,
            ),
            child: Transform.rotate(
              angle: heroAttackTicks > 0
                  ? -0.10 - (heroAttackTicks / 12) * 0.13
                  : math.sin(animationTicks * 0.13) * 0.025,
              child: Transform.scale(
                scale: (1 + math.sin(animationTicks * 0.13) * 0.025) *
                    (heroAttackTicks > 0 ? 1.045 : 1.0),
                child: SpriteSheetFrame(
                  asset: playerDying
                      ? '${heroSpritePrefix}_death.svg'
                      : heroAttackTicks > 0
                          ? '${heroSpritePrefix}_attack.svg'
                          : playerMoveTicks > 0
                              ? '${heroSpritePrefix}_walk.svg'
                              : '${heroSpritePrefix}_idle.svg',
                  frameCount: 4,
                  frameIndex: playerDying
                      ? (playerDeathTicks ~/ 6).clamp(0, 3)
                      : heroAttackTicks > 0
                          ? (animationTicks ~/ 2) % 4
                          : playerMoveTicks > 0
                              ? (animationTicks ~/ 7) % 4
                              : 0,
                ),
              ),
            ),
          ),
        ),
      );
}
