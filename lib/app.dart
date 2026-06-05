import 'package:flutter/material.dart';

import 'core/audio/tone_player.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/splash/splash_screen.dart';

/// Provides app-wide singletons (theme + audio) to the widget tree.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.themeController,
    required this.tonePlayer,
    required super.child,
  });

  final ThemeController themeController;
  final TonePlayer tonePlayer;

  /// Looks up the scope without registering a dependency, so it is safe to
  /// call from `initState`. The held singletons never change for the app's
  /// lifetime, so dependency tracking isn't needed.
  static AppScope of(BuildContext context) {
    final scope =
        context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      themeController != oldWidget.themeController ||
      tonePlayer != oldWidget.tonePlayer;
}

/// Root widget: wires theme controller into [MaterialApp] and hosts the
/// app-wide singletons.
class EarPowerApp extends StatefulWidget {
  const EarPowerApp({super.key});

  @override
  State<EarPowerApp> createState() => _EarPowerAppState();
}

class _EarPowerAppState extends State<EarPowerApp> {
  final ThemeController _themeController = ThemeController();
  final TonePlayer _tonePlayer = TonePlayer();

  @override
  void initState() {
    super.initState();
    _themeController.load();
  }

  @override
  void dispose() {
    _tonePlayer.dispose();
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      themeController: _themeController,
      tonePlayer: _tonePlayer,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: _themeController,
        builder: (context, mode, _) {
          return MaterialApp(
            title: 'Ear Power Check',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: mode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
