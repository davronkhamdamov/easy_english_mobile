class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? bio;
  final String? avatarUrl;
  final String role;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.bio,
    this.avatarUrl,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['user_id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      fullName: (json['full_name'] ?? json['name'] ?? '').toString(),
      bio: json['bio']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      role: (json['role'] ?? 'student').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        if (bio != null) 'bio': bio,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'role': role,
      };
}
