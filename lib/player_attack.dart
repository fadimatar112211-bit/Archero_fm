import 'combat_targeting.dart';

class PlayerArrowSpawn {
  const PlayerArrowSpawn({
    required this.origin,
    required this.velocity,
  });

  final CombatPoint origin;
  final CombatPoint velocity;
}

/// Builds the player's existing aimed arrow volley, including its alternating
/// spread pattern, without depending on widget or game-loop state.
List<PlayerArrowSpawn> createPlayerArrowVolley({
  required CombatPoint origin,
  required CombatPoint target,
  required int extraArrows,
  double projectileSpeed = 8.5,
  double spreadAngle = 0.20,
}) {
  final totalShots = 1 + extraArrows;
  if (totalShots <= 0) return const [];

  return List<PlayerArrowSpawn>.generate(totalShots, (index) {
    final spread = index == 0
        ? 0.0
        : (index.isOdd ? spreadAngle : -spreadAngle);
    return PlayerArrowSpawn(
      origin: origin,
      velocity: aimedProjectileVelocity(
        origin: origin,
        target: target,
        speed: projectileSpeed,
        angleOffset: spread,
      ),
    );
  }, growable: false);
}
