import 'user_model.dart';

class AuthSession {
  final String accessToken;
  final String refreshToken;
  final UserModel user;
  final String? fcmToken;
  final String? deviceToken;

  AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    this.fcmToken,
    this.deviceToken,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final userJson = (json['user'] is Map<String, dynamic>)
        ? json['user'] as Map<String, dynamic>
        : json;

    return AuthSession(
      accessToken: (json['access_token'] ?? json['token'] ?? '').toString(),
      refreshToken: (json['refresh_token'] ?? '').toString(),
      user: UserModel.fromJson(userJson),
      fcmToken: json['fcm_token'] as String?,
      deviceToken: json['device_token'] as String?,
    );
  }
}
