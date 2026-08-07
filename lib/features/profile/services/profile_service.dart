import 'dart:convert';
import '../../../core/auth/api_client.dart';
import '../../../core/models/user_model.dart';

class ProfileService {
  final ApiClient _client = ApiClient();

  /// Get Current User Profile (GET /api/v1/user/profile)
  Future<UserModel> fetchProfile() async {
    final response = await _client.get('/api/v1/user/profile');
    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to fetch profile (${response.statusCode}): ${response.body}');
    }
  }

  /// Create / Setup Initial Profile (POST /api/v1/user/profile)
  Future<UserModel> createProfile({
    required String fullName,
    String? bio,
    String? avatarUrl,
    String role = 'student',
  }) async {
    final response = await _client.post('/api/v1/user/profile', {
      'full_name': fullName,
      if (bio != null) 'bio': bio,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'role': role,
    });

    if (response.statusCode == 201 || response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create profile (${response.statusCode}): ${response.body}');
    }
  }

  /// Update Profile (PUT /api/v1/user/profile)
  Future<UserModel> updateProfile({
    String? fullName,
    String? bio,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{
      if (fullName != null) 'full_name': fullName,
      if (bio != null) 'bio': bio,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };

    final response = await _client.put('/api/v1/user/profile', body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return UserModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update profile (${response.statusCode}): ${response.body}');
    }
  }
}
