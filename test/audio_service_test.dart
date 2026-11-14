import 'package:flutter_test/flutter_test.dart';
import 'package:archero_fm/audio_service.dart';

void main() {
  test('unknown sound identifiers are safely ignored', () async {
    await expectLater(GameAudio.play('not-a-real-sound'), completes);
  });
}
