import 'dart:convert';
import 'package:http/http.dart' as http;

/// Sends the agent's known percepts to a hosted LLM endpoint (Groq / Gemini
/// / any OpenAI-compatible proxy) and returns one short tactical sentence.
///
/// DESIGN NOTE (Syllabus #4 — REST API Integration): this is intentionally
/// "just HTTP + JSON". There is ZERO on-device ML SDK, ZERO native model
/// weights, and ZERO complex tooling — only the `http` package students
/// already understand from any other backend call. That keeps the lesson
/// focused on async Dart + error handling, not AI internals.
class AiAdvisorService {
  // Swap for your own key/proxy. NEVER ship a real key in a public repo —
  // in production, this call should go through a Cloud Function instead.
  static const _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';
  final String apiKey;

  AiAdvisorService(this.apiKey);

  /// THE CORE 10-12 LINE ASYNC HTTP POST (Syllabus #4 requirement).
  ///
  /// TODO (BLOCK 2 — LIVE CODE WITH TRAINER):
  /// 1. Wrap everything in a try/catch (network calls MUST be guarded).
  /// 2. `await http.post(Uri.parse(_endpoint), headers: {...}, body: jsonEncode({...}))`
  ///    - headers need 'Content-Type': 'application/json' and
  ///      'Authorization': 'Bearer $apiKey'.
  ///    - body should jsonEncode a map with a 'model' and a 'messages' list
  ///      containing one {'role': 'user', 'content': '...$perceptSummary...'}.
  /// 3. Chain `.timeout(const Duration(seconds: 8))` so a dead network never
  ///    hangs the UI forever.
  /// 4. If `response.statusCode == 200`, `jsonDecode(response.body)` and
  ///    return `data['choices'][0]['message']['content'] as String`.
  /// 5. Otherwise return a friendly fallback string.
  /// 6. In the `catch (e)` block, return a fallback string too — NEVER let
  ///    this function throw into the UI layer.
  Future<String> getRiskAdvice(String perceptSummary) async {
    throw UnimplementedError('TODO: implement getRiskAdvice');
  }
}
