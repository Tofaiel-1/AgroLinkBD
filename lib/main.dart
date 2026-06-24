import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider;
import 'package:agrolinkbd/presentation/screens/dashboard/buyer_dashboard_screen.dart';
import 'package:agrolinkbd/presentation/buyer/screens/browse_products_screen.dart';
import 'package:agrolinkbd/presentation/buyer/screens/cart_screen.dart';
import 'package:agrolinkbd/presentation/buyer/screens/checkout_screen.dart';
import 'package:agrolinkbd/presentation/buyer/screens/buyer_orders_screen.dart';
import 'package:agrolinkbd/presentation/buyer/screens/wishlist_screen.dart';
import 'core/services/notification_service.dart';
import 'core/services/location_service.dart';
import 'core/services/app_lifecycle_tracker.dart';
import 'presentation/screens/app_router.dart';
import 'presentation/screens/auth/auth_routing_controller.dart';
import 'presentation/screens/admin/admin_login_screen.dart';
import 'presentation/screens/admin/admin_dashboard.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/admin_provider.dart';
import 'core/providers/product_provider.dart';
import 'core/providers/auction_provider.dart';
import 'core/providers/machinery_provider.dart';
import 'core/providers/transport_provider.dart';
import 'core/providers/cart_provider.dart';
import 'core/providers/role_content_provider.dart';
import 'core/config/firebase_options.dart';
import 'ultimate_automatic_setup.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('✅ dotenv loaded successfully');
  } catch (e) {
    debugPrint('❌ Failed to load .env file: $e');
  }

  // Initialize Firebase with proper options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅✅✅ Firebase initialized successfully');

    // Configure Firestore settings
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    debugPrint('✅ Firestore configured with persistence enabled');

    // Enable offline data
    await FirebaseFirestore.instance.enableNetwork();
    debugPrint('✅ Firestore network enabled');

    // Force sign out to clear any stuck state from the background script
    await FirebaseAuth.instance.signOut();
    debugPrint('✅ Forced sign out to show login screen');
  } catch (e) {
    debugPrint('❌❌ Firebase initialization ERROR: $e');
    debugPrint('🔧 Ensure you have:');
    debugPrint('   1. google-services.json in android/app/');
    debugPrint('   2. Correct Firebase project credentials');
    debugPrint('   3. Internet connection enabled');
  }

  // Initialize Services (skip on web for now)
  try {
    if (!kIsWeb) {
      await NotificationService().initialize();
      await LocationService().initialize();
      debugPrint('✅ Notification and Location services initialized');
    }
  } catch (e) {
    debugPrint('⚠️ Service initialization warning: $e');
  }

  runApp(const AgroLinkBDApp());
}

/// Initialize super admin if not exists
Future<void> _initializeAdminIfNeeded() async {
  try {
    // Run the ultimate automatic setup
    await runUltimateSetupOnAppStart();
  } catch (e) {
    debugPrint('⚠️ Admin initialization error: $e');
  }
}

class AgroLinkBDApp extends StatelessWidget {
  const AgroLinkBDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => AdminProvider()),
          ChangeNotifierProvider(create: (_) => ProductProvider()),
          ChangeNotifierProvider(create: (_) => AuctionProvider()),
          ChangeNotifierProvider(create: (_) => MachineryProvider()),
          ChangeNotifierProvider(create: (_) => TransportProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => RoleContentProvider()),
        ],
        child: AppLifecycleTracker(
          child: GetMaterialApp(
          title: 'AgroLinkBD - কৃষি বাজার',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: const AppRouter(),
          initialBinding: AuthRouteBindings(),
          getPages: [
            // Auth routes
            ...authPages,

            // Admin routes
            GetPage(
              name: '/admin-login',
              page: () => const AdminLoginScreen(),
              transition: Transition.fadeIn,
            ),
            GetPage(
              name: '/admin-dashboard',
              page: () => const AdminDashboard(),
              transition: Transition.fadeIn,
            ),

            // Buyer routes
            GetPage(
              name: '/buyer/dashboard',
              page: () => const BuyerDashboardScreen(),
              transition: Transition.fadeIn,
            ),
            GetPage(
              name: '/buyer/browse',
              page: () => const BrowseProductsScreen(),
              transition: Transition.rightToLeft,
            ),
            GetPage(
              name: '/buyer/cart',
              page: () => const CartScreen(),
              transition: Transition.rightToLeft,
            ),
            GetPage(
              name: '/buyer/checkout',
              page: () => const CheckoutScreen(),
              transition: Transition.rightToLeft,
            ),
            GetPage(
              name: '/buyer/orders',
              page: () => const BuyerOrdersScreen(),
              transition: Transition.rightToLeft,
            ),
            GetPage(
              name: '/buyer/wishlist',
              page: () => const WishlistScreen(),
              transition: Transition.rightToLeft,
            ),
          ],
          // Fallback routes dictionary for named route navigation
          routes: {
            // ========== ADMIN ROUTES ==========
            '/admin-login': (context) => const AdminLoginScreen(),
            '/admin-dashboard': (context) => const AdminDashboard(),

            // ========== BUYER MODULE ROUTES ==========
            '/buyer/dashboard': (context) => const BuyerDashboardScreen(),
            '/buyer/browse': (context) => const BrowseProductsScreen(),
            '/buyer/cart': (context) => const CartScreen(),
            '/buyer/checkout': (context) => const CheckoutScreen(),
            '/buyer/orders': (context) => const BuyerOrdersScreen(),
            '/buyer/wishlist': (context) => const WishlistScreen(),
          },
        ),
        ),
      ),
    );
  }
}
