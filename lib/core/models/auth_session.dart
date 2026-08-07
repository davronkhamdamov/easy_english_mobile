import 'user_model.dart';

class AuthSession {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final userJson = (json['user'] is Map<String, dynamic>)
        ? json['user'] as Map<String, dynamic>
        : json;

    return AuthSession(
      accessToken: (json['access_token'] ?? json['token'] ?? '').toString(),
      refreshToken: (json['refresh_token'] ?? '').toString(),
      user: UserModel.fromJson(userJson),
    );
  }
}
