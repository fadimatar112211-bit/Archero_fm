import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/game_render_rules.dart';

void main() {
  group('normalizedHealthRatio', () {
    test('clamps health to the valid progress range', () {
      expect(normalizedHealthRatio(current: 50, maximum: 100), 0.5);
      expect(normalizedHealthRatio(current: 150, maximum: 100), 1);
      expect(normalizedHealthRatio(current: -5, maximum: 100), 0);
    });
    test('returns zero for non-finite or non-positive maximum values', () {
      for (final pair in [
        (double.nan, 100.0),
        (50.0, double.infinity),
        (50.0, 0.0),
        (50.0, -1.0),
      ]) {
        expect(normalizedHealthRatio(current: pair.$1, maximum: pair.$2), 0);
      }
    });
  });
  group('normalizedSpriteFrameIndex', () {
    test('wraps normal and negative indexes', () {
      expect(normalizedSpriteFrameIndex(frameIndex: 5, frameCount: 4), 1);
      expect(normalizedSpriteFrameIndex(frameIndex: -1, frameCount: 4), 3);
    });
    test('falls back to one frame for invalid frame counts', () {
      expect(normalizedSpriteFrameIndex(frameIndex: 12, frameCount: 0), 0);
      expect(normalizedSpriteFrameIndex(frameIndex: -8, frameCount: -4), 0);
    });
  });
}
