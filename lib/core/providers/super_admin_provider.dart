import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_model.dart';
import '../services/audit_service.dart';

/// SuperAdmin Provider - Manage other admins
/// Handles: Create, Edit, Delete, Suspend admins + Full admin lifecycle
class SuperAdminProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuditService _auditService = AuditService();

  List<AdminModel> _allAdmins = [];
  bool _isLoading = false;
  String? _error;
  int _totalAdmins = 0;
  Map<String, int> _adminsByRole = {};

  // Getters
  List<AdminModel> get allAdmins => _allAdmins;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalAdmins => _totalAdmins;
  Map<String, int> get adminsByRole => _adminsByRole;

  /// Load all admins with real-time updates
  Future<void> loadAllAdminsRealtime({
    required String currentAdminId,
    required String currentAdminRole,
  }) async {
    if (currentAdminRole != 'super_admin') {
      _error = 'Only super admin can manage admins';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _firestore.collection('admins').snapshots().listen((snapshot) {
        _allAdmins = snapshot.docs
            .map((doc) => AdminModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList();

        // Calculate stats
        _totalAdmins = _allAdmins.length;
        _adminsByRole = {};
        for (var admin in _allAdmins) {
          _adminsByRole[admin.role] = (_adminsByRole[admin.role] ?? 0) + 1;
        }

        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _error = 'Error loading admins: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new admin
  Future<bool> createNewAdmin({
    required String email,
    required String password,
    required String name,
    required String role,
    required String currentAdminId,
    required String currentAdminName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create in Firestore first
      final docRef = _firestore.collection('admins').doc();
      final newAdminId = docRef.id;

      await docRef.set({
        'id': newAdminId,
        'email': email.trim(),
        'name': name.trim(),
        'role': role,
        'isActive': true,
        'isSuspended': false,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': null,
        'permissions': _getPermissionsForRole(role),
        'metadata': {
          'createdBy': currentAdminId,
          'createdByName': currentAdminName,
          'department': 'General',
        },
      });

      // Log this action
      await _auditService.logAdminAction(
        adminId: currentAdminId,
        adminName: currentAdminName,
        actionType: 'ADMIN_CREATED',
        entityType: 'ADMIN',
        entityId: newAdminId,
        newValues: {
          'email': email,
          'name': name,
          'role': role,
        },
        description: 'New admin created: $name ($role)',
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to create admin: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update admin details
  Future<bool> updateAdmin({
    required String adminId,
    required String name,
    required String role,
    required bool isActive,
    required String currentAdminId,
    required String currentAdminName,
    AdminModel? oldAdmin,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Can't change super_admin role
      if (oldAdmin?.role == 'super_admin' && role != 'super_admin') {
        _error = 'Cannot change super_admin role';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      Map<String, dynamic> updateData = {
        'name': name.trim(),
        'role': role,
        'isActive': isActive,
        'metadata': {
          'updatedBy': currentAdminId,
          'updatedByName': currentAdminName,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      };

      if (role != oldAdmin?.role) {
        updateData['permissions'] = _getPermissionsForRole(role);
      }

      await _firestore.collection('admins').doc(adminId).update(updateData);

      // Log this action
      await _auditService.logAdminAction(
        adminId: currentAdminId,
        adminName: currentAdminName,
        actionType: 'ADMIN_UPDATED',
        entityType: 'ADMIN',
        entityId: adminId,
        oldValues: {
          'name': oldAdmin?.name,
          'role': oldAdmin?.role,
          'isActive': oldAdmin?.isActive,
        },
        newValues: {
          'name': name,
          'role': role,
          'isActive': isActive,
        },
        description: 'Admin updated: $name (Role: $role, Active: $isActive)',
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update admin: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Suspend admin (temporary ban)
  Future<bool> suspendAdmin({
    required String adminId,
    required String reason,
    required int suspensionDays,
    required String currentAdminId,
    required String currentAdminName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final suspendUntil = DateTime.now().add(Duration(days: suspensionDays));

      await _firestore.collection('admins').doc(adminId).update({
        'isSuspended': true,
        'suspendedUntil': suspendUntil,
        'suspensionReason': reason,
        'isActive': false,
      });

      await _auditService.logAdminAction(
        adminId: currentAdminId,
        adminName: currentAdminName,
        actionType: 'ADMIN_SUSPENDED',
        entityType: 'ADMIN',
        entityId: adminId,
        newValues: {
          'isSuspended': true,
          'suspendedUntil': suspendUntil.toString(),
          'reason': reason,
        },
        description:
            'Admin suspended for $suspensionDays days. Reason: $reason',
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to suspend admin: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Activate suspended admin
  Future<bool> activateSuspendedAdmin({
    required String adminId,
    required String currentAdminId,
    required String currentAdminName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('admins').doc(adminId).update({
        'isSuspended': false,
        'suspendedUntil': null,
        'suspensionReason': null,
        'isActive': true,
      });

      await _auditService.logAdminAction(
        adminId: currentAdminId,
        adminName: currentAdminName,
        actionType: 'ADMIN_ACTIVATED',
        entityType: 'ADMIN',
        entityId: adminId,
        newValues: {'isSuspended': false, 'isActive': true},
        description: 'Suspended admin reactivated',
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to activate admin: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete admin (soft delete - keep audit trail)
  Future<bool> deleteAdmin({
    required String adminId,
    required String currentAdminId,
    required String currentAdminName,
    AdminModel? adminToDelete,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Prevent deleting super_admin
      if (adminToDelete?.role == 'super_admin') {
        _error = 'Cannot delete super_admin account';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Soft delete - mark as deleted instead of removing
      await _firestore.collection('admins').doc(adminId).update({
        'isActive': false,
        'isSuspended': true,
        'suspensionReason': 'Account deleted by super admin',
        'suspendedUntil': DateTime(2099, 12, 31), // Permanent
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': currentAdminId,
        'deletedByName': currentAdminName,
      });

      await _auditService.logAdminAction(
        adminId: currentAdminId,
        adminName: currentAdminName,
        actionType: 'ADMIN_DELETED',
        entityType: 'ADMIN',
        entityId: adminId,
        oldValues: {
          'email': adminToDelete?.email,
          'name': adminToDelete?.name,
          'role': adminToDelete?.role,
        },
        description: 'Admin deleted: ${adminToDelete?.name}',
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete admin: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get admin activity summary
  Future<Map<String, dynamic>> getAdminActivitySummary(String adminId) async {
    try {
      final activity = await _firestore
          .collection('audit_logs')
          .where('adminId', isEqualTo: adminId)
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      Map<String, int> actionCounts = {};
      for (var log in activity.docs) {
        final action = log['actionType'] as String;
        actionCounts[action] = (actionCounts[action] ?? 0) + 1;
      }

      return {
        'totalActions': activity.docs.length,
        'actions': actionCounts,
        'lastAction':
            activity.docs.isNotEmpty ? activity.docs.first['timestamp'] : null,
      };
    } catch (e) {
      debugPrint('Error getting activity summary: $e');
      return {
        'totalActions': 0,
        'actions': {},
        'lastAction': null,
      };
    }
  }

  /// Get permissions for role
  List<String> _getPermissionsForRole(String role) {
    switch (role) {
      case 'super_admin':
        return [
          'manage_users',
          'manage_admins',
          'manage_products',
          'manage_orders',
          'view_analytics',
          'manage_settings',
          'view_audit_logs',
          'bulk_operations',
        ];
      case 'admin':
        return [
          'manage_users',
          'manage_products',
          'manage_orders',
          'view_analytics',
          'view_audit_logs',
          'bulk_operations',
        ];
      case 'moderator':
        return [
          'moderate_users',
          'moderate_products',
          'moderate_orders',
        ];
      default:
        return [];
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
