import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// 🔐 Setup Superadmin with Specified Credentials
///
/// This script creates the exact superadmin account with:
/// Email: mdtofaielhussaintota@gmail.com
/// Password: super123
///
/// HOW TO USE:
/// 1. Add this to main.dart: await setupSuperadminAccount();
/// 2. Run the app once
/// 3. Check console for success message
/// 4. Remove this line from main.dart after success

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

/// Setup Superadmin Account ✅
Future<Map<String, dynamic>> setupSuperadminAccount() async {
  try {
    debugPrint('🔐 Starting Superadmin Setup...');

    const String email = 'mdtofaielhussaintota@gmail.com';
    const String password = 'super123';
    const String name = 'Super Admin';

    // ═══════════════════════════════════════════════════════════════
    // STEP 1: Check if admin already exists in Firestore
    // ═══════════════════════════════════════════════════════════════
    debugPrint('📋 Check 1: Looking for existing admin accounts...');
    final adminSnapshot = await _firestore.collection('admins').limit(1).get();

    if (adminSnapshot.docs.isNotEmpty) {
      debugPrint('⚠️  Admin already exists! Skipping setup...');
      return {
        'success': false,
        'message': 'Admin account already exists',
        'action': 'Login with existing credentials',
      };
    }
    debugPrint('✅ Check 1 PASSED: No existing admins found');

    // ═══════════════════════════════════════════════════════════════
    // STEP 2: Create Firebase Auth User
    // ═══════════════════════════════════════════════════════════════
    debugPrint('📝 Step 1: Creating Firebase Auth user...');
    debugPrint('   Email: $email');

    UserCredential userCredential;
    try {
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Auth Error: ${e.code}');

      if (e.code == 'email-already-in-use') {
        debugPrint('   User already exists in Auth. Trying to sign in...');
        // User exists, try to sign in
        try {
          userCredential = await _auth.signInWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );
          debugPrint('✅ Signed in to existing Auth user');
        } catch (signInError) {
          debugPrint('❌ Sign in failed: $signInError');
          return {
            'success': false,
            'message': 'User exists but password incorrect',
            'action': 'Reset password or use correct password',
          };
        }
      } else {
        debugPrint('   Error: ${e.message}');
        return {
          'success': false,
          'message': 'Firebase Auth Error: ${e.message}',
          'action': 'Check Firebase console and try again',
        };
      }
    }

    final String uid = userCredential.user!.uid;
    debugPrint('✅ Step 1 PASSED: Firebase Auth user created/found');
    debugPrint('   UID: $uid');

    // ═══════════════════════════════════════════════════════════════
    // STEP 3: Create/Update Admin Document in Firestore
    // ═══════════════════════════════════════════════════════════════
    debugPrint('📝 Step 2: Creating Firestore admin document...');

    final adminDocRef = _firestore.collection('admins').doc(uid);

    // Check if document exists
    final adminDocSnapshot = await adminDocRef.get();

    if (adminDocSnapshot.exists) {
      debugPrint('   Document exists. Updating...');
      await adminDocRef.update({
        'lastLogin': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Admin document updated');
    } else {
      debugPrint('   Creating new document...');

      // Create the admin document with ALL 7 FIELDS
      await adminDocRef.set({
        // Field 1: id
        'id': uid,

        // Field 2: email
        'email': email,

        // Field 3: name
        'name': name,

        // Field 4: role ⭐ CRITICAL
        'role': 'super_admin',

        // Field 5: isActive
        'isActive': true,

        // Field 6: createdAt (server timestamp)
        'createdAt': FieldValue.serverTimestamp(),

        // Field 7: lastLogin (server timestamp)
        'lastLogin': FieldValue.serverTimestamp(),

        // Additional useful fields
        'permissions': [
          'manage_users',
          'manage_products',
          'manage_admins',
          'view_analytics',
          'manage_orders',
        ],
        'status': 'active',
      });

      debugPrint('✅ Step 2 PASSED: Admin document created with 7 fields');
    }

    // ═══════════════════════════════════════════════════════════════
    // STEP 4: Verify Document Was Created
    // ═══════════════════════════════════════════════════════════════
    debugPrint('📋 Verification: Reading document back...');

    final verifySnapshot = await adminDocRef.get();
    if (verifySnapshot.exists) {
      final data = verifySnapshot.data() as Map<String, dynamic>;
      debugPrint('✅ Document verified with fields:');
      debugPrint('   ├─ id: ${data['id']}');
      debugPrint('   ├─ email: ${data['email']}');
      debugPrint('   ├─ name: ${data['name']}');
      debugPrint('   ├─ role: ${data['role']}');
      debugPrint('   ├─ isActive: ${data['isActive']}');
      debugPrint('   ├─ createdAt: ${data['createdAt']}');
      debugPrint('   └─ lastLogin: ${data['lastLogin']}');
    } else {
      debugPrint('❌ Document creation failed!');
      return {
        'success': false,
        'message': 'Document creation verification failed',
        'action': 'Check Firestore console and try again',
      };
    }

    // ═══════════════════════════════════════════════════════════════
    // SUCCESS! Sign out and return info
    // ═══════════════════════════════════════════════════════════════
    await _auth.signOut();
    debugPrint('✅ Auth signed out');

    // Print beautiful success message
    debugPrint('');
    debugPrint('╔═══════════════════════════════════════════════════════╗');
    debugPrint('║  ✅ SUPERADMIN ACCOUNT CREATED SUCCESSFULLY!          ║');
    debugPrint('╚═══════════════════════════════════════════════════════╝');
    debugPrint('');
    debugPrint('📧 Email: $email');
    debugPrint('🔐 Password: $password');
    debugPrint('👤 Name: $name');
    debugPrint('🆔 UID: $uid');
    debugPrint('');
    debugPrint('📍 Location: Firestore > admins > $uid');
    debugPrint('');
    debugPrint('⚠️  NEXT STEPS:');
    debugPrint('   1. Comment out setupSuperadminAccount() call in main.dart');
    debugPrint('   2. Restart the app');
    debugPrint('   3. Navigate to Admin Login');
    debugPrint('   4. Use above credentials to login');
    debugPrint('');
    debugPrint('💾 Save these credentials securely!');
    debugPrint('');

    return {
      'success': true,
      'message': 'Superadmin account created successfully',
      'email': email,
      'password': password,
      'uid': uid,
      'role': 'super_admin',
    };
  } catch (e) {
    debugPrint('❌ Unexpected error: $e');
    return {
      'success': false,
      'message': 'Unexpected error: $e',
      'action': 'Check logs and try again',
    };
  }
}

/// Quick verify if admin exists
Future<bool> superAdminExists() async {
  try {
    final adminSnapshot = await _firestore
        .collection('admins')
        .where('role', isEqualTo: 'super_admin')
        .limit(1)
        .get();

    return adminSnapshot.docs.isNotEmpty;
  } catch (e) {
    debugPrint('Error checking admin: $e');
    return false;
  }
}

/// Get admin details (for debugging)
Future<Map<String, dynamic>?> getAdminDetails(String uid) async {
  try {
    final doc = await _firestore.collection('admins').doc(uid).get();
    if (doc.exists) {
      return doc.data();
    }
  } catch (e) {
    debugPrint('Error getting admin details: $e');
  }
  return null;
}

/// Delete admin account (use with caution!)
/// This is for cleanup if setup goes wrong
Future<void> deleteAdminAccounts() async {
  try {
    debugPrint('❌ Deleting admin accounts...');

    final adminDocs = await _firestore.collection('admins').get();
    for (final doc in adminDocs.docs) {
      await doc.reference.delete();
      debugPrint('   Deleted: ${doc.id}');
    }

    debugPrint('✅ All admin accounts deleted');
  } catch (e) {
    debugPrint('Error deleting admins: $e');
  }
}
