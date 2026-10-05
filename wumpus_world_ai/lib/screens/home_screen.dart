import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_profile.dart';
import '../providers/player_profile_provider.dart';
import '../providers/service_providers.dart';
import '../widgets/theme_toggle_button.dart';
import 'difficulty_screen.dart';
import 'how_to_play_screen.dart';
import 'leaderboard_screen.dart';

/// Landing screen: performs Firebase Anonymous Auth, then uses EXPLICIT
/// route navigation (`Navigator.push` with `MaterialPageRoute`, Syllabus #3)
/// to move into the Difficulty screen (FEATURE: choose grid size/pit
/// density before a run) or the leaderboard.
///
/// FEATURE enhancement: also shows a Player Profile card (games played,
/// best score, best moves) streamed live from Firestore, with a
/// name-edit dialog.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _signingIn = false;
  bool _syncedNameOnce = false;

  Future<void> _startGame() async {
    setState(() => _signingIn = true);
    try {
      await ref.read(authServiceProvider).signInAnonymously(); // Application State: auth/profile
      // The profile stream provider reads `currentUser` only once per
      // (re)build; invalidate it now so it picks up the freshly-signed-in
      // uid instead of staying stuck on its pre-auth `Stream.empty()`.
      ref.invalidate(playerProfileStreamProvider);
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => const DifficultyScreen()));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

  Future<void> _editName(String currentName) async {
    final controller = TextEditingController(text: currentName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your explorer name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 24,
          decoration: const InputDecoration(hintText: 'e.g. Indiana'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newName == null || newName.trim().isEmpty) return;
    final trimmed = newName.trim();
    ref.read(playerNameProvider.notifier).setName(trimmed);
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid != null) {
      try {
        await ref.read(playerProfileServiceProvider).updateDisplayName(uid, trimmed);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(playerProfileStreamProvider);

    // Keep `playerNameProvider` (what GameController submits runs under)
    // in sync with whatever name is already saved in Firestore, the first
    // time real profile data arrives.
    ref.listen<AsyncValue<PlayerProfile>>(playerProfileStreamProvider, (previous, next) {
      final profile = next.value;
      if (!_syncedNameOnce && profile != null && profile.gamesPlayed > 0) {
        _syncedNameOnce = true;
        ref.read(playerNameProvider.notifier).setName(profile.displayName);
      }
    });

    final playerName = ref.watch(playerNameProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wumpus World AI'),
        actions: [
          IconButton(
            tooltip: 'How to play',
            icon: const Icon(Icons.help_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HowToPlayScreen()),
            ),
          ),
          const ThemeToggleButton(),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🕳️ Wumpus World AI',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('A knowledge-based agent, in your pocket.', textAlign: TextAlign.center),
                const SizedBox(height: 20),
                _ProfileCard(
                  playerName: playerName,
                  profileAsync: profileAsync,
                  onEditName: () => _editName(playerName),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _signingIn ? null : _startGame,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(220, 48)),
                  child: _signingIn
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Enter the Cave'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                  ),
                  child: const Text('View Leaderboard'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String playerName;
  final AsyncValue<PlayerProfile> profileAsync;
  final VoidCallback onEditName;

  const _ProfileCard({
    required this.playerName,
    required this.profileAsync,
    required this.onEditName,
  });

  @override
  Widget build(BuildContext context) {
    final profile = profileAsync.value ?? PlayerProfile.empty;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(playerName.isNotEmpty ? playerName[0].toUpperCase() : '?')),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(playerName, style: Theme.of(context).textTheme.titleMedium),
                ),
                IconButton(
                  tooltip: 'Edit name',
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEditName,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Stat(label: 'Games', value: '${profile.gamesPlayed}'),
                _Stat(label: 'Best Score', value: '${profile.bestScore}'),
                _Stat(
                  label: 'Best Moves',
                  value: profile.hasWonBefore ? '${profile.bestMoves}' : '—',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
