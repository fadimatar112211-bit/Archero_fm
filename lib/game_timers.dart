import 'dart:async';

/// Owns periodic timers for one game screen and guarantees that replaced or
/// disposed timers cannot continue invoking their callbacks.
class GameTimerRegistry {
  final Map<String, Timer> _timers = {};
  bool _disposed = false;

  bool get isDisposed => _disposed;
  int get activeTimerCount => _timers.length;

  void periodic(
    String key,
    Duration interval,
    void Function() callback,
  ) {
    if (_disposed) {
      throw StateError('Cannot schedule a timer after disposal.');
    }
    cancel(key);

    late final Timer timer;
    timer = Timer.periodic(interval, (_) {
      if (_disposed || !identical(_timers[key], timer)) return;
      callback();
    });
    _timers[key] = timer;
  }

  void cancel(String key) {
    _timers.remove(key)?.cancel();
  }

  void cancelAll() {
    final active = _timers.values.toList(growable: false);
    _timers.clear();
    for (final timer in active) {
      timer.cancel();
    }
  }

  void dispose() {
    if (_disposed) return;
    cancelAll();
    _disposed = true;
  }
}
