import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import '../../features/test/models/hearing_test_models.dart';

/// Generates real, calibrated-relative pure-tone sine waves for the hearing
/// screening, with independent left/right panning.
///
/// NOTE: Without per-device acoustic calibration this produces a *relative*
/// screening level, not a clinically-accurate dB SPL. Levels are mapped from a
/// dB-HL-like scale to a perceptual linear gain.
class TonePlayer {
  SoLoud get _soloud => SoLoud.instance;

  AudioSource? _source;
  SoundHandle? _handle;

  /// 0–1 amplitude of whatever is currently sounding, for the visualizer.
  final ValueNotifier<double> output = ValueNotifier(0);

  bool get isInitialized => _soloud.isInitialized;

  Future<void> ensureInitialized() async {
    if (_soloud.isInitialized) return;
    await _soloud.init();
    // A single reusable sine source; frequency is changed per tone.
    _source = await _soloud.loadWaveform(WaveForm.sin, false, 1, 0);
  }

  /// Maps a dB-HL-like level to a perceptual linear gain in [0, 1].
  ///
  /// Lower dB HL = quieter. Uses a roughly logarithmic-to-linear mapping so the
  /// faintest steps are perceptible without the loudest being painful.
  double _levelToGain(double dbHl) {
    final clamped = dbHl.clamp(kMinDbHl, kMaxDbHl);
    final normalized = (clamped - kMinDbHl) / (kMaxDbHl - kMinDbHl); // 0..1
    // Perceptual curve: quiet region expanded, gentle top end.
    final gain = (normalized * normalized) * 0.9 + 0.02;
    return gain.clamp(0.0, 1.0);
  }

  /// Plays a sustained tone at [frequency] Hz, panned to [ear], at the given
  /// [dbHl] level. Replaces any currently-playing tone.
  Future<void> playTone({
    required double frequency,
    required Ear ear,
    required double dbHl,
  }) async {
    await ensureInitialized();
    final source = _source;
    if (source == null) return;

    await stop();

    _soloud.setWaveformFreq(source, frequency);
    final gain = _levelToGain(dbHl);
    final handle = _soloud.play(
      source,
      volume: 0,
      pan: ear.isLeft ? -1.0 : 1.0,
      looping: true,
    );
    _handle = handle;
    // Quick fade-in to avoid a click on tone onset.
    _soloud.fadeVolume(handle, gain, const Duration(milliseconds: 40));
    output.value = gain;
  }

  /// Updates the level of the currently-playing tone without restarting it
  /// (used while sweeping a frequency up/down in the manual test).
  void setLevel(double dbHl) {
    final handle = _handle;
    if (handle == null) return;
    final gain = _levelToGain(dbHl);
    _soloud.setVolume(handle, gain);
    output.value = gain;
  }

  Future<void> stop() async {
    final handle = _handle;
    if (handle != null) {
      await _soloud.stop(handle);
      _handle = null;
    }
    output.value = 0;
  }

  void dispose() {
    final handle = _handle;
    if (handle != null) _soloud.stop(handle);
    output.dispose();
  }
}
