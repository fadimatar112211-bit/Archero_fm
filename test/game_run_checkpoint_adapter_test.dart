import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/game_run_checkpoint_adapter.dart';
import 'package:archero_fm/game_run_state.dart';
import 'package:archero_fm/run_checkpoint.dart';
import 'package:archero_fm/skill_system.dart';

void main() {
  test('captures and restores a complete active run snapshot', () {
    final run = GameRunState(initialStage: 6)
      ..arenaWidth = 400
      ..arenaHeight = 700
      ..arenaInitialized = true
      ..playerX = 145
      ..playerY = 510
      ..playerHp = 72
      ..playerMaxHp = 125
      ..score = 840
      ..animationTicks = 550
      ..challengeRoomRewardPending = true
      ..roomHazardCooldownTicks = 12;
    run.selectedSkills.addAll([SkillId.extraArrow, SkillId.vitality]);
    run.activeSkillSynergies.add(SkillSynergyId.treasureHeart);
    run.enemies.add({
      'type': 'boss',
      'x': 200.0,
      'y': 160.0,
      'hp': 450.0,
      'maxHp': 900.0,
      'attackCooldown': 30,
    });
    run.coins.add({'x': 120.0, 'y': 240.0});

    final checkpoint = captureRunCheckpoint(
      heroType: 4,
      run: run,
    );
    final decoded = RunCheckpoint.decode(checkpoint.encode())!;
    final restored = restoreRunCheckpointState(decoded)!;

    expect(decoded.state['hazardCooldownTicks'], 12);
    expect(restored.stage, 6);
    expect(restored.playerHp, 72);
    expect(restored.playerMaxHp, 125);
    expect(restored.score, 840);
    expect(restored.challengeRoomRewardPending, isTrue);
    expect(restored.selectedSkills, [SkillId.extraArrow, SkillId.vitality]);
    expect(restored.activeSkillSynergies, {SkillSynergyId.treasureHeart});
    expect(restored.enemies.single['type'], 'boss');
    expect(restored.coins.single['x'], 120.0);
  });

  test('restores version-1 checkpoints created before room hazard cooldown existed', () {
    final current = captureRunCheckpoint(
      heroType: 2,
      run: GameRunState(initialStage: 3),
    );
    final legacy = RunCheckpoint(
      heroType: current.heroType,
      stage: current.stage,
      state: Map<String, Object?>.from(current.state)
        ..remove('hazardCooldownTicks'),
    );

    final restored = restoreRunCheckpointState(legacy);
    expect(restored, isNotNull);
    expect(restored!.stage, 3);
    expect(restored.roomHazardCooldownTicks, 0);
  });

  test('rejects structurally invalid run state instead of restoring partial data', () {
    final checkpoint = RunCheckpoint(
      heroType: 1,
      stage: 2,
      state: {'playerHp': 20},
    );
    expect(restoreRunCheckpointState(checkpoint), isNull);
  });
}
