# Wumpus World AI — Reference Solution

This is the **complete, working reference implementation** used by the
trainer. Students should NOT be given this folder before the workshop ends —
hand them `../starter_kit` instead.

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

Open `lib/screens/home_screen.dart` and replace `'YOUR_API_KEY_HERE'` with a
free [Groq](https://console.groq.com/keys) (or Gemini-compatible) API key.
If you skip this, the app still runs — `AiAdvisorService` fails gracefully
and shows a fallback message instead of crashing.

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
| 🌗 Dark mode | `lib/theme/theme_controller.dart`, `lib/widgets/theme_toggle_button.dart` | A global light/dark "cave" theme toggle shared via a single `ValueNotifier`, demonstrating minimal shared Application State without a state-management package |

These are intentionally **not** part of the starter kit's 5 core TODOs —
see `starter_kit/README.md`'s "Stretch Goals" section if you want to offer
them to students who finish early.

## Folder map

| Path | Syllabus area |
|---|---|
| `lib/models/` | OOP — Cell, Agent, Percept |
| `lib/mixins/risk_evaluation_mixin.dart` | Mixins |
| `lib/world/wumpus_world_generator.dart` | World generation / percept derivation |
| `lib/painters/percept_painter.dart` | CustomPainter |
| `lib/widgets/cave_grid.dart` | GridView.builder, MediaQuery, AnimatedOpacity, Stack |
| `lib/widgets/move_history_list.dart` | ListView.builder |
| `lib/services/ai_advisor_service.dart` | async/await, http POST, try-catch |
| `lib/services/firestore_service.dart` | Cloud Firestore CRUD + Stream |
| `lib/services/auth_service.dart` | Firebase Anonymous Auth |
| `lib/screens/` | setState, Navigator, StreamBuilder |

See the root-level `WORKSHOP_GUIDE.md` for the full 120-minute curriculum.
