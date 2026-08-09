import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../../../../core/debug/api_logger.dart';
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

    final url = '${ApiClient.baseUrl}/api/v1/auth/google';
    final headers = {'Content-Type': 'application/json'};
    final bodyMap = <String, dynamic>{
      'id_token': idToken,
      if (fcmToken != null && fcmToken.isNotEmpty) ...{
        'fcm_token': fcmToken,
        'device_token': fcmToken,
      },
    };

    final startTime = DateTime.now();
    final log = ApiLogger.instance.logRequest(
      method: 'POST',
      url: url,
      headers: headers,
      body: bodyMap,
    );

    try {
      final res = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(bodyMap),
      );

      ApiLogger.instance.logResponse(
        logItem: log,
        statusCode: res.statusCode,
        headers: res.headers,
        body: res.body,
        duration: DateTime.now().difference(startTime),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final session = AuthSessionModel.fromJson(data);

        await _apiClient.saveTokens(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
        );

        return session;
      } else {
        throw Exception(
          'Backend authentication failed (${res.statusCode}): ${res.body}',
        );
      }
    } catch (e) {
      ApiLogger.instance.logError(
        logItem: log,
        error: e.toString(),
        duration: DateTime.now().difference(startTime),
      );
      rethrow;
    }
  }
}
