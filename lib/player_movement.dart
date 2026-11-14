import 'dart:math';
import 'dart:ui' show Offset;

/// Pure player-position movement and arena-boundary clamping.
class PlayerMovement {
  PlayerMovement._();

  static Offset applyDelta({
    required Offset position,
    required Offset delta,
    required double minX,
    required double maxX,
    required double minY,
    required double maxY,
  }) {
    final safeMaxX = max(minX, maxX);
    final safeMaxY = max(minY, maxY);
    return Offset(
      (position.dx + delta.dx).clamp(minX, safeMaxX).toDouble(),
      (position.dy + delta.dy).clamp(minY, safeMaxY).toDouble(),
    );
  }
}
