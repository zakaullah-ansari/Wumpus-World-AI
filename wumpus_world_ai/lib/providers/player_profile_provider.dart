import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_profile.dart';
import 'service_providers.dart';

/// The player's chosen display name, kept as simple reactive app state
/// (Syllabus-style "Application State", now formalised via Riverpod
/// instead of a ValueNotifier/ChangeNotifier). Defaults to 'Explorer' for
/// anonymous players who never bother naming themselves.
class PlayerNameController extends Notifier<String> {
  @override
  String build() => 'Explorer';

  void setName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    state = trimmed;
  }
}

final playerNameProvider = NotifierProvider<PlayerNameController, String>(PlayerNameController.new);

/// Live stream of the signed-in player's Firestore profile (stats card on
/// the Home screen). Resolves to `null` if nobody is signed in yet.
final playerProfileStreamProvider = StreamProvider.autoDispose<PlayerProfile>((ref) {
  final uid = ref.watch(authServiceProvider).currentUser?.uid;
  if (uid == null) return Stream<PlayerProfile>.empty();
  return ref.watch(playerProfileServiceProvider).watchProfile(uid);
});
