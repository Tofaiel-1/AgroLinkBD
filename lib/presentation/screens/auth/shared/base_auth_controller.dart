import 'package:agrolinkbd/core/models/user_model.dart';
import 'package:agrolinkbd/core/services/auth_service.dart';

/// Base auth controller for all roles - to be extended by role-specific controllers
abstract class BaseAuthController {
  final AuthService authService = AuthService();

  /// Common fields
  late String email;
  late String password;
  late String phone;
  late String name;

  /// Login method - implemented by each role
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      await authService.signInWithEmail(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Register method - implemented by each role
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserType userType,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await authService.registerWithEmail(
        email: email,
        password: password,
        name: name,
        phone: phone,
        userType: userType.toString(),
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Role-specific validation - override in each role controller
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'ফোন নম্বর প্রয়োজন';
    }
    if (value.length != 11 && !value.startsWith('01')) {
      return 'সঠিক বাংলাদেশী ফোন নম্বর দিন';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'ইমেইল প্রয়োজন';
    }
    if (!value.contains('@')) {
      return 'সঠিক ইমেইল দিন';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'পাসওয়ার্ড প্রয়োজন';
    }
    if (value.length < 6) {
      return 'পাসওয়ার্ড কমপক্ষে ৬ ক্যারেক্টার হওয়া উচিত';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'নাম প্রয়োজন';
    }
    if (value.length < 3) {
      return 'নাম কমপক্ষে ৩ ক্যারেক্টার হওয়া উচিত';
    }
    return null;
  }

  /// Logout
  Future<void> logout() async {
    await authService.signOut();
  }
}
