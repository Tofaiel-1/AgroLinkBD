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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/controllers/user_controller.dart';

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
                        onPressed: () {
                          Provider.of<AdminProvider>(context, listen: false).clearAdminState();
                          FirebaseAuth.instance.signOut();
                        },
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
                  adminProvider.clearAdminState();
                }
              });
              
              return const LoginScreen();
            }

            return Consumer2<AdminProvider, UserProvider>(
              builder: (context, adminProvider, userProvider, _) {
             final userId = authSnapshot.data!.uid;
             final email = authSnapshot.data!.email ?? 'user@example.com';

             // Show Admin dashboard ONLY IF this specific authenticated user is an active admin
             if (adminProvider.isAdminLoggedIn && adminProvider.currentAdmin?.id == userId) {
               return const AdvancedAdminDashboard();
             }

             // Show RoleBasedNavigationContainer if user data is available for this authenticated user
             if (userProvider.currentUser != null && userProvider.currentUser!.id == userId) {
               final user = userProvider.currentUser!;
               return RoleBasedNavigationContainer(user: user);
             }

            // User is authenticated - Load user data if not already loaded
            if (!_loadedUserIds.contains(userId) &&
                !_loadingUserIds.contains(userId)) {
              _loadingUserIds.add(userId);

              Future.microtask(() async {
                try {
                  // 1. Quick Admin Check for this specific user
                  try {
                    final adminDoc = await FirebaseFirestore.instance
                        .collection('admins')
                        .doc(userId)
                        .get()
                        .timeout(const Duration(milliseconds: 1500));
                    if (adminDoc.exists && mounted) {
                      debugPrint('✅ Admin profile verified: $userId');
                      Provider.of<AdminProvider>(context, listen: false).setAdminFromDoc(adminDoc);
                      _lastError = null;
                      return;
                    } else if (mounted) {
                      // Definitely NOT an admin -> clear admin state
                      Provider.of<AdminProvider>(context, listen: false).clearAdminState();
                    }
                  } catch (adminErr) {
                    debugPrint('ℹ️ Admin check bypassed/skipped: $adminErr');
                    if (mounted) {
                      Provider.of<AdminProvider>(context, listen: false).clearAdminState();
                    }
                  }

                  // 2. Load Regular User Profile from Firestore
                  if (mounted && !Provider.of<AdminProvider>(context, listen: false).isAdminLoggedIn) {
                    try {
                      await userProvider.loadUser(userId).timeout(const Duration(seconds: 8));
                    } catch (loadErr) {
                      debugPrint('⚠️ loadUser warning: $loadErr');
                    }

                    // 3. Fail-Safe: Check Firestore document directly before falling back
                    if (userProvider.currentUser == null) {
                      debugPrint('⏳ Checking active session profile for user: $userId');
                      try {
                        final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
                        if (userDoc.exists && userDoc.data() != null) {
                          final existingUser = UserModel.fromJson(userDoc.data()!);
                          userProvider.setCurrentUser(existingUser);
                          debugPrint('✅ Restored existing user profile (${existingUser.userType.name}): $userId');
                        }
                      } catch (docErr) {
                        debugPrint('⚠️ Direct user doc check error: $docErr');
                      }
                    }

                    // 4. If user profile still not loaded, consult local storage preferences instead of assuming farmer
                    if (userProvider.currentUser == null) {
                      final firebaseUser = authSnapshot.data!;
                      final prefs = await SharedPreferences.getInstance();
                      final savedRoleStr = prefs.getString('selected_role');
                      final savedDomainStr = prefs.getString('selected_domain');

                      UserType detectedType = UserType.farmer;
                      String detectedDomain = savedDomainStr ?? 'agriculture';

                      if (savedRoleStr != null && savedRoleStr.isNotEmpty) {
                        final clean = savedRoleStr.replaceAll('UserType.', '').replaceAll('_', '').toLowerCase();
                        if (clean == 'fishfarmer' || clean == 'fishfarming') {
                          detectedType = UserType.fishFarmer;
                          detectedDomain = 'fisheries';
                        } else if (clean == 'fishbuyer') {
                          detectedType = UserType.fishBuyer;
                          detectedDomain = 'fisheries';
                        } else if (clean == 'fishdriver') {
                          detectedType = UserType.fishDriver;
                          detectedDomain = 'fisheries';
                        } else {
                          detectedType = UserType.values.firstWhere(
                            (e) => e.name.toLowerCase() == clean,
                            orElse: () => UserType.farmer,
                          );
                        }
                      }

                      final fallbackUser = UserModel(
                        id: userId,
                        name: firebaseUser.displayName?.isNotEmpty == true
                            ? firebaseUser.displayName!
                            : (email.split('@').first),
                        phone: firebaseUser.phoneNumber ?? '',
                        email: email,
                        userType: detectedType,
                        domain: detectedDomain,
                        status: UserStatus.active,
                        createdAt: DateTime.now(),
                      );
                      // In-memory only! DO NOT overwrite Firestore user document with default!
                      userProvider.setCurrentUser(fallbackUser);
                    }

                    if (userProvider.currentUser != null) {
                      final activeUser = userProvider.currentUser!;
                      debugPrint('✅ User profile ready: $userId (${activeUser.userType.name})');

                      // 1. Synchronize GetX UserController
                      try {
                        final userController = Get.isRegistered<UserController>()
                            ? Get.find<UserController>()
                            : Get.put(UserController());
                        final userRole = _mapUserTypeToUserRole(activeUser.userType);
                        userController.setUserData(
                          id: activeUser.id,
                          name: activeUser.name,
                          phone: activeUser.phone,
                          location: activeUser.district ?? activeUser.address ?? '',
                          role: userRole,
                          balance: activeUser.mainBalance,
                        );
                      } catch (ucErr) {
                        debugPrint('⚠️ UserController sync: $ucErr');
                      }

                      // 2. Synchronize SharedPreferences
                      try {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('selected_domain', activeUser.domain);
                        await prefs.setString('selected_role', activeUser.userType.name);
                      } catch (prefErr) {
                        debugPrint('⚠️ SharedPreferences sync: $prefErr');
                      }

                      // 3. Auto-repair/persist Firestore role
                      try {
                        FirebaseFirestore.instance.collection('users').doc(userId).set({
                          'userType': activeUser.userType.name,
                          'role': activeUser.userType.name,
                          'domain': activeUser.domain,
                        }, SetOptions(merge: true));
                      } catch (_) {}
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
                  // Even on error, establish active fallback user without writing to Firestore
                  if (userProvider.currentUser == null) {
                    final firebaseUser = authSnapshot.data!;
                    final prefs = await SharedPreferences.getInstance();
                    final savedRoleStr = prefs.getString('selected_role');
                    final savedDomainStr = prefs.getString('selected_domain');
                    UserType detectedType = UserType.farmer;
                    String detectedDomain = savedDomainStr ?? 'agriculture';
                    if (savedRoleStr != null && savedRoleStr.isNotEmpty) {
                      final clean = savedRoleStr.replaceAll('UserType.', '').replaceAll('_', '').toLowerCase();
                      if (clean == 'fishfarmer' || clean == 'fishfarming' || clean == 'fish_farmer') {
                        detectedType = UserType.fishFarmer;
                        detectedDomain = 'fisheries';
                      } else if (clean == 'fishbuyer' || clean == 'fish_buyer') {
                        detectedType = UserType.fishBuyer;
                        detectedDomain = 'fisheries';
                      } else if (clean == 'fishdriver' || clean == 'fish_driver') {
                        detectedType = UserType.fishDriver;
                        detectedDomain = 'fisheries';
                      } else if (clean == 'fishserviceprovider' || clean == 'fish_service_provider') {
                        detectedType = UserType.fishServiceProvider;
                        detectedDomain = 'fisheries';
                      } else if (clean == 'fishcompany' || clean == 'fish_company') {
                        detectedType = UserType.fishCompany;
                        detectedDomain = 'fisheries';
                      } else if (clean == 'fishexpert' || clean == 'fish_expert') {
                        detectedType = UserType.fishExpert;
                        detectedDomain = 'fisheries';
                      } else if (clean == 'hatchery') {
                        detectedType = UserType.hatchery;
                        detectedDomain = 'fisheries';
                      } else if (clean == 'driver') {
                        detectedType = UserType.driver;
                        detectedDomain = 'agriculture';
                      } else if (clean == 'buyer') {
                        detectedType = UserType.buyer;
                        detectedDomain = 'agriculture';
                      } else if (clean == 'farmer') {
                        detectedType = UserType.farmer;
                        detectedDomain = 'agriculture';
                      } else if (clean == 'serviceprovider' || clean == 'service_provider') {
                        detectedType = UserType.serviceProvider;
                        detectedDomain = 'agriculture';
                      } else if (clean == 'company') {
                        detectedType = UserType.company;
                        detectedDomain = 'agriculture';
                      } else if (clean == 'seller') {
                        detectedType = UserType.seller;
                        detectedDomain = 'agriculture';
                      } else if (clean == 'expert') {
                        detectedType = UserType.expert;
                        detectedDomain = 'agriculture';
                      } else {
                        detectedType = UserType.values.firstWhere(
                          (e) => e.name.toLowerCase() == clean,
                          orElse: () => UserType.farmer,
                        );
                        detectedDomain = (detectedType.name.toLowerCase().contains('fish') || detectedType == UserType.hatchery)
                            ? 'fisheries'
                            : 'agriculture';
                      }
                    }
                    final recoveryUser = UserModel(
                      id: userId,
                      name: firebaseUser.displayName?.isNotEmpty == true
                          ? firebaseUser.displayName!
                          : (email.split('@').first),
                      phone: firebaseUser.phoneNumber ?? '',
                      email: email,
                      userType: detectedType,
                      domain: detectedDomain,
                      status: UserStatus.active,
                      createdAt: DateTime.now(),
                    );
                    userProvider.setCurrentUser(recoveryUser);
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
                              Provider.of<AdminProvider>(context, listen: false).clearAdminState();
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

  UserRole _mapUserTypeToUserRole(UserType type) {
    switch (type) {
      case UserType.farmer:
        return UserRole.farmer;
      case UserType.buyer:
        return UserRole.buyer;
      case UserType.driver:
        return UserRole.driver;
      case UserType.serviceProvider:
        return UserRole.serviceProvider;
      case UserType.company:
        return UserRole.company;
      case UserType.seller:
        return UserRole.seller;
      case UserType.expert:
        return UserRole.expert;
      case UserType.fishFarmer:
        return UserRole.fishFarmer;
      case UserType.fishBuyer:
        return UserRole.fishBuyer;
      case UserType.fishDriver:
        return UserRole.fishDriver;
      case UserType.fishServiceProvider:
        return UserRole.fishServiceProvider;
      case UserType.fishCompany:
        return UserRole.fishCompany;
      case UserType.fishExpert:
        return UserRole.fishExpert;
      case UserType.hatchery:
        return UserRole.hatchery;
    }
  }
}
