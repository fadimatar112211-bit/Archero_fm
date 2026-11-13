/// Owns the lifetime and insertion of short-lived combat visuals.
class CombatEffectManager {
  const CombatEffectManager._();

  /// Advances every transient effect by one simulation tick.
  /// Expired entries are removed in reverse order to avoid skipped elements.
  static void advance(List<Map<String, dynamic>> effects) {
    for (var i = effects.length - 1; i >= 0; i--) {
      final remaining = (effects[i]['life'] as int) - 1;
      effects[i]['life'] = remaining;
      if (remaining <= 0) {
        effects.removeAt(i);
      }
    }
  }

  static void add(
    List<Map<String, dynamic>> effects, {
    required double x,
    required double y,
    required String type,
    required int lifetime,
  }) {
    if (!x.isFinite || !y.isFinite || lifetime <= 0) return;
    effects.add({'x': x, 'y': y, 'type': type, 'life': lifetime});
  }
}
