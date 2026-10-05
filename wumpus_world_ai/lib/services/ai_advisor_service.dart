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
                {
                  'role': 'user',
                  'content':
                      'You are a Wumpus World risk advisor. Percepts: '
                      '$perceptSummary. In ONE short sentence, estimate the '
                      'risk percentage of the nearest unvisited cell.',
                }
              ],
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      }
      return 'Advisor unavailable (HTTP ${response.statusCode}). Trust your instincts!';
    } catch (e) {
      // Network failures, timeouts, or bad JSON must NEVER crash the game.
      return 'Advisor offline ($e). Fall back to local risk estimate.';
    }
  }
}
