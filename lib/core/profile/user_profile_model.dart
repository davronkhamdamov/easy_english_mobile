class UserProfile {
  final String userId;
  final String? fullName;
  final String? bio;
  final String? avatarUrl;
  final String role;
  final String? status;
  final String? updatedAt;

  const UserProfile({
    required this.userId,
    this.fullName,
    this.bio,
    this.avatarUrl,
    this.role = 'student',
    this.status,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as String? ?? '',
      fullName: json['full_name'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'student',
      status: json['status'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (fullName != null) 'full_name': fullName,
      if (bio != null) 'bio': bio,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'role': role,
    };
  }

  UserProfile copyWith({
    String? userId,
    String? fullName,
    String? bio,
    String? avatarUrl,
    String? role,
    String? status,
    String? updatedAt,
  }) {
    return UserProfile(
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
