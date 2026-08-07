# Firebase Google Sign-In Integration Guide

This guide documents the complete end-to-end flow for authenticating users via **Google Sign-In with Firebase** in the Flutter mobile application (`easy_english`) and synchronizing user sessions with the Go Backend (`go_backend`).

---

## 🏗 System Architecture & Sequence

```
┌──────────────────────────┐          ┌──────────────────────────┐          ┌──────────────────────────┐
│   Flutter App (Mobile)   │          │   Firebase Auth / Google │          │    Go Backend Gateway    │
└────────────┬─────────────┘          └────────────┬─────────────┘          └────────────┬─────────────┘
             │                                     │                                     │
             │ 1. User taps "Sign in with Google"  │                                     │
             ├────────────────────────────────────>│                                     │
             │ 2. Prompts user & returns ID token  │                                     │
             │<────────────────────────────────────┤                                     │
             │                                     │                                     │
             │ 3. POST /api/v1/auth/google {"id_token": "..."}                           │
             ├──────────────────────────────────────────────────────────────────────────>│
             │                                                                           │ 4. Verifies token via
             │                                                                           │    oauth2.googleapis.com
             │                                                                           │ 5. Creates/Retrieves User
             │                                                                           │    in Database
             │ 6. Returns Backend JWT Access & Refresh Tokens                             │
             │<──────────────────────────────────────────────────────────────────────────┤
```

---

## 📱 1. Mobile App Setup (Flutter)

### Step 1: Place Configuration File
Ensure `google-services.json` downloaded from Firebase Console is placed in:
```
easy_english/android/app/google-services.json
```

### Step 2: Dependencies (`pubspec.yaml`)
The following dependencies have been added to [`easy_english/pubspec.yaml`](file:///root/easy/easy_english/pubspec.yaml):

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.10.0
  firebase_auth: ^5.4.0
  google_sign_in: ^6.2.2
  http: ^1.2.0
```

### Step 3: Flutter Auth Implementation (`lib/core/auth/firebase_auth_service.dart`)

```dart
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  final String backendBaseUrl;

  FirebaseAuthService({this.backendBaseUrl = 'http://10.0.2.2:8080'}); // 10.0.2.2 for Android Emulator

  Future<Map<String, dynamic>?> signInWithGoogle() async {
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

    // 4. Extract ID token
    final String idToken = (await user.getIdToken()) ?? googleAuth.idToken ?? '';

    // 5. Exchange token with Go Backend Gateway
    final response = await http.post(
      Uri.parse('$backendBaseUrl/api/v1/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_token': idToken}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Backend authentication failed: ${response.body}');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
```

---

## ⚙️ 2. Backend Implementation (Go Backend)

The Go backend verifies the ID token with Google's public token API and handles automatic user provisioning.

### API Endpoint
* **URL**: `POST /api/v1/auth/google`
* **Headers**: `Content-Type: application/json`
* **Request Body**:
```json
{
  "id_token": "YOUR_FIREBASE_OR_GOOGLE_ID_TOKEN"
}
```

### Backend Processing Logic ([`service.go`](file:///root/easy/go_backend/internal/user/service.go#L147-L240))
1. **Token Verification**: Calls `https://oauth2.googleapis.com/tokeninfo?id_token=<id_token>`.
2. **Extract Claims**: Obtains verified `email`, `sub` (Google UID), `name`, `picture`.
3. **Database Sync**:
   * If user email doesn't exist $\rightarrow$ Registers new user in PostgreSQL database.
   * If user email exists $\rightarrow$ Fetches existing profile.
4. **Issue JWT Session**: Signs a 72-hour JWT access token and session refresh token.

### Successful Response Format
```json
{
  "user": {
    "id": "usr_a1b2c3d4e5f6",
    "email": "user@gmail.com",
    "full_name": "John Doe",
    "avatar_url": "https://lh3.googleusercontent.com/...",
    "role": "student"
  },
  "access_token": "eyJhbGciOiJIUzI1Ni...",
  "refresh_token": "0123456789abcdef...",
  "token_type": "Bearer",
  "expires_in": 900
}
```

---

## 🧪 3. How to Test

### Testing Backend Endpoint via `curl`
Run the command below in your terminal to test token verification:

```bash
curl -X POST http://localhost:8080/api/v1/auth/google \
  -H "Content-Type: application/json" \
  -d '{"id_token": "test_google_id_token"}'
```

### Running Mobile App
To launch the Flutter app on Android emulator:

```bash
cd easy_english
flutter run
```
