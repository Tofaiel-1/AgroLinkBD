import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_model.dart';

class AdminProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdminModel? _currentAdmin;
  bool _isLoading = false;
  String? _error;
  List<AdminModel> _allAdmins = [];
  bool _isPinVerified = false;

  AdminModel? get currentAdmin => _currentAdmin;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdminLoggedIn => _currentAdmin != null;
  bool get isPinVerified => _isPinVerified;
  bool get isSuperAdmin => _currentAdmin?.role == 'super_admin';
  List<AdminModel> get allAdmins => _allAdmins;

  /// Admin Sign In
  Future<bool> adminSignIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Step 1: Authenticate with Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      debugPrint('✅ Firebase Auth successful for: $email (UID: $uid)');

      // Step 2: Check if user is admin (read admin document from Firestore)
      try {
        final adminDoc = await _firestore.collection('admins').doc(uid).get();

        if (!adminDoc.exists) {
          _error =
              'This account is not registered as an admin. Please contact system administrator.';
          _isLoading = false;
          notifyListeners();
          await _auth.signOut();
          return false;
        }

        // Step 3: Load admin data
        final adminData = adminDoc.data()!;
        _currentAdmin = AdminModel.fromMap({...adminData, 'id': uid});
        debugPrint(
            '✅ Admin loaded: ${_currentAdmin?.name} (Role: ${_currentAdmin?.role})');

        // Step 4: Update last login
        try {
          await _firestore.collection('admins').doc(uid).update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
          debugPrint('✅ Last login updated');
        } catch (e) {
          debugPrint('⚠️  Warning updating last login: $e');
          // Don't fail on this non-critical update
        }

        _isLoading = false;
        notifyListeners();
        
        // Log successful login
        await logAdminAction('ADMIN_LOGIN', 'Admin logged into the system: ${_currentAdmin?.name}');
        
        return true;
      } on FirebaseException catch (e) {
        _error =
            'Database error: ${e.message ?? e.code}. Ensure admin document exists in Firestore.';
        debugPrint(
            '❌ Firestore error during admin check: ${e.code} - ${e.message}');
        _isLoading = false;
        notifyListeners();
        await _auth.signOut();
        return false;
      }
    } on FirebaseAuthException catch (e) {
      _error = _handleAuthException(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Unexpected error: ${e.toString()}';
      debugPrint('❌ Unexpected error during admin login: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Set admin from a pre-fetched Firestore document snapshot
  /// Used when login_screen reads the admin doc directly after sign-in
  void setAdminFromDoc(DocumentSnapshot adminDoc) {
    if (adminDoc.exists) {
      final adminData = adminDoc.data() as Map<String, dynamic>;
      _currentAdmin = AdminModel.fromMap({...adminData, 'id': adminDoc.id});
      notifyListeners();
    }
  }

  /// Admin Sign Out
  Future<void> adminSignOut() async {
    // Log logout before clearing current admin
    if (_currentAdmin != null) {
      await logAdminAction('ADMIN_LOGOUT', 'Admin logged out: ${_currentAdmin?.name}');
    }
    await _auth.signOut();
    _currentAdmin = null;
    _isPinVerified = false;
    _error = null;
    notifyListeners();
  }

  /// Verify 2FA Security PIN
  Future<bool> verifyPin(String pin) async {
    // In production, this might verify against Firestore doc
    // For now, hardcoded 123456 as requested
    if (pin == '123456') {
      _isPinVerified = true;
      notifyListeners();
      await logAdminAction('2FA_SUCCESS', 'Admin successfully passed 2FA Security PIN');
      return true;
    } else {
      await logAdminAction('2FA_FAILED', 'Admin failed 2FA Security PIN attempt');
      return false;
    }
  }

  /// Create New Admin (Super Admin only)
  Future<bool> createAdmin({
    required String email,
    required String password,
    required String name,
    required String role, // 'admin', 'moderator'
  }) async {
    if (!isSuperAdmin) {
      _error = 'Only super admin can create new admins';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final adminModel = AdminModel(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        role: role,
        createdAt: DateTime.now(),
        isActive: true,
      );

      await _firestore.collection('admins').doc(userCredential.user!.uid).set(
            adminModel.toMap(),
          );

      // Log activity
      await logAdminAction('ADMIN_CREATED', 'Admin created: $email');

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _handleAuthException(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load all admins
  Future<void> loadAllAdmins() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('admins').get();
      _allAdmins = snapshot.docs
          .map((doc) => AdminModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update admin
  Future<bool> updateAdmin({
    required String adminId,
    required String name,
    required String role,
    required bool isActive,
  }) async {
    if (!isSuperAdmin) {
      _error = 'Only super admin can update admins';
      notifyListeners();
      return false;
    }

    try {
      await _firestore.collection('admins').doc(adminId).update({
        'name': name,
        'role': role,
        'isActive': isActive,
      });

      await logAdminAction('ADMIN_UPDATED', 'Admin updated: $adminId');
      await loadAllAdmins();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete admin
  Future<bool> deleteAdmin(String adminId) async {
    if (!isSuperAdmin) {
      _error = 'Only super admin can delete admins';
      notifyListeners();
      return false;
    }

    try {
      // Delete from admins collection
      await _firestore.collection('admins').doc(adminId).delete();

      // Note: Firebase Auth user deletion requires running as Cloud Function
      // For now, just log the activity
      await logAdminAction('ADMIN_DELETED', 'Admin deleted: $adminId');

      await loadAllAdmins();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Log admin activity publicly
  Future<void> logAdminAction(String actionType, String description) async {
    try {
      await _firestore.collection('admin_logs').add({
        'adminId': _currentAdmin?.id,
        'adminName': _currentAdmin?.name,
        'actionType': actionType,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error logging activity: $e');
    }
  }

  /// Handle auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Wrong password. Please try again.';
      case 'too-many-requests':
        return 'Too many failed login attempts. Please try later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'account-exists-with-different-credential':
        return 'Account exists with different credential.';
      default:
        return e.message ?? 'An error occurred: ${e.code}';
    }
  }

  /// Get admin statistics (for dashboard)
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      // Get user count
      final usersSnapshot = await _firestore.collection('users').count().get();

      // Get product count
      final productsSnapshot =
          await _firestore.collection('products').count().get();

      // Get orders count
      final ordersSnapshot =
          await _firestore.collection('orders').count().get();

      // Get admins count
      final adminsSnapshot =
          await _firestore.collection('admins').count().get();

      return {
        'totalUsers': usersSnapshot.count,
        'totalProducts': productsSnapshot.count,
        'totalOrders': ordersSnapshot.count,
        'totalAdmins': adminsSnapshot.count,
        'timestamp': DateTime.now(),
      };
    } catch (e) {
      debugPrint('Error getting admin stats: $e');
      return {
        'totalUsers': 0,
        'totalProducts': 0,
        'totalOrders': 0,
        'totalAdmins': 0,
        'error': e.toString(),
      };
    }
  }

  /// Get recent activity logs
  Future<List<Map<String, dynamic>>> getRecentActivity({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('admin_logs')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('Error getting recent activity: $e');
      return [];
    }
  }

  /// Verify admin account is properly set up
  Future<Map<String, dynamic>> verifyAdminSetup() async {
    try {
      if (_currentAdmin == null) {
        return {'status': 'error', 'message': 'No admin logged in'};
      }

      final adminDoc =
          await _firestore.collection('admins').doc(_currentAdmin!.id).get();

      if (!adminDoc.exists) {
        return {'status': 'error', 'message': 'Admin document not found'};
      }

      final data = adminDoc.data()!;
      final requiredFields = [
        'id',
        'email',
        'name',
        'role',
        'isActive',
        'createdAt'
      ];

      for (final field in requiredFields) {
        if (!data.containsKey(field)) {
          return {
            'status': 'error',
            'message': 'Missing required field: $field',
            'missingFields': [field]
          };
        }
      }

      return {
        'status': 'ok',
        'message': 'Admin setup verified',
        'adminId': _currentAdmin!.id,
        'role': _currentAdmin!.role,
        'email': _currentAdmin!.email,
      };
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Get admin account info
  Map<String, dynamic> getAdminInfo() {
    if (_currentAdmin == null) {
      return {'status': 'no_admin'};
    }

    return {
      'status': 'logged_in',
      'id': _currentAdmin!.id,
      'name': _currentAdmin!.name,
      'email': _currentAdmin!.email,
      'role': _currentAdmin!.role,
      'isActive': _currentAdmin!.isActive,
      'createdAt': _currentAdmin!.createdAt.toIso8601String(),
      'lastLogin': _currentAdmin!.lastLogin?.toIso8601String(),
    };
  }

  /// Check if user email is admin
  Future<bool> isUserAdmin(String email) async {
    try {
      final query = await _firestore
          .collection('admins')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if user is admin: $e');
      return false;
    }
  }
}
