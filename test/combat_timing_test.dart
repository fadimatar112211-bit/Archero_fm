import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/combat_timing.dart';

void main() {
  group('tickTimedEntities', () {
    test('decrements each entity lifetime by one tick', () {
      final entities = <Map<String, dynamic>>[
        {'type': 'hit', 'life': 3},
        {'type': 'dodge', 'life': 1},
      ];

      tickTimedEntities(entities);

      expect(entities, [
        {'type': 'hit', 'life': 2},
      ]);
    });

    test('removes expired entries without skipping adjacent entries', () {
      final entities = <Map<String, dynamic>>[
        {'id': 1, 'life': 1},
        {'id': 2, 'life': 1},
        {'id': 3, 'life': 2},
        {'id': 4, 'life': 1},
      ];

      tickTimedEntities(entities);

      expect(entities, [
        {'id': 3, 'life': 1},
      ]);
    });

    test('supports an empty collection', () {
      final entities = <Map<String, dynamic>>[];

      expect(() => tickTimedEntities(entities), returnsNormally);
      expect(entities, isEmpty);
    });
  });
}
