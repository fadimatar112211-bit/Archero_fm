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

    test('disposes lifecycle and all timers with the session', () {
      final session = GameRunSession();
      session.timers.periodic('owned', const Duration(hours: 1), () {});

      session.dispose();

      expect(session.isDisposed, isTrue);
      expect(session.lifecycle.isGameOver, isTrue);
      expect(session.timers.isDisposed, isTrue);
      expect(session.timers.activeTimerCount, 0);
    });

    test('keeps separate sessions isolated', () {
      final first = GameRunSession(initialStage: 3);
      final second = GameRunSession(initialStage: 8);
      first.state.enemies.add({'hp': 1});
      first.lifecycle.finishRun();

      expect(first.isTerminal, isTrue);
      expect(second.isTerminal, isFalse);
      expect(second.state.stage, 8);
      expect(second.state.enemies, isEmpty);
    });
  });
}
