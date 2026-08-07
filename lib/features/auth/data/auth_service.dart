import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/auth/firebase_auth_service.dart';
import '../../../core/models/auth_session.dart';

class AuthService {
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

  /// Signs in with Google, authenticates with Firebase, exchanges the ID token with Go backend,
  /// saves session tokens securely, and returns an [AuthSession] (or null if canceled).
  Future<AuthSession?> signInWithGoogle() async {
    return await _firebaseAuthService.signInWithGoogle();
  }

  /// Signs out from Google, Firebase, and clears secure storage tokens.
  Future<void> signOut() async {
    await _firebaseAuthService.signOut();
  }

  /// Returns the current signed in Firebase user, if any.
  User? get currentUser => _firebaseAuthService.currentUser;
}
