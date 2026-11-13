import 'game_run_lifecycle.dart';
import 'game_run_state.dart';
import 'game_timers.dart';

/// Single owner for the data and lifecycle of one active game session.
class GameRunSession {
  GameRunSession({int initialStage = 1})
      : state = GameRunState(initialStage: initialStage),
        lifecycle = GameRunLifecycle(),
        timers = GameTimerRegistry();

  final GameRunState state;
  final GameRunLifecycle lifecycle;
  final GameTimerRegistry timers;

  bool _disposed = false;
  bool get isDisposed => _disposed;
  bool get isTerminal => lifecycle.isGameOver;

  /// Ends this run and releases every timer owned by it.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    lifecycle.finishRun();
    timers.dispose();
  }
}
