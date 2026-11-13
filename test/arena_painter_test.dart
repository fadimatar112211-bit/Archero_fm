import 'dart:ui' as ui;

import 'package:flutter/animation.dart';

import 'package:archero_fm/main.dart';
import 'package:archero_fm/world_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('arena painter renders every world across phone and landscape sizes', () {
    for (final theme in WorldTheme.all) {
      for (final size in [
        const ui.Size(360, 640),
        const ui.Size(411, 891),
        const ui.Size(640, 360),
      ]) {
        final recorder = ui.PictureRecorder();
        final canvas = ui.Canvas(recorder);
        expect(
          () => ArenaPainter(theme: theme).paint(canvas, size),
          returnsNormally,
          reason: 'Painter should render ${theme.name} at $size',
        );
        recorder.endRecording().dispose();
      }
    }
  });

  test('arena painter repaints only when the world changes', () {
    final forestPainter = ArenaPainter(theme: WorldTheme.forest);
    final sameForestPainter = ArenaPainter(theme: WorldTheme.forest);
    final volcanoPainter = ArenaPainter(theme: WorldTheme.volcano);

    expect(forestPainter.shouldRepaint(sameForestPainter), isFalse);
    expect(forestPainter.shouldRepaint(volcanoPainter), isTrue);
  });

  test('arena painter repaints when its animation delegate changes', () {
    final firstAnimation = AlwaysStoppedAnimation<double>(0.0);
    final secondAnimation = AlwaysStoppedAnimation<double>(0.5);
    final firstPainter = ArenaPainter(animation: firstAnimation);
    final sameAnimationPainter = ArenaPainter(animation: firstAnimation);
    final nextAnimationPainter = ArenaPainter(animation: secondAnimation);

    expect(firstPainter.shouldRepaint(sameAnimationPainter), isFalse);
    expect(firstPainter.shouldRepaint(nextAnimationPainter), isTrue);
  });

  test('stage progression switches worlds every ten stages', () {
    expect(WorldTheme.forStage(1), WorldTheme.forest);
    expect(WorldTheme.forStage(10), WorldTheme.forest);
    expect(WorldTheme.forStage(11), WorldTheme.volcano);
    expect(WorldTheme.forStage(20), WorldTheme.volcano);
    expect(WorldTheme.forStage(21), WorldTheme.ice);
    expect(WorldTheme.forStage(31), WorldTheme.desert);
    expect(WorldTheme.forStage(41), WorldTheme.shadows);
    expect(WorldTheme.forStage(51), WorldTheme.citadel);
    expect(WorldTheme.forStage(60), WorldTheme.citadel);
    expect(WorldTheme.forStage(100), WorldTheme.citadel);
    expect(WorldTheme.forStage(0), WorldTheme.forest);
  });
}
