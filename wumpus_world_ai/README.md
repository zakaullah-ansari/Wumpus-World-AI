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
