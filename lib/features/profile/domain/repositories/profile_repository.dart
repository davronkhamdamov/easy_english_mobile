import '../../data/models/user_profile_model.dart';

abstract class ProfileRepository {
  Future<UserProfileModel> fetchProfile();
  Future<UserProfileModel> createProfile({
    required String fullName,
    String? bio,
    String? avatarUrl,
    String role = 'student',
  });
  Future<UserProfileModel> updateProfile({
    String? fullName,
    String? bio,
    String? avatarUrl,
  });
}
