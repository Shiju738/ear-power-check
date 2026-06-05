import 'package:flutter/foundation.dart';

/// Which ear a tone is directed to.
enum Ear {
  left,
  right;

  bool get isLeft => this == Ear.left;
  String get label => isLeft ? 'Left' : 'Right';
}

/// Standard pure-tone audiometry frequencies (Hz).
const List<int> kTestFrequencies = [250, 500, 1000, 2000, 4000, 8000];

/// The faintest and loudest hearing levels (in dB HL) the screening sweeps
/// through. This is a relative, non-diagnostic screening scale.
const double kMinDbHl = -10;
const double kMaxDbHl = 90;

/// A single recorded hearing threshold: the quietest level (dB HL) at which the
/// user could still hear a given frequency in a given ear.
@immutable
class ThresholdResult {
  const ThresholdResult({
    required this.ear,
    required this.frequencyHz,
    required this.thresholdDbHl,
  });

  final Ear ear;
  final int frequencyHz;

  /// Lower is better hearing. `null` semantics are avoided — if the user never
  /// heard the tone we store [kMaxDbHl].
  final double thresholdDbHl;

  Map<String, dynamic> toJson() => {
        'ear': ear.name,
        'frequencyHz': frequencyHz,
        'thresholdDbHl': thresholdDbHl,
      };

  factory ThresholdResult.fromJson(Map<String, dynamic> json) =>
      ThresholdResult(
        ear: Ear.values.byName(json['ear'] as String),
        frequencyHz: json['frequencyHz'] as int,
        thresholdDbHl: (json['thresholdDbHl'] as num).toDouble(),
      );
}

/// The complete outcome of one screening session for both ears.
@immutable
class HearingTestResult {
  const HearingTestResult({
    required this.timestamp,
    required this.thresholds,
  });

  final DateTime timestamp;
  final List<ThresholdResult> thresholds;

  List<ThresholdResult> forEar(Ear ear) =>
      thresholds.where((t) => t.ear == ear).toList()
        ..sort((a, b) => a.frequencyHz.compareTo(b.frequencyHz));

  /// Pure-Tone Average across speech frequencies (500, 1k, 2k Hz) for an ear —
  /// the standard summary number for screening.
  double ptaForEar(Ear ear) {
    const speech = [500, 2000, 1000];
    final vals = thresholds
        .where((t) => t.ear == ear && speech.contains(t.frequencyHz))
        .map((t) => t.thresholdDbHl)
        .toList();
    if (vals.isEmpty) return kMaxDbHl;
    return vals.reduce((a, b) => a + b) / vals.length;
  }

  /// Average PTA across both ears.
  double get overallPta => (ptaForEar(Ear.left) + ptaForEar(Ear.right)) / 2;

  /// A 0–100 "ear power" score derived from the overall PTA, where a lower
  /// (better) threshold maps to a higher score.
  int get score {
    final clamped = overallPta.clamp(kMinDbHl, kMaxDbHl);
    final normalized = (clamped - kMinDbHl) / (kMaxDbHl - kMinDbHl);
    return ((1 - normalized) * 100).round();
  }

  HearingGrade get grade => HearingGrade.fromPta(overallPta);

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'thresholds': thresholds.map((t) => t.toJson()).toList(),
      };

  factory HearingTestResult.fromJson(Map<String, dynamic> json) =>
      HearingTestResult(
        timestamp: DateTime.parse(json['timestamp'] as String),
        thresholds: (json['thresholds'] as List)
            .map((e) => ThresholdResult.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Categorical interpretation of a PTA value (screening, not diagnosis).
enum HearingGrade {
  excellent('Excellent', 'Your hearing is in great shape.'),
  good('Good', 'Normal hearing range.'),
  mild('Mild loss', 'Slight difficulty with quiet sounds.'),
  moderate('Moderate loss', 'Consider a professional evaluation.'),
  significant('Significant loss', 'We recommend seeing an audiologist.');

  const HearingGrade(this.title, this.description);
  final String title;
  final String description;

  static HearingGrade fromPta(double pta) {
    if (pta <= 10) return HearingGrade.excellent;
    if (pta <= 25) return HearingGrade.good;
    if (pta <= 40) return HearingGrade.mild;
    if (pta <= 60) return HearingGrade.moderate;
    return HearingGrade.significant;
  }
}
