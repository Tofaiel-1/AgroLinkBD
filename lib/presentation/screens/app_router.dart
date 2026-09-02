import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/core/providers/admin_provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/providers/cart_provider.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/models/user_model.dart';
import 'package:agrolinkbd/presentation/screens/navigation/role_based_navigation_container.dart';
import 'package:agrolinkbd/presentation/screens/auth/login_screen.dart';
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
    final bool isBn = LanguageProvider.isBn(context);

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
                isBn ? 'অ্যাপ শুরু হচ্ছে...' : 'Starting app...',
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
                        isBn ? 'আপনার পরিচয় যাচাই করা হচ্ছে...' : 'Verifying your identity...',
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
                        isBn ? 'প্রমাণীকরণ ত্রুটি' : 'Authentication Error',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          isBn
                              ? 'দুঃখিত, প্রমাণীকরণ প্রক্রিয়ায় সমস্যা হয়েছে। অনুগ্রহ করে পুনরায় চেষ্টা করুন বা অ্যাপটি পুনরায় চালু করুন।'
                              : 'Sorry, an authentication error occurred. Please try again or restart the app.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => FirebaseAuth.instance.signOut(),
                        child: Text(isBn ? 'লগইন স্ক্রিনে যান' : 'Go to Login'),
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

             // Show Admin dashboard if admin
            if (adminProvider.isAdminLoggedIn) {
              return const AdvancedAdminDashboard();
            }

            // Show RoleBasedNavigationContainer if user data is available
            if (userProvider.currentUser != null) {
              final user = userProvider.currentUser!;
              return RoleBasedNavigationContainer(user: user);
            }

            // User is authenticated - Load user data if not already loaded
            if (!_loadedUserIds.contains(userId) &&
                !_loadingUserIds.contains(userId)) {
              _loadingUserIds.add(userId);

              Future.microtask(() async {
                try {
                  // 1. Quick Admin Check
                  try {
                    final adminDoc = await FirebaseFirestore.instance
                        .collection('admins')
                        .doc(userId)
                        .get()
                        .timeout(const Duration(milliseconds: 1500));
                    if (adminDoc.exists && mounted) {
                      debugPrint('✅ Admin profile found: $userId');
                      Provider.of<AdminProvider>(context, listen: false).setAdminFromDoc(adminDoc);
                      _lastError = null;
                      return;
                    }
                  } catch (adminErr) {
                    debugPrint('ℹ️ Admin check bypassed/skipped: $adminErr');
                  }

                  // 2. Load Regular User Profile from Firestore
                  if (mounted && !Provider.of<AdminProvider>(context, listen: false).isAdminLoggedIn) {
                    try {
                      await userProvider.loadUser(userId).timeout(const Duration(seconds: 4));
                    } catch (loadErr) {
                      debugPrint('⚠️ loadUser warning: $loadErr');
                    }

                    // 3. Fail-Safe Instant Fallback Profile if profile was missing
                    if (userProvider.currentUser == null) {
                      debugPrint('⏳ Creating/restoring active session profile for user: $userId');
                      final firebaseUser = authSnapshot.data!;
                      final fallbackUser = UserModel(
                        id: userId,
                        name: firebaseUser.displayName?.isNotEmpty == true
                            ? firebaseUser.displayName!
                            : (email.split('@').first),
                        phone: firebaseUser.phoneNumber ?? '',
                        email: email,
                        userType: UserType.farmer,
                        status: UserStatus.active,
                        createdAt: DateTime.now(),
                      );
                      await userProvider.updateUser(fallbackUser);
                    }

                    if (userProvider.currentUser != null) {
                      debugPrint('✅ User profile ready: $userId');
                    }

                    try {
                      if (mounted) {
                        final cartProvider = Provider.of<CartProvider>(context, listen: false);
                        cartProvider.loadUserCart(userId);
                      }
                    } catch (e) {
                      debugPrint('⚠️ Cart load warning: $e');
                    }

                    _lastError = null;
                  }
                } catch (e) {
                  debugPrint('⚠️ AppRouter profile recovery fallback: $e');
                  // Even on error, establish active fallback user so Shift+R hot restart never gets stuck
                  if (userProvider.currentUser == null) {
                    final firebaseUser = authSnapshot.data!;
                    final recoveryUser = UserModel(
                      id: userId,
                      name: firebaseUser.displayName?.isNotEmpty == true
                          ? firebaseUser.displayName!
                          : (email.split('@').first),
                      phone: firebaseUser.phoneNumber ?? '',
                      email: email,
                      userType: UserType.farmer,
                      status: UserStatus.active,
                      createdAt: DateTime.now(),
                    );
                    userProvider.updateUser(recoveryUser);
                  }
                  _lastError = null;
                } finally {
                  _loadedUserIds.add(userId);
                  _loadingUserIds.remove(userId);
                  if (mounted) {
                    setState(() {});
                  }
                }
              });
            }

            final bool isBn = LanguageProvider.isBn(context);

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
                        isBn
                            ? 'আপনার প্রোফাইল প্রস্তুত করা হচ্ছে...'
                            : 'Preparing your profile...',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (_lastError != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          isBn ? 'সমস্যা: $_lastError' : 'Error: $_lastError',
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
                            label: Text(isBn ? 'পুনরায় চেষ্টা করুন' : 'Retry'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
                            },
                            icon: const Icon(Icons.logout),
                            label: Text(isBn ? 'লগইন এ যান' : 'Go to Login'),
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
