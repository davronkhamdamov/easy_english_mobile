import 'user_entity.dart';

class AuthSession {
  final String accessToken;
  final String refreshToken;
  final UserEntity user;
  final String? fcmToken;
  final String? deviceToken;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    this.fcmToken,
    this.deviceToken,
  });
}
