import 'package:cloud_firestore/cloud_firestore.dart';

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

  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is DateTime) return date;
    if (date is Timestamp) return date.toDate();
    if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
    if (date is String) return DateTime.tryParse(date);
    return null;
  }

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      id: map['id'] as String? ?? '',
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      role: map['role'] as String? ?? 'admin',
      createdAt: _parseDate(map['createdAt']) ?? DateTime.now(),
      lastLogin: _parseDate(map['lastLogin']),
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
