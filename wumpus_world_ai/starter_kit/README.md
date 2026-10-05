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
