import 'package:flutter/foundation.dart';

import '../../../core/audio/tone_player.dart';
import '../models/hearing_test_models.dart';

/// One unit of the manual test: a specific frequency in a specific ear.
@immutable
class TestStep {
  const TestStep(this.ear, this.frequencyHz);
  final Ear ear;
  final int frequencyHz;
}

/// Drives the manual hearing test: walks through every (ear, frequency) pair,
/// lets the user adjust the tone level, and records the faintest audible level
/// as the threshold for that pair.
class EarTestController extends ChangeNotifier {
  EarTestController(this._player) {
    _steps = [
      for (final ear in [Ear.right, Ear.left])
        for (final f in kTestFrequencies) TestStep(ear, f),
    ];
  }

  final TonePlayer _player;

  late final List<TestStep> _steps;
  final List<ThresholdResult> _results = [];

  int _index = 0;
  double _dbHl = 35;
  bool _isPlaying = false;
  bool _finished = false;

  List<TestStep> get steps => _steps;
  int get index => _index;
  int get total => _steps.length;
  TestStep get current => _steps[_index];
  double get dbHl => _dbHl;
  bool get isPlaying => _isPlaying;
  bool get finished => _finished;
  double get progress => _index / _steps.length;
  List<ThresholdResult> get results => List.unmodifiable(_results);

  ValueListenable<double> get output => _player.output;

  Future<void> start() async {
    await _player.ensureInitialized();
    await _play();
  }

  Future<void> _play() async {
    _isPlaying = true;
    notifyListeners();
    await _player.playTone(
      frequency: current.frequencyHz.toDouble(),
      ear: current.ear,
      dbHl: _dbHl,
    );
  }

  Future<void> togglePlay() async {
    if (_isPlaying) {
      await _player.stop();
      _isPlaying = false;
      notifyListeners();
    } else {
      await _play();
    }
  }

  /// Live-update the level while the user drags the slider.
  void setLevel(double dbHl) {
    _dbHl = dbHl.clamp(kMinDbHl, kMaxDbHl);
    if (_isPlaying) _player.setLevel(_dbHl);
    notifyListeners();
  }

  /// Record the current level as the threshold for this step and advance.
  /// If [inaudible] is true, the user could not hear it at all → max level.
  Future<void> confirmThreshold({bool inaudible = false}) async {
    _results.add(ThresholdResult(
      ear: current.ear,
      frequencyHz: current.frequencyHz,
      thresholdDbHl: inaudible ? kMaxDbHl : _dbHl,
    ));

    if (_index >= _steps.length - 1) {
      await _player.stop();
      _isPlaying = false;
      _finished = true;
      notifyListeners();
      return;
    }

    _index++;
    _dbHl = 35; // reset to a comfortable starting level for the next tone
    notifyListeners();
    await _play();
  }

  HearingTestResult buildResult(DateTime timestamp) =>
      HearingTestResult(timestamp: timestamp, thresholds: results);

  @override
  void dispose() {
    _player.stop();
    super.dispose();
  }
}
