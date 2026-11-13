import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ProgressPreferences {
  int? getInt(String key);
  Future<bool> setInt(String key, int value);
}

class _SharedPreferencesProgressPreferences implements ProgressPreferences {
  _SharedPreferencesProgressPreferences(this.preferences);

  final SharedPreferences preferences;

  @override
  int? getInt(String key) => preferences.getInt(key);

  @override
  Future<bool> setInt(String key, int value) =>
      preferences.setInt(key, value);
}

class ProgressStore {
  static const Map<String, int> _defaults = {
    'coins': 150,
    'hpUpgrade': 0,
    'atkUpgrade': 0,
    'bestStage': 1,
    'bestScore': 0,
  };

  // Serialize complete snapshots so overlapping saves cannot interleave.
  static Future<void> _pendingWrite = Future<void>.value();
  static Future<ProgressPreferences> Function() _preferencesProvider =
      _sharedPreferencesProvider;

  static Future<ProgressPreferences> _sharedPreferencesProvider() async {
    final preferences = await SharedPreferences.getInstance();
    return _SharedPreferencesProgressPreferences(preferences);
  }

  /// Allows deterministic storage failure tests without changing production IO.
  static void setPreferencesProviderForTesting(
    Future<ProgressPreferences> Function() provider,
  ) {
    _preferencesProvider = provider;
    _pendingWrite = Future<void>.value();
  }

  static void resetForTesting() {
    _preferencesProvider = _sharedPreferencesProvider;
    _pendingWrite = Future<void>.value();
  }

  static int _validValue(String key, int? value) {
    final fallback = _defaults[key]!;
    final candidate = value ?? fallback;
    if (key == 'bestStage') return candidate < 1 ? 1 : candidate;
    return candidate < 0 ? 0 : candidate;
  }

  static Future<Map<String, int>> load() async {
    final prefs = await _preferencesProvider();
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
    final values = <String, int>{
      'coins': _validValue('coins', coins),
      'hpUpgrade': _validValue('hpUpgrade', hpUpgrade),
      'atkUpgrade': _validValue('atkUpgrade', atkUpgrade),
      'bestStage': _validValue('bestStage', bestStage),
      'bestScore': _validValue('bestScore', bestScore),
    };

    final nextWrite = _pendingWrite.then((_) async {
      final prefs = await _preferencesProvider();
      final previousValues = <String, int>{
        for (final key in values.keys) key: _validValue(key, prefs.getInt(key)),
      };
      final writtenKeys = <String>[];

      try {
        for (final entry in values.entries) {
          // Include the in-flight key too: a failing backend may have written
          // the value before reporting its error.
          writtenKeys.add(entry.key);
          final stored = await prefs.setInt(entry.key, entry.value);
          if (!stored) {
            throw StateError('Failed to persist progression key: ${entry.key}');
          }
        }
      } catch (error, stackTrace) {
        Object? rollbackError;
        for (final key in writtenKeys.reversed) {
          try {
            final restored = await prefs.setInt(key, previousValues[key]!);
            if (!restored) {
              throw StateError('Failed to restore progression key: $key');
            }
          } catch (error) {
            rollbackError ??= error;
          }
        }
        if (rollbackError != null) {
          throw StateError(
            'Progress save failed and rollback was incomplete: $rollbackError',
          );
        }
        Error.throwWithStackTrace(error, stackTrace);
      }
    });

    // Keep the queue usable after a failure, while returning that failure
    // to the caller that initiated this particular save.
    _pendingWrite = nextWrite.catchError((Object _) {});
    return nextWrite;
  }
}
