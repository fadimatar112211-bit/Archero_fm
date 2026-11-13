import 'world_rules.dart';
import 'world_theme.dart';

/// Unlock rules for the six ten-stage worlds.
///
/// [bestStage] is the next stage made available by persistent progression:
/// a player who has cleared stage 10 has bestStage == 11 and can enter world 2.
class WorldStageProgression {
  const WorldStageProgression({required this.bestStage});

  static const int stagesPerWorld = 10;
  static const int totalStages = WorldRules.all.length * stagesPerWorld;

  final int bestStage;

  int get maxUnlockedStage => bestStage.clamp(1, totalStages).toInt();

  int get maxUnlockedWorld =>
      ((maxUnlockedStage - 1) ~/ stagesPerWorld) + 1;

  bool isStageUnlocked(int stage) =>
      stage >= 1 && stage <= totalStages && stage <= maxUnlockedStage;

  bool isWorldUnlocked(int worldId) {
    if (worldId < 1 || worldId > WorldRules.all.length) return false;
    final firstStage = ((worldId - 1) * stagesPerWorld) + 1;
    return isStageUnlocked(firstStage);
  }

  int firstStageOfWorld(int worldId) {
    _validateWorldId(worldId);
    return ((worldId - 1) * stagesPerWorld) + 1;
  }

  int lastStageOfWorld(int worldId) {
    _validateWorldId(worldId);
    return worldId * stagesPerWorld;
  }

  List<int> stagesForWorld(int worldId) {
    _validateWorldId(worldId);
    return List<int>.generate(
      stagesPerWorld,
      (index) => firstStageOfWorld(worldId) + index,
      growable: false,
    );
  }

  WorldTheme themeForWorld(int worldId) {
    _validateWorldId(worldId);
    return WorldTheme.all[worldId - 1];
  }

  WorldRules rulesForWorld(int worldId) {
    _validateWorldId(worldId);
    return WorldRules.all[worldId - 1];
  }

  void _validateWorldId(int worldId) {
    if (worldId < 1 || worldId > WorldRules.all.length) {
      throw RangeError.range(worldId, 1, WorldRules.all.length, 'worldId');
    }
  }
}
