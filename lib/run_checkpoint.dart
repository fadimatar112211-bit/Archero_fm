import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Versioned, JSON-safe snapshot of an active run. The payload deliberately
/// contains plain values only so it can survive process death and upgrades.
class RunCheckpoint {
  const RunCheckpoint({
    required this.heroType,
    required this.stage,
    required this.state,
    this.version = currentVersion,
    this.savedAtEpochMs,
  });

  static const int currentVersion = 1;
  static const String storageKey = 'activeRunCheckpoint';

  final int version;
  final int heroType;
  final int stage;
  final Map<String, Object?> state;
  final int? savedAtEpochMs;

  String encode() => jsonEncode({
        'version': version,
        'heroType': heroType,
        'stage': stage,
        'savedAtEpochMs': savedAtEpochMs ?? DateTime.now().millisecondsSinceEpoch,
        'state': state,
      });

  static RunCheckpoint? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final version = decoded['version'];
      final heroType = decoded['heroType'];
      final stage = decoded['stage'];
      final state = decoded['state'];
      final savedAt = decoded['savedAtEpochMs'];
      if (version != currentVersion ||
          heroType is! int || heroType < 1 || heroType > 4 ||
          stage is! int || stage < 1 ||
          state is! Map<String, dynamic> ||
          (savedAt != null && savedAt is! int)) {
        return null;
      }
      if (!_isJsonSafe(state)) return null;
      return RunCheckpoint(
        version: version as int,
        heroType: heroType,
        stage: stage,
        state: Map<String, Object?>.from(state),
        savedAtEpochMs: savedAt as int?,
      );
    } catch (_) {
      return null;
    }
  }

  static bool _isJsonSafe(Object? value) {
    if (value == null || value is String || value is bool || value is int) {
      return true;
    }
    if (value is double) return value.isFinite;
    if (value is List) return value.every(_isJsonSafe);
    if (value is Map) {
      return value.keys.every((key) => key is String) &&
          value.values.every(_isJsonSafe);
    }
    return false;
  }
}

/// Small isolated store for the optional in-progress run snapshot.
class RunCheckpointStore {
  static Future<void> _pendingWrite = Future<void>.value();

  static Future<void> save(RunCheckpoint checkpoint) {
    final nextWrite = _pendingWrite.then((_) async {
      final preferences = await SharedPreferences.getInstance();
      final saved = await preferences.setString(
        RunCheckpoint.storageKey,
        checkpoint.encode(),
      );
      if (!saved) throw StateError('Unable to persist active run checkpoint');
    });
    _pendingWrite = nextWrite.catchError((Object _) {});
    return nextWrite;
  }

  static Future<RunCheckpoint?> load() async {
    await _pendingWrite;
    final preferences = await SharedPreferences.getInstance();
    return RunCheckpoint.decode(preferences.getString(RunCheckpoint.storageKey));
  }

  static Future<void> clear() {
    final nextWrite = _pendingWrite.then((_) async {
      final preferences = await SharedPreferences.getInstance();
      final removed = await preferences.remove(RunCheckpoint.storageKey);
      if (!removed && preferences.containsKey(RunCheckpoint.storageKey)) {
        throw StateError('Unable to clear active run checkpoint');
      }
    });
    _pendingWrite = nextWrite.catchError((Object _) {});
    return nextWrite;
  }
}
