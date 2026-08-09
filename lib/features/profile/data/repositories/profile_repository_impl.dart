import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource _remoteDatasource;

  ProfileRepositoryImpl({ProfileRemoteDatasource? remoteDatasource})
    : _remoteDatasource = remoteDatasource ?? ProfileRemoteDatasource();

  @override
  Future<UserProfileModel> fetchProfile() {
    return _remoteDatasource.fetchProfile();
  }

  @override
  Future<UserProfileModel> createProfile({
    required String fullName,
    String? bio,
    String? avatarUrl,
    String role = 'student',
  }) {
    return _remoteDatasource.createProfile(
      fullName: fullName,
      bio: bio,
      avatarUrl: avatarUrl,
      role: role,
    );
  }

  @override
  Future<UserProfileModel> updateProfile({
    String? fullName,
    String? bio,
    String? avatarUrl,
  }) {
    return _remoteDatasource.updateProfile(
      fullName: fullName,
      bio: bio,
      avatarUrl: avatarUrl,
    );
  }
}
