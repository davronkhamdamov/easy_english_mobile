class UserProfileModel {
  final String userId;
  final String? fullName;
  final String? bio;
  final String? avatarUrl;
  final String role;
  final String? status;
  final String? updatedAt;

  const UserProfileModel({
    required this.userId,
    this.fullName,
    this.bio,
    this.avatarUrl,
    this.role = 'student',
    this.status,
    this.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['user_id'] as String? ?? json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? json['name'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String? ?? json['photo_url'] as String?,
      role: json['role'] as String? ?? 'student',
      status: json['status'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId.isNotEmpty) 'user_id': userId,
      if (fullName != null) 'full_name': fullName,
      if (bio != null) 'bio': bio,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'role': role,
      if (status != null) 'status': status,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  UserProfileModel copyWith({
    String? userId,
    String? fullName,
    String? bio,
    String? avatarUrl,
    String? role,
    String? status,
    String? updatedAt,
  }) {
    return UserProfileModel(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
