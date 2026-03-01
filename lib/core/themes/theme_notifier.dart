import 'package:artsphere/core/services/storage/user_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  () => ThemeModeNotifier(),
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = "theme_mode"; // "light" | "dark" | "system"

  @override
  ThemeMode build() {
    // if you already have sharedPreferencesProvider, use it.
    final prefs = ref.read(sharedPreferencesProvider);
    final raw = prefs.getString(_key) ?? "system";
    return _fromRaw(raw);
  }

  ThemeMode _fromRaw(String raw) {
    switch (raw) {
      case "light":
        return ThemeMode.light;
      case "dark":
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _toRaw(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return "light";
      case ThemeMode.dark:
        return "dark";
      case ThemeMode.system:
        return "system";
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_key, _toRaw(mode));
    state = mode;
  }

  Future<void> toggleDarkMode(bool enabled) async {
    await setMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }
}
