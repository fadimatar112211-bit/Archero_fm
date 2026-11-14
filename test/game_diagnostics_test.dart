import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/game_diagnostics.dart';

void main() {
  test('diagnostic reporting is non-throwing', () {
    expect(
      () => GameDiagnostics.record(
        'unit-test',
        StateError('simulated diagnostic event'),
        StackTrace.current,
      ),
      returnsNormally,
    );
  });
}
