import 'stage_flow.dart';
import 'world_rules.dart';

enum GameRoomType { combat, boss }

class GameRoom {
  const GameRoom({
    required this.stage,
    required this.worldId,
    required this.roomNumber,
    required this.type,
  });

  final int stage;
  final int worldId;
  final int roomNumber;
  final GameRoomType type;

  bool get isBoss => type == GameRoomType.boss;
}

class RoomTransition {
  const RoomTransition({
    required this.currentRoom,
    required this.nextRoom,
    required this.stageAdvance,
  });

  final GameRoom currentRoom;
  final GameRoom nextRoom;
  final StageAdvance stageAdvance;

  bool get changesWorld => currentRoom.worldId != nextRoom.worldId;
}

class RoomFlow {
  const RoomFlow._();

  /// Maps the existing ten-stage world structure into explicit room addresses.
  static GameRoom forStage(int stage) {
    final safeStage = stage < 1 ? 1 : stage;
    final world = WorldRules.forStage(safeStage);
    return GameRoom(
      stage: safeStage,
      worldId: world.worldId,
      roomNumber: ((safeStage - 1) % 10) + 1,
      type: safeStage % 5 == 0 ? GameRoomType.boss : GameRoomType.combat,
    );
  }

  /// Resolves the current encounter's exit and next room without mutating state.
  static RoomTransition complete(int currentStage) {
    final currentRoom = forStage(currentStage);
    final advance = StageFlow.complete(currentRoom.stage);
    return RoomTransition(
      currentRoom: currentRoom,
      nextRoom: forStage(advance.nextStage),
      stageAdvance: advance,
    );
  }
}
