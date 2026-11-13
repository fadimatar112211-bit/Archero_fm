import 'dart:math';
import 'dart:typed_data';

/// Builds a short mono PCM WAV effect without network or bundled audio assets.
Uint8List buildToneWav(String type) {
  const sampleRate = 22050;
  final settings = switch (type) {
    'shoot' => (frequency: 760.0, duration: 0.075, endFrequency: 430.0),
    'hit' => (frequency: 190.0, duration: 0.11, endFrequency: 95.0),
    'coin' => (frequency: 980.0, duration: 0.16, endFrequency: 1480.0),
    'special' => (frequency: 520.0, duration: 0.24, endFrequency: 1040.0),
    _ => (frequency: 440.0, duration: 0.08, endFrequency: 440.0),
  };
  final sampleCount = (sampleRate * settings.duration).round();
  final bytes = Uint8List(44 + sampleCount * 2);
  final data = ByteData.sublistView(bytes);

  void writeText(int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      bytes[offset + i] = value.codeUnitAt(i);
    }
  }

  writeText(0, 'RIFF');
  data.setUint32(4, bytes.length - 8, Endian.little);
  writeText(8, 'WAVE');
  writeText(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, 1, Endian.little);
  data.setUint32(24, sampleRate, Endian.little);
  data.setUint32(28, sampleRate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  writeText(36, 'data');
  data.setUint32(40, sampleCount * 2, Endian.little);

  for (var i = 0; i < sampleCount; i++) {
    final progress = i / sampleCount;
    final frequency = settings.frequency +
        (settings.endFrequency - settings.frequency) * progress;
    final attack = (progress / 0.08).clamp(0.0, 1.0);
    final decay = (1.0 - progress).clamp(0.0, 1.0);
    final envelope = attack * decay * decay;
    final wave = sin(2 * pi * frequency * i / sampleRate);
    final harmonic = type == 'hit'
        ? 0.22 * sin(4 * pi * frequency * i / sampleRate)
        : 0.12 * sin(4 * pi * frequency * i / sampleRate);
    final sample = ((wave + harmonic) * envelope * 10500)
        .round()
        .clamp(-32768, 32767);
    data.setInt16(44 + i * 2, sample, Endian.little);
  }
  return bytes;
}

