enum UserRole { user, helpdesk, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String? avatarUrl;
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.avatarUrl,
    required this.createdAt,
    this.isActive = true,
  });

  String get roleName {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.helpdesk:
        return 'Helpdesk';
      case UserRole.user:
        return 'User';
    }
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:        json['id'],
      name:      json['name'],
      email:     json['email'],
      password:  json['password'],
      role:      UserRole.values.firstWhere((e) => e.name == json['role']),
      avatarUrl: json['avatar_url'],
      createdAt: DateTime.parse(json['created_at']),
      isActive:  json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':         id,
    'name':       name,
    'email':      email,
    'password':   password,
    'role':       role.name,
    'avatar_url': avatarUrl,
    'created_at': createdAt.toIso8601String(),
    'is_active':  isActive,
  };
}
