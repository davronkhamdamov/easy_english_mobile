import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../models/user_profile_model.dart';

class ProfileRemoteDatasource {
  final ApiClient _client;

  ProfileRemoteDatasource({ApiClient? client})
    : _client = client ?? ApiClient();

  /// Get Current User Profile (GET /api/v1/user/profile)
  Future<UserProfileModel> fetchProfile() async {
    final response = await _client.get('/api/v1/user/profile');
    if (response.statusCode == 200) {
      return UserProfileModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        'Failed to fetch profile (${response.statusCode}): ${response.body}',
      );
    }
  }

  /// Create / Setup Initial Profile (POST /api/v1/user/profile)
  Future<UserProfileModel> createProfile({
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
      return UserProfileModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        'Failed to create profile (${response.statusCode}): ${response.body}',
      );
    }
  }

  /// Update Profile (PUT /api/v1/user/profile)
  Future<UserProfileModel> updateProfile({
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
      return UserProfileModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        'Failed to update profile (${response.statusCode}): ${response.body}',
      );
    }
  }
}
