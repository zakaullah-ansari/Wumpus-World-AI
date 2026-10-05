import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

/// A small AppBar action that flips between the light "daylight cave" and
/// dark "deep cave" theme. CODE enhancement: now backed by a Riverpod
/// `Notifier` (`themeModeProvider`) instead of a bare `ValueNotifier`, so
/// any screen can watch/toggle it through the same `ref` API used for the
/// rest of the app's state.
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return IconButton(
      tooltip: 'Toggle light/dark cave',
      icon: Icon(mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
      onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
    );
  }
}
