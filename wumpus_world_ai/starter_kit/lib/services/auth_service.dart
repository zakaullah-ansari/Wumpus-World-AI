import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around Firebase Authentication (Syllabus #4). Anonymous
/// sign-in is used so students get real Firebase Auth state (an actual
/// `User` with a `uid`) with zero login-form UI to build.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception('Anonymous sign-in failed: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected auth error: $e');
    }
  }

  User? get currentUser => _auth.currentUser;
}
