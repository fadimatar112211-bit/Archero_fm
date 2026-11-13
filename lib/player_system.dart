import 'combat_collision.dart';
import 'combat_targeting.dart';
import 'hero_rules.dart';
import 'player_attack.dart';
import 'player_movement.dart';
import 'player_projectiles.dart';

/// Public player-domain target data. GameScreen does not need to depend on
/// combat geometry primitives to move, aim, or advance player projectiles.
class PlayerTarget {
  const PlayerTarget({required this.x, required this.y, this.radius = 0});

  final double x;
  final double y;
  final double radius;
}

/// A player-owned arrow spawn expressed without exposing combat internals.
class PlayerArrowState {
  const PlayerArrowState({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
  });

  final double x;
  final double y;
  final double velocityX;
  final double velocityY;
}

/// Result of advancing one player-owned arrow.
class PlayerArrowUpdate {
  const PlayerArrowUpdate({
    required this.x,
    required this.y,
    required this.shouldRemove,
    required this.hitTargetIndex,
  });

  final double x;
  final double y;
  final bool shouldRemove;
  final int? hitTargetIndex;
}

/// Player-domain boundary for hero setup, movement, aiming and owned arrows.
///
/// Combat geometry and low-level projectile calculations stay behind this
/// facade. The game screen consumes player concepts rather than composing
/// combat primitives directly.
abstract final class PlayerSystem {
  static HeroProfile profileForHero(int heroType) =>
      HeroProfile.forType(heroType);

  static HeroRunStats createRunStats({
    required int heroType,
    required int hpUpgrade,
    required int attackUpgrade,
  }) =>
      createHeroRunStats(
        heroType: heroType,
        hpUpgrade: hpUpgrade,
        attackUpgrade: attackUpgrade,
      );

  static PlayerMovementResolution resolveDrag({
    required double currentX,
    required double currentY,
    required double deltaX,
    required double deltaY,
    required double arenaWidth,
    required double arenaHeight,
    required int currentMoveTicks,
    double movementThresholdSquared = 0.25,
    int dodgeTicks = 8,
  }) =>
      resolvePlayerDrag(
        currentX: currentX,
        currentY: currentY,
        deltaX: deltaX,
        deltaY: deltaY,
        arenaWidth: arenaWidth,
        arenaHeight: arenaHeight,
        currentMoveTicks: currentMoveTicks,
        movementThresholdSquared: movementThresholdSquared,
        dodgeTicks: dodgeTicks,
      );

  static int? nearestTargetIndex({
    required double originX,
    required double originY,
    required List<PlayerTarget> targets,
  }) =>
      _nearestTargetIndex(
        origin: CombatPoint(originX, originY),
        targets: targets.map((target) => CombatPoint(target.x, target.y)).toList(growable: false),
      );

  static List<PlayerArrowState> createArrowVolley({
    required double originX,
    required double originY,
    required double targetX,
    required double targetY,
    required int extraArrows,
    double projectileSpeed = 8.5,
    double spreadAngle = 0.20,
  }) =>
      createPlayerArrowVolley(
        origin: CombatPoint(originX, originY),
        target: CombatPoint(targetX, targetY),
        extraArrows: extraArrows,
        projectileSpeed: projectileSpeed,
        spreadAngle: spreadAngle,
      ).map((shot) => PlayerArrowState(
            x: shot.origin.x,
            y: shot.origin.y,
            velocityX: shot.velocity.x,
            velocityY: shot.velocity.y,
          )).toList(growable: false);

  static PlayerArrowUpdate advanceArrow({
    required double x,
    required double y,
    required double velocityX,
    required double velocityY,
    required double arenaWidth,
    required double arenaHeight,
    List<PlayerTarget> targets = const [],
    double margin = 20,
    double projectileRadius = 5,
  }) {
    final update = advancePlayerProjectile(
      x: x,
      y: y,
      velocityX: velocityX,
      velocityY: velocityY,
      arenaWidth: arenaWidth,
      arenaHeight: arenaHeight,
      margin: margin,
      projectileRadius: projectileRadius,
      targets: targets.map((target) => CombatCircle(
        x: target.x,
        y: target.y,
        radius: target.radius,
      )).toList(growable: false),
    );
    return PlayerArrowUpdate(
      x: update.x,
      y: update.y,
      shouldRemove: update.shouldRemove,
      hitTargetIndex: update.hitTargetIndex,
    );
  }

  static int? _nearestTargetIndex({
    required CombatPoint origin,
    required List<CombatPoint> targets,
  }) =>
      nearestTargetIndex(origin: origin, targets: targets);
}
