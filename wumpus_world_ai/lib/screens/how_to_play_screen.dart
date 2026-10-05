import 'package:flutter/material.dart';

/// UI/UX enhancement: a short, scannable rules explainer so a first-time
/// player isn't dropped into a dark cave with zero context. Reachable from
/// both the Home screen and the Difficulty screen's app bar.
class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  static const _rules = [
    (
      icon: '🎯',
      title: 'The Goal',
      body: 'Find the gold hidden somewhere in the cave, then make your way '
          'back to the entrance at the top-left and Climb Out — without '
          'falling into a pit or running into the Wumpus.',
    ),
    (
      icon: '💨',
      title: 'Breeze',
      body: 'A breeze means a bottomless Pit is in one of the adjacent '
          'cells. You won\'t know which one until you risk stepping closer.',
    ),
    (
      icon: '🤢',
      title: 'Stench',
      body: 'A stench means the Wumpus is lurking in an adjacent cell. '
          'Step into its cell and it\'s game over — unless you shoot it first.',
    ),
    (
      icon: '🏹',
      title: 'Arrows',
      body: 'You carry a limited number of arrows. Fire one in a straight '
          'line to try to slay the Wumpus from a safe distance — a miss '
          'still costs you points, so aim carefully.',
    ),
    (
      icon: '🌫️',
      title: 'Fog of War',
      body: 'Cells you haven\'t visited stay hidden. Entering a cell reveals '
          'it fully; its neighbours become "discovered" (you know a percept '
          'came from nearby) without being fully explored.',
    ),
    (
      icon: '🤖',
      title: 'AI Advisor',
      body: 'Stuck on a risky decision? Ask the AI Advisor — it reads your '
          'current percepts and gives a quick, informal risk estimate for '
          'nearby unvisited cells.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How to Play')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _rules.length,
        separatorBuilder: (_, __) => const Divider(height: 24),
        itemBuilder: (context, index) {
          final rule = _rules[index];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rule.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rule.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(rule.body),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
