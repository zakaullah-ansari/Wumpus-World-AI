import 'package:flutter/material.dart';

/// A tiny app-wide preference: light "daylight cave" vs. dark "deep cave"
/// theme. This is intentionally the simplest possible shared Application
/// State — a single global `ValueNotifier` — rather than pulling in a full
/// state-management package for one on/off switch.
class ThemeController {
  ThemeController._();

  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.dark);

  static void toggle() {
    mode.value = mode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}
