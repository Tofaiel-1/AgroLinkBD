import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/providers/admin_provider.dart';
import 'package:agrolinkbd/core/services/auth_service.dart';
import 'package:agrolinkbd/core/controllers/user_controller.dart';
import 'package:agrolinkbd/core/models/user_model.dart';
import 'package:agrolinkbd/presentation/screens/auth/register_screen.dart';
import 'package:agrolinkbd/presentation/screens/app_router.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _otpSent = false;
  String? _verificationId;
  bool _useEmailLogin =
      true; // Default to email login since phone API not integrated
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Navigation is handled by AppRouter via authStateChanges stream
  // No manual navigation needed after login

  Future<void> _forgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Email Required',
        'Enter your email to reset password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
        icon: const Icon(Icons.warning, color: Colors.orange),
      );
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(_emailController.text.trim());
      Get.snackbar(
        'Email Sent ✅',
        'Check your email and click the password reset link',
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        icon: const Icon(Icons.check_circle, color: Colors.green),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Error ❌',
        e.toString(),
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        icon: const Icon(Icons.error, color: Colors.red),
      );
    }
  }

  Future<void> _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text;

      // Sign in with Firebase Auth
      await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      String userId = _authService.currentUser!.uid;

      // CHECK IF THIS IS AN ADMIN ACCOUNT (read-only check, no re-sign-in)
      try {
        final adminProvider = Provider.of<AdminProvider>(context, listen: false);
        final adminDoc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(userId)
            .get();

        if (adminDoc.exists) {
          // This is an admin - set admin data and navigate
          adminProvider.setAdminFromDoc(adminDoc);

          if (mounted) setState(() => _isLoading = false);

          Get.snackbar(
            'Admin Login Successful ✅',
            'Welcome ${adminProvider.currentAdmin?.name}',
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade900,
            icon: const Icon(Icons.check_circle, color: Colors.green),
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
          // Clear navigation stack and let AppRouter handle admin navigation
          Get.offAll(() => const AppRouter());
          return;
        }
      } catch (adminCheckError) {
        // Not an admin or permission denied - continue as regular user
        debugPrint('ℹ️ Not an admin account (expected for regular users)');
      }

      // Not an admin - check for regular user profile
      final userController = Get.put(UserController());
      final userData = await _authService.getUserData(userId);

      if (userData != null) {
        // User profile exists - proceed with login
        UserRole userRole;
        switch (userData.userType) {
          case UserType.farmer:
            userRole = UserRole.farmer;
            break;
          case UserType.buyer:
            userRole = UserRole.buyer;
            break;
          case UserType.serviceProvider:
          case UserType.company:
            userRole = UserRole.expert;
            break;
          default:
            userRole = UserRole.farmer;
        }

        // Set user data in controller
        userController.setUserData(
          id: userId,
          name: userData.name,
          phone: userData.phone,
          location: userData.district ?? '',
          role: userRole,
        );

        // Load user in provider
        await Provider.of<UserProvider>(
          context,
          listen: false,
        ).loadUser(userId);

        // Update last login
        await _authService.updateLastLogin(userId);

        // Show success message
        Get.snackbar(
          'Login Successful ✅',
          'Welcome ${userData.name}',
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          icon: const Icon(Icons.check_circle, color: Colors.green),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );

        if (mounted) setState(() => _isLoading = false);
        // Clear navigation stack and let AppRouter handle role-based navigation
        Get.offAll(() => const AppRouter());
      } else {
        // User authenticated but no profile - redirect to registration
        await _authService.signOut();

        if (mounted) setState(() => _isLoading = false);

        Get.snackbar(
          'প্রোফাইল সম্পূর্ণ করুন',
          'আপনার অ্যাকাউন্ট আছে কিন্তু প্রোফাইল নেই। অনুগ্রহ করে নিবন্ধন সম্পূর্ণ করুন।',
          duration: const Duration(seconds: 4),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade900,
          icon: const Icon(Icons.warning, color: Colors.orange),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );

        // Navigate to registration with email
        Get.off(
          () => RegisterScreen(
            userId: userId,
            phone: _emailController.text.split('@')[0],
          ),
        );
      }
    } catch (e) {
      String errorMsg = e.toString();
      String bengaliErrorMsg = errorMsg;

      // Clean error message
      if (errorMsg.contains('Exception:')) {
        errorMsg = errorMsg.split('Exception:').last.trim();
      }

      // Check for permission errors
      bool isPermissionError = errorMsg.toLowerCase().contains('permission') ||
          errorMsg.toLowerCase().contains('permission denied') ||
          errorMsg.toLowerCase().contains('you do not have permission');

      if (isPermissionError) {
        bengaliErrorMsg =
            'অনুমতি ত্রুটি: এই ডেটা অ্যাক্সেস করার অনুমতি আপনার নেই।';

        // Auto logout on permission error
        await _authService.signOut();

        if (mounted) {
          setState(() => _isLoading = false);
        }

        // Show error and redirect to login after 2 seconds
        Get.snackbar(
          'লগইন ব্যর্থ ❌',
          bengaliErrorMsg,
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          icon: const Icon(Icons.error, color: Colors.red),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Get.offAll(() => const LoginScreen());
          }
        });

        return;
      }

      Get.snackbar(
        'লগইন ব্যর্থ ❌',
        errorMsg,
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        icon: const Icon(Icons.error, color: Colors.red),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String phone = '+88${_phoneController.text}';

    await _authService.signInWithPhone(
      phoneNumber: phone,
      codeSent: (verificationId) {
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
            _otpSent = true;
            _isLoading = false;
          });
        }
        Get.snackbar('Success', 'OTP sent to your phone');
      },
      verificationFailed: (error) {
        if (mounted) setState(() => _isLoading = false);
        Get.snackbar('Error', error);
      },
    );
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      Get.snackbar('Error', 'Please enter valid 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.verifyOTP(
        verificationId: _verificationId!,
        otp: _otpController.text,
      );

      String userId = _authService.currentUser!.uid;

      // Check if user exists
      bool exists = await _authService.userExists(userId);

      if (exists) {
        // Load user data
        await Provider.of<UserProvider>(
          context,
          listen: false,
        ).loadUser(userId);

        // Update last login
        await _authService.updateLastLogin(userId);

        // AppRouter will auto-navigate via authStateChanges stream
      } else {
        // New user - go to registration
        Get.off(
          () => RegisterScreen(userId: userId, phone: _phoneController.text),
        );
      }
    } catch (e) {
      String errorMsg = e.toString();
      String bengaliErrorMsg = 'Invalid OTP. Please try again.';

      // Check for permission errors
      bool isPermissionError = errorMsg.toLowerCase().contains('permission') ||
          errorMsg.toLowerCase().contains('permission denied') ||
          errorMsg.toLowerCase().contains('you do not have permission');

      if (isPermissionError) {
        bengaliErrorMsg =
            'অনুমতি ত্রুটি: এই ডেটা অ্যাক্সেস করার অনুমতি আপনার নেই।';

        // Auto logout on permission error
        await _authService.signOut();

        if (mounted) {
          setState(() => _isLoading = false);
        }

        // Show error and redirect to login
        Get.snackbar(
          'লগইন ব্যর্থ ❌',
          bengaliErrorMsg,
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          icon: const Icon(Icons.error, color: Colors.red),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Get.offAll(() => const LoginScreen());
          }
        });

        return;
      }

      Get.snackbar(
        'Error',
        bengaliErrorMsg,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        icon: const Icon(Icons.error, color: Colors.red),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final bgGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E1E2C), Color(0xFF12121A)],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade50, Colors.white],
          );

    final cardColor = isDark ? const Color(0xFF2A2A3C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: isDark ? const Color(0xFF1E1E2C) : Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: primaryColor,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.4 : 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryColor, primaryColor.withOpacity(0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.agriculture,
                            size: 44,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      Text(
                        _useEmailLogin
                            ? 'Sign in to continue to AgroLinkBD'
                            : 'Enter your mobile number to sign in',
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Email/Phone Toggle
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E2C) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _useEmailLogin = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _useEmailLogin ? cardColor : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: _useEmailLogin
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 10,
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    'Email',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: _useEmailLogin ? FontWeight.bold : FontWeight.normal,
                                      color: _useEmailLogin ? textColor : subTextColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _useEmailLogin = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !_useEmailLogin ? cardColor : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: !_useEmailLogin
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 10,
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    'Mobile',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: !_useEmailLogin ? FontWeight.bold : FontWeight.normal,
                                      color: !_useEmailLogin ? textColor : subTextColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Email Login Form
                      if (_useEmailLogin) ...[
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: textColor),
                          decoration: inputDecoration.copyWith(
                            labelText: 'Email',
                            hintText: 'example@email.com',
                            prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter email';
                            }
                            if (!value.contains('@')) {
                              return 'Enter valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: TextStyle(color: textColor),
                          decoration: inputDecoration.copyWith(
                            labelText: 'Password',
                            hintText: '••••••••',
                            prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'পাসওয়ার্ড লিখুন';
                            }
                            if (value.length < 6) {
                              return 'পাসওয়ার্ড কমপক্ষে ৬ সংখ্যার হতে হবে';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _forgotPassword,
                            style: TextButton.styleFrom(
                              foregroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: const Text(
                              'পাসওয়ার্ড ভুলে গেছেন?',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildPrimaryButton(
                          onPressed: _isLoading ? null : _loginWithEmail,
                          text: 'লগইন করুন',
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('নতুন ইউজার? ', style: TextStyle(color: subTextColor)),
                            TextButton(
                              onPressed: () {
                                Get.to(() => const RegisterScreen(
                                      userId: '',
                                      phone: '',
                                    ));
                              },
                              child: const Text(
                                'রেজিস্টার করুন',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Phone input
                      if (!_useEmailLogin && !_otpSent) ...[
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(color: textColor),
                          decoration: inputDecoration.copyWith(
                            labelText: 'মোবাইল নম্বর',
                            hintText: '01XXXXXXXXX',
                            prefixText: '+88 ',
                            prefixStyle: TextStyle(color: textColor, fontSize: 16),
                            prefixIcon: Icon(Icons.phone_outlined, color: primaryColor),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'মোবাইল নম্বর লিখুন';
                            }
                            if (value.length != 11) {
                              return '১১ ডিজিটের মোবাইল নম্বর লিখুন';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        _buildPrimaryButton(
                          onPressed: _isLoading ? null : _sendOTP,
                          text: 'OTP পাঠান',
                          isLoading: _isLoading,
                        ),
                      ],

                      // OTP input
                      if (!_useEmailLogin && _otpSent) ...[
                        TextFormField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          style: TextStyle(color: textColor, letterSpacing: 8, fontSize: 18),
                          textAlign: TextAlign.center,
                          decoration: inputDecoration.copyWith(
                            labelText: 'OTP',
                            hintText: '------',
                            prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                            counterText: '',
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildPrimaryButton(
                          onPressed: _isLoading ? null : _verifyOTP,
                          text: 'যাচাই করুন',
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _otpSent = false;
                              _otpController.clear();
                            });
                          },
                          child: const Text('নম্বর পরিবর্তন করুন'),
                        ),
                      ],

                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 24),

                      // Features showcase
                      _buildFeatureCard(
                        icon: Icons.storefront_outlined,
                        title: 'বাজার',
                        description: 'সরাসরি কৃষক থেকে পণ্য কিনুন',
                        isDark: isDark,
                        primaryColor: primaryColor,
                        cardColor: cardColor,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureCard(
                        icon: Icons.agriculture_outlined,
                        title: 'যন্ত্রপাতি ভাড়া',
                        description: 'ট্রাক্টর, হারভেস্টার সহজে ভাড়া করুন',
                        isDark: isDark,
                        primaryColor: primaryColor,
                        cardColor: cardColor,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureCard(
                        icon: Icons.local_shipping_outlined,
                        title: 'পরিবহন সেবা',
                        description: 'ফসল বাজারে পৌঁছে দিন সহজে',
                        isDark: isDark,
                        primaryColor: primaryColor,
                        cardColor: cardColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback? onPressed,
    required String text,
    required bool isLoading,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: primaryColor.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
    required Color primaryColor,
    required Color cardColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
