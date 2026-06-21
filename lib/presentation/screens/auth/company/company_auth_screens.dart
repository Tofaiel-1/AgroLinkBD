import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/models/user_model.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import '../shared/auth_constants.dart';
import '../shared/auth_text_field.dart';
import '../shared/auth_button.dart';
import '../shared/auth_header.dart';
import 'company_auth_controller.dart';

/// Company Login Screen
class CompanyLoginScreen extends StatefulWidget {
  const CompanyLoginScreen({super.key});

  @override
  State<CompanyLoginScreen> createState() => _CompanyLoginScreenState();
}

class _CompanyLoginScreenState extends State<CompanyLoginScreen> {
  final CompanyAuthController _controller = CompanyAuthController();
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
                    roleKey: 'company',
                    title: 'কোম্পানি লগইন',
                    subtitle: 'আপনার কোম্পানির অ্যাকাউন্টে প্রবেশ করুন',
                  ),
                  const SizedBox(height: 40),
                  AuthTextField(
                    controller: _controller.emailController,
                    label: 'Email',
                    labelBn: 'ইমেইল',
                    hint: 'company@email.com',
                    keyboardType: TextInputType.emailAddress,
                    roleColor: AuthConstants.companyPrimary,
                    validator: _controller.validateEmail,
                    prefixIcon: '✉️',
                  ),
                  AuthTextField(
                    controller: _controller.passwordController,
                    label: 'Password',
                    labelBn: 'পাসওয়ার্ড',
                    hint: 'আপনার পাসওয়ার্ড দিন',
                    isPassword: true,
                    roleColor: AuthConstants.companyPrimary,
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
                          color: AuthConstants.companyPrimary,
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
                        roleColor: AuthConstants.companyPrimary,
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
                        onTap: () => Get.off(
                            () => const CompanyRegisterScreen(),
                            transition: Transition.rightToLeft),
                        child: const Text('এখন নিবন্ধন করুন',
                            style: TextStyle(
                                color: AuthConstants.companyPrimary,
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
      final success = await _controller.companyLogin(
        email: _controller.emailController.text.trim(),
        password: _controller.passwordController.text,
      );
      if (success && mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        if (_controller.authService.currentUser != null) {
          await userProvider.loadUser(_controller.authService.currentUser!.uid);
        }
        Get.offAllNamed('/company/dashboard');
      }
    } catch (e) {
      Get.snackbar('লগইন ব্যর্থ ❌', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900);
    }
  }
}

/// Company Register Screen
class CompanyRegisterScreen extends StatefulWidget {
  const CompanyRegisterScreen({super.key});

  @override
  State<CompanyRegisterScreen> createState() => _CompanyRegisterScreenState();
}

class _CompanyRegisterScreenState extends State<CompanyRegisterScreen> {
  final CompanyAuthController _controller = CompanyAuthController();
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
                    roleKey: 'company',
                    title: 'কোম্পানি রেজিস্ট্রেশন',
                    subtitle: 'নতুন অ্যাকাউন্ট তৈরি করুন এবং শুরু করুন',
                    isRegister: true,
                  ),
                  const SizedBox(height: 40),
                  AuthTextField(
                    controller: _controller.companyNameController,
                    label: 'Company Name',
                    labelBn: 'কোম্পানির নাম',
                    hint: 'আপনার কোম্পানির নাম দিন',
                    roleColor: AuthConstants.companyPrimary,
                    validator: _controller.validateName,
                    prefixIcon: '🏢',
                  ),
                  AuthTextField(
                    controller: _controller.contactPersonController,
                    label: 'Contact Person',
                    labelBn: 'যোগাযোগকারী ব্যক্তি',
                    hint: 'নাম লিখুন',
                    roleColor: AuthConstants.companyPrimary,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'নাম প্রয়োজন' : null,
                    prefixIcon: '👤',
                  ),
                  AuthTextField(
                    controller: _controller.phoneController,
                    label: 'Phone Number',
                    labelBn: 'মোবাইল নম্বর',
                    hint: '01xxxxxxxxx',
                    keyboardType: TextInputType.phone,
                    roleColor: AuthConstants.companyPrimary,
                    validator: _controller.validatePhone,
                    prefixIcon: '📱',
                  ),
                  AuthTextField(
                    controller: _controller.emailController,
                    label: 'Email',
                    labelBn: 'ইমেইল',
                    hint: 'company@email.com',
                    keyboardType: TextInputType.emailAddress,
                    roleColor: AuthConstants.companyPrimary,
                    validator: _controller.validateEmail,
                    prefixIcon: '✉️',
                  ),
                  // Company-specific: Registration number
                  AuthTextField(
                    controller: _controller.registrationNumberController,
                    label: 'Registration Number',
                    labelBn: 'রেজিস্ট্রেশন নম্বর',
                    hint: 'কোম্পানির রেজিস্ট্রেশন নম্বর',
                    roleColor: AuthConstants.companyPrimary,
                    validator: (value) => value?.isEmpty ?? true
                        ? 'রেজিস্ট্রেশন নম্বর প্রয়োজন'
                        : null,
                    prefixIcon: '📜',
                  ),
                  // Company-specific: Company size
                  AuthTextField(
                    controller: _controller.companySizeController,
                    label: 'Company Size (Employees)',
                    labelBn: 'কোম্পানির আকার (কর্মচারী)',
                    hint: 'উদাহরণ: 50',
                    keyboardType: TextInputType.number,
                    roleColor: AuthConstants.companyPrimary,
                    prefixIcon: '👥',
                  ),
                  AuthTextField(
                    controller: _controller.passwordController,
                    label: 'Password',
                    labelBn: 'পাসওয়ার্ড',
                    hint: 'শক্তিশালী পাসওয়ার্ড দিন',
                    isPassword: true,
                    roleColor: AuthConstants.companyPrimary,
                    validator: _controller.validatePassword,
                    prefixIcon: '🔒',
                  ),
                  AuthTextField(
                    controller: _controller.confirmPasswordController,
                    label: 'Confirm Password',
                    labelBn: 'পাসওয়ার্ড নিশ্চিত করুন',
                    hint: 'পাসওয়ার্ড আবার দিন',
                    isPassword: true,
                    roleColor: AuthConstants.companyPrimary,
                    validator: (value) =>
                        _controller.validateConfirmPassword(value),
                    prefixIcon: '✅',
                  ),
                  const SizedBox(height: 32),
                  Obx(() => AuthButton(
                        label: 'Register',
                        labelBn: 'নিবন্ধন করুন',
                        onPressed: () => _handleRegister(),
                        roleColor: AuthConstants.companyPrimary,
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
                        onTap: () => Get.off(() => const CompanyLoginScreen(),
                            transition: Transition.leftToRight),
                        child: const Text('লগইন করুন',
                            style: TextStyle(
                                color: AuthConstants.companyPrimary,
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
      final success = await _controller.companyRegister(
        email: _controller.emailController.text.trim(),
        password: _controller.passwordController.text,
        companyName: _controller.companyNameController.text.trim(),
        contactPerson: _controller.contactPersonController.text.trim(),
        phone: _controller.phoneController.text.trim(),
        registrationNumber:
            _controller.registrationNumberController.text.trim(),
        companySize: _controller.companySizeController.text,
      );
      if (success && mounted) {
        Get.snackbar('রেজিস্ট্রেশন সফল ✅', 'আপনার অ্যাকাউন্ট তৈরি হয়েছে',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade900);
        Get.off(() => const CompanyLoginScreen());
      }
    } catch (e) {
      Get.snackbar('রেজিস্ট্রেশন ব্যর্থ ❌', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900);
    }
  }
}
