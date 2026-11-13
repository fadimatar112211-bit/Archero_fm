import 'dart:ui' as ui;

import 'package:archero_fm/main.dart';
import 'package:archero_fm/world_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('arena painter renders every world at a typical phone size', () {
    for (final theme in WorldTheme.all) {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      const size = ui.Size(360, 640);

      expect(
        () => ArenaPainter(theme: theme).paint(canvas, size),
        returnsNormally,
        reason: 'Painter should render each world without throwing',
      );

      recorder.endRecording().dispose();
    }
  });

  test('arena painter repaints only when the world changes', () {
    final forestPainter = ArenaPainter(theme: WorldTheme.forest);
    final sameForestPainter = ArenaPainter(theme: WorldTheme.forest);
    final volcanoPainter = ArenaPainter(theme: WorldTheme.volcano);

    expect(forestPainter.shouldRepaint(sameForestPainter), isFalse);
    expect(forestPainter.shouldRepaint(volcanoPainter), isTrue);
  });
}
