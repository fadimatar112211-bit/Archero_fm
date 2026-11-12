import 'package:shared_preferences/shared_preferences.dart';

class ProgressStore {
  static Future<Map<String, int>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'coins': prefs.getInt('coins') ?? 150,
      'hpUpgrade': prefs.getInt('hpUpgrade') ?? 0,
      'atkUpgrade': prefs.getInt('atkUpgrade') ?? 0,
      'bestStage': prefs.getInt('bestStage') ?? 1,
      'bestScore': prefs.getInt('bestScore') ?? 0,
    };
  }

  static Future<void> save({
    required int coins,
    required int hpUpgrade,
    required int atkUpgrade,
    required int bestStage,
    required int bestScore,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', coins);
    await prefs.setInt('hpUpgrade', hpUpgrade);
    await prefs.setInt('atkUpgrade', atkUpgrade);
    await prefs.setInt('bestStage', bestStage);
    await prefs.setInt('bestScore', bestScore);
  }
}
