import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Super Admin Setup Script
///
/// This script needs to run ONCE to create the first super admin.
///
/// HOW TO USE:
/// 1. In your Flutter app main.dart or during first startup, call:
///    - createFirstSuperAdmin() after Firebase is initialized
/// 2. After running once, remember the credentials
/// 3. Login with those credentials to access admin panel
/// 4. Use admin panel to create more admins

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

/// Create first super admin (run this once)
Future<bool> createFirstSuperAdmin() async {
  try {
    print('🔒 Creating Super Admin...');

    const String email = 'admin@agrolinkbd.com';
    const String password = 'Admin@2026Secure';
    const String name = 'Super Administrator';

    // Step 1: Check if admin already exists
    final existingAdmin = await _firestore.collection('admins').limit(1).get();
    if (existingAdmin.docs.isNotEmpty) {
      print('⚠️  Super admin already exists!');
      return false;
    }

    // Step 2: Create Firebase Auth user
    print('📝 Creating Firebase Auth user...');
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    String uid = userCredential.user!.uid;
    print('✅ Auth user created: $uid');

    // Step 3: Create admin document in Firestore
    print('📝 Creating admin profile...');
    await _firestore.collection('admins').doc(uid).set({
      'id': uid,
      'email': email,
      'name': name,
      'role': 'super_admin',
      'permissions': [
        'manage_users',
        'manage_products',
        'manage_admins',
        'view_analytics',
        'manage_auctions',
        'manage_machinery',
        'manage_transport',
      ],
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
    });

    print('✅ Admin document created');

    // Step 4: Sign out after setup
    await _auth.signOut();

    print('');
    print('═'.padRight(50, '═'));
    print('✅ SUPER ADMIN CREATED SUCCESSFULLY!');
    print('═'.padRight(50, '═'));
    print('');
    print('📧 Email: $email');
    print('🔐 Password: $password');
    print('👤 Name: $name');
    print('');
    print('⚠️  IMPORTANT: Save these credentials securely!');
    print('💡 Use these to login to the Admin Portal');
    print('');
    print('═'.padRight(50, '═'));

    return true;
  } on FirebaseAuthException catch (e) {
    print('❌ Auth Error: ${e.message}');
    if (e.code == 'email-already-in-use') {
      print('   - This email is already registered');
      print('   - Try another email or reset the admin account');
    }
    return false;
  } catch (e) {
    print('❌ Error: $e');
    return false;
  }
}

/// Reset admin account (use if first admin setup failed)
/// WARNING: This requires admin privileges to execute
Future<bool> resetAdminAccount() async {
  try {
    print('⚠️  RESETTING ADMIN ACCOUNT...');

    // Delete all admin documents
    final admins = await _firestore.collection('admins').get();
    for (var doc in admins.docs) {
      await doc.reference.delete();
      print('✅ Deleted admin: ${doc.id}');
    }

    print('✅ Admin accounts reset. You can now create a new super admin.');
    return true;
  } catch (e) {
    print('❌ Error resetting admin: $e');
    return false;
  }
}

/// Check super admin exists
Future<bool> superAdminExists() async {
  try {
    final admins = await _firestore
        .collection('admins')
        .where('role', isEqualTo: 'super_admin')
        .limit(1)
        .get();
    return admins.docs.isNotEmpty;
  } catch (e) {
    print('Error checking admin: $e');
    return false;
  }
}

/// Get admin by email
Future<Map<String, dynamic>?> getAdminByEmail(String email) async {
  try {
    final admin = await _firestore
        .collection('admins')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (admin.docs.isNotEmpty) {
      return admin.docs.first.data();
    }
    return null;
  } catch (e) {
    print('Error getting admin: $e');
    return null;
  }
}

// MAIN FUNCTION FOR MANUAL TESTING
void main() async {
  print('AgroLinkBD Admin Setup Tool');
  print('Note: This requires Firebase initialization from Flutter app\n');

  // Uncomment to test (requires Firebase initialized):
  // await createFirstSuperAdmin();
}
