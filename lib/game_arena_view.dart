import 'package:flutter/material.dart';

import 'game_actor_widgets.dart';
import 'game_overlay_widgets.dart';
import 'game_painters.dart';
import 'world_theme.dart';

/// Flutter-only presentation for an active arena.
///
/// The widget receives a read-only snapshot of run data and reports user
/// intent through callbacks. It does not own combat rules, timers, progression,
/// or mutable game state.
class GameArenaView extends StatelessWidget {
  const GameArenaView({
    super.key,
    required this.stage,
    required this.score,
    required this.coins,
    required this.isPaused,
    required this.playerHp,
    required this.playerMaxHp,
    required this.worldAnimation,
    required this.worldTheme,
    required this.coinActors,
    required this.playerArrows,
    required this.enemyProjectiles,
    required this.enemies,
    required this.defeatedSprites,
    required this.combatEffects,
    required this.playerX,
    required this.playerY,
    required this.heroSpritePrefix,
    required this.animationTicks,
    required this.heroAttackTicks,
    required this.playerMoveTicks,
    required this.playerDying,
    required this.playerDeathTicks,
    required this.specialCooldown,
    required this.showMysteryChest,
    required this.onArenaSizeChanged,
    required this.onPlayerDrag,
    required this.onPause,
    required this.onSpecialSkill,
    required this.onCollectChest,
  });

  final int stage;
  final int score;
  final int coins;
  final bool isPaused;
  final double playerHp;
  final double playerMaxHp;
  final Animation<double> worldAnimation;
  final WorldTheme worldTheme;
  final List<Map<String, dynamic>> coinActors;
  final List<Map<String, dynamic>> playerArrows;
  final List<Map<String, dynamic>> enemyProjectiles;
  final List<Map<String, dynamic>> enemies;
  final List<Map<String, dynamic>> defeatedSprites;
  final List<Map<String, dynamic>> combatEffects;
  final double playerX;
  final double playerY;
  final String heroSpritePrefix;
  final int animationTicks;
  final int heroAttackTicks;
  final int playerMoveTicks;
  final bool playerDying;
  final int playerDeathTicks;
  final int specialCooldown;
  final bool showMysteryChest;
  final void Function(double width, double height) onArenaSizeChanged;
  final void Function(Offset delta, double width, double height) onPlayerDrag;
  final VoidCallback onPause;
  final VoidCallback onSpecialSkill;
  final VoidCallback onCollectChest;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            onArenaSizeChanged(width, height);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) =>
                  onPlayerDrag(details.delta, width, height),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF202638), Color(0xFF10131C)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: ArenaPainter(
                          theme: worldTheme,
                          animation: worldAnimation,
                        ),
                      ),
                    ),
                  ),
                  GameHudWidget(
                    stage: stage,
                    score: score,
                    coins: coins,
                    isPaused: isPaused,
                    playerHp: playerHp,
                    playerMaxHp: playerMaxHp,
                    onPause: onPause,
                  ),
                  ...coinActors.map((coin) => CoinSpriteWidget(coin: coin)),
                  ...playerArrows
                      .map((arrow) => PlayerArrowSpriteWidget(arrow: arrow)),
                  ...enemyProjectiles.map(
                    (shot) => EnemyProjectileSpriteWidget(
                      projectile: shot,
                      animationTicks: animationTicks,
                    ),
                  ),
                  ...enemies.map(
                    (enemy) => EnemyActorWidget(
                      enemy: enemy,
                      animationTicks: animationTicks,
                    ),
                  ),
                  ...defeatedSprites.map(
                    (sprite) => DefeatedEnemySpriteWidget(sprite: sprite),
                  ),
                  ...combatEffects.map(
                    (effect) => CombatEffectSpriteWidget(effect: effect),
                  ),
                  PlayerActorSpriteWidget(
                    x: playerX,
                    y: playerY,
                    heroSpritePrefix: heroSpritePrefix,
                    animationTicks: animationTicks,
                    heroAttackTicks: heroAttackTicks,
                    playerMoveTicks: playerMoveTicks,
                    playerDying: playerDying,
                    playerDeathTicks: playerDeathTicks,
                  ),
                  Positioned(
                    right: 15,
                    bottom: 20,
                    child: FilledButton.icon(
                      onPressed: onSpecialSkill,
                      style: FilledButton.styleFrom(
                        backgroundColor: specialCooldown == 0
                            ? Colors.deepPurple
                            : Colors.grey.shade800,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(
                        specialCooldown == 0
                            ? 'المهارة الخاصة'
                            : 'انتظر $specialCooldown',
                      ),
                    ),
                  ),
                  if (isPaused) GamePauseOverlay(onResume: onPause),
                  if (showMysteryChest)
                    MysteryChestOverlay(onCollect: onCollectChest),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
