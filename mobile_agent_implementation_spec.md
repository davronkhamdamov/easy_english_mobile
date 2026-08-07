# Mobile AI Agent Implementation Specification & Prompt

> **Instruction for Mobile AI Coding Agent**: Use this document to implement full backend integration (Firebase Auth, Profile Management, AI Evaluation, and Recommendations) in the Flutter mobile application (`easy_english`).

---

## 🎯 Target System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            Flutter App (easy_english)                        │
│                                                                             │
│  ┌──────────────────────┐   ┌──────────────────────┐   ┌─────────────────┐  │
│  │ FirebaseAuthService  │   │    ProfileService    │   │  EvaluationSvc  │  │
│  └──────────┬───────────┘   └──────────┬───────────┘   └────────┬────────┘  │
└─────────────┼──────────────────────────┼────────────────────────┼───────────┘
              │                          │                        │
              ▼                          ▼                        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      Go Backend Gateway (Port 8080)                          │
│                                                                             │
│  /api/v1/auth/google        /api/v1/user/profile       /api/v1/placement/submit│
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📦 1. Required Packages (`pubspec.yaml`)

Ensure the following packages are configured in `easy_english/pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  firebase_core: ^3.10.0
  firebase_auth: ^5.4.0
  google_sign_in: ^6.2.2
  http: ^1.2.0
  flutter_secure_storage: ^9.0.0 # Secure token storage
```

---

## 🔑 2. Core Models

### `UserModel` (`lib/core/models/user_model.dart`)
```dart
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? bio;
  final String? avatarUrl;
  final String role;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.bio,
    this.avatarUrl,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['user_id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      bio: json['bio'],
      avatarUrl: json['avatar_url'],
      role: json['role'] ?? 'student',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'bio': bio,
        'avatar_url': avatarUrl,
        'role': role,
      };
}
```

### `AuthSession` (`lib/core/models/auth_session.dart`)
```dart
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
    return AuthSession(
      accessToken: json['access_token'] ?? json['token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      user: UserModel.fromJson(json['user'] ?? json),
    );
  }
}
```

---

## 🔐 3. Authentication & API Client (`lib/core/auth/api_client.dart`)

Implement a central `ApiClient` that attaches `Authorization: Bearer <token>` and auto-refreshes tokens upon HTTP 401:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:8080'; // Emulator host IP
  final _storage = const FlutterSecureStorage();

  Future<String?> getAccessToken() async => await _storage.read(key: 'access_token');

  Future<Map<String, String>> _headers() async {
    final token = await getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String path) async {
    final response = await http.get(Uri.parse('$baseUrl$path'), headers: await _headers());
    return _handleResponse(response, () => get(path));
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _handleResponse(response, () => post(path, body));
  }

  Future<http.Response> _handleResponse(http.Response response, Future<http.Response> Function() retry) async {
    if (response.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) return await retry();
    }
    return response;
  }

  Future<bool> refreshToken() async {
    final refresh = await _storage.read(key: 'refresh_token');
    if (refresh == null) return false;

    final res = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refresh}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await _storage.write(key: 'access_token', value: data['access_token']);
      return true;
    }
    return false;
  }
}
```

---

## 🚪 4. Firebase Google Sign-In (`lib/core/auth/firebase_auth_service.dart`)

```dart
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_session.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  final _storage = const FlutterSecureStorage();
  static const String baseUrl = 'http://10.0.2.2:8080';

  Future<AuthSession?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // Cancelled

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    final User? user = userCredential.user;
    if (user == null) throw Exception('Firebase Authentication failed');

    final String idToken = (await user.getIdToken()) ?? googleAuth.idToken ?? '';

    // Exchange ID Token with Go Gateway
    final res = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_token': idToken}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final session = AuthSession.fromJson(data);
      await _storage.write(key: 'access_token', value: session.accessToken);
      await _storage.write(key: 'refresh_token', value: session.refreshToken);
      return session;
    } else {
      throw Exception('Backend authentication failed: ${res.body}');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    await _storage.deleteAll();
  }
}
```

---

## 👤 5. User Profile Service (`lib/features/profile/services/profile_service.dart`)

```dart
import 'dart:convert';
import '../../../core/auth/api_client.dart';
import '../../../core/models/user_model.dart';

class ProfileService {
  final ApiClient _client = ApiClient();

  /// Get Current User Profile (GET /api/v1/user/profile)
  Future<UserModel> fetchProfile() async {
    final response = await _client.get('/api/v1/user/profile');
    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch profile');
    }
  }

  /// Create / Setup Initial Profile (POST /api/v1/user/profile)
  Future<UserModel> createProfile({required String fullName, String? bio, String? avatarUrl}) async {
    final response = await _client.post('/api/v1/user/profile', {
      'full_name': fullName,
      if (bio != null) 'bio': bio,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    });

    if (response.statusCode == 201 || response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create profile');
    }
  }
}
```

---

## 🎨 6. UI Implementation Tasks for Mobile Agent

1. **Google Sign-In Button on Login Screen**:
   - Implement `ElevatedButton` or `OutlinedButton` with Google logo calling `FirebaseAuthService().signInWithGoogle()`.
   - On success, navigate to `ProfileSetupScreen` (if new user) or `DashboardScreen`.

2. **Profile Setup Screen (`lib/features/profile/presentation/profile_setup_screen.dart`)**:
   - Input fields for `Full Name`, `Bio`, `Target Band Score`.
   - Submit button calling `ProfileService().createProfile(...)`.

3. **AI Coach Dashboard Screen (`lib/features/ai_coach/presentation/ai_coach_screen.dart`)**:
   - Displays student target band score, weak skill focus, and AI recommendations fetched from `/api/v1/content-recommendations/`.
