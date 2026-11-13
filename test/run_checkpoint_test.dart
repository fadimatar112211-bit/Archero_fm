import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:archero_fm/run_checkpoint.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('round-trips a versioned run checkpoint with entity collections', () {
    final checkpoint = RunCheckpoint(
      heroType: 3,
      stage: 7,
      state: {
        'playerHp': 62.5,
        'playerX': 120.0,
        'selectedSkills': ['extraArrow', 'vitality'],
        'enemies': [
          {'type': 'boss', 'x': 90.0, 'hp': 420.0, 'attackCooldown': 35},
        ],
      },
      savedAtEpochMs: 123456,
    );

    final restored = RunCheckpoint.decode(checkpoint.encode());
    expect(restored, isNotNull);
    expect(restored!.heroType, 3);
    expect(restored.stage, 7);
    expect(restored.savedAtEpochMs, 123456);
    expect(restored.state['playerHp'], 62.5);
    expect((restored.state['enemies'] as List).single['type'], 'boss');
  });

  test('rejects malformed, unsupported, and unsafe checkpoint payloads', () {
    expect(RunCheckpoint.decode('{broken'), isNull);
    expect(RunCheckpoint.decode('{"version":99}'), isNull);
    expect(
      RunCheckpoint.decode(
        '{"version":1,"heroType":8,"stage":1,"state":{}}',
      ),
      isNull,
    );
    expect(
      () => RunCheckpoint(
        heroType: 1,
        stage: 1,
        state: {'invalid': double.infinity},
      ).encode(),
      throwsA(anything),
    );
  });

  test('persists, loads, and clears the active run checkpoint', () async {
    final checkpoint = RunCheckpoint(
      heroType: 2,
      stage: 4,
      state: {'score': 900, 'coins': 120},
    );

    await RunCheckpointStore.save(checkpoint);
    final restored = await RunCheckpointStore.load();
    expect(restored, isNotNull);
    expect(restored!.heroType, 2);
    expect(restored.stage, 4);
    expect(restored.state['score'], 900);

    await RunCheckpointStore.clear();
    expect(await RunCheckpointStore.load(), isNull);
  });

  test('ignores corrupted persisted checkpoint without crashing startup', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(RunCheckpoint.storageKey, 'not-json');
    expect(await RunCheckpointStore.load(), isNull);
    expect(prefs.containsKey(RunCheckpoint.storageKey), isFalse);
  });
  test('discards a checkpoint stored with the wrong preference type', () async {
    SharedPreferences.setMockInitialValues({
      RunCheckpoint.storageKey: 12345,
      'coins': 900,
    });
    expect(await RunCheckpointStore.load(), isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey(RunCheckpoint.storageKey), isFalse);
    expect(prefs.getInt('coins'), 900);
  });
}

