import 'package:flutter/material.dart';
import '../theme/theme_controller.dart';

/// A small AppBar action that flips between the light "daylight cave" and
/// dark "deep cave" theme. Wrapped in its own `ValueListenableBuilder` so
/// only this icon rebuilds when the theme changes — not the whole screen.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) => IconButton(
        tooltip: 'Toggle light/dark cave',
        icon: Icon(mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
        onPressed: ThemeController.toggle,
      ),
    );
  }
}
