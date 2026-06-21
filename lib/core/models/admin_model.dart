class AdminModel {
  final String id;
  final String email;
  final String name;
  final String role; // 'super_admin', 'admin', 'moderator'
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;
  final bool isSuspended;

  AdminModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    this.lastLogin,
    this.isActive = true,
    this.isSuspended = false,
  });

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      id: map['id'] as String? ?? '',
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      role: map['role'] as String? ?? 'admin',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'].toString())
          : DateTime.now(),
      lastLogin: map['lastLogin'] != null
          ? DateTime.parse(map['lastLogin'].toString())
          : null,
      isActive: map['isActive'] as bool? ?? true,
      isSuspended: map['isSuspended'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'isActive': isActive,
      'isSuspended': isSuspended,
    };
  }
}
