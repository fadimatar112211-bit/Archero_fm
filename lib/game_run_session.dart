import 'game_run_lifecycle.dart';
import 'game_run_state.dart';

/// Single owner for the data and lifecycle of one active game session.
class GameRunSession {
  GameRunSession({int initialStage = 1})
      : state = GameRunState(initialStage: initialStage),
        lifecycle = GameRunLifecycle();

  final GameRunState state;
  final GameRunLifecycle lifecycle;

  bool get isTerminal => lifecycle.isGameOver;
}
