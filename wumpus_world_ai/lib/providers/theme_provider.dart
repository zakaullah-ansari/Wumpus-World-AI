import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Light "daylight cave" vs. dark "deep cave" theme, modeled as a Riverpod
/// [Notifier] (the modern replacement for the older StateNotifier/
/// StateProvider APIs). Any widget can `ref.watch(themeModeProvider)` to
/// react to it, or `ref.read(themeModeProvider.notifier).toggle()` to
/// flip it.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
