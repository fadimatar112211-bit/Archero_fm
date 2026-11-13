import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:archero_fm/progress_store.dart';

class _FakeProgressPreferences implements ProgressPreferences {
  final Map<String, int> values = {};
  String? failKey;
  bool returnFalse = false;
  bool writeBeforeFailure = false;
  bool hasFailed = false;

  @override
  int? getInt(String key) => values[key];

  @override
  Future<bool> setInt(String key, int value) async {
    if (key == failKey && !hasFailed) {
      hasFailed = true;
      if (writeBeforeFailure) values[key] = value;
      if (returnFalse) return false;
      throw StateError('simulated storage failure');
    }
    values[key] = value;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _FakeProgressPreferences fake;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    fake = _FakeProgressPreferences();
    ProgressStore.setPreferencesProviderForTesting(() async => fake);
  });

  tearDown(ProgressStore.resetForTesting);

  test('reports a failed write to the initiating caller', () async {
    fake.failKey = 'hpUpgrade';

    await expectLater(
      ProgressStore.save(
        coins: 200,
        hpUpgrade: 25,
        atkUpgrade: 15,
        bestStage: 2,
        bestScore: 50,
      ),
      throwsA(isA<StateError>()),
    );

    // Coins were written first and must be restored after the next key fails.
    expect(fake.values['coins'], 150);
  });

  test('rolls back a key written before the storage backend throws', () async {
    fake.failKey = 'hpUpgrade';
    fake.writeBeforeFailure = true;

    await expectLater(
      ProgressStore.save(
        coins: 200,
        hpUpgrade: 25,
        atkUpgrade: 15,
        bestStage: 2,
        bestScore: 50,
      ),
      throwsA(isA<StateError>()),
    );

    expect(fake.values['coins'], 150);
    expect(fake.values['hpUpgrade'], 0);
  });

  test('keeps the save queue usable after a failed write', () async {
    fake.failKey = 'hpUpgrade';
    await expectLater(
      ProgressStore.save(
        coins: 200,
        hpUpgrade: 25,
        atkUpgrade: 15,
        bestStage: 2,
        bestScore: 50,
      ),
      throwsA(isA<StateError>()),
    );

    fake.failKey = null;
    await ProgressStore.save(
      coins: 300,
      hpUpgrade: 50,
      atkUpgrade: 30,
      bestStage: 5,
      bestScore: 500,
    );

    expect(await ProgressStore.load(), {
      'coins': 300,
      'hpUpgrade': 50,
      'atkUpgrade': 30,
      'bestStage': 5,
      'bestScore': 500,
      'equippedWeaponId': 0,
        'equippedArmorId': 0,
        'equippedHelmetId': 0,
        'equippedRingId': 0,
        'equippedRelicId': 0,
        'ownedEquipmentMask': 585,
    });
  });

  test('treats a false storage result as a failed write', () async {
    fake.failKey = 'coins';
    fake.returnFalse = true;

    await expectLater(
      ProgressStore.save(
        coins: 200,
        hpUpgrade: 25,
        atkUpgrade: 15,
        bestStage: 2,
        bestScore: 50,
      ),
      throwsA(isA<StateError>()),
    );
    expect(fake.values['coins'], 150);
  });
}
