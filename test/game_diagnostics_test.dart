import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/game_diagnostics.dart';

void main() {
  setUp(GameDiagnostics.clear);

  group('GameDiagnostics', () {
    test('records error source, message, timestamp and stack trace', () {
      final stack = StackTrace.current;

      GameDiagnostics.record(
        StateError('save failed'),
        stack,
        source: 'progress_store',
      );

      expect(GameDiagnostics.entries, hasLength(1));
      final entry = GameDiagnostics.entries.single;
      expect(entry.source, 'progress_store');
      expect(entry.message, contains('save failed'));
      expect(entry.stackTrace, stack.toString());
      expect(entry.timestamp, isA<DateTime>());
    });

    test('keeps only the newest bounded set of diagnostics', () {
      for (var index = 0; index < GameDiagnostics.maxEntries + 2; index++) {
        GameDiagnostics.record(
          Exception('error $index'),
          StackTrace.current,
          source: 'test',
        );
      }

      expect(GameDiagnostics.entries, hasLength(GameDiagnostics.maxEntries));
      expect(GameDiagnostics.entries.first.message, contains('error 2'));
      expect(GameDiagnostics.entries.last.message, contains('error 51'));
    });

    test('exposes an immutable snapshot', () {
      GameDiagnostics.record(
        Exception('sample'),
        StackTrace.current,
        source: 'test',
      );

      expect(
        () => GameDiagnostics.entries.clear(),
        throwsUnsupportedError,
      );
    });
  });
}
