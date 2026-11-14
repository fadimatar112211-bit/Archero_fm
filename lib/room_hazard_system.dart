import 'room_layout.dart';

enum RoomHazardStatus { coolingDown, safe, dodged, damaged }

class RoomHazardResolution {
  const RoomHazardResolution({
    required this.status,
    required this.cooldownTicks,
    required this.playerHp,
    required this.damageApplied,
  });

  final RoomHazardStatus status;
  final int cooldownTicks;
  final double playerHp;
  final double damageApplied;
}

/// Resolves one simulation tick against the current room's environmental
/// hazard. The caller owns presentation effects and timestamps.
class RoomHazardSystem {
  const RoomHazardSystem._();

  static const int defaultCooldownTicks = 45;
  static const double defaultDamage = 8;

  static RoomHazardResolution advance({
    required RoomLayout layout,
    required int cooldownTicks,
    required double x,
    required double y,
    required double arenaWidth,
    required double arenaHeight,
    required double playerHp,
    required double playerMaxHp,
    required bool playerIsDodging,
    double damageReduction = 0,
  }) {
    final nextCooldown = cooldownTicks > 0 ? cooldownTicks - 1 : 0;
    final safeHp = playerHp.isFinite ? playerHp : 0.0;

    if (nextCooldown > 0) {
      return RoomHazardResolution(
        status: RoomHazardStatus.coolingDown,
        cooldownTicks: nextCooldown,
        playerHp: safeHp,
        damageApplied: 0,
      );
    }

    if (!layout.playerTouchesHazard(
      x: x,
      y: y,
      arenaWidth: arenaWidth,
      arenaHeight: arenaHeight,
    )) {
      return RoomHazardResolution(
        status: RoomHazardStatus.safe,
        cooldownTicks: 0,
        playerHp: safeHp,
        damageApplied: 0,
      );
    }

    if (playerIsDodging) {
      return RoomHazardResolution(
        status: RoomHazardStatus.dodged,
        cooldownTicks: defaultCooldownTicks,
        playerHp: safeHp,
        damageApplied: 0,
      );
    }

    final safeMaxHp = playerMaxHp.isFinite && playerMaxHp > 0
        ? playerMaxHp
        : 0.0;
    final reduction = damageReduction.isFinite
        ? damageReduction.clamp(0.0, 1.0).toDouble()
        : 0.0;
    final damage = defaultDamage * (1 - reduction);
    final nextHp = (safeHp - damage).clamp(0.0, safeMaxHp).toDouble();
    return RoomHazardResolution(
      status: RoomHazardStatus.damaged,
      cooldownTicks: defaultCooldownTicks,
      playerHp: nextHp,
      damageApplied: (safeHp - nextHp).clamp(0.0, double.infinity).toDouble(),
    );
  }
}
