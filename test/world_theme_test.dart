import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/world_theme.dart';

void main() {
  test('stages map to six ten-stage worlds', () {
    expect(WorldTheme.forStage(1).name, 'الغابة المسحورة');
    expect(WorldTheme.forStage(10).id, 1);
    expect(WorldTheme.forStage(11).id, 2);
    expect(WorldTheme.forStage(20).id, 2);
    expect(WorldTheme.forStage(21).id, 3);
    expect(WorldTheme.forStage(31).id, 4);
    expect(WorldTheme.forStage(41).id, 5);
    expect(WorldTheme.forStage(51).id, 6);
    expect(WorldTheme.forStage(100).id, 6);
  });

  test('invalid low stages safely use the first world', () {
    expect(WorldTheme.forStage(0).id, 1);
    expect(WorldTheme.forStage(-5).id, 1);
  });

  test('every world has a distinct identity and palette', () {
    expect(WorldTheme.all.map((world) => world.id).toSet().length, 6);
    expect(WorldTheme.all.map((world) => world.midColor).toSet().length, 6);
  });
}
