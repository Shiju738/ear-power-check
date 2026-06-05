# Ear Power Check

A premium, animated Flutter hearing-screening app — glassmorphism UI, real pure-tone audio generation, dark & light modes.

## Screenshots

| Splash | Home | Ear Test | Results |
|:------:|:----:|:--------:|:-------:|
| ![Splash](screenshots/01_splash.png) | ![Home](screenshots/02_home.png) | ![Ear Test](screenshots/03_ear_test.png) | ![Results](screenshots/04_results.png) |

## Features

- **Real tone generation** — pure sine tones (250 Hz–8 kHz) with per-ear L/R panning via `flutter_soloud`
- **Premium UI** — glassmorphism cards, soft gradients, animated ambient background, custom page transitions
- **Live audio visualizer** — circular waveform with pulsing rings reacting to the active tone
- **Animated results** — score-reveal ring, per-ear summaries, and an animated audiogram (`fl_chart`)
- **Dark & light modes** with persisted preference

## Installation

### Prerequisites

- **Flutter SDK** 3.41+ (Dart 3.11+) — [install guide](https://docs.flutter.dev/get-started/install)
- **CMake** — required because `flutter_soloud` compiles a native audio engine
  - macOS: `brew install cmake`
  - Linux: `sudo apt install cmake ninja-build`
  - Windows: install from [cmake.org](https://cmake.org/download/) (or via Visual Studio's C++ tools)
- A device or emulator:
  - iOS → Xcode + a simulator (`open -a Simulator`)
  - Android → Android Studio + an AVD

Verify your setup:

```bash
flutter doctor
```

### Run

```bash
# 1. Get this project
cd ear_power_check

# 2. Install Dart/Flutter dependencies
flutter pub get

# 3. (iOS only) install native pods — usually automatic on first run
cd ios && pod install && cd ..

# 4. Launch on a connected device / running emulator
flutter devices        # see what's available
flutter run            # pick a device, or:
flutter run -d <id>    # e.g. flutter run -d "iPhone 17"
```

### Build a release binary

```bash
flutter build apk        # Android
flutter build ios        # iOS (then archive in Xcode)
```

### Verify

```bash
flutter analyze          # static analysis (should report no issues)
flutter test             # unit tests (scoring / grading logic)
```

> 🎧 Use **headphones** for the test — left/right tones can't be separated on a single speaker.

## How it works — the full flow

The app walks the user from launch to a scored hearing report:

1. **Splash** (`features/splash/`)
   Animated logo reveal (scale + fade + shimmer) over the ambient gradient background, then auto-transitions to Home after ~2.6 s.

2. **Home** (`features/home/`)
   Glass header with a **dark/light toggle** (persisted via `shared_preferences`), a gradient hero card to start a check, and a staggered grid of feature cards. Tapping **Manual Test** (or the hero) opens the test.
   *Automatic test, standalone Graph, and History cards are placeholders for now.*

3. **Ear Test** (`features/test/ear_test_screen.dart`)
   The core screening loop, driven by `EarTestController`:
   - Steps through **12 tones** — 6 frequencies (250, 500, 1k, 2k, 4k, 8k Hz) × 2 ears (right, then left).
   - `TonePlayer` generates a real **sine wave** with `flutter_soloud`, panned fully to the active ear.
   - The user lowers the volume slider until the tone is **barely audible**, then taps **"I can barely hear it"** (or **"Can't hear it"**). That level is recorded as the **threshold** (in dB HL) for that ear/frequency.
   - A live circular **visualizer** and a glowing ear indicator reflect the active tone; progress ring tracks completion.

4. **Results** (`features/test/results_screen.dart`)
   When all 12 thresholds are collected, the controller builds a `HearingTestResult` and the app transitions here:
   - **Ear Power score (0–100)** revealed in an animated gradient ring, derived from the Pure-Tone Average (PTA) of the speech frequencies.
   - A **grade** (Excellent → Significant loss) with guidance, per-ear PTA summaries, and an **animated audiogram** (`fl_chart`) plotting both ears with the dB axis inverted (clinical convention — lower/better at top).
   - Confetti plays for good results. **Test again** restarts the flow; **Back to home** returns.

### Architecture

```
lib/
├── app.dart                 # root MaterialApp + AppScope (theme + audio singletons)
├── main.dart
├── core/
│   ├── theme/               # colors, gradients, ThemeData, theme controller
│   ├── widgets/             # GlassCard, GradientBackground, AudioVisualizer, buttons, logo
│   ├── navigation/          # custom fade/slide/scale page transitions
│   └── audio/               # TonePlayer — sine-tone generation + L/R panning
└── features/
    ├── splash/
    ├── home/
    └── test/                # controller, models, ear-test + results screens, charts
```

### Key dependencies

| Package | Role |
|---|---|
| `flutter_soloud` | Native audio engine — real-time sine-tone generation & panning |
| `fl_chart` | Animated audiogram chart |
| `flutter_animate` | Declarative entrance/loop animations |
| `flutter_staggered_animations` | Staggered grid/list reveals |
| `google_fonts` | Inter typeface |
| `shimmer` | Shimmer loading effects |
| `shared_preferences` | Persists theme preference (and future history) |

> ⚠️ **Disclaimer:** results are a self-screening, **not a medical diagnosis** — they depend on your headphones, volume, and surroundings. See an audiologist for a clinical evaluation.

## Resources

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Flutter documentation](https://docs.flutter.dev/)
