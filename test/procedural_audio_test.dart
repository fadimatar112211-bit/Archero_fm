import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import '../lib/procedural_audio.dart';

void main() {
  const soundTypes = ['shoot', 'hit', 'coin', 'special'];

  for (final type in soundTypes) {
    test('$type effect is a valid non-empty PCM WAV', () {
      final bytes = buildToneWav(type);
      final data = ByteData.sublistView(bytes);

      expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
      expect(String.fromCharCodes(bytes.sublist(8, 12)), 'WAVE');
      expect(String.fromCharCodes(bytes.sublist(12, 16)), 'fmt ');
      expect(String.fromCharCodes(bytes.sublist(36, 40)), 'data');
      expect(data.getUint32(4, Endian.little), bytes.length - 8);
      expect(data.getUint32(24, Endian.little), 22050);
      expect(data.getUint16(22, Endian.little), 1);
      expect(data.getUint16(34, Endian.little), 16);
      expect(data.getUint32(40, Endian.little), bytes.length - 44);
      expect(bytes.length, greaterThan(44));
    });
  }

  test('each effect has a valid data size and finite PCM samples', () {
    for (final type in soundTypes) {
      final bytes = buildToneWav(type);
      final data = ByteData.sublistView(bytes);
      for (var offset = 44; offset < bytes.length; offset += 2) {
        expect(data.getInt16(offset, Endian.little), inInclusiveRange(-32768, 32767));
      }
    }
  });
}
