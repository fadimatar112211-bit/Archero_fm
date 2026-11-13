import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:archero_fm/progress_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loads safe defaults for a new player', () async {
    expect(await ProgressStore.load(), {
      'coins': 150,
      'hpUpgrade': 0,
      'atkUpgrade': 0,
      'bestStage': 1,
      'bestScore': 0,
    });
  });

  test('saves and restores all progression values', () async {
    await ProgressStore.save(
      coins: 275,
      hpUpgrade: 50,
      atkUpgrade: 30,
      bestStage: 8,
      bestScore: 1240,
    );

    expect(await ProgressStore.load(), {
      'coins': 275,
      'hpUpgrade': 50,
      'atkUpgrade': 30,
      'bestStage': 8,
      'bestScore': 1240,
    });
  });

  test('serializes overlapping saves as complete snapshots', () async {
    final firstSave = ProgressStore.save(
      coins: 200,
      hpUpgrade: 25,
      atkUpgrade: 15,
      bestStage: 4,
      bestScore: 400,
    );
    final secondSave = ProgressStore.save(
      coins: 315,
      hpUpgrade: 50,
      atkUpgrade: 30,
      bestStage: 9,
      bestScore: 950,
    );

    await Future.wait([firstSave, secondSave]);

    expect(await ProgressStore.load(), {
      'coins': 315,
      'hpUpgrade': 50,
      'atkUpgrade': 30,
      'bestStage': 9,
      'bestScore': 950,
    });
  });

  test('normalizes invalid negative progression values', () async {
    SharedPreferences.setMockInitialValues({
      'coins': -40,
      'hpUpgrade': -5,
      'atkUpgrade': -2,
      'bestStage': 0,
      'bestScore': -100,
    });

    expect(await ProgressStore.load(), {
      'coins': 0,
      'hpUpgrade': 0,
      'atkUpgrade': 0,
      'bestStage': 1,
      'bestScore': 0,
    });
  });

  test('does not persist negative values supplied by callers', () async {
    await ProgressStore.save(
      coins: -10,
      hpUpgrade: -1,
      atkUpgrade: -3,
      bestStage: -8,
      bestScore: -20,
    );

    expect(await ProgressStore.load(), {
      'coins': 0,
      'hpUpgrade': 0,
      'atkUpgrade': 0,
      'bestStage': 1,
      'bestScore': 0,
    });
  });
}
