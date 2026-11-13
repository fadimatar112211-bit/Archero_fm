import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/game_timers.dart';

void main() {
  group('GameTimerRegistry', () {
    test('replacing a key cancels the previous periodic timer', () async {
      final registry = GameTimerRegistry();
      var oldTicks = 0;
      var newTicks = 0;

      registry.periodic('shoot', const Duration(milliseconds: 5), () {
        oldTicks++;
      });
      await Future<void>.delayed(const Duration(milliseconds: 12));
      registry.periodic('shoot', const Duration(milliseconds: 5), () {
        newTicks++;
      });
      final oldTicksAtReplacement = oldTicks;
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(oldTicks, oldTicksAtReplacement);
      expect(newTicks, greaterThan(0));
      expect(registry.activeTimerCount, 1);
      registry.dispose();
    });

    test('cancel prevents further callbacks', () async {
      final registry = GameTimerRegistry();
      var ticks = 0;
      registry.periodic('game', const Duration(milliseconds: 5), () {
        ticks++;
      });
      await Future<void>.delayed(const Duration(milliseconds: 12));
      registry.cancel('game');
      final stoppedAt = ticks;
      await Future<void>.delayed(const Duration(milliseconds: 15));

      expect(ticks, stoppedAt);
      expect(registry.activeTimerCount, 0);
      registry.dispose();
    });

    test('cancelAll and dispose stop every timer', () async {
      final registry = GameTimerRegistry();
      var ticks = 0;
      registry.periodic('game', const Duration(milliseconds: 5), () {
        ticks++;
      });
      registry.periodic('shoot', const Duration(milliseconds: 5), () {
        ticks++;
      });
      await Future<void>.delayed(const Duration(milliseconds: 12));
      registry.dispose();
      final stoppedAt = ticks;
      await Future<void>.delayed(const Duration(milliseconds: 15));

      expect(ticks, stoppedAt);
      expect(registry.activeTimerCount, 0);
      expect(registry.isDisposed, isTrue);
      expect(
        () => registry.periodic('late', const Duration(milliseconds: 5), () {}),
        throwsStateError,
      );
    });

    test('canceling an unknown key is safe and disposal is idempotent', () {
      final registry = GameTimerRegistry();
      expect(() => registry.cancel('missing'), returnsNormally);
      expect(() => registry.dispose(), returnsNormally);
      expect(() => registry.dispose(), returnsNormally);
    });
  });
}
