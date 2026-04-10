import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'core/services/notification_service.dart';
import 'core/services/location_service.dart';
import 'presentation/screens/app_router.dart';
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
import 'core/config/firebase_options.dart';
import 'core/controllers/user_controller.dart';
import 'ultimate_automatic_setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

    // Initialize admin on first run
    await _initializeAdminIfNeeded();
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

  // Register GetX Controllers
  try {
    Get.put(UserController());
    debugPrint('✅ UserController registered with GetX');
  } catch (e) {
    debugPrint('⚠️ UserController registration warning: $e');
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

  // Firebase will be added later
  // static FirebaseAnalytics? analytics = FirebaseAnalytics.instance;
  // static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics!);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => AuctionProvider()),
        ChangeNotifierProvider(create: (_) => MachineryProvider()),
        ChangeNotifierProvider(create: (_) => TransportProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: GetMaterialApp(
        title: 'AgroLinkBD',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AppRouter(), // Routes based on admin/user login status
        // home: const WelcomeScreen(), // Restore when auth is needed
        // navigatorObservers: [observer], // Will be enabled when Firebase is added
        locale: const Locale('bn', 'BD'),
        fallbackLocale: const Locale('en', 'US'),
        translations: AppTranslations(),
        routes: {
          '/admin-login': (context) => const AdminLoginScreen(),
          '/admin-dashboard': (context) => const AdminDashboard(),
        },
      ),
    );
  }
}

// Localization
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'bn_BD': {
          'app_name': 'AgroLinkBD',
          'welcome': 'Welcome',
          'login': 'Login',
          'register': 'Register',
          'farmer': 'Farmer',
          'buyer': 'Buyer',
          'driver': 'Driver',
          'service_provider': 'Service Provider',
          'marketplace': 'Marketplace',
          'machinery_rental': 'Machinery Rental',
          'transport': 'Transport',
          'auction': 'Auction',
          'invest': 'Investment',
          'soil_test': 'Soil Testing',
          'voice_assistant': 'Voice Assistant',
          'calendar': 'Calendar',
          'contract_farming': 'Contract Farming',
        },
        'en_US': {
          'app_name': 'AgroLinkBD',
          'welcome': 'Welcome',
          'login': 'Login',
          'register': 'Register',
          'farmer': 'Farmer',
          'buyer': 'Buyer',
          'driver': 'Driver',
          'service_provider': 'Service Provider',
          'marketplace': 'Marketplace',
          'machinery_rental': 'Machinery Rental',
          'transport': 'Transport',
          'auction': 'Auction',
          'invest': 'Invest',
          'soil_test': 'Soil Test',
          'voice_assistant': 'Voice Assistant',
          'calendar': 'Calendar',
          'contract_farming': 'Contract Farming',
        },
      };
}
