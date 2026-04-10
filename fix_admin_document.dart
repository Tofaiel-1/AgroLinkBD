import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// 🔧 FIX: Create Admin Document for Existing User
///
/// This script creates an admin document for an existing Firebase user
/// that already has a regular user profile.
///
/// Use this when:
/// - User registered as farmer/regular user first
/// - Now needs admin privileges
/// - Has valid Firebase Auth account but missing admin document

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

/// Create admin document for existing user with given UID
Future<Map<String, dynamic>> createAdminDocumentForUID(
  String existingUID, {
  String email = 'mdtofaielhussaintota@gmail.com',
  String name = 'Super Admin',
  String role = 'super_admin',
}) async {
  try {
    debugPrint('🔧 Starting admin document creation for UID: $existingUID');

    // Step 1: Check if admin document already exists
    debugPrint('📋 Step 1: Checking if admin document exists...');
    final adminDocRef = _firestore.collection('admins').doc(existingUID);
    final adminSnapshot = await adminDocRef.get();

    if (adminSnapshot.exists) {
      debugPrint('⚠️  Admin document already exists!');
      return {
        'success': false,
        'message': 'Admin document already exists for this UID',
        'action': 'Document already created',
      };
    }

    // Step 2: Verify user exists in users collection (safety check)
    debugPrint('📋 Step 2: Verifying user exists in users collection...');
    final userSnapshot =
        await _firestore.collection('users').doc(existingUID).get();

    if (!userSnapshot.exists) {
      debugPrint('⚠️  User document not found!');
      return {
        'success': false,
        'message': 'User not found with this UID',
        'action': 'Check UID and try again',
      };
    }

    final existingUser = userSnapshot.data();
    debugPrint(
        '✅ User found: ${existingUser?['name']} (${existingUser?['email']})');

    // Step 3: Create admin document with all required fields
    debugPrint('📝 Step 3: Creating admin document...');

    await adminDocRef.set({
      // All 7 required fields
      'id': existingUID,
      'email': email,
      'name': name,
      'role': role,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),

      // Additional fields
      'permissions': [
        'manage_users',
        'manage_products',
        'manage_admins',
        'view_analytics',
        'manage_orders',
      ],
      'status': 'active',
      'linkedUserUID': existingUID,
      'linkedUserEmail': existingUser?['email'] ?? email,
    });

    debugPrint('✅ Step 3 PASSED: Admin document created');

    // Step 4: Verify creation
    debugPrint('📋 Step 4: Verifying admin document...');
    final verifySnapshot = await adminDocRef.get();

    if (verifySnapshot.exists) {
      final data = verifySnapshot.data() as Map<String, dynamic>;
      debugPrint('✅ Verification successful with fields:');
      debugPrint('   ├─ id: ${data['id']}');
      debugPrint('   ├─ email: ${data['email']}');
      debugPrint('   ├─ name: ${data['name']}');
      debugPrint('   ├─ role: ${data['role']}');
      debugPrint('   ├─ isActive: ${data['isActive']}');
      debugPrint('   ├─ createdAt: ${data['createdAt']}');
      debugPrint('   └─ lastLogin: ${data['lastLogin']}');
    } else {
      debugPrint('❌ Verification failed - document not found after creation');
      return {
        'success': false,
        'message': 'Document creation verification failed',
        'action': 'Try again',
      };
    }

    debugPrint('');
    debugPrint('╔═══════════════════════════════════════════════════════╗');
    debugPrint('║  ✅ ADMIN DOCUMENT CREATED SUCCESSFULLY!              ║');
    debugPrint('╚═══════════════════════════════════════════════════════╝');
    debugPrint('');
    debugPrint('📍 Location: Firestore > admins > $existingUID');
    debugPrint('📧 Admin Email: $email');
    debugPrint('👤 Admin Name: $name');
    debugPrint('🔑 Role: $role');
    debugPrint('🆔 UID: $existingUID');
    debugPrint('');
    debugPrint('⚠️  NEXT STEPS:');
    debugPrint('   1. Comment out fixAdminDocumentForUID() call in main.dart');
    debugPrint('   2. Restart the app');
    debugPrint('   3. Navigate to Admin Login');
    debugPrint('   4. Login with credentials above');
    debugPrint('   5. Should see Admin Dashboard');
    debugPrint('');

    return {
      'success': true,
      'message': 'Admin document created successfully',
      'uid': existingUID,
      'email': email,
      'name': name,
      'role': role,
    };
  } catch (e) {
    debugPrint('❌ Unexpected error: $e');
    return {
      'success': false,
      'message': 'Error: $e',
      'action': 'Check Firestore permissions and try again',
    };
  }
}

/// Convenience function - use with exact UID from your Firebase console
Future<void> fixAdminForMdtofaielhussainUID() async {
  final result = await createAdminDocumentForUID(
    'nl896hqgaMc5NVfBLDJnZoP57uj2', // Your exact UID
    email: 'mdtofaielhussaintota@gmail.com',
    name: 'Super Admin',
    role: 'super_admin',
  );

  debugPrint('Result: $result');
}
