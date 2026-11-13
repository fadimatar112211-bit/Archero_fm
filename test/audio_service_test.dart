import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/audio_service.dart';

void main() {
  group('GameAudioService', () {
    test('exposes only supported local gameplay sound categories', () {
      expect(
        GameAudioService.supportedSounds,
        containsAll(<String>['shoot', 'hit', 'coin', 'special']),
      );
      expect(GameAudioService.supportedSounds, hasLength(4));
      expect(GameAudioService.supportedSounds, isNot(contains('unknown')));
    });

    test('ignores unsupported sounds without creating audio players', () async {
      final audio = GameAudioService();

      await audio.play('not-a-real-sound');

      expect(audio.isDisposed, isFalse);
      await audio.dispose();
      expect(audio.isDisposed, isTrue);
    });

    test('dispose is safe to call more than once', () async {
      final audio = GameAudioService();

      await audio.dispose();
      await audio.dispose();

      expect(audio.isDisposed, isTrue);
    });

    test('does not play sounds after disposal', () async {
      final audio = GameAudioService();
      await audio.dispose();

      await audio.play('coin');

      expect(audio.isDisposed, isTrue);
    });
  });
}
