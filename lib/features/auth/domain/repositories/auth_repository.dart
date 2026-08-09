import '../entities/auth_session.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<AuthSession?> signInWithGoogle();
  Future<void> signOut();
  UserEntity? getCurrentUser();
}
