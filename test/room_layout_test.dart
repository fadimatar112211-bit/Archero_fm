import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/room_layout.dart';

void main() {
  group('RoomLayout', () {
    test('creates four deterministic floor plan variants', () {
      final layouts = List.generate(4, (index) => RoomLayout.forStage(index + 1));
      expect(layouts.map((layout) => layout.variant).toSet(), {0, 1, 2, 3});
      expect(layouts.every((layout) => layout.props.isNotEmpty), isTrue);
      expect(layouts.map((layout) => layout.name).toSet().length, 4);
      expect(RoomLayout.forStage(1).props.first.centerX,
          RoomLayout.forStage(5).props.first.centerX);
    });

    test('assigns a world-specific environmental hazard', () {
      expect(RoomLayout.forStage(1).hazard.kind, RoomHazardKind.thorns);
      expect(RoomLayout.forStage(11).hazard.kind, RoomHazardKind.lava);
      expect(RoomLayout.forStage(21).hazard.kind, RoomHazardKind.frost);
      expect(RoomLayout.forStage(31).hazard.kind, RoomHazardKind.sand);
      expect(RoomLayout.forStage(41).hazard.kind, RoomHazardKind.shadow);
      expect(RoomLayout.forStage(51).hazard.kind, RoomHazardKind.storm);
    });

    test('detects player overlap with the room hazard in viewport coordinates', () {
      final layout = RoomLayout.forStage(1);
      expect(layout.playerTouchesHazard(
        x: 180, y: 358.4, arenaWidth: 360, arenaHeight: 640,
      ), isTrue);
      expect(layout.playerTouchesHazard(
        x: 180, y: 520, arenaWidth: 360, arenaHeight: 640,
      ), isFalse);
    });

    test('normalizes invalid stages and rejects invalid viewport data', () {
      final layout = RoomLayout.forStage(0);
      expect(layout.stage, 1);
      expect(layout.playerTouchesHazard(
        x: double.nan, y: 20, arenaWidth: 360, arenaHeight: 640,
      ), isFalse);
    });
  });
}
