import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/notifications/push_notification_service.dart';
import '../models/auth_session_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthSessionModel> exchangeGoogleToken(String idToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  @override
  Future<AuthSessionModel> exchangeGoogleToken(String idToken) async {
    String? fcmToken = PushNotificationService().fcmToken;
    if (fcmToken == null || fcmToken.isEmpty) {
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        // Fallback or ignore if failed
      }
    }

    final bodyMap = <String, dynamic>{
      'id_token': idToken,
      if (fcmToken != null && fcmToken.isNotEmpty) ...{
        'fcm_token': fcmToken,
        'device_token': fcmToken,
      },
    };

    final res = await _apiClient.post('/api/v1/auth/google', bodyMap);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final session = AuthSessionModel.fromJson(data);

      await _apiClient.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        userId: session.user.id,
      );

      return session;
    } else {
      throw Exception(
        'Backend authentication failed (${res.statusCode}): ${res.body}',
      );
    }
  }
}
