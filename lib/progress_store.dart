import 'package:shared_preferences/shared_preferences.dart';

class ProgressStore {
  static const Map<String, int> _defaults = {
    'coins': 150,
    'hpUpgrade': 0,
    'atkUpgrade': 0,
    'bestStage': 1,
    'bestScore': 0,
  };

  // Keep snapshots from overlapping saves in call order. Without this queue,
  // concurrent platform writes can interleave and leave a mixed save profile.
  static Future<void> _pendingWrite = Future<void>.value();

  static int _validValue(String key, int? value) {
    final fallback = _defaults[key]!;
    final candidate = value ?? fallback;
    if (key == 'bestStage') return candidate < 1 ? 1 : candidate;
    return candidate < 0 ? 0 : candidate;
  }

  static Future<Map<String, int>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      for (final key in _defaults.keys)
        key: _validValue(key, prefs.getInt(key)),
    };
  }

  static Future<void> save({
    required int coins,
    required int hpUpgrade,
    required int atkUpgrade,
    required int bestStage,
    required int bestScore,
  }) {
    // Capture and validate the complete snapshot before it enters the queue.
    final values = <String, int>{
      'coins': _validValue('coins', coins),
      'hpUpgrade': _validValue('hpUpgrade', hpUpgrade),
      'atkUpgrade': _validValue('atkUpgrade', atkUpgrade),
      'bestStage': _validValue('bestStage', bestStage),
      'bestScore': _validValue('bestScore', bestScore),
    };

    final nextWrite = _pendingWrite.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      for (final entry in values.entries) {
        await prefs.setInt(entry.key, entry.value);
      }
    });

    // A failed save is still reported to its caller, but must not permanently
    // poison the queue and prevent later progress snapshots from being saved.
    _pendingWrite = nextWrite.catchError((Object _) {});
    return nextWrite;
  }
}
