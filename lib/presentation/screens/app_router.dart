import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/core/providers/admin_provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/providers/cart_provider.dart';
import 'package:agrolinkbd/core/models/user_model.dart';
import 'package:agrolinkbd/presentation/screens/navigation/role_based_navigation_container.dart';
import 'package:agrolinkbd/presentation/screens/admin/admin_dashboard.dart';
import 'package:agrolinkbd/presentation/screens/auth/login_screen.dart';
import 'package:agrolinkbd/presentation/screens/auth/register_screen.dart';
import 'package:agrolinkbd/presentation/screens/admin/admin_security_pin_screen.dart';
import 'package:agrolinkbd/presentation/screens/admin/advanced_admin_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// App Router - Routes user to appropriate screen based on authentication and login status
/// 1. Admin logged in → AdminDashboard
/// 2. Regular user logged in → RoleBasedNavigation (routes by farmer/buyer/driver/service_provider)
/// 3. Not logged in → LoginScreen
class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  final Set<String> _loadingUserIds = {};
  final Set<String> _loadedUserIds = {};
  String? _lastError;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize app - restore user session if logged in
    // DO NOT sign out users on app restart
    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'অ্যাপ শুরু হচ্ছে...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // Still loading auth state
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'আপনার পরিচয় যাচাই করা হচ্ছে...',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              );
            }

            // Error in auth stream
            if (authSnapshot.hasError) {
              debugPrint('Auth Stream Error: ${authSnapshot.error}');
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'প্রমাণীকরণ ত্রুটি',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'দুঃখিত, প্রমাণীকরণ প্রক্রিয়ায় সমস্যা হয়েছে। অনুগ্রহ করে পুনরায় চেষ্টা করুন বা অ্যাপটি পুনরায় চালু করুন।',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => FirebaseAuth.instance.signOut(),
                        child: const Text('লগইন স্ক্রিনে যান'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // No user logged in
            if (authSnapshot.data == null) {
              _loadingUserIds.clear();
              _loadedUserIds.clear();
              
              // Clear stale provider state if previously logged out without clearing
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  final adminProvider = Provider.of<AdminProvider>(context, listen: false);
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  
                  if (adminProvider.isAdminLoggedIn) {
                    adminProvider.adminSignOut();
                  }
                  // We don't call userProvider.signOut() because it calls auth.signOut(), which could loop.
                  // We just need it to clear its internal state if we had a method for that.
                  // However, let's just let it be, as userProvider reloads data on login anyway.
                }
              });
              
              return const LoginScreen();
            }

            return Consumer2<AdminProvider, UserProvider>(
              builder: (context, adminProvider, userProvider, _) {
             final userId = authSnapshot.data!.uid;
            final email = authSnapshot.data!.email ?? 'user@example.com';

            // User is authenticated - Load user data if not already loaded
            if (!_loadedUserIds.contains(userId) &&
                !_loadingUserIds.contains(userId)) {
              _loadingUserIds.add(userId);

              Future.microtask(() async {
                try {
                  // Check if the user is an admin first
                  final adminDoc = await FirebaseFirestore.instance.collection('admins').doc(userId).get();
                  if (adminDoc.exists) {
                    debugPrint('✅ Admin profile found: $userId');
                    Provider.of<AdminProvider>(context, listen: false).setAdminFromDoc(adminDoc);
                    _lastError = null;
                  } else {
                    // Prevent race condition: if it's a known admin email, wait for setup script to create the doc
                    if (email == 'superadmin@agrolinkbd.com' || email == 'admin@agrolinkbd.com' || email == 'mdtofaielhussaintota@gmail.com') {
                      debugPrint('⏳ AppRouter: Superadmin detected but admin doc missing. Waiting for setup...');
                      await Future.delayed(const Duration(seconds: 4));
                      final retryAdmin = await FirebaseFirestore.instance.collection('admins').doc(userId).get();
                      if (retryAdmin.exists) {
                        debugPrint('✅ Admin profile found after wait: $userId');
                        Provider.of<AdminProvider>(context, listen: false).setAdminFromDoc(retryAdmin);
                        _lastError = null;
                      }
                    }

                    // Only proceed with user loading if AdminProvider is still NOT logged in
                    if (!Provider.of<AdminProvider>(context, listen: false).isAdminLoggedIn) {
                      // Try to load user from Firestore
                      await userProvider.loadUser(userId);

                      // Fallback: If profile document is missing in Firestore, create default user
                      // Only do this if there was NO error loading it (i.e. document actually does not exist)
                      if (userProvider.currentUser == null && userProvider.error == null) {
                        if (email == 'superadmin@agrolinkbd.com' || email == 'admin@agrolinkbd.com' || email == 'mdtofaielhussaintota@gmail.com') {
                          debugPrint('⏳ Skipping fallback farmer profile creation for superadmin');
                        } else {
                          debugPrint('⏳ Creating fallback profile for user: $userId');
                          final firebaseUser = authSnapshot.data!;
                          final fallbackUser = UserModel(
                            id: userId,
                            name: firebaseUser.displayName?.isNotEmpty == true
                                ? firebaseUser.displayName!
                                : (email.split('@').first),
                            phone: firebaseUser.phoneNumber ?? '',
                            email: email,
                            userType: UserType.farmer, // Default role
                            status: UserStatus.active,
                            createdAt: DateTime.now(),
                          );
                          await userProvider.updateUser(fallbackUser);
                        }
                      }

                      if (userProvider.currentUser != null) {
                        debugPrint('✅ User profile loaded: $userId');
                      }

                      try {
                        final cartProvider =
                            Provider.of<CartProvider>(context, listen: false);
                        cartProvider.loadUserCart(userId);
                      } catch (e) {
                        debugPrint('⚠️ Cart load warning in AppRouter: $e');
                      }

                      _lastError = null;
                    }
                  }
                } catch (e) {
                  debugPrint('❌ Error loading user profile: $e');
                  _lastError = 'প্রোফাইল লোড করতে সমস্যা হয়েছে';
                } finally {
                  _loadedUserIds.add(userId);
                  _loadingUserIds.remove(userId);
                  if (mounted) {
                    setState(() {});
                  }
                }
              });
            }

            // Show Admin dashboard if admin
            if (adminProvider.isAdminLoggedIn) {
              return const AdvancedAdminDashboard();
            }

            // Show RoleBasedNavigationContainer if user data is available
            if (userProvider.currentUser != null) {
              final user = userProvider.currentUser!;
              debugPrint(
                '✅ User authenticated: ${user.name} (${user.userType.toString().split('.').last})',
              );
              return RoleBasedNavigationContainer(user: user);
            }

            // Fallback while initializing or if error occurred
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'আপনার প্রোফাইল প্রস্তুত করা হচ্ছে...',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (_lastError != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'সমস্যা: $_lastError',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.orange.shade700,
                                  ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _loadedUserIds.remove(userId);
                                _loadingUserIds.remove(userId);
                                _lastError = null;
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('পুনরায় চেষ্টা করুন'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
                            },
                            icon: const Icon(Icons.logout),
                            label: const Text('লগইন এ যান'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
