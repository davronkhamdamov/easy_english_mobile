import '../domain/repositories/profile_repository.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../data/models/user_profile_model.dart';

/// Service wrapper maintaining backward compatibility for Profile API interactions
class ProfileService {
  final ProfileRepository _repository;

  ProfileService({ProfileRepository? repository})
    : _repository = repository ?? ProfileRepositoryImpl();

  /// Get Current User Profile (GET /api/v1/user/profile)
  Future<UserProfileModel> fetchProfile() {
    return _repository.fetchProfile();
  }

  /// Create / Setup Initial Profile (POST /api/v1/user/profile)
  Future<UserProfileModel> createProfile({
    required String fullName,
    String? bio,
    String? avatarUrl,
    String role = 'student',
  }) {
    return _repository.createProfile(
      fullName: fullName,
      bio: bio,
      avatarUrl: avatarUrl,
      role: role,
    );
  }

  /// Update Profile (PUT /api/v1/user/profile)
  Future<UserProfileModel> updateProfile({
    String? fullName,
    String? bio,
    String? avatarUrl,
  }) {
    return _repository.updateProfile(
      fullName: fullName,
      bio: bio,
      avatarUrl: avatarUrl,
    );
  }
}
