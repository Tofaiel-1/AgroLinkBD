import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/models/user_model.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import '../shared/auth_constants.dart';
import '../shared/auth_text_field.dart';
import '../shared/auth_button.dart';
import '../shared/auth_header.dart';
import 'buyer_auth_controller.dart';

/// Buyer Login Screen
class BuyerLoginScreen extends StatefulWidget {
  const BuyerLoginScreen({super.key});

  @override
  State<BuyerLoginScreen> createState() => _BuyerLoginScreenState();
}

class _BuyerLoginScreenState extends State<BuyerLoginScreen> {
  final BuyerAuthController _controller = BuyerAuthController();
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
                  const AuthHeader(
                    roleKey: 'buyer',
                    title: 'ক্রেতা লগইন',
                    subtitle: 'সেরা কৃষি পণ্য কিনুন সরাসরি কৃষকদের কাছ থেকে',
                  ),
                  const SizedBox(height: 40),
                  AuthTextField(
                    controller: _controller.emailController,
                    label: 'Email',
                    labelBn: 'ইমেইল',
                    hint: 'example@email.com',
                    keyboardType: TextInputType.emailAddress,
                    roleColor: AuthConstants.buyerPrimary,
                    validator: _controller.validateEmail,
                    prefixIcon: '✉️',
                  ),
                  AuthTextField(
                    controller: _controller.passwordController,
                    label: 'Password',
                    labelBn: 'পাসওয়ার্ড',
                    hint: 'আপনার পাসওয়ার্ড দিন',
                    isPassword: true,
                    roleColor: AuthConstants.buyerPrimary,
                    validator: _controller.validatePassword,
                    prefixIcon: '🔒',
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => _controller.handleForgotPassword(context),
                      child: const Text(
                        'পাসওয়ার্ড ভুলে গেছেন?',
                        style: TextStyle(
                          color: AuthConstants.buyerPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Obx(() => AuthButton(
                        label: 'Login',
                        labelBn: 'লগইন করুন',
                        onPressed: () => _handleLogin(),
                        roleColor: AuthConstants.buyerPrimary,
                        isLoading: _controller.isLoading.value,
                      )),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('অ্যাকাউন্ট নেই?',
                          style: TextStyle(
                              color: AuthConstants.textLight, fontSize: 14)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Get.off(() => const BuyerRegisterScreen(),
                            transition: Transition.rightToLeft),
                        child: const Text('এখন নিবন্ধন করুন',
                            style: TextStyle(
                                color: AuthConstants.buyerPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
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
      final success = await _controller.buyerLogin(
        email: _controller.emailController.text.trim(),
        password: _controller.passwordController.text,
      );
      if (success && mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        if (_controller.authService.currentUser != null) {
          await userProvider.loadUser(_controller.authService.currentUser!.uid);
        }
        Get.offAllNamed('/buyer/dashboard');
      }
    } catch (e) {
      Get.snackbar('লগইন ব্যর্থ ❌', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900);
    }
  }
}

/// Buyer Register Screen
class BuyerRegisterScreen extends StatefulWidget {
  const BuyerRegisterScreen({super.key});

  @override
  State<BuyerRegisterScreen> createState() => _BuyerRegisterScreenState();
}

class _BuyerRegisterScreenState extends State<BuyerRegisterScreen> {
  final BuyerAuthController _controller = BuyerAuthController();
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
                  const AuthHeader(
                    roleKey: 'buyer',
                    title: 'ক্রেতা রেজিস্ট্রেশন',
                    subtitle: 'নতুন অ্যাকাউন্ট তৈরি করুন এবং শপিং শুরু করুন',
                    isRegister: true,
                  ),
                  const SizedBox(height: 40),
                  AuthTextField(
                    controller: _controller.nameController,
                    label: 'Full Name',
                    labelBn: 'পূর্ণ নাম',
                    hint: 'আপনার পূর্ণ নাম দিন',
                    roleColor: AuthConstants.buyerPrimary,
                    validator: _controller.validateName,
                    prefixIcon: '👤',
                  ),
                  AuthTextField(
                    controller: _controller.phoneController,
                    label: 'Phone Number',
                    labelBn: 'মোবাইল নম্বর',
                    hint: '01xxxxxxxxx',
                    keyboardType: TextInputType.phone,
                    roleColor: AuthConstants.buyerPrimary,
                    validator: _controller.validatePhone,
                    prefixIcon: '📱',
                  ),
                  AuthTextField(
                    controller: _controller.emailController,
                    label: 'Email',
                    labelBn: 'ইমেইল',
                    hint: 'example@email.com',
                    keyboardType: TextInputType.emailAddress,
                    roleColor: AuthConstants.buyerPrimary,
                    validator: _controller.validateEmail,
                    prefixIcon: '✉️',
                  ),
                  // Buyer-specific: Address
                  AuthTextField(
                    controller: _controller.addressController,
                    label: 'Delivery Address',
                    labelBn: 'ডেলিভারির ঠিকানা',
                    hint: 'সম্পূর্ণ ঠিকানা লিখুন',
                    roleColor: AuthConstants.buyerPrimary,
                    maxLines: 2,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'ঠিকানা প্রয়োজন' : null,
                    prefixIcon: '📍',
                  ),
                  AuthTextField(
                    controller: _controller.passwordController,
                    label: 'Password',
                    labelBn: 'পাসওয়ার্ড',
                    hint: 'শক্তিশালী পাসওয়ার্ড দিন',
                    isPassword: true,
                    roleColor: AuthConstants.buyerPrimary,
                    validator: _controller.validatePassword,
                    prefixIcon: '🔒',
                  ),
                  AuthTextField(
                    controller: _controller.confirmPasswordController,
                    label: 'Confirm Password',
                    labelBn: 'পাসওয়ার্ড নিশ্চিত করুন',
                    hint: 'পাসওয়ার্ড আবার দিন',
                    isPassword: true,
                    roleColor: AuthConstants.buyerPrimary,
                    validator: (value) =>
                        _controller.validateConfirmPassword(value),
                    prefixIcon: '✅',
                  ),
                  const SizedBox(height: 32),
                  Obx(() => AuthButton(
                        label: 'Register',
                        labelBn: 'নিবন্ধন করুন',
                        onPressed: () => _handleRegister(),
                        roleColor: AuthConstants.buyerPrimary,
                        isLoading: _controller.isLoading.value,
                      )),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('ইতিমধ্যে অ্যাকাউন্ট আছে?',
                          style: TextStyle(
                              color: AuthConstants.textLight, fontSize: 14)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Get.off(() => const BuyerLoginScreen(),
                            transition: Transition.leftToRight),
                        child: const Text('লগইন করুন',
                            style: TextStyle(
                                color: AuthConstants.buyerPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
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
      final success = await _controller.buyerRegister(
        email: _controller.emailController.text.trim(),
        password: _controller.passwordController.text,
        name: _controller.nameController.text.trim(),
        phone: _controller.phoneController.text.trim(),
        address: _controller.addressController.text.trim(),
      );
      if (success && mounted) {
        Get.snackbar('রেজিস্ট্রেশন সফল ✅', 'আপনার অ্যাকাউন্ট তৈরি হয়েছে',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade900);
        Get.off(() => const BuyerLoginScreen());
      }
    } catch (e) {
      Get.snackbar('রেজিস্ট্রেশন ব্যর্থ ❌', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900);
    }
  }
}
