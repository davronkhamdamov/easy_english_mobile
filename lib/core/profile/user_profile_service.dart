import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_profile_model.dart';
import '../debug/api_logger.dart';

class UserProfileService {
  final String baseUrl;

  UserProfileService({
    this.baseUrl = 'https://easy-english.uz/api',
  });

  String get _profileEndpoint {
    return baseUrl.endsWith('/api')
        ? '$baseUrl/v1/user/profile'
        : '$baseUrl/api/v1/user/profile';
  }

  /// 1. Create / Setup Initial Profile
  /// POST /api/v1/user/profile
  Future<UserProfile> createProfile({
    required String token,
    required String fullName,
    String? bio,
    String? avatarUrl,
    String role = 'student',
  }) async {
    final url = _profileEndpoint;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final bodyMap = {
      'full_name': fullName,
      if (bio != null) 'bio': bio,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'role': role,
    };
    final startTime = DateTime.now();
    final log = ApiLogger.instance.logRequest(
      method: 'POST',
      url: url,
      headers: headers,
      body: bodyMap,
    );

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(bodyMap),
      );

      ApiLogger.instance.logResponse(
        logItem: log,
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        duration: DateTime.now().difference(startTime),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return UserProfile.fromJson(json);
      } else {
        throw Exception('Failed to create profile (${response.statusCode}): ${response.body}');
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

  /// 2. Get User Profile
  /// GET /api/v1/user/profile
  Future<UserProfile> getProfile({required String token}) async {
    final url = _profileEndpoint;
    final headers = {'Authorization': 'Bearer $token'};
    final startTime = DateTime.now();
    final log = ApiLogger.instance.logRequest(
      method: 'GET',
      url: url,
      headers: headers,
    );

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      ApiLogger.instance.logResponse(
        logItem: log,
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        duration: DateTime.now().difference(startTime),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return UserProfile.fromJson(json);
      } else {
        throw Exception('Failed to fetch profile (${response.statusCode}): ${response.body}');
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

  /// 3. Update User Profile
  /// PUT /api/v1/user/profile
  Future<UserProfile> updateProfile({
    required String token,
    String? fullName,
    String? bio,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['full_name'] = fullName;
    if (bio != null) body['bio'] = bio;
    if (avatarUrl != null) body['avatar_url'] = avatarUrl;

    final url = _profileEndpoint;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final startTime = DateTime.now();
    final log = ApiLogger.instance.logRequest(
      method: 'PUT',
      url: url,
      headers: headers,
      body: body,
    );

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      ApiLogger.instance.logResponse(
        logItem: log,
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        duration: DateTime.now().difference(startTime),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return UserProfile.fromJson(json);
      } else {
        throw Exception('Failed to update profile (${response.statusCode}): ${response.body}');
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

