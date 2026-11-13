import 'package:flutter/foundation.dart';

/// A bounded in-memory record of unexpected game/application errors.
///
/// The service intentionally has no external reporting dependency. It keeps
/// recent diagnostics available during the current process and writes them to
/// Flutter's debug log so failures are not silently swallowed.
class GameErrorEntry {
  const GameErrorEntry({
    required this.timestamp,
    required this.source,
    required this.message,
    required this.stackTrace,
  });

  final DateTime timestamp;
  final String source;
  final String message;
  final String stackTrace;
}

class GameDiagnostics {
  GameDiagnostics._();

  static const int maxEntries = 50;
  static final List<GameErrorEntry> _entries = [];

  static List<GameErrorEntry> get entries =>
      List<GameErrorEntry>.unmodifiable(_entries);

  static void record(
    Object error,
    StackTrace stackTrace, {
    required String source,
  }) {
    final entry = GameErrorEntry(
      timestamp: DateTime.now(),
      source: source,
      message: error.toString(),
      stackTrace: stackTrace.toString(),
    );
    _entries.add(entry);
    if (_entries.length > maxEntries) {
      _entries.removeRange(0, _entries.length - maxEntries);
    }
    debugPrint(
      '[GameDiagnostics][$source] ${entry.message}\n${entry.stackTrace}',
    );
  }

  @visibleForTesting
  static void clear() => _entries.clear();
}
