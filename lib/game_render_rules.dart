/// Pure rendering guards shared by actor and HUD widgets.
double normalizedHealthRatio({required double current, required double maximum}) {
  if (!current.isFinite || !maximum.isFinite || maximum <= 0) return 0;
  return (current / maximum).clamp(0.0, 1.0).toDouble();
}

/// Safely wraps a sprite-sheet frame, including negative indexes and invalid counts.
int normalizedSpriteFrameIndex({required int frameIndex, required int frameCount}) {
  final safeCount = frameCount > 0 ? frameCount : 1;
  return ((frameIndex % safeCount) + safeCount) % safeCount;
}
