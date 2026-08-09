import '../../domain/entities/auth_session.dart';
import 'user_model.dart';

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required super.accessToken,
    required super.refreshToken,
    required UserModel super.user,
    super.fcmToken,
    super.deviceToken,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    final userJson = (json['user'] is Map<String, dynamic>)
        ? json['user'] as Map<String, dynamic>
        : json;

    return AuthSessionModel(
      accessToken: (json['access_token'] ?? json['token'] ?? '').toString(),
      refreshToken: (json['refresh_token'] ?? '').toString(),
      user: UserModel.fromJson(userJson),
      fcmToken: json['fcm_token'] as String?,
      deviceToken: json['device_token'] as String?,
    );
  }
}
