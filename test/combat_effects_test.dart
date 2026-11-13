import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/combat_effects.dart';

void main() {
  group('CombatEffectManager', () {
    test('advances effect lifetime and removes expired entries', () {
      final effects = <Map<String, dynamic>>[
        {'x': 1.0, 'y': 2.0, 'type': 'hit', 'life': 2},
        {'x': 3.0, 'y': 4.0, 'type': 'dodge', 'life': 1},
      ];

      CombatEffectManager.advance(effects);

      expect(effects, hasLength(1));
      expect(effects.single['life'], 1);
      expect(effects.single['type'], 'hit');
    });

    test('removes adjacent expired effects without skipping', () {
      final effects = <Map<String, dynamic>>[
        {'life': 1},
        {'life': 1},
        {'life': 3},
      ];

      CombatEffectManager.advance(effects);

      expect(effects, hasLength(1));
      expect(effects.single['life'], 2);
    });

    test('adds valid effects and ignores invalid visual data', () {
      final effects = <Map<String, dynamic>>[];
      CombatEffectManager.add(
        effects,
        x: 10,
        y: 20,
        type: 'criticalHit',
        lifetime: 12,
      );
      CombatEffectManager.add(
        effects,
        x: double.nan,
        y: 20,
        type: 'invalid',
        lifetime: 12,
      );
      CombatEffectManager.add(
        effects,
        x: 10,
        y: 20,
        type: 'expired',
        lifetime: 0,
      );

      expect(effects, hasLength(1));
      expect(effects.single['type'], 'criticalHit');
    });

    test('supports empty effect collections', () {
      final effects = <Map<String, dynamic>>[];
      expect(() => CombatEffectManager.advance(effects), returnsNormally);
      expect(effects, isEmpty);
    });
  });
}
