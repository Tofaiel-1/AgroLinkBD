import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/models/user_model.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import '../shared/auth_constants.dart';
import '../shared/auth_text_field.dart';
import '../shared/auth_button.dart';
import '../shared/auth_header.dart';
import 'farmer_auth_controller.dart';

/// Farmer Login Screen
class FarmerLoginScreen extends StatefulWidget {
  const FarmerLoginScreen({super.key});

  @override
  State<FarmerLoginScreen> createState() => _FarmerLoginScreenState();
}

class _FarmerLoginScreenState extends State<FarmerLoginScreen> {
  final FarmerAuthController _controller = FarmerAuthController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AuthConstants.padding24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: AuthConstants.borderColor),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Header
                  const AuthHeader(
                    roleKey: 'farmer',
                    title: 'কৃষক লগইন',
                    subtitle:
                        'আপনার অ্যাকাউন্টে প্রবেশ করুন এবং শস্য বিক্রি শুরু করুন',
                  ),
                  const SizedBox(height: 40),

                  // Email field
                  AuthTextField(
                    controller: _controller.emailController,
                    label: 'Email',
                    labelBn: 'ইমেইল',
                    hint: 'example@email.com',
                    keyboardType: TextInputType.emailAddress,
                    roleColor: AuthConstants.farmerPrimary,
                    validator: _controller.validateEmail,
                    prefixIcon: '✉️',
                  ),

                  // Password field
                  AuthTextField(
                    controller: _controller.passwordController,
                    label: 'Password',
                    labelBn: 'পাসওয়ার্ড',
                    hint: 'আপনার পাসওয়ার্ড দিন',
                    isPassword: true,
                    roleColor: AuthConstants.farmerPrimary,
                    validator: _controller.validatePassword,
                    prefixIcon: '🔒',
                  ),

                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => _controller.handleForgotPassword(context),
                      child: const Text(
                        'পাসওয়ার্ড ভুলে গেছেন?',
                        style: TextStyle(
                          color: AuthConstants.farmerPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Login button
                  Obx(() => AuthButton(
                        label: 'Login',
                        labelBn: 'লগইন করুন',
                        onPressed: () => _handleLogin(),
                        roleColor: AuthConstants.farmerPrimary,
                        isLoading: _controller.isLoading.value,
                      )),
                  const SizedBox(height: 20),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'অ্যাকাউন্ট নেই?',
                        style: TextStyle(
                          color: AuthConstants.textLight,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Get.off(
                          () => const FarmerRegisterScreen(),
                          transition: Transition.rightToLeft,
                        ),
                        child: const Text(
                          'এখন নিবন্ধন করুন',
                          style: TextStyle(
                            color: AuthConstants.farmerPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final success = await _controller.login(
        email: _controller.emailController.text.trim(),
        password: _controller.passwordController.text,
      );

      if (success && mounted) {
        // Get user provider to load user data
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        if (_controller.authService.currentUser != null) {
          await userProvider.loadUser(_controller.authService.currentUser!.uid);
        }

        Get.offAllNamed('/farmer/dashboard');
      }
    } catch (e) {
      Get.snackbar(
        'লগইন ব্যর্থ ❌',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }
}

/// Farmer Register Screen
class FarmerRegisterScreen extends StatefulWidget {
  const FarmerRegisterScreen({super.key});

  @override
  State<FarmerRegisterScreen> createState() => _FarmerRegisterScreenState();
}

class _FarmerRegisterScreenState extends State<FarmerRegisterScreen> {
  final FarmerAuthController _controller = FarmerAuthController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AuthConstants.padding24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: AuthConstants.borderColor),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Header
                  const AuthHeader(
                    roleKey: 'farmer',
                    title: 'কৃষক রেজিস্ট্রেশন',
                    subtitle: 'নতুন অ্যাকাউন্ট তৈরি করুন এবং আজই শুরু করুন',
                    isRegister: true,
                  ),
                  const SizedBox(height: 40),

                  // Name field
                  AuthTextField(
                    controller: _controller.nameController,
                    label: 'Full Name',
                    labelBn: 'পূর্ণ নাম',
                    hint: 'আপনার পূর্ণ নাম দিন',
                    roleColor: AuthConstants.farmerPrimary,
                    validator: _controller.validateName,
                    prefixIcon: '👤',
                  ),

                  // Phone field
                  AuthTextField(
                    controller: _controller.phoneController,
                    label: 'Phone Number',
                    labelBn: 'মোবাইল নম্বর',
                    hint: '01xxxxxxxxx',
                    keyboardType: TextInputType.phone,
                    roleColor: AuthConstants.farmerPrimary,
                    validator: _controller.validatePhone,
                    prefixIcon: '📱',
                  ),

                  // Email field
                  AuthTextField(
                    controller: _controller.emailController,
                    label: 'Email',
                    labelBn: 'ইমেইল',
                    hint: 'example@email.com',
                    keyboardType: TextInputType.emailAddress,
                    roleColor: AuthConstants.farmerPrimary,
                    validator: _controller.validateEmail,
                    prefixIcon: '✉️',
                  ),

                  // Password field
                  AuthTextField(
                    controller: _controller.passwordController,
                    label: 'Password',
                    labelBn: 'পাসওয়ার্ড',
                    hint: 'শক্তিশালী পাসওয়ার্ড দিন',
                    isPassword: true,
                    roleColor: AuthConstants.farmerPrimary,
                    validator: _controller.validatePassword,
                    prefixIcon: '🔒',
                  ),

                  // Confirm password field
                  AuthTextField(
                    controller: _controller.confirmPasswordController,
                    label: 'Confirm Password',
                    labelBn: 'পাসওয়ার্ড নিশ্চিত করুন',
                    hint: 'পাসওয়ার্ড আবার দিন',
                    isPassword: true,
                    roleColor: AuthConstants.farmerPrimary,
                    validator: (value) =>
                        _controller.validateConfirmPassword(value),
                    prefixIcon: '✅',
                  ),

                  // Farm info (Farmer-specific)
                  AuthTextField(
                    controller: _controller.farmNameController,
                    label: 'Farm Name',
                    labelBn: 'খামারের নাম',
                    hint: 'আপনার খামারের নাম',
                    roleColor: AuthConstants.farmerPrimary,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'খামারের নাম প্রয়োজন' : null,
                    prefixIcon: '🌾',
                  ),

                  // Area field (Farmer-specific)
                  AuthTextField(
                    controller: _controller.areaController,
                    label: 'Farm Area (Bigha)',
                    labelBn: 'খামারের আয়তন (বিঘা)',
                    hint: 'উদাহরণ: 5',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    roleColor: AuthConstants.farmerPrimary,
                    prefixIcon: '📐',
                  ),

                  const SizedBox(height: 32),

                  // Register button
                  Obx(() => AuthButton(
                        label: 'Register',
                        labelBn: 'নিবন্ধন করুন',
                        onPressed: () => _handleRegister(),
                        roleColor: AuthConstants.farmerPrimary,
                        isLoading: _controller.isLoading.value,
                      )),
                  const SizedBox(height: 20),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'ইতিমধ্যে অ্যাকাউন্ট আছে?',
                        style: TextStyle(
                          color: AuthConstants.textLight,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Get.off(
                          () => const FarmerLoginScreen(),
                          transition: Transition.leftToRight,
                        ),
                        child: const Text(
                          'লগইন করুন',
                          style: TextStyle(
                            color: AuthConstants.farmerPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final success = await _controller.farmerRegister(
        email: _controller.emailController.text.trim(),
        password: _controller.passwordController.text,
        name: _controller.nameController.text.trim(),
        phone: _controller.phoneController.text.trim(),
        farmName: _controller.farmNameController.text.trim(),
        farmArea: _controller.areaController.text,
      );

      if (success && mounted) {
        Get.snackbar(
          'রেজিস্ট্রেশন সফল ✅',
          'আপনার অ্যাকাউন্ট তৈরি হয়েছে',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );

        // Navigate to login
        Get.off(() => const FarmerLoginScreen());
      }
    } catch (e) {
      Get.snackbar(
        'রেজিস্ট্রেশন ব্যর্থ ❌',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }
}
