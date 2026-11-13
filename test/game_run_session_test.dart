import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/game_run_lifecycle.dart';
import 'package:archero_fm/game_run_session.dart';

void main() {
  group('GameRunSession', () {
    test('owns matching state and lifecycle for the requested initial stage', () {
      final session = GameRunSession(initialStage: 6);
      expect(session.state.stage, 6);
      expect(session.lifecycle.phase, GameRunPhase.active);
      expect(session.isTerminal, isFalse);
    });

    test('keeps separate sessions isolated', () {
      final first = GameRunSession(initialStage: 3);
      final second = GameRunSession(initialStage: 8);
      first.state.coins.add({'value': 1});
      first.lifecycle.finishRun();

      expect(first.isTerminal, isTrue);
      expect(second.isTerminal, isFalse);
      expect(second.state.stage, 8);
      expect(second.state.coins, isEmpty);
    });
  });
}
