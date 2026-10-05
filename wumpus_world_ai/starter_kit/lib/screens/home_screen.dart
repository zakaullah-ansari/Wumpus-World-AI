import 'package:flutter/material.dart';
import '../services/ai_advisor_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';

/// Landing screen: performs Firebase Anonymous Auth, then uses EXPLICIT
/// route navigation (`Navigator.push` with `MaterialPageRoute`, Syllabus #3)
/// to move into the game or leaderboard.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  // Replace with your Groq/Gemini proxy key. Never commit real keys.
  final AiAdvisorService _aiAdvisorService = AiAdvisorService('YOUR_API_KEY_HERE');
  bool _signingIn = false;

  Future<void> _startGame() async {
    setState(() => _signingIn = true);
    try {
      await _authService.signInAnonymously(); // Application State: auth/profile
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GameScreen(
            aiAdvisorService: _aiAdvisorService,
            firestoreService: _firestoreService,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🕳️ Wumpus World AI',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('A knowledge-based agent, in your pocket.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _signingIn ? null : _startGame,
              child: _signingIn
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enter the Cave'),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LeaderboardScreen(firestoreService: _firestoreService),
                ),
              ),
              child: const Text('View Leaderboard'),
            ),
          ],
        ),
      ),
    );
  }
}
