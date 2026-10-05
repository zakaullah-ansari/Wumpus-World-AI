import 'package:flutter/material.dart';

/// UI/UX enhancement: replaces a static `Text('Score: $score')` with a
/// counter that visibly rolls from the old value to the new one whenever
/// the score changes, using `TweenAnimationBuilder` so no manual
/// `AnimationController` lifecycle is needed.
class AnimatedScore extends StatelessWidget {
  final int score;
  final TextStyle? style;

  const AnimatedScore({super.key, required this.score, this.style});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: score),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Text(
        'Score: $value',
        style: style ?? Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
