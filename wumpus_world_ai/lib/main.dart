import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Requires `flutterfire configure` to generate firebase_options.dart.
    await Firebase.initializeApp();
  } catch (e) {
    // Exception Handling (Syllabus #1): don't crash a UI-only demo/build
    // just because Firebase hasn't been wired up yet.
    debugPrint('Firebase init skipped/failed (ok for local UI-only testing): $e');
  }
  // CODE enhancement: the entire app is now wrapped in a `ProviderScope` —
  // the single root that owns every Riverpod provider's state (theme,
  // game controller, player name/profile, service singletons).
  runApp(const ProviderScope(child: WumpusWorldApp()));
}

class WumpusWorldApp extends ConsumerWidget {
  const WumpusWorldApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'Wumpus World AI',
      themeMode: mode,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
