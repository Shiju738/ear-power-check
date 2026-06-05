import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds and persists the user's preferred [ThemeMode].
///
/// Exposed as a [ValueNotifier] so the root [MaterialApp] can rebuild on
/// changes without a heavier state-management dependency.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system);

  static const _prefsKey = 'theme_mode';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    value = switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> toggle(bool isDarkNow) async {
    value = isDarkNow ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, value == ThemeMode.dark ? 'dark' : 'light');
  }
}
