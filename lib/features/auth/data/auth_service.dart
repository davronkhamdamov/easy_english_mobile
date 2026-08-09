import '../domain/entities/auth_session.dart';
import '../domain/entities/user_entity.dart';
import '../domain/repositories/auth_repository.dart';
import 'repositories/auth_repository_impl.dart';

class AuthService {
  final AuthRepository _repository;

  AuthService({AuthRepository? repository})
    : _repository = repository ?? AuthRepositoryImpl();

  /// Signs in with Google, authenticates with Firebase, exchanges the ID token with Go backend,
  /// saves session tokens securely, and returns an [AuthSession] (or null if canceled).
  Future<AuthSession?> signInWithGoogle() async {
    return await _repository.signInWithGoogle();
  }

  /// Signs out from Google, Firebase, and clears secure storage tokens.
  Future<void> signOut() async {
    await _repository.signOut();
  }

  /// Returns the current signed in user entity, if any.
  UserEntity? get currentUser => _repository.getCurrentUser();
}
