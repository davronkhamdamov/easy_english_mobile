import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogle {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  Future<AuthSession?> call() {
    return repository.signInWithGoogle();
  }
}
