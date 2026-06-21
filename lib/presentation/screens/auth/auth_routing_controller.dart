import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'farmer/farmer_auth_screens.dart';
import 'buyer/buyer_auth_screens.dart';
import 'driver/driver_auth_screens.dart';
import 'service_provider/service_provider_auth_screens.dart';
import 'company/company_auth_screens.dart';
import 'role_selection_screen.dart';

/// Auth Routing Controller - Manages navigation across all role-based auth flows
class AuthRoutingController extends GetxController {
  static const String routeRoleSelection = '/auth/role-selection';
  static const String routeFarmerLogin = '/auth/farmer/login';
  static const String routeFarmerRegister = '/auth/farmer/register';
  static const String routeBuyerLogin = '/auth/buyer/login';
  static const String routeBuyerRegister = '/auth/buyer/register';
  static const String routeDriverLogin = '/auth/driver/login';
  static const String routeDriverRegister = '/auth/driver/register';
  static const String routeServiceProviderLogin =
      '/auth/service_provider/login';
  static const String routeServiceProviderRegister =
      '/auth/service_provider/register';
  static const String routeCompanyLogin = '/auth/company/login';
  static const String routeCompanyRegister = '/auth/company/register';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _currentRole = ''.obs;
  final _isLoggedIn = false.obs;

  String get currentRole => _currentRole.value;
  bool get isLoggedIn => _isLoggedIn.value;

  @override
  void onInit() {
    super.onInit();
    // Only track auth state - do NOT auto-navigate
    // AppRouter handles all auth-based routing via StreamBuilder
    _auth.authStateChanges().listen(_handleAuthStateChange);
    final user = _auth.currentUser;
    if (user != null) {
      _isLoggedIn.value = true;
    }
  }

  /// Handle Firebase auth state changes (tracking only, no navigation)
  void _handleAuthStateChange(User? user) {
    if (user != null) {
      _isLoggedIn.value = true;
    } else {
      _isLoggedIn.value = false;
    }
  }

  /// Navigate to role selection screen
  void goToRoleSelection() {
    _currentRole.value = '';
    Get.offAllNamed(routeRoleSelection);
  }

  /// Navigate to role-specific login based on selected role
  void goToRoleLogin(String role) {
    _currentRole.value = role;
    final routeMap = {
      'farmer': routeFarmerLogin,
      'buyer': routeBuyerLogin,
      'driver': routeDriverLogin,
      'service_provider': routeServiceProviderLogin,
      'company': routeCompanyLogin,
    };
    final route = routeMap[role];
    if (route != null) {
      Get.offNamed(route);
    }
  }

  /// Navigate to role-specific register based on selected role
  void goToRoleRegister(String role) {
    _currentRole.value = role;
    final routeMap = {
      'farmer': routeFarmerRegister,
      'buyer': routeBuyerRegister,
      'driver': routeDriverRegister,
      'service_provider': routeServiceProviderRegister,
      'company': routeCompanyRegister,
    };
    final route = routeMap[role];
    if (route != null) {
      Get.offNamed(route);
    }
  }

  /// Navigate to role-specific dashboard after successful login
  void goToDashboard(String role) {
    _currentRole.value = role;
    final dashboardRoutes = {
      'farmer': '/farmer/dashboard',
      'buyer': '/buyer/dashboard',
      'driver': '/driver/dashboard',
      'service_provider': '/service_provider/dashboard',
      'company': '/company/dashboard',
    };
    final route = dashboardRoutes[role];
    if (route != null) {
      Get.offAllNamed(route);
    }
  }


  /// Logout and return to role selection
  Future<void> logout() async {
    try {
      await _auth.signOut();
      _isLoggedIn.value = false;
      _currentRole.value = '';
      goToRoleSelection();
    } catch (e) {
      Get.snackbar(
        'লগআউট ত্রুটি',
        'লগআউট করতে ব্যর্থ: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }
}

/// Auth Flow Handler - Manages the complete auth flow
class AuthFlowHandler {
  static final AuthRoutingController _controller =
      Get.isRegistered<AuthRoutingController>()
          ? Get.find<AuthRoutingController>()
          : Get.put(AuthRoutingController());

  /// Start auth flow from app
  static void startAuthFlow() {
    _controller.goToRoleSelection();
  }

  /// Get current auth controller
  static AuthRoutingController getController() => _controller;
}

/// Auth Route Bindings - Register all auth screens with GetX
class AuthRouteBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthRoutingController());
  }
}

/// Role Selection Route - Initial role selection screen
List<GetPage> get authPages => [
      GetPage(
        name: AuthRoutingController.routeRoleSelection,
        page: () => const RoleSelectionScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: AuthRoutingController.routeFarmerLogin,
        page: () => const FarmerLoginScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: AuthRoutingController.routeFarmerRegister,
        page: () => const FarmerRegisterScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: AuthRoutingController.routeBuyerLogin,
        page: () => const BuyerLoginScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: AuthRoutingController.routeBuyerRegister,
        page: () => const BuyerRegisterScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: AuthRoutingController.routeDriverLogin,
        page: () => const DriverLoginScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: AuthRoutingController.routeDriverRegister,
        page: () => const DriverRegisterScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: AuthRoutingController.routeServiceProviderLogin,
        page: () => const ServiceProviderLoginScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: AuthRoutingController.routeServiceProviderRegister,
        page: () => const ServiceProviderRegisterScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: AuthRoutingController.routeCompanyLogin,
        page: () => const CompanyLoginScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: AuthRoutingController.routeCompanyRegister,
        page: () => const CompanyRegisterScreen(),
        transition: Transition.rightToLeft,
      ),
    ];
