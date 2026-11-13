import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/game_diagnostics.dart';
import 'package:archero_fm/game_progress.dart';
import 'package:archero_fm/progress_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GameDiagnostics.clear();
    ProgressStore.setPreferencesProviderForTesting(
      () async => throw StateError('simulated storage unavailable'),
    );
  });

  tearDown(() {
    ProgressStore.resetForTesting();
    GameDiagnostics.clear();
  });

  test('safe gameplay save contains storage failures and records diagnostics',
      () async {
    final saved = await saveProgressSafely();

    expect(saved, isFalse);
    expect(GameDiagnostics.entries, hasLength(1));
    expect(GameDiagnostics.entries.single.source, 'progress_save');
    expect(
      GameDiagnostics.entries.single.message,
      contains('simulated storage unavailable'),
    );
  });

  test('strict save still reports persistence failures to its caller',
      () async {
    await expectLater(saveProgress(), throwsA(isA<StateError>()));
    expect(GameDiagnostics.entries, hasLength(1));
  });
}
