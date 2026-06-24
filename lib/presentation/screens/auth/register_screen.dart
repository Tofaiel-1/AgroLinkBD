import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/models/user_model.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/controllers/user_controller.dart';
import 'package:agrolinkbd/core/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agrolinkbd/presentation/screens/auth/login_screen.dart';
import 'package:agrolinkbd/core/constants/bd_location_data.dart';
import 'package:agrolinkbd/presentation/widgets/searchable_dropdown.dart';

class RegisterScreen extends StatefulWidget {
  final String userId;
  final String phone;

  const RegisterScreen({super.key, required this.userId, required this.phone});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final AuthService _authService = AuthService();

  UserType _selectedUserType = UserType.farmer;
  String? _selectedDivision;
  String? _selectedDistrict;
  String? _selectedUpazila;
  bool _isLoading = false;

  List<String> get _districts {
    if (_selectedDivision == null) return [];
    return BDLocationData.districtsByDivision[_selectedDivision] ?? [];
  }

  List<String> get _upazilas {
    if (_selectedDistrict == null) return [];
    return BDLocationData.upazilasByDistrict[_selectedDistrict] ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Navigation is handled by AppRouter via authStateChanges stream
  // No manual navigation needed after registration

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      debugPrint('📝 Starting user registration...');
      debugPrint('   Email: ${_emailController.text.trim()}');
      debugPrint('   Name: ${_nameController.text}');
      debugPrint('   Type: ${_selectedUserType.toString()}');

      // Extract provider before await
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Register with Firebase Auth (Email/Password)
      final credential = await _authService.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text.isEmpty ? null : '+88${_phoneController.text.trim()}',
        userType: _selectedUserType.toString(),
      );

      String userId = credential.user!.uid;
      debugPrint('✅ Firebase Auth user created: $userId');

      // Send verification email
      try {
        await credential.user!.sendEmailVerification();
        debugPrint('✅ Verification email sent');
      } catch (e) {
        debugPrint('⚠️ Verification email error: $e');
      }

      // Map UserType to UserRole
      UserRole userRole;
      switch (_selectedUserType) {
        case UserType.farmer:
          userRole = UserRole.farmer;
          break;
        case UserType.buyer:
          userRole = UserRole.buyer;
          break;
        case UserType.serviceProvider:
          userRole = UserRole.expert;
          break;
        default:
          userRole = UserRole.farmer;
      }

      // Create user profile in Firestore
      
      String finalAddress = _addressController.text;
      if (_selectedUpazila != null && _selectedUpazila!.isNotEmpty) {
        if (finalAddress.isNotEmpty) {
          finalAddress = '$finalAddress, $_selectedUpazila';
        } else {
          finalAddress = _selectedUpazila!;
        }
      }

      UserModel user = UserModel(
        id: userId,
        name: _nameController.text,
        phone:
            _phoneController.text.isEmpty ? '' : '+88${_phoneController.text}',
        email: _emailController.text.trim(),
        userType: _selectedUserType,
        status: UserStatus.active,
        address: finalAddress,
        district: _selectedDistrict,
        createdAt: DateTime.now(),
      );

      debugPrint('📝 Creating user profile in Firestore...');
      debugPrint(
          '   Fields to save: id, name, email, phone, userType, address, district, status, createdAt');

      await _authService.createOrUpdateUser(user);
      debugPrint('✅ User profile created: $userId');

      // Verify profile was created by attempting to read it
      debugPrint('📋 Verifying profile was created...');
      final verifyUser = await _authService.getUserData(userId);
      if (verifyUser != null) {
        debugPrint(
            '✅ Profile verification successful - user can read their own profile');
      } else {
        debugPrint(
            '⚠️ Profile verification failed - profile exists but could not be read');
      }

      // Set user role in controller
      final userController = Get.put(UserController());
      userController.setUserRole(userRole);
      userController.setUserData(
        id: userId,
        name: user.name,
        phone: user.phone,
        location: user.district ?? '',
        role: userRole,
      );
      debugPrint('✅ User role and data set in controller');

      // Load user in provider
      debugPrint('📝 Loading user in provider...');
      await userProvider.loadUser(userId);
      debugPrint('✅ User loaded in provider');

      Get.snackbar(
        'Registration Success! ✅',
        'A verification link has been sent to ${_emailController.text}. Please verify your email and login.',
        duration: const Duration(seconds: 6),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        icon: const Icon(Icons.check_circle, color: Colors.green),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );

      debugPrint(
          '🎉 Registration completed successfully - navigating to dashboard');
      // AppRouter will auto-navigate via authStateChanges stream
    } catch (e) {
      String errorMessage = e.toString();
      debugPrint('❌ Registration error: $errorMessage');

      // Clean error message
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.split('Exception:').last.trim();
      }

      // Check if email is already in use
      if (errorMessage.contains('email-already-in-use') ||
          errorMessage.contains('The email address is already in use')) {
        _showEmailExistsDialog();
      }
      // Check for network errors
      else if (errorMessage.contains('Connection reset') ||
          errorMessage.contains('network') ||
          errorMessage.contains('socket') ||
          errorMessage.contains('timeout')) {
        _showNetworkErrorDialog();
      }
      // Check for permission errors during profile creation
      else if (errorMessage.contains('permission') ||
          errorMessage.contains('Permission')) {
        Get.snackbar(
          'Profile Creation Error ❌',
          'Could not save your profile. This may be a security rule issue. Please contact support.',
          duration: const Duration(seconds: 6),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          icon: const Icon(Icons.error, color: Colors.red),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      } else {
        Get.snackbar(
          'Registration Failed ❌',
          errorMessage,
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          icon: const Icon(Icons.error, color: Colors.red),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showEmailExistsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email Already Registered'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This email address is already registered with us.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              'Would you like to:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(
                '• Log in with this email',
                style: TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(
                '• Try registering with a different email',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Try Different Email'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.off(() => const LoginScreen());
            },
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  void _showNetworkErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Network Connection Error'),
        content: const Text(
          'Unable to connect to the registration server. Please check your internet connection and try again.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Retry registration with same data
              _register();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
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
      labelStyle: TextStyle(color: subTextColor),
      hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Register', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {
              Get.changeThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
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
                      Text(
                        'Create Account',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your details below to get started',
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Name
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: textColor),
                        decoration: inputDecoration.copyWith(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline, color: primaryColor),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: textColor),
                        decoration: inputDecoration.copyWith(
                          labelText: 'Email *',
                          prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: TextStyle(color: textColor),
                        decoration: inputDecoration.copyWith(
                          labelText: 'Password *',
                          prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Confirm Password
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        style: TextStyle(color: textColor),
                        decoration: inputDecoration.copyWith(
                          labelText: 'Confirm Password *',
                          prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Phone (Optional)
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: textColor),
                        decoration: inputDecoration.copyWith(
                          labelText: 'Mobile Number (Optional)',
                          hintText: '01XXXXXXXXX',
                          prefixIcon: Icon(Icons.phone_outlined, color: primaryColor),
                          prefixText: '+88 ',
                          prefixStyle: TextStyle(color: textColor, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // User Type
                      DropdownButtonFormField<UserType>(
                        value: _selectedUserType,
                        dropdownColor: cardColor,
                        style: TextStyle(color: textColor, fontSize: 16),
                        decoration: inputDecoration.copyWith(
                          labelText: 'Who are you?',
                          prefixIcon: Icon(Icons.person_pin_outlined, color: primaryColor),
                        ),
                        items: const [
                          DropdownMenuItem(value: UserType.farmer, child: Text('Farmer')),
                          DropdownMenuItem(value: UserType.buyer, child: Text('Buyer')),
                          DropdownMenuItem(value: UserType.driver, child: Text('Driver')),
                          DropdownMenuItem(value: UserType.serviceProvider, child: Text('Service Provider')),
                          DropdownMenuItem(value: UserType.company, child: Text('Company')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedUserType = value);
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      // Division
                      SearchableDropdown(
                        hint: 'Select Division',
                        value: _selectedDivision,
                        items: BDLocationData.divisions,
                        icon: Icons.map_outlined,
                        onChanged: (value) {
                          setState(() {
                            _selectedDivision = value;
                            _selectedDistrict = null; // Reset dependent fields
                            _selectedUpazila = null;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // District
                      SearchableDropdown(
                        hint: 'Select District',
                        value: _selectedDistrict,
                        items: _districts,
                        icon: Icons.location_city_outlined,
                        onChanged: (value) {
                          setState(() {
                            _selectedDistrict = value;
                            _selectedUpazila = null; // Reset dependent field
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Upazila
                      SearchableDropdown(
                        hint: 'Select Upazila',
                        value: _selectedUpazila,
                        items: _upazilas,
                        icon: Icons.location_on_outlined,
                        onChanged: (value) {
                          setState(() => _selectedUpazila = value);
                        },
                      ),
                      const SizedBox(height: 20),

                      // Address
                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        style: TextStyle(color: textColor),
                        decoration: inputDecoration.copyWith(
                          labelText: 'Address',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Icon(Icons.home_outlined, color: primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Register button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _register,
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
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account? ', style: TextStyle(color: subTextColor)),
                          TextButton(
                            onPressed: () {
                              Get.offAll(() => const LoginScreen());
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(fontWeight: FontWeight.bold),
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
        ),
      ),
    );
  }

}
