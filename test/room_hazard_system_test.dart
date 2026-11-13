import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/room_hazard_system.dart';
import 'package:archero_fm/room_layout.dart';

void main() {
  final layout = RoomLayout.forStage(1);

  RoomHazardResolution resolve({
    int cooldown = 0,
    double hp = 100,
    bool dodging = false,
    double reduction = 0,
    double x = 180,
    double y = 358.4,
  }) => RoomHazardSystem.advance(
        layout: layout,
        cooldownTicks: cooldown,
        x: x,
        y: y,
        arenaWidth: 360,
        arenaHeight: 640,
        playerHp: hp,
        playerMaxHp: 100,
        playerIsDodging: dodging,
        damageReduction: reduction,
      );

  group('RoomHazardSystem', () {
    test('applies the original hazard damage and starts its tick cooldown', () {
      final result = resolve();
      expect(result.status, RoomHazardStatus.damaged);
      expect(result.playerHp, 92);
      expect(result.damageApplied, 8);
      expect(result.cooldownTicks, 45);
    });

    test('movement invulnerability dodges hazard damage but still starts cooldown', () {
      final result = resolve(dodging: true);
      expect(result.status, RoomHazardStatus.dodged);
      expect(result.playerHp, 100);
      expect(result.damageApplied, 0);
      expect(result.cooldownTicks, 45);
    });

    test('respects equipment damage reduction and clamps lethal damage', () {
      final reduced = resolve(reduction: .25);
      expect(reduced.playerHp, 94);
      expect(reduced.damageApplied, 6);
      final lethal = resolve(hp: 3);
      expect(lethal.playerHp, 0);
      expect(lethal.damageApplied, 3);
    });

    test('counts down cooldown before allowing another hazard hit', () {
      final cooling = resolve(cooldown: 2);
      expect(cooling.status, RoomHazardStatus.coolingDown);
      expect(cooling.cooldownTicks, 1);
      expect(cooling.playerHp, 100);
      final ready = resolve(cooldown: 1);
      expect(ready.status, RoomHazardStatus.damaged);
      expect(ready.cooldownTicks, 45);
    });

    test('safe positions and invalid geometry do not apply damage', () {
      final safe = resolve(x: 180, y: 520);
      expect(safe.status, RoomHazardStatus.safe);
      expect(safe.cooldownTicks, 0);
      final invalid = RoomHazardSystem.advance(
        layout: layout,
        cooldownTicks: 0,
        x: double.nan,
        y: 0,
        arenaWidth: 360,
        arenaHeight: 640,
        playerHp: 100,
        playerMaxHp: 100,
        playerIsDodging: false,
      );
      expect(invalid.status, RoomHazardStatus.safe);
      expect(invalid.playerHp, 100);
    });
  });
}
