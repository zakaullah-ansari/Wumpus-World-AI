import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_config.dart';
import '../state/game_controller.dart';
import 'game_screen.dart';
import 'how_to_play_screen.dart';

/// FEATURE enhancement: lets the player choose a difficulty (grid size,
/// pit density, starting arrows) before a run starts, instead of always
/// playing the same fixed 4x4 world.
class DifficultyScreen extends ConsumerStatefulWidget {
  const DifficultyScreen({super.key});

  @override
  ConsumerState<DifficultyScreen> createState() => _DifficultyScreenState();
}

class _DifficultyScreenState extends ConsumerState<DifficultyScreen> {
  GameConfig _selected = GameConfig.normal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Cave'),
        actions: [
          IconButton(
            tooltip: 'How to play',
            icon: const Icon(Icons.help_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HowToPlayScreen()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bigger caves mean more cells to explore and higher risk — '
              'pick a difficulty that matches your nerve.',
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: GameConfig.all.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final config = GameConfig.all[index];
                  final isSelected = config.difficulty == _selected.difficulty;
                  return Card(
                    elevation: isSelected ? 4 : 0,
                    color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: RadioListTile<Difficulty>(
                      value: config.difficulty,
                      groupValue: _selected.difficulty,
                      onChanged: (_) => setState(() => _selected = config),
                      title: Text(config.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(config.description),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Game'),
              onPressed: () {
                ref.read(gameControllerProvider.notifier).startNewGame(_selected);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
