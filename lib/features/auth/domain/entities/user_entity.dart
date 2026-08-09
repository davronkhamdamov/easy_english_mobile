class UserEntity {
  final String id;
  final String email;
  final String fullName;
  final String? bio;
  final String? avatarUrl;
  final String role;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.bio,
    this.avatarUrl,
    required this.role,
  });

  String get displayName => fullName;
  String? get photoURL => avatarUrl;
}
