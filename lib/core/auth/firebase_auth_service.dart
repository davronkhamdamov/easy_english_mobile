import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import '../debug/api_logger.dart';
import '../models/auth_session.dart';
import '../notifications/push_notification_service.dart';

class FirebaseAuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  final ApiClient _apiClient = ApiClient();
  static String get baseUrl => ApiClient.baseUrl;

  /// Signs in with Google, authenticates with Firebase, exchanges the ID token with Go backend,
  /// saves the session securely in FlutterSecureStorage, and returns an [AuthSession].
  Future<AuthSession?> signInWithGoogle() async {
    // 1. Trigger Google Sign-In UI on mobile device
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // User cancelled

    // 2. Obtain Google Auth tokens
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // 3. Sign into Firebase with Google credentials
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    final User? user = userCredential.user;
    if (user == null) throw Exception('Firebase authentication failed');

    // 4. Extract ID token and FCM token
    final String idToken = (await user.getIdToken()) ?? googleAuth.idToken ?? '';
    String? fcmToken = PushNotificationService().fcmToken;
    if (fcmToken == null || fcmToken.isEmpty) {
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        // Fallback or ignore if failed
      }
    }

    // 5. Exchange token with Go Backend Gateway
    final url = '$baseUrl/api/v1/auth/google';
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
        final session = AuthSession.fromJson(data);

        // Securely store access and refresh tokens
        await _apiClient.saveTokens(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
        );

        return session;
      } else {
        throw Exception('Backend authentication failed (${res.statusCode}): ${res.body}');
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

  /// Signs out from Google, Firebase, and clears secure storage tokens.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    await _apiClient.clearTokens();
  }

  User? get currentUser => _auth.currentUser;
}
