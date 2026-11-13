import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/room_flow.dart';
import 'package:archero_fm/stage_flow.dart';

void main() {
  group('RoomFlow', () {
    test('maps stages to ten-room world addresses', () {
      final first = RoomFlow.forStage(1);
      final tenth = RoomFlow.forStage(10);
      final eleventh = RoomFlow.forStage(11);

      expect(first.worldId, 1);
      expect(first.roomNumber, 1);
      expect(first.type, GameRoomType.combat);
      expect(tenth.worldId, 1);
      expect(tenth.roomNumber, 10);
      expect(tenth.type, GameRoomType.boss);
      expect(eleventh.worldId, 2);
      expect(eleventh.roomNumber, 1);
    });

    test('marks every fifth stage as a boss room', () {
      for (var stage = 1; stage <= 60; stage++) {
        expect(
          RoomFlow.forStage(stage).isBoss,
          stage % 5 == 0,
          reason: 'stage $stage',
        );
      }
    });

    test('transitions to the next room and preserves reward cadence', () {
      final transition = RoomFlow.complete(4);

      expect(transition.currentRoom.stage, 4);
      expect(transition.currentRoom.roomNumber, 4);
      expect(transition.nextRoom.stage, 5);
      expect(transition.nextRoom.roomNumber, 5);
      expect(transition.nextRoom.isBoss, isTrue);
      expect(transition.stageAdvance.reward, StageRewardType.skillChoice);
      expect(transition.changesWorld, isFalse);
    });

    test('reports world boundary transitions', () {
      final transition = RoomFlow.complete(10);

      expect(transition.currentRoom.worldId, 1);
      expect(transition.nextRoom.worldId, 2);
      expect(transition.nextRoom.roomNumber, 1);
      expect(transition.changesWorld, isTrue);
    });

    test('normalizes invalid stage inputs', () {
      final room = RoomFlow.forStage(0);
      expect(room.stage, 1);
      expect(room.worldId, 1);
      expect(room.roomNumber, 1);
    });
  });
}
