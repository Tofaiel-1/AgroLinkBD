import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/user_model.dart';
import 'audit_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuditService _auditService = AuditService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get Device Info
  Future<String> _getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        return webInfo.userAgent ?? 'Web Browser';
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return '${iosInfo.name} ${iosInfo.model}';
      }
      return 'Unknown Device';
    } catch (e) {
      return 'Unknown Device';
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Log successful login
      if (credential.user != null) {
        final deviceInfo = await _getDeviceInfo();
        await _auditService.logUserSessionEvent(
          userId: credential.user!.uid,
          userName: email,
          action: 'login',
          deviceInfo: deviceInfo,
        );
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      // Log failed login
      final deviceInfo = await _getDeviceInfo();
      await _auditService.logUserSessionEvent(
        userId: 'unknown',
        userName: email,
        action: 'failed_login',
        deviceInfo: deviceInfo,
        status: 'failed',
      );

      // Check if suspicious
      final isSuspicious = await _auditService.isSuspiciousActivity('unknown');
      if (isSuspicious) {
        await _auditService.logUserSessionEvent(
          userId: 'unknown',
          userName: email,
          action: 'suspicious_activity',
          deviceInfo: deviceInfo,
          status: 'suspicious',
        );
      }

      throw _handleAuthException(e);
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    String? name,
    String? phone,
    String? userType,
  }) async {
    try {
      debugPrint('📝 Starting registration for email: $email');

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('✅ Firebase Auth account created: ${credential.user?.uid}');

      // Create user profile document immediately
      if (credential.user != null) {
        try {
          final Map<String, dynamic> data = {
            'id': credential.user!.uid,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
            'emailVerified': false,
            'isPremium': false,
            'isActive': true,
          };
          if (name != null) data['name'] = name;
          if (phone != null) data['phone'] = phone;
          if (userType != null) data['userType'] = userType;

          await _firestore.collection('users').doc(credential.user!.uid).set(data, SetOptions(merge: true));
          debugPrint('✅ User profile created in Firestore');
        } catch (e) {
          debugPrint('⚠️ Warning - could not create profile: $e');
        }
      }

      // Send email verification
      try {
        await credential.user?.sendEmailVerification();
        debugPrint('✅ Verification email sent to: $email');
      } catch (e) {
        debugPrint('⚠️ Warning - could not send verification email: $e');
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Registration error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Unexpected error during registration: $e');
      throw 'Registration failed: $e';
    }
  }

  // Register buyer profile after user registration
  Future<void> createBuyerProfile({
    required String userId,
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      debugPrint('🛍️ Creating buyer profile for: $userId');

      await _firestore.collection('buyer_profiles').doc(userId).set({
        'id': userId,
        'name': name,
        'email': email,
        'phone': phone,
        'profilePhoto': null,
        'walletBalance': 0.0,
        'savedFarmers': [],
        'wishlistProducts': [],
        'defaultAddressId': null,
        'totalSpent': 0.0,
        'totalOrdersPlaced': 0,
        'averageRating': 0.0,
        'memberSince': FieldValue.serverTimestamp(),
        'isKycVerified': false,
        'savedCouponCodes': [],
        'referralEarnings': 0,
        'preferredLanguage': 'bn',
        'darkModeEnabled': false,
        'notificationPreferences': {
          'orderUpdates': true,
          'promotions': true,
          'alerts': true,
        },
        'preferredCategories': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Buyer profile created successfully');
    } catch (e) {
      debugPrint('⚠️ Could not create buyer profile: $e');
      throw 'Failed to create buyer profile: $e';
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Use a strong password with at least 6 characters.';
      case 'email-already-in-use':
        return 'This email is already registered. Use a different email or login.';
      case 'invalid-email':
        return 'Invalid email address. Please enter a valid email.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Wrong password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Contact admin.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }

  // Sign in with phone number
  Future<void> signInWithPhone({
    required String phoneNumber,
    required Function(String verificationId) codeSent,
    required Function(String error) verificationFailed,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        verificationFailed(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      timeout: const Duration(seconds: 60),
    );
  }

  // Verify OTP
  Future<UserCredential> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    return await _auth.signInWithCredential(credential);
  }

  // Create or update user profile
  Future<void> createOrUpdateUser(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.id)
        .set(user.toJson(), SetOptions(merge: true));
  }

  // Get user data
  Future<UserModel?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
        throw Exception(
            'Internet connection failed. Please check your connection and try again.');
      } else if (e.code == 'permission-denied') {
        throw Exception('You do not have permission to access this data.');
      } else {
        throw Exception('Failed to load data: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Update last login
  Future<void> updateLastLogin(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'lastLoginAt': DateTime.now().toIso8601String(),
    });
  }

  // Sign out
  Future<void> signOut() async {
    try {
      debugPrint('🔐 Starting logout process...');
      final user = _auth.currentUser;

      if (user != null) {
        // Calculate session duration and log logout
        final lastLogin = await _auditService.getLastLoginTime(user.uid);
        int? durationInSeconds;
        if (lastLogin != null) {
          durationInSeconds = DateTime.now().difference(lastLogin).inSeconds;
        }

        final deviceInfo = await _getDeviceInfo();
        await _auditService.logUserSessionEvent(
          userId: user.uid,
          userName: user.email ?? user.phoneNumber ?? 'unknown',
          action: 'logout',
          deviceInfo: deviceInfo,
          sessionDuration: durationInSeconds,
        );
      }

      // Sign out from Firebase Auth
      await _auth.signOut();
      debugPrint('✅ Firebase Auth signout complete');

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      debugPrint('✅ SharedPreferences cleared');

      debugPrint('✅ Logout successful');
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      rethrow;
    }
  }

  // Update premium status
  Future<void> updatePremiumStatus({
    required String userId,
    required bool isPremium,
    DateTime? expiryDate,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'isPremium': isPremium,
      'premiumExpiryDate': expiryDate?.toIso8601String(),
    });
  }

  // Check if user exists
  Future<bool> userExists(String userId) async {
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(userId).get();
    return doc.exists;
  }
}
