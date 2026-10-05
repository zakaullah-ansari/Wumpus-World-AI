import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_advisor_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/player_profile_service.dart';

/// Plain dependency-injection providers — each service is a stable
/// singleton for the app's lifetime, handed out via `ref.watch`/`ref.read`
/// instead of being constructed inline inside widgets. This is the CODE
/// enhancement: swapping ad-hoc `final x = XService()` fields scattered
/// across StatefulWidgets for one composition root Riverpod manages,
/// which makes every one of these trivially mockable in tests.
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

final playerProfileServiceProvider =
    Provider<PlayerProfileService>((ref) => PlayerProfileService());

// Replace with your Groq/Gemini proxy key. Never commit real keys.
final aiAdvisorServiceProvider =
    Provider<AiAdvisorService>((ref) => AiAdvisorService('YOUR_API_KEY_HERE'));
