import '../../../../core/network/api_client.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _firebaseAuthDataSource;
  final AuthRemoteDataSource _authRemoteDataSource;
  final ApiClient _apiClient;

  AuthRepositoryImpl({
    FirebaseAuthDataSource? firebaseAuthDataSource,
    AuthRemoteDataSource? authRemoteDataSource,
    ApiClient? apiClient,
  }) : _firebaseAuthDataSource =
           firebaseAuthDataSource ?? FirebaseAuthDataSourceImpl(),
       _authRemoteDataSource =
           authRemoteDataSource ??
           AuthRemoteDataSourceImpl(apiClient: apiClient),
       _apiClient = apiClient ?? ApiClient();

  @override
  Future<AuthSession?> signInWithGoogle() async {
    final userCredential = await _firebaseAuthDataSource.signInWithGoogle();
    if (userCredential == null) return null;

    final user = userCredential.user;
    if (user == null) throw Exception('Firebase authentication failed');

    final idToken = await user.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Failed to retrieve Firebase ID token');
    }

    return await _authRemoteDataSource.exchangeGoogleToken(idToken);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuthDataSource.signOut();
    await _apiClient.clearTokens();
  }

  @override
  UserEntity? getCurrentUser() {
    final fbUser = _firebaseAuthDataSource.currentUser;
    if (fbUser == null) return null;
    return UserEntity(
      id: fbUser.uid,
      email: fbUser.email ?? '',
      fullName: fbUser.displayName ?? '',
      avatarUrl: fbUser.photoURL,
      role: 'student',
    );
  }
}
