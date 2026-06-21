import 'package:flutter/material.dart';
import 'package:agrolinkbd/core/models/user_model.dart';
import 'package:agrolinkbd/core/services/role_service.dart';
import 'package:agrolinkbd/core/services/role_permissions.dart';

/// Role-Based Content Provider - Manages role-specific data and content
class RoleContentProvider extends ChangeNotifier {
  UserModel? _user;
  Map<String, dynamic> _roleMetadata = {};
  List<dynamic> _roleFeatures = [];
  Set<String> _permissions = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get user => _user;
  Map<String, dynamic> get roleMetadata => _roleMetadata;
  List<dynamic> get roleFeatures => _roleFeatures;
  Set<String> get permissions => _permissions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize role content for user
  Future<void> initializeRoleContent(UserModel user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = user;
      _roleFeatures = RoleService.getFeaturesByRole(user.userType);
      _permissions = RolePermissions.getPermissionsByRole(user.userType);
      _roleMetadata = _buildRoleMetadata(user);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Check if user has permission
  bool hasPermission(String permission) {
    return _permissions.contains(permission);
  }

  /// Get role display information
  String getRoleDisplayName() {
    if (_user == null) return '';
    return RoleService.getRoleNameBN(_user!.userType);
  }

  /// Get role color
  Color getRoleColor() {
    if (_user == null) return const Color(0xFF808080);
    return RoleService.getRoleColor(_user!.userType);
  }

  /// Build role-specific metadata
  Map<String, dynamic> _buildRoleMetadata(UserModel user) {
    return {
      'roleName': RoleService.getRoleName(user.userType),
      'roleNameBN': RoleService.getRoleNameBN(user.userType),
      'roleColor': RoleService.getRoleColor(user.userType),
      'navigationItems': RoleService.getNavigationItems(user.userType),
      'totalFeatures': _roleFeatures.length,
      'totalPermissions': _permissions.length,
    };
  }

  /// Get formatted role metadata for display
  Map<String, String> getFormattedRoleInfo() {
    return {
      'name': _user?.name ?? 'User',
      'email': _user?.email ?? '',
      'role': getRoleDisplayName(),
      'status': _user?.status.toString().split('.').last ?? 'Unknown',
      'rating': _user?.rating.toString() ?? '0.0',
      'createdAt': _user?.createdAt.toString() ?? '',
    };
  }

  /// Clear content on logout
  void clearContent() {
    _user = null;
    _roleMetadata = {};
    _roleFeatures = [];
    _permissions = {};
    _error = null;
    notifyListeners();
  }
}

// Extension for easy access to role information
extension RoleExtension on UserModel {
  /// Get role display name
  String getDisplayName() {
    return RoleService.getRoleName(userType);
  }

  /// Get role display name in Bengali
  String getDisplayNameBN() {
    return RoleService.getRoleNameBN(userType);
  }

  /// Get role color
  Color getColor() {
    return RoleService.getRoleColor(userType);
  }

  /// Get available features
  List<dynamic> getFeatures() {
    return RoleService.getFeaturesByRole(userType);
  }
}
