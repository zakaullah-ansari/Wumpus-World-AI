# Wumpus World AI — 120-Minute Flutter + Firebase + AI Agent Reasoning Workshop

**Audience:** 3rd-year engineering students, total Flutter beginners
**Duration:** 120 minutes, 3 blocks
**Format:** Fill-in-the-blanks, starter-repo-driven, live-coded with a trainer
**Companion code:** `wumpus_world_ai/` (full reference solution) and
`wumpus_world_ai/starter_kit/` (what students actually receive)

---

## 0. Instructor Design Rationale (Chain-of-Thought Summary)

Before writing the curriculum, the following four design questions were
resolved — they explain *why* the app and agenda look the way they do.

**Step 1 — Environment & State Data Modeling.**
A 4x4 cave cell has six overlapping booleans. Beginners drown in these if
they're flattened into one undifferentiated list. The fix: group them by
*epistemic category*, not alphabetically —
(a) **ground truth** the world knows (`hasPit`, `hasWumpus`, `hasGold`),
(b) **derived percepts** sensed from neighbours (`hasBreeze`, `hasStench`),
(c) **player knowledge / fog-of-war** (`isVisited`, `isDiscovered`).
This mirrors exactly how a real knowledge-based agent reasons: *world
state* → *sensors* → *belief state*. It's also a teachable, interview-ready
story: "I modeled epistemic uncertainty as a first-class part of my data
layer," not just "I made a grid of bools."

**Step 2 — AI REST API Integration Architecture.**
The AI "tactical advisor" is a single `http.post()` call to any
OpenAI-compatible chat endpoint (Groq / Gemini-via-proxy), sending a plain
English percept string and receiving plain English/JSON back. No on-device
model, no TensorFlow Lite, no native SDK, no vector DB. This keeps the
cognitive load on **async Dart + JSON + error handling** — the actual
syllabus target — while still letting students truthfully say "I integrated
an LLM into a mobile app" on their résumé.

**Step 3 — Syllabus Mapping Verification.**
Every one of the 11 required syllabus bullet points was matched to one (and
usually exactly one) concrete file/feature in the app *before* any code was
written, so nothing is vestigial or "for show." See the table in Section 2.

**Step 4 — Time & Cognitive Load Optimization.**
Anything that is purely *scaffolding* (pubspec, theming, navigation
shell, world generator/RNG, data models) ships pre-written in the starter
repo — it teaches nothing new to re-type and would burn the clock. Anything
that is a **named syllabus topic** is left as a guided TODO the students
type themselves, because muscle-memory typing is where retention actually
happens. This produced exactly **5 live-coded exercises**, each mapped to
one block (see Section 4 and the starter kit's `README.md`).

---

## 1. Final Project Concept & Elevator Pitch

**Project name:** 🕳️ **Wumpus World AI**

**Elevator pitch (2 sentences):** Wumpus World AI reimagines Stuart
Russell & Peter Norvig's classic AI benchmark — a 4x4 cave hiding pits, a
Wumpus, and gold — as a cross-platform Flutter app where every tile is
fogged until the player's knowledge-based agent senses breeze/stench
percepts and reasons about risk. A live LLM "Risk Advisor" and a real-time
Firebase leaderboard turn a textbook AI exercise into a shippable product
with cloud infrastructure behind it.

**Why this stands out to technical interviewers:** Most student portfolios
are to-do apps or weather-API clones — CRUD with a UI. Wumpus World AI is
instead a **knowledge-based agent**: state is uncertain, percepts are
probabilistic, and decisions are risk-weighted — the same mental model
behind recommendation engines, autonomous navigation, and fraud-risk
scoring. Pairing that with Firebase Auth/Firestore and a real LLM REST call
lets a 3rd-year student credibly say they built something that touches
*classical AI reasoning, mobile engineering, and applied LLM integration*
in one 120-minute artifact — a combination interviewers rarely see from
undergrads, and one that opens natural follow-up conversations in an
interview (vs. a to-do app, which invites none).

---

## 2. Comprehensive Syllabus-to-Feature Mapping Table

| Syllabus Area | Specific Requirement | Exact Role in Wumpus World AI |
|---|---|---|
| **Dart Foundations** | OOP (Cell, Agent, Percepts) | `lib/models/cell.dart`, `agent.dart`, `percept.dart` — plain classes modeling world truth, the player, and a sensed snapshot |
| **Dart Foundations** | Mixins | `lib/mixins/risk_evaluation_mixin.dart` — `RiskEvaluationMixin` adds scoring + `estimateLocalRisk()` to `Agent` via `with`, without forcing an inheritance chain |
| **Dart Foundations** | Exception Handling | `try/catch` around the Firestore write in `firestore_service.dart`, the HTTP call in `ai_advisor_service.dart`, and Firebase Auth in `auth_service.dart` — every network/DB boundary is guarded |
| **Dart Foundations** | Async (`Future`, delays, API calls) | `Future<String> getRiskAdvice()` (AI call), `Future<void> submitRun()` (Firestore write), `Future<User?> signInAnonymously()` (Auth) — all `async`/`await` |
| **Dart Foundations** | Stream handling | `Stream<List<LeaderboardEntry>> topRunsStream()` in `firestore_service.dart`, consumed by a `StreamBuilder` |
| **Flutter UI** | Single & multi-child widgets (Column/Row/Container/Stack) | `game_screen.dart` layout (`Column` of grid + D-pad + advisor bar + history); `_CaveTile` uses `Stack` to layer fog over percept badges |
| **Flutter UI** | `MediaQuery` adaptive scaling | `cave_grid.dart` reads `MediaQuery.of(context).size.width` to size the 4x4 board for phone vs. tablet/web |
| **Flutter UI** | `GridView.builder` | `cave_grid.dart` renders the 16 cave cells |
| **Flutter UI** | `ListView.builder` | `move_history_list.dart` renders the scrolling move log; `leaderboard_screen.dart` renders ranked runs |
| **Flutter UI** | Animations (`AnimatedOpacity` fog reveal) | `_CaveTile` fades a tile from `opacity: 0.0` (hidden) → `0.35` (discovered) → `1.0` (visited) |
| **Flutter UI** | `CustomPainter` | `percept_painter.dart` — `PerceptPainter` draws the green stench "fog cloud" (RadialGradient) and the blue breeze "wind vector" arrows directly on canvas |
| **State & Navigation** | Ephemeral state (`setState`) | `game_screen.dart` — grid movement, fog reveal, score updates all mutate via `setState` |
| **State & Navigation** | Application state (auth/profile) | `auth_service.dart` + `FirebaseAuth.instance.currentUser` persists identity across the whole app session, outside any one screen's ephemeral state |
| **State & Navigation** | Explicit route navigation | `Navigator.push(context, MaterialPageRoute(...))` in `home_screen.dart` (→ Game, → Leaderboard) and `game_screen.dart` (→ Leaderboard on game over) |
| **Firebase & APIs** | Firebase Authentication | `auth_service.dart` — Anonymous sign-in on "Enter the Cave" |
| **Firebase & APIs** | Cloud Firestore real-time CRUD | `firestore_service.dart` — `submitRun()` (Create) + `topRunsStream()` (Read, real-time, ordered, limited) against the `cave_runs` collection |
| **Firebase & APIs** | REST API integration (AI advisor) | `ai_advisor_service.dart` — `http.post()` to a Groq/Gemini-compatible chat endpoint, sending percept text, parsing JSON, returning a hint string |

Every syllabus bullet has **at least one** concrete, student-editable file.
Nothing in the required list is left unmapped.

---

## 3. Deep-Dive Concept Analogy Breakdown

### 3.1 Fog-of-War Matrix (`GridView.builder`)
**Beginner analogy:** Imagine a 4x4 sheet of scratch-off lottery tickets
taped to a wall. `GridView.builder` is the person taping them up — given a
`crossAxisCount: 4` and an `itemBuilder`, it asks "what goes in square #0?
square #1? …" and places each answer in a perfect grid, without you
manually computing pixel positions.
**Production mental model:** `GridView.builder` is *lazy* — exactly like
`ListView.builder`, it only builds the widgets currently on/near screen.
For a fixed 4x4 board this performance distinction barely matters, but the
habit matters enormously the day a junior dev reuses this pattern for a
500-row data table and it doesn't jank. Pair it with `MediaQuery` the same
way production apps do: don't hardcode `480.0`, derive it from
`MediaQuery.of(context).size.width` so the exact same widget tree is
correct on a 5" phone, a foldable, and a Chrome tab.

### 3.2 Ephemeral vs. App State in games
**Beginner analogy:** Ephemeral state is like your position on a
Monopoly board mid-game — it only matters while that specific game is being
played, and resets when you start a new one. App state is like your *name
on the Monopoly box lid* — it persists whether or not a game is currently
in progress, and every game you play is "tagged" with it.
**Production mental model:** `setState` inside `_GameScreenState` is
correct for `_agent.row`, `_agent.score`, fog flags — none of that should
outlive the `GameScreen` widget, and nothing else in the app needs to read
it. Firebase Auth's `currentUser`, by contrast, is **application state**:
it must survive navigation, screen rebuilds, and even app restarts (session
persistence). The tell-tale interview question is "why didn't you just put
everything in one global state object?" — the answer is scope and
lifecycle: collapsing them wastes memory, causes unrelated widgets to
rebuild, and makes testing harder. (This is also exactly the reasoning that
later motivates Provider/Riverpod/Bloc — but for a 2-hour workshop,
`setState` + a plain service class is the honest, correctly-scoped choice.)

### 3.3 `StreamBuilder` vs. `FutureBuilder`
**Beginner analogy:** `FutureBuilder` is checking your exam result **once**
on the results-day website — you refresh, you get one answer, done.
`StreamBuilder` is a **live sports scoreboard** — it keeps updating itself
automatically every time the score changes, with no manual refresh.
**Production mental model:** Use `FutureBuilder` for one-shot reads (e.g.
"fetch this user's profile once"). Use `StreamBuilder` whenever *other
people's actions* should be reflected live in your UI — exactly the
leaderboard case: when another student finishes a run anywhere in the
world, Firestore pushes a new snapshot and every open `LeaderboardScreen`
re-renders without anyone hitting refresh. The architectural cost is a
standing subscription (remember: `StreamBuilder` disposes it for you when
the widget is removed — that's precisely why we don't manage
`StreamSubscription` manually here).

### 3.4 `CustomPainter` canvas layers
**Beginner analogy:** A `CustomPainter` is a sheet of transparent acetate
film laid on a table. You're handed a marker (`Canvas`) and the sheet's
dimensions (`Size`), and every `canvas.draw...()` call is literally one
more mark on that sheet — order matters, and later marks sit on top of
earlier ones, exactly like stacking acetate layers in old hand-drawn
animation.
**Production mental model:** Unlike declarative widgets, `CustomPainter`
gives you **zero automatic layout** — you own every coordinate, and you own
performance: `shouldRepaint()` is the contract that tells Flutter whether
to re-run `paint()` at all (we key it off `hasBreeze`/`hasStench` so static
tiles never repaint needlessly). This is the exact tool production teams
reach for when a design calls for something a widget tree genuinely can't
express cheaply — gauges, signal-strength bars, custom chart overlays, or
here: sensory "badges" that need radial gradients and vector arrows no
`Icon` could replicate.

---

## 4. 120-Minute Step-by-Step Trainer Execution Agenda

> Legend: 🟢 pre-built in starter repo (walk through, don't re-type) · 🟠 live-coded TODO (students type, trainer narrates) · 🔵 instructor demo only

### Block 1 — Grid UI & State (0–45 min)

| Min | Activity | Type |
|---|---|---|
| 0–10 | Kickoff: show the finished app running (reference solution) on web. Explain Wumpus World rules (pits, Wumpus, gold, percepts) and the SMART goals for the session. | 🔵 |
| 10–18 | Starter repo walkthrough: clone `starter_kit/`, `flutter pub get`, `flutter run -d chrome`. Tour `lib/models/`, `lib/world/wumpus_world_generator.dart`, `main.dart`, `home_screen.dart` — emphasize these are **given**, not written today. | 🟢 |
| 18–26 | Explain `Cell`'s 3-category boolean model (ground truth / derived percepts / fog-of-war) using the Step-1 analogy ("truth card"). Walk `cave_grid.dart`'s `GridView.builder` + `MediaQuery` sizing + `Stack`/`AnimatedOpacity` shell (pre-built, not yet wired to real moves). | 🟢 |
| 26–40 | **Exercise 1 (live-coded):** implement `_move()` and `_revealFog()` in `game_screen.dart` — bounds-check, `setState`, mutate `_agent`, call `_agent.recordMove()`, detect pit/Wumpus/gold. Wire the D-pad buttons (already built) to `_move`. | 🟠 |
| 40–45 | Run it: tap the D-pad, watch fog reveal animate in, confirm score decrements per move. Quick Q&A / troubleshooting. | 🔵 |

### Block 2 — Fog-of-War Animations, CustomPainter & AI REST Advisor (45–90 min)

| Min | Activity | Type |
|---|---|---|
| 45–52 | Recap `AnimatedOpacity` fog fade (already functional after Block 1). Introduce Mixins with the "acetate/superpower" framing; show `Agent with RiskEvaluationMixin`. | 🟢 |
| 52–62 | **Exercise 2 (live-coded):** implement the 4 score mutators + `estimateLocalRisk()` in `risk_evaluation_mixin.dart`. Test by printing `_agent.score` after a move. | 🟠 |
| 62–75 | **Exercise 3 (live-coded):** implement `PerceptPainter.paint()` — stench `RadialGradient` circle, then breeze "wind vector" loop with `cos`/`sin` angles. Hot-reload after each half to see badges appear live on the grid. | 🟠 |
| 75–88 | **Exercise 4 (live-coded):** implement `getRiskAdvice()` in `ai_advisor_service.dart` — the 10-12 line `http.post()` with headers/body/timeout, `jsonDecode`, and a `try/catch` fallback. Wire an API key, tap "Ask AI Advisor," read the live hint on-device. | 🟠 |
| 88–90 | Discuss graceful degradation: what happens with no API key / no network (the app never crashes — this is the Exception Handling syllabus point in action). | 🔵 |

### Block 3 — Cloud Firestore Leaderboard & Resume Framing (90–120 min)

| Min | Activity | Type |
|---|---|---|
| 90–98 | Firebase console tour: enable Anonymous Auth + create Firestore DB (test mode). Run `flutterfire configure`. Explain `auth_service.dart` (already built) and **Application State** vs. **Ephemeral State**. | 🟢 |
| 98–105 | Walk `firestore_service.dart`'s `submitRun()` (already built, Create + try/catch) and the `cave_runs` collection shape. Confirm a completed run (win or death) writes a document — check it appear live in the Firebase console. | 🟢 |
| 105–115 | **Exercise 5 (live-coded):** implement the `StreamBuilder<List<LeaderboardEntry>>` in `leaderboard_screen.dart` — loading/error/empty states, `ListView.builder` of ranked runs. Open two browser tabs side-by-side, finish a run in one, watch the other update live with **zero refresh**. | 🟠 |
| 115–120 | **Resume framing exercise:** students fill in the 3 résumé bullet points (Section 6) using *their own* numbers (e.g. grid size, # of Firestore reads, actual tech stack) and paste them into a shared doc / LinkedIn draft. Wrap-up + syllabus recap against Section 2's table. | 🔵 |

**Cognitive-load rule used throughout:** boilerplate that teaches nothing
new today (pubspec, theming, navigation shell, RNG-based world generation,
all data model classes) is 🟢 pre-built; every 🟠 block is a *named*
syllabus topic the student must produce with their own hands, so by minute
120 every required syllabus item in Section 2 has been either explained
live or physically typed by the student.

---

## 5. Complete Production Codebase & Starter Snippets

Full, runnable versions of all files below live in this repo:
- **Reference solution:** [`wumpus_world_ai/`](./wumpus_world_ai)
- **Student starter kit (fill-in-the-blanks):** [`wumpus_world_ai/starter_kit/`](./wumpus_world_ai/starter_kit) — search for `TODO (BLOCK` to find all 5 exercises

### a) `RiskEvaluationMixin` — scoring & risk assessment

```dart
// lib/mixins/risk_evaluation_mixin.dart
import '../models/cell.dart';

/// A MIXIN is a "superpower" bolted onto a class without classic
/// single-parent inheritance. `Agent` borrows scoring/risk behaviour here
/// instead of inheriting it, because Dart only allows one superclass.
mixin RiskEvaluationMixin {
  int score = 0; // mixins CAN hold their own state in Dart.

  static const int moveCost = -1;
  static const int goldReward = 1000;
  static const int deathPenalty = -1000;
  static const int climbOutBonus = 10;

  void applyMoveCost() => score += moveCost;
  void applyGoldBonus() => score += goldReward;
  void applyDeathPenalty() => score += deathPenalty;
  void applyClimbOutBonus() => score += climbOutBonus;

  /// Cheap LOCAL heuristic used before ever calling the (slower, async)
  /// AI REST API: counts how many already-visited neighbours of [cell]
  /// reported a danger percept, expressed as a 0-100% risk score.
  double estimateLocalRisk(Cell cell, List<Cell> visitedNeighbours) {
    if (visitedNeighbours.isEmpty) return 50.0; // no evidence -> moderate risk
    final dangerSignals =
        visitedNeighbours.where((c) => c.hasBreeze || c.hasStench).length;
    return (dangerSignals / visitedNeighbours.length) * 100;
  }
}
```

### b) `PerceptPainter` — `CustomPainter` for breeze/stench badges

```dart
// lib/painters/percept_painter.dart
import 'dart:math';
import 'package:flutter/material.dart';

/// Paints a green "stench fog cloud" (RadialGradient) and blue "breeze
/// wind vectors" (4 outward arrows) directly onto a single cave tile.
class PerceptPainter extends CustomPainter {
  final bool hasBreeze;
  final bool hasStench;
  PerceptPainter({required this.hasBreeze, required this.hasStench});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    if (hasStench) {
      final stenchPaint = Paint()
        ..shader = RadialGradient(
          colors: [Colors.green.withOpacity(0.55), Colors.green.withOpacity(0.0)],
        ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.5));
      canvas.drawCircle(center, size.width * 0.5, stenchPaint);
    }

    if (hasBreeze) {
      final windPaint = Paint()
        ..color = Colors.lightBlueAccent
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      for (int i = 0; i < 4; i++) {
        final angle = (pi / 2) * i + pi / 4;
        final direction = Offset(cos(angle), sin(angle));
        final start = center + direction * (size.width * 0.15);
        final end = center + direction * (size.width * 0.38);
        canvas.drawLine(start, end, windPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PerceptPainter oldDelegate) =>
      oldDelegate.hasBreeze != hasBreeze || oldDelegate.hasStench != hasStench;
}
```

### c) Async HTTP POST → AI tactical advisor (REST API Integration)

```dart
// lib/services/ai_advisor_service.dart (core method — 12 lines)
Future<String> getRiskAdvice(String perceptSummary) async {
  try {
    final response = await http
        .post(
          Uri.parse(_endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': 'llama-3.1-8b-instant',
            'messages': [
              {'role': 'user', 'content': 'Percepts: $perceptSummary. Estimate risk %.'}
            ],
          }),
        )
        .timeout(const Duration(seconds: 8));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String;
    }
    return 'Advisor unavailable (HTTP ${response.statusCode}).';
  } catch (e) {
    return 'Advisor offline ($e).'; // network/timeout/parse never crashes the game
  }
}
```

Sample prompt sent for `Cell (1,1): [Clean]` → `Cell (1,2): [Breeze]`:

> "You are a Wumpus World risk advisor. Percepts: Cell (1,2): [Breeze].
> In ONE short sentence, estimate the risk percentage of the nearest
> unvisited cell."

No native ML SDK, no on-device model weights — just `http` + `dart:convert`.

### d) Cloud Firestore `StreamBuilder` — live "top safe cave runs"

```dart
// lib/services/firestore_service.dart (stream half)
Stream<List<LeaderboardEntry>> topRunsStream({int limit = 10}) {
  return FirebaseFirestore.instance
      .collection('cave_runs')
      .orderBy('score', descending: true)
      .limit(limit)
      .snapshots()
      .map((snap) => snap.docs.map(LeaderboardEntry.fromDoc).toList());
}
```

```dart
// lib/screens/leaderboard_screen.dart
StreamBuilder<List<LeaderboardEntry>>(
  stream: firestoreService.topRunsStream(),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return Center(child: Text('Could not load leaderboard: ${snapshot.error}'));
    }
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    final runs = snapshot.data ?? [];
    if (runs.isEmpty) return const Center(child: Text('No runs yet!'));
    return ListView.builder(
      itemCount: runs.length,
      itemBuilder: (context, i) => ListTile(
        leading: CircleAvatar(child: Text('#${i + 1}')),
        title: Text(runs[i].playerName),
        subtitle: Text('${runs[i].movesUsed} moves'),
        trailing: Text('${runs[i].score} pts'),
      ),
    );
  },
)
```

---

## 6. Resume-Ready Student Bullet Points

1. **Architected an AI knowledge-based agent simulation in Flutter/Dart**,
   modeling uncertain world state (hidden pits, Wumpus, gold) across a 4x4
   grid with percept-driven fog-of-war, custom `CustomPainter` sensory
   overlays, and a reusable `Mixin`-based risk-scoring engine.
2. **Integrated a cloud LLM REST API (Groq/Gemini) via asynchronous Dart**
   (`Future`/`async`-`await`, `http`, `dart:convert`) to deliver real-time,
   probabilistic tactical risk advice, with fully guarded exception
   handling to keep the app resilient to network failures.
3. **Built a real-time, multi-user leaderboard with Firebase Authentication
   and Cloud Firestore**, using `Stream`-based live data sync
   (`StreamBuilder`) so every completed game run updates all connected
   clients instantly without manual refresh or polling.
