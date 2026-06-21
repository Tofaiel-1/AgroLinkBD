import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/models/user_model.dart';
import '../shared/base_auth_controller.dart';

/// Service Provider-specific auth controller
class ServiceProviderAuthController extends BaseAuthController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final nameController = TextEditingController();
  final servicesController = TextEditingController();
  final experienceController = TextEditingController();

  final isLoading = false.obs;

  @override
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'ইমেইল প্রয়োজন';
    if (!GetUtils.isEmail(value)) return 'সঠিক ইমেইল ঠিকানা দিন';
    return null;
  }

  @override
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'পাসওয়ার্ড প্রয়োজন';
    if (value.length < 6) return 'পাসওয়ার্ড কমপক্ষে ৬ ক্যারেক্টার হতে হবে';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'পাসওয়ার্ড নিশ্চিত করুন';
    if (value != passwordController.text) return 'পাসওয়ার্ড মিলছে না';
    return null;
  }

  @override
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'মোবাইল নম্বর প্রয়োজন';
    if (!value.startsWith('01')) return 'বৈধ বাংলাদেশী নম্বর দিন';
    if (value.length != 11) return 'নম্বর ১১ সংখ্যার হওয়া উচিত';
    return null;
  }

  @override
  String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'নাম প্রয়োজন';
    if (value.length < 3) return 'নাম কমপক্ষে ৩ অক্ষর হতে হবে';
    return null;
  }

  Future<bool> serviceProviderLogin(
      {required String email, required String password}) async {
    try {
      isLoading.value = true;
      final result = await super.login(email: email, password: password);
      isLoading.value = false;
      return result;
    } catch (e) {
      isLoading.value = false;
      rethrow;
    }
  }

  Future<bool> serviceProviderRegister({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String servicesOffered,
    required String yearsOfExperience,
  }) async {
    try {
      isLoading.value = true;
      final result = await super.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
        userType: UserType.serviceProvider,
      );

      if (result && authService.currentUser != null) {
        // Create service provider user profile
        final user = UserModel(
          id: authService.currentUser!.uid,
          name: name,
          phone: phone,
          email: email,
          userType: UserType.serviceProvider,
          status: UserStatus.active,
          createdAt: DateTime.now(),
          machineryTypes:
              servicesOffered.split(',').map((e) => e.trim()).toList(),
          yearsOfExperience: int.tryParse(yearsOfExperience),
          hourlyRate: 0.0,
        );
        await authService.createOrUpdateUser(user);
      }

      isLoading.value = false;
      return result;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('ত্রুটি ❌', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900);
      rethrow;
    }
  }

  Future<void> handleForgotPassword(BuildContext context) async {
    if (emailController.text.isEmpty) {
      Get.snackbar('ইমেইল প্রয়োজন', 'পাসওয়ার্ড রিসেট করতে ইমেইল লিখুন',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      await authService.sendPasswordResetEmail(emailController.text.trim());
      Get.snackbar('সফল ✅', 'পাসওয়ার্ড রিসেট লিংক আপনার ইমেইলে পাঠানো হয়েছে',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900);
    } catch (e) {
      Get.snackbar('ত্রুটি ❌', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    nameController.dispose();
    servicesController.dispose();
    experienceController.dispose();
  }
}
