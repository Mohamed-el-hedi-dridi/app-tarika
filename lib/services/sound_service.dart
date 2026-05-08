import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  SoundService
//
//  Joue deux sons générés algorithmiquement (WAV en mémoire) :
//    • playClick() — bip court grave  (tap sur عدّ)
//    • playDone()  — bip double aigu  (compteur terminé)
//
//  Aucun fichier audio externe requis.
// ─────────────────────────────────────────────────────────────────────────────
class SoundService {
  SoundService._();

  static final _click = AudioPlayer()..setVolume(0.6);
  static final _done  = AudioPlayer()..setVolume(0.7);

  // Bip court 520 Hz — un clic discret
  static final Uint8List _clickWav = _generateBeep(
    frequency: 520,
    durationMs: 60,
    fadeMs: 40,
  );

  // Double bip montant 700 → 1050 Hz — signal de fin
  static final Uint8List _doneWav = _generateDoubleBeep();

  /// Joue le bip de comptage (عدّ)
  static Future<void> playClick() async {
    try {
      await _click.play(BytesSource(_clickWav), volume: 0.6);
    } catch (e) {
      debugPrint('[Sound] playClick erreur: $e');
    }
  }

  /// Joue le bip de fin (compteur atteint)
  static Future<void> playDone() async {
    try {
      await _done.play(BytesSource(_doneWav), volume: 0.7);
    } catch (e) {
      debugPrint('[Sound] playDone erreur: $e');
    }
  }

  // ── Génération WAV ──────────────────────────────────────────────────────────

  static Uint8List _generateBeep({
    required double frequency,
    required int durationMs,
    required int fadeMs,
    int sampleRate = 22050,
    double amplitude = 14000,
  }) {
    final numSamples = (sampleRate * durationMs / 1000).round();
    final fadeSamples = (sampleRate * fadeMs / 1000).round();
    final dataSize = numSamples * 2;

    final buf = _WavBuilder(sampleRate, dataSize);
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      // Fade-out linéaire sur les derniers fadeMs
      final env = i < (numSamples - fadeSamples)
          ? 1.0
          : (numSamples - i) / fadeSamples;
      final sample = (sin(2 * pi * frequency * t) * env * amplitude).round();
      buf.writeSample(sample);
    }
    return buf.bytes();
  }

  static Uint8List _generateDoubleBeep({int sampleRate = 22050}) {
    // Bip 1 : 700 Hz / 80 ms  +  silence 40 ms  +  Bip 2 : 1050 Hz / 120 ms
    const b1Dur = 80, silDur = 40, b2Dur = 120;
    final b1Samples  = (sampleRate * b1Dur  / 1000).round();
    final silSamples = (sampleRate * silDur / 1000).round();
    final b2Samples  = (sampleRate * b2Dur  / 1000).round();
    final total = b1Samples + silSamples + b2Samples;
    final dataSize = total * 2;

    final buf = _WavBuilder(sampleRate, dataSize);

    for (int i = 0; i < b1Samples; i++) {
      final t = i / sampleRate;
      final env = i < (b1Samples - 20) ? 1.0 : (b1Samples - i) / 20.0;
      buf.writeSample((sin(2 * pi * 700 * t) * env * 13000).round());
    }
    for (int i = 0; i < silSamples; i++) {
      buf.writeSample(0);
    }
    for (int i = 0; i < b2Samples; i++) {
      final t = i / sampleRate;
      final fadeOut = (b2Samples - 30).clamp(0, b2Samples);
      final env = i < fadeOut ? 1.0 : (b2Samples - i) / 30.0;
      buf.writeSample((sin(2 * pi * 1050 * t) * env * 15000).round());
    }
    return buf.bytes();
  }
}

// ── Helper WAV builder ────────────────────────────────────────────────────────
class _WavBuilder {
  final _data = BytesBuilder();

  _WavBuilder(int sampleRate, int dataSize) {
    _addStr('RIFF');
    _int32(36 + dataSize);
    _addStr('WAVE');
    _addStr('fmt ');
    _int32(16);
    _int16(1);           // PCM
    _int16(1);           // mono
    _int32(sampleRate);
    _int32(sampleRate * 2); // byte rate
    _int16(2);           // block align
    _int16(16);          // bits per sample
    _addStr('data');
    _int32(dataSize);
  }

  void writeSample(int v) => _int16(v.clamp(-32768, 32767));

  Uint8List bytes() => _data.toBytes();

  void _addStr(String s) => _data.add(s.codeUnits);

  void _int32(int v) {
    _data.addByte(v & 0xFF);
    _data.addByte((v >> 8) & 0xFF);
    _data.addByte((v >> 16) & 0xFF);
    _data.addByte((v >> 24) & 0xFF);
  }

  void _int16(int v) {
    final u = v < 0 ? v + 65536 : v;
    _data.addByte(u & 0xFF);
    _data.addByte((u >> 8) & 0xFF);
  }
}
