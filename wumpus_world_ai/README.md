# Wumpus World AI — Reference Solution

This is the **complete, working reference implementation** used by the
trainer. Students should NOT be given this folder before the workshop ends —
hand them `../starter_kit` instead.

## Build verification note

This project was authored in a sandbox with **no network access to
Flutter/Dart's distribution infrastructure** (`storage.googleapis.com`),
so `flutter pub get` / `flutter analyze` could not be run directly here.
To compensate:

1. Every `.dart` file was manually reviewed for syntax, type, and
   null-safety correctness (two real issues were caught and fixed this way:
   a `num`→`double` cast on an `Animation.value.clamp()`, and a `setState`
   that was missing around a state mutation).
2. All `pubspec.yaml` dependency versions were cross-checked **live**
   against pub.dev's package API (`https://pub.dev/api/packages/<name>`)
   to confirm they're current, mutually compatible releases rather than
   stale/guessed version numbers — see the comment above `environment:`
   in `pubspec.yaml`.

**Please still run `flutter pub get && flutter analyze` yourself once**
before the workshop as a final sanity check.

## Run it

```bash
flutter pub get
flutter run -d chrome        # fastest for a classroom (no emulator needed)
```

### Firebase setup (needed for Block 3)

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This generates `lib/firebase_options.dart` (gitignored) wired to your own
Firebase project. Enable **Anonymous Authentication** and create a
**Cloud Firestore** database (test mode is fine for a 2-hour workshop) in the
Firebase console first.

### AI Advisor key (needed for Block 2)

Open `lib/providers/service_providers.dart` and replace `'YOUR_API_KEY_HERE'`
with a free [Groq](https://console.groq.com/keys) (or Gemini-compatible) API
key. If you skip this, the app still runs — `AiAdvisorService` fails
gracefully and shows a fallback message instead of crashing.

## Beyond the 120-minute core curriculum

The reference solution also ships four **extended / stretch features**
that go past the core workshop scope — useful as a trainer demo of "where
this could go next," or as take-home extensions for fast finishers:

| Feature | Where | What it adds |
|---|---|---|
| 🏹 Arrow-shooting | `game_screen.dart` (`_shootArrow`), `wumpus_world_generator.dart` (`recomputePercepts`) | Classic Wumpus World action: fire in a straight line, slay the Wumpus, silence its Stench everywhere |
| 🪜 Climb-out win condition | `game_screen.dart` (`_climbOut`, `_canClimbOut`) | Return to (0,0) with the gold and explicitly climb out to win (vs. only losing by death) |
| 🎬 Animated win/lose dialog | `game_screen.dart` (`_endGame`, `showGeneralDialog` + `CurvedAnimation`) | A scale/fade "victory" or "game over" entrance animation instead of a flat `AlertDialog` |
| 🔍 Cell-inspect panel | `game_screen.dart` (`_showCellDetails`) | Tap any discovered/visited tile for a bottom sheet of what's actually known about it — still respects fog-of-war |
| 🌗 Dark mode | `lib/providers/theme_provider.dart`, `lib/widgets/theme_toggle_button.dart` | A global light/dark "cave" theme toggle — originally a single `ValueNotifier`, now a Riverpod `Notifier` (see "v2" below) |

These are intentionally **not** part of the starter kit's 5 core TODOs —
see `starter_kit/README.md`'s "Stretch Goals" section if you want to offer
them to students who finish early.

## v2: State management, UI/UX, and feature enhancement

A second extension pass reworked the reference solution further, on top of
the four stretch features above. Like those, this is **solution-only** —
the starter kit intentionally stays at the simpler 120-minute-workshop
level (plain `setState`, no Riverpod) so students aren't handed a
state-management framework before the core curriculum covers it.

**Code — state management.** Every mutable piece of app state (the theme,
the player's name, and the entire game — grid, agent, score, advisor hint)
moved out of ad hoc `setState`/`ValueNotifier` fields and into
[Riverpod](https://riverpod.dev) `Notifier`/`NotifierProvider`s:

| Provider | File | Replaces |
|---|---|---|
| `gameControllerProvider` | `lib/state/game_controller.dart`, `lib/state/game_state.dart` | `GameScreen`'s own `State` fields (`_grid`, `_agent`, `_gameOver`, …) |
| `themeModeProvider` | `lib/providers/theme_provider.dart` | `lib/theme/theme_controller.dart`'s `ValueNotifier<ThemeMode>` (file removed) |
| `playerNameProvider` | `lib/providers/player_profile_provider.dart` | the hardcoded `'Explorer'` string previously passed to Firestore |
| `authServiceProvider`, `firestoreServiceProvider`, `aiAdvisorServiceProvider`, `playerProfileServiceProvider` | `lib/providers/service_providers.dart` | services previously constructed inline inside each `StatefulWidget` |

`GameScreen` and `LeaderboardScreen` are now `Consumer(Stateful)Widget`s
that just render whatever state a provider hands them, instead of owning
gameplay logic themselves — which is what makes `GameController`
realistically unit-testable without ever building a widget tree. We used
Riverpod's modern `Notifier` API (not the deprecated `StateNotifier`/
`StateProvider`, which Riverpod 3.x moved to `package:riverpod/legacy.dart`).

**Feature — difficulty levels & settings.** A new `lib/screens/difficulty_screen.dart`
sits between Home and Game: pick **Easy** (4×4, 15% pits, 2 arrows),
**Normal** (6×6, 20% pits, 2 arrows), or **Hard** (8×8, 25% pits, 1 arrow)
before a run starts. `WumpusWorldGenerator` and `CaveGrid` were both
generalised to take a `gridSize` parameter instead of a hardcoded 4×4
board (`lib/models/game_config.dart`).

**Feature — player profile & stats.** Firestore now also stores a running
per-player profile at `players/{uid}` (`lib/models/player_profile.dart`,
`lib/services/player_profile_service.dart`): games played, best score, and
best moves-to-win, updated atomically via a Firestore transaction after
every run. The Home screen shows this as a stats card with an editable
display name (`lib/screens/home_screen.dart`).

**UI/UX — visual polish, onboarding, and accessibility.**
- `lib/widgets/confetti_overlay.dart` — a custom `CustomPainter` +
  `AnimationController` particle burst on a win (no extra package).
- `lib/widgets/animated_score.dart` — the score counter now rolls to its
  new value via `TweenAnimationBuilder` instead of snapping instantly.
- `lib/screens/how_to_play_screen.dart` — a short rules explainer, reachable
  from an info icon on Home and on the Difficulty screen.
- In-game `SnackBar` feedback for key events (moves, gold pickup, arrow
  hit/miss) via `ref.listen` on `GameState.lastEventMessage`, alongside the
  existing move-history panel and win/lose dialog.
- `GameScreen` now uses a `LayoutBuilder` to place the D-pad/shoot controls
  beside the grid on wide (tablet/desktop) screens instead of always
  stacking them vertically.
- `CaveGrid` tiles and the D-pad/shoot buttons carry explicit `Semantics`
  labels for screen readers, and every button keeps a ≥44×44 logical-pixel
  tap target.

This also bumped `environment.sdk` to `'>=3.12.0 <4.0.0'` and added
`flutter_riverpod: ^3.4.3` to `pubspec.yaml` — `flutter_riverpod` declares
`sdk: ^3.12.0`, the highest floor among this project's dependencies (cross-
checked live against `https://pub.dev/api/packages/flutter_riverpod`, same
method as the "Build verification note" above).

## Folder map

| Path | Syllabus area |
|---|---|
| `lib/models/` | OOP — Cell, Agent, Percept, GameConfig, PlayerProfile |
| `lib/mixins/risk_evaluation_mixin.dart` | Mixins |
| `lib/world/wumpus_world_generator.dart` | World generation / percept derivation (parameterised by grid size) |
| `lib/painters/percept_painter.dart` | CustomPainter |
| `lib/state/` | Riverpod `Notifier` + immutable state (`GameController`, `GameState`) |
| `lib/providers/` | Riverpod DI/app-state providers (services, theme, player name/profile) |
| `lib/widgets/cave_grid.dart` | GridView.builder, MediaQuery, AnimatedOpacity, Stack, Semantics |
| `lib/widgets/move_history_list.dart` | ListView.builder |
| `lib/widgets/confetti_overlay.dart` | CustomPainter + AnimationController particle effects |
| `lib/widgets/animated_score.dart` | TweenAnimationBuilder |
| `lib/services/ai_advisor_service.dart` | async/await, http POST, try-catch |
| `lib/services/firestore_service.dart` | Cloud Firestore CRUD + Stream (leaderboard) |
| `lib/services/player_profile_service.dart` | Cloud Firestore transactions (per-player stats) |
| `lib/services/auth_service.dart` | Firebase Anonymous Auth |
| `lib/screens/` | Riverpod `Consumer(Stateful)Widget`s, Navigator, StreamBuilder |

See the root-level `WORKSHOP_GUIDE.md` for the full 120-minute curriculum.
