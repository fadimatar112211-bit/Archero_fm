import 'game_run_state.dart';
import 'run_checkpoint.dart';
import 'skill_system.dart';

/// Converts the mutable in-memory run into a stable, JSON-safe snapshot.
RunCheckpoint captureRunCheckpoint({
  required int heroType,
  required GameRunState run,
}) {
  return RunCheckpoint(
    heroType: heroType,
    stage: run.stage,
    state: {
      'arenaWidth': run.arenaWidth,
      'arenaHeight': run.arenaHeight,
      'arenaInitialized': run.arenaInitialized,
      'playerX': run.playerX,
      'playerY': run.playerY,
      'playerHp': run.playerHp,
      'playerMaxHp': run.playerMaxHp,
      'playerSpeed': run.playerSpeed,
      'lastDamageAt': run.lastDamageAt?.millisecondsSinceEpoch,
      'attackPowerMultiplier': run.attackPowerMultiplier,
      'extraArrows': run.extraArrows,
      'criticalChance': run.criticalChance,
      'attackSpeedMultiplier': run.attackSpeedMultiplier,
      'enemySpeedMultiplier': run.enemySpeedMultiplier,
      'coinPickupRadius': run.coinPickupRadius,
      'animationTicks': run.animationTicks,
      'heroAttackTicks': run.heroAttackTicks,
      'playerMoveTicks': run.playerMoveTicks,
      'selectedSkills': run.selectedSkills.map((value) => value.name).toList(),
      'activeSkillSynergies':
          run.activeSkillSynergies.map((value) => value.name).toList(),
      'combatEffects': _copyEntities(run.combatEffects),
      'defeatedSprites': _copyEntities(run.defeatedSprites),
      'score': run.score,
      'specialCooldown': run.specialCooldown,
      'playerDeathTicks': run.playerDeathTicks,
      'challengeRoomRewardPending': run.challengeRoomRewardPending,
      'enemies': _copyEntities(run.enemies),
      'arrows': _copyEntities(run.arrows),
      'enemyProjectiles': _copyEntities(run.enemyProjectiles),
      'coins': _copyEntities(run.coins),
      'hazardCooldownTicks': run.roomHazardCooldownTicks,
    },
  );
}

/// Restores only a structurally valid checkpoint. Unknown/malformed values
/// return null so callers can safely fall back to a fresh run.
GameRunState? restoreRunCheckpointState(RunCheckpoint checkpoint) {
  final data = checkpoint.state;
  try {
    final hazardCooldown = data['hazardCooldownTicks'];
    final lastDamageAt = data['lastDamageAt'];
    if (hazardCooldown is! int || hazardCooldown < 0 ||
        data['arenaInitialized'] is! bool ||
        data['challengeRoomRewardPending'] is! bool ||
        (lastDamageAt != null && lastDamageAt is! int)) {
      return null;
    }
    final run = GameRunState(initialStage: checkpoint.stage);
    run.arenaWidth = _number(data, 'arenaWidth');
    run.arenaHeight = _number(data, 'arenaHeight');
    run.arenaInitialized = data['arenaInitialized'] == true;
    run.playerX = _number(data, 'playerX');
    run.playerY = _number(data, 'playerY');
    run.playerHp = _number(data, 'playerHp');
    run.playerMaxHp = _number(data, 'playerMaxHp');
    run.playerSpeed = _number(data, 'playerSpeed');
    run.lastDamageAt = lastDamageAt is int
        ? DateTime.fromMillisecondsSinceEpoch(lastDamageAt)
        : null;
    run.attackPowerMultiplier = _number(data, 'attackPowerMultiplier');
    run.extraArrows = _integer(data, 'extraArrows');
    run.criticalChance = _number(data, 'criticalChance');
    run.attackSpeedMultiplier = _number(data, 'attackSpeedMultiplier');
    run.enemySpeedMultiplier = _number(data, 'enemySpeedMultiplier');
    run.coinPickupRadius = _number(data, 'coinPickupRadius');
    run.animationTicks = _integer(data, 'animationTicks');
    run.heroAttackTicks = _integer(data, 'heroAttackTicks');
    run.playerMoveTicks = _integer(data, 'playerMoveTicks');
    run.score = _integer(data, 'score');
    run.specialCooldown = _integer(data, 'specialCooldown');
    run.playerDeathTicks = _integer(data, 'playerDeathTicks');
    run.roomHazardCooldownTicks = hazardCooldown;
    run.challengeRoomRewardPending = data['challengeRoomRewardPending'] == true;

    run.selectedSkills
      ..clear()
      ..addAll(_enumValues<SkillId>(data['selectedSkills'], SkillId.values));
    run.activeSkillSynergies
      ..clear()
      ..addAll(_enumValues<SkillSynergyId>(
          data['activeSkillSynergies'], SkillSynergyId.values));
    _restoreEntities(run.combatEffects, data['combatEffects']);
    _restoreEntities(run.defeatedSprites, data['defeatedSprites']);
    _restoreEntities(run.enemies, data['enemies']);
    _restoreEntities(run.arrows, data['arrows']);
    _restoreEntities(run.enemyProjectiles, data['enemyProjectiles']);
    _restoreEntities(run.coins, data['coins']);

    if (run.arenaWidth <= 0 ||
        run.arenaHeight <= 0 ||
        run.playerMaxHp <= 0 ||
        run.playerHp < 0 ||
        run.playerHp > run.playerMaxHp ||
        run.playerX < 0 ||
        run.playerX > run.arenaWidth ||
        run.playerY < 0 ||
        run.playerY > run.arenaHeight) {
      return null;
    }
    return run;
  } catch (_) {
    return null;
  }
}

double _number(Map<String, Object?> data, String key) {
  final value = data[key];
  if (value is! num || !value.toDouble().isFinite) {
    throw FormatException('Invalid run checkpoint field: $key');
  }
  return value.toDouble();
}

int _integer(Map<String, Object?> data, String key) {
  final value = data[key];
  if (value is! int || value < 0) {
    throw FormatException('Invalid run checkpoint field: $key');
  }
  return value;
}

List<T> _enumValues<T extends Enum>(
  Object? raw,
  List<T> values,
) {
  if (raw is! List) throw const FormatException('Invalid enum list');
  final result = <T>[];
  for (final item in raw) {
    if (item is! String) throw const FormatException('Invalid enum value');
    result.add(values.firstWhere((value) => value.name == item));
  }
  return result;
}

void _restoreEntities(List<GameRunEntity> target, Object? raw) {
  if (raw is! List) throw const FormatException('Invalid entity collection');
  for (final item in raw) {
    if (item is! Map || item.keys.any((key) => key is! String)) {
      throw const FormatException('Invalid entity');
    }
    target.add(Map<String, dynamic>.from(item));
  }
}

List<Map<String, Object?>> _copyEntities(List<GameRunEntity> entities) => [
  for (final entity in entities) Map<String, Object?>.from(entity),
];
