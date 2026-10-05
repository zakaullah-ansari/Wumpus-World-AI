import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'theme/theme_controller.dart';

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
  runApp(const WumpusWorldApp());
}

class WumpusWorldApp extends StatelessWidget {
  const WumpusWorldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, mode, _) => MaterialApp(
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
      ),
    );
  }
}
