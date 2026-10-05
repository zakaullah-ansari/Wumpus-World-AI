# Wumpus World AI — Student Starter Kit

Welcome! This repo already contains the **static UI shell, layouts, models,
and world generator** — fully working. Your job during the workshop is to
fill in **5 TODO blocks** that bring the game to life. Search the codebase
for `TODO (BLOCK` to find every exercise.

```bash
flutter pub get
flutter run -d chrome
```

The app will run immediately, even before you touch any TODO — movement
just won't do anything yet, the tiles won't show sensory badges, the AI
button will throw, and the leaderboard will show a placeholder. That's
expected! You'll fix each one, block by block.

## Your 5 exercises

| # | File | Block | What you'll implement |
|---|---|---|---|
| 1 | `lib/screens/game_screen.dart` | 1 (0-45 min) | `_move()` + `_revealFog()` — ephemeral state via `setState`, fog-of-war reveal |
| 2 | `lib/mixins/risk_evaluation_mixin.dart` | 2 (45-90 min) | Score mutators + `estimateLocalRisk()` — a Mixin |
| 3 | `lib/painters/percept_painter.dart` | 2 (45-90 min) | `paint()` — CustomPainter breeze/stench badges |
| 4 | `lib/services/ai_advisor_service.dart` | 2 (45-90 min) | `getRiskAdvice()` — async HTTP POST to an AI endpoint |
| 5 | `lib/screens/leaderboard_screen.dart` | 3 (90-120 min) | `StreamBuilder` wired to Cloud Firestore |

## Setup you'll need

1. **Firebase**: run `flutterfire configure` (trainer will provide a shared
   test project, or create your own). Enable Anonymous Auth + Firestore.
2. **AI key**: get a free key at https://console.groq.com/keys and paste it
   into `lib/screens/home_screen.dart` where you see `YOUR_API_KEY_HERE`.

Good luck, Explorer — don't step on a Wumpus. 🕳️

## Stretch Goals (optional — if you finish all 5 exercises early)

The trainer's reference solution (`../lib/`) implements four extra features
past the core curriculum. Once your 5 TODOs are working, try adding one
yourself (peek at the reference solution if you get stuck):

1. **🏹 Arrow-shooting** — give the agent an `arrows` counter (already on
   the `Agent` model!) and a "shoot" action that fires in a straight line
   until it hits the Wumpus or exits the grid. Don't forget to recompute
   Stench everywhere once the Wumpus is dead.
2. **🪜 A real win condition** — right now the game only ends in death.
   Add a "Climb Out" button, enabled only when the agent is back at (0,0)
   carrying the gold, that ends the game as a win.
3. **🎬 A nicer result screen** — swap the plain `AlertDialog` for a
   `showGeneralDialog` with a custom `transitionBuilder` (try `Transform.scale`
   driven by a `CurvedAnimation`) for an animated win/lose entrance.
4. **🔍 A cell-inspect panel** — wire up `CaveGrid`'s `onCellTap` to open a
   `showModalBottomSheet` summarizing what's known about that cell. Be
   careful not to leak information the fog-of-war hasn't earned yet!
5. **🌗 Dark mode** — add a `ValueNotifier<ThemeMode>` and a toggle button
   in the AppBar, consumed by `MaterialApp`'s `themeMode`.
