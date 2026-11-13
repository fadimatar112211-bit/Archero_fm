/// Advances the lifetime of transient combat visuals by one game tick.
///
/// Entries whose lifetime reaches zero are removed. The list and its maps are
/// updated in place so existing render/update references remain valid.
void tickTimedEntities(List<Map<String, dynamic>> entities) {
  for (var i = entities.length - 1; i >= 0; i--) {
    final remaining = (entities[i]['life'] as int) - 1;
    entities[i]['life'] = remaining;
    if (remaining <= 0) {
      entities.removeAt(i);
    }
  }
}
