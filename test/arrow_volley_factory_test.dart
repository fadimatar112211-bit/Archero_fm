import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/arrow_volley_factory.dart';

void main() {
  test('fires one arrow toward the nearest enemy', () {
    final arrows = ArrowVolleyFactory.create(
      enemies: [
        {'x': 300.0, 'y': 100.0},
        {'x': 110.0, 'y': 100.0},
      ],
      playerX: 100,
      playerY: 100,
    );

    expect(arrows, hasLength(1));
    expect(arrows.single['vx'], closeTo(8.5, 0.0001));
    expect(arrows.single['vy'], closeTo(0, 0.0001));
  });

  test('extra arrows create a spread volley from the player position', () {
    final arrows = ArrowVolleyFactory.create(
      enemies: [{'x': 100.0, 'y': 200.0}],
      playerX: 100,
      playerY: 100,
      extraArrows: 2,
    );

    expect(arrows, hasLength(3));
    expect(arrows.every((arrow) => arrow['x'] == 100.0), isTrue);
    expect(arrows.every((arrow) => arrow['y'] == 100.0), isTrue);
    expect(arrows.map((arrow) => arrow['vx']).toSet(), hasLength(3));
  });

  test('empty enemy list returns no projectiles', () {
    expect(
      ArrowVolleyFactory.create(
        enemies: const [],
        playerX: 0,
        playerY: 0,
      ),
      isEmpty,
    );
  });
}
