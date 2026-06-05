import 'package:flutter_test/flutter_test.dart';

import 'package:ear_power_check/features/test/models/hearing_test_models.dart';

void main() {
  test('better hearing yields a higher score', () {
    HearingTestResult build(double db) => HearingTestResult(
          timestamp: DateTime(2026),
          thresholds: [
            for (final ear in Ear.values)
              for (final f in kTestFrequencies)
                ThresholdResult(ear: ear, frequencyHz: f, thresholdDbHl: db),
          ],
        );

    expect(build(0).score, greaterThan(build(60).score));
    expect(build(0).grade, HearingGrade.excellent);
    expect(build(80).grade, HearingGrade.significant);
  });
}
