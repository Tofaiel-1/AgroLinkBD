import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/models/user_model.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/controllers/user_controller.dart';
import 'package:agrolinkbd/core/services/auth_service.dart';
import 'package:agrolinkbd/presentation/screens/auth/login_screen.dart';
import 'package:agrolinkbd/core/constants/bd_location_data.dart';
import 'package:agrolinkbd/presentation/widgets/searchable_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';

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
  String? _selectedUnion;
  bool _isLoading = false;

  List<String> get _districts {
    if (_selectedDivision == null) return [];
    return BDLocationData.districtsByDivision[_selectedDivision] ?? [];
  }

  List<String> get _upazilas {
    if (_selectedDistrict == null) return [];
    return BDLocationData.upazilasByDistrict[_selectedDistrict] ?? [];
  }

  List<String> get _unions {
    if (_selectedUpazila == null) return [];
    return BDLocationData.getUnions(_selectedUpazila);
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

  @override
  void initState() {
    super.initState();
    
    // Check if role was passed via arguments or saved preferences
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String? role = Get.arguments?['role'] as String?;
      if (role == null) {
        final prefs = await SharedPreferences.getInstance();
        role = prefs.getString('selected_role');
      }

      if (role != null) {
        setState(() {
          final clean = role!.replaceAll('UserType.', '').replaceAll('_', '').toLowerCase();
          switch (clean) {
            case 'farmer': _selectedUserType = UserType.farmer; break;
            case 'buyer': _selectedUserType = UserType.buyer; break;
            case 'driver': _selectedUserType = UserType.driver; break;
            case 'serviceprovider': _selectedUserType = UserType.serviceProvider; break;
            case 'company': _selectedUserType = UserType.company; break;
            // Fisheries
            case 'fishfarmer': _selectedUserType = UserType.fishFarmer; break;
            case 'fishbuyer': _selectedUserType = UserType.fishBuyer; break;
            case 'fishdriver': _selectedUserType = UserType.fishDriver; break;
            case 'fishserviceprovider': _selectedUserType = UserType.fishServiceProvider; break;
            case 'fishcompany': _selectedUserType = UserType.fishCompany; break;
            case 'fishexpert': _selectedUserType = UserType.fishExpert; break;
            case 'hatchery': _selectedUserType = UserType.hatchery; break;
            case 'expert': _selectedUserType = UserType.expert; break;
          }
        });
      }
    });
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

      String userId = widget.userId;

      if (userId.isEmpty) {
        // Legacy Email Registration
        final credential = await _authService.registerWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          phone: _phoneController.text.isEmpty ? null : '+880${_phoneController.text.trim()}',
          userType: _selectedUserType.toString(),
        );
        userId = credential.user!.uid;
        debugPrint('✅ Firebase Auth user created: $userId');

        // Send verification email
        try {
          await credential.user!.sendEmailVerification();
          debugPrint('✅ Verification email sent');
        } catch (e) {
          debugPrint('⚠️ Verification email error: $e');
        }
      } else {
        debugPrint('✅ Using existing Phone Auth user ID: $userId');
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
        case UserType.driver:
          userRole = UserRole.driver;
          break;
        case UserType.serviceProvider:
          userRole = UserRole.serviceProvider;
          break;
        case UserType.company:
          userRole = UserRole.company;
          break;
        case UserType.seller:
          userRole = UserRole.seller;
          break;
        case UserType.expert:
          userRole = UserRole.expert;
          break;
        case UserType.fishFarmer:
          userRole = UserRole.fishFarmer;
          break;
        case UserType.fishBuyer:
          userRole = UserRole.fishBuyer;
          break;
        case UserType.fishDriver:
          userRole = UserRole.fishDriver;
          break;
        case UserType.fishServiceProvider:
          userRole = UserRole.fishServiceProvider;
          break;
        case UserType.fishCompany:
          userRole = UserRole.fishCompany;
          break;
        case UserType.fishExpert:
          userRole = UserRole.fishExpert;
          break;
        case UserType.hatchery:
          userRole = UserRole.hatchery;
          break;
      }

      // Create user profile in Firestore
      
      String finalAddress = _addressController.text;
      String villageName = _addressController.text;
      
      // Build a full address string for backward compatibility
      List<String> addressParts = [];
      if (villageName.isNotEmpty) addressParts.add(villageName);
      if (_selectedUnion != null && _selectedUnion!.isNotEmpty) addressParts.add(_selectedUnion!);
      if (_selectedUpazila != null && _selectedUpazila!.isNotEmpty) addressParts.add(_selectedUpazila!);
      
      if (addressParts.isNotEmpty) {
        finalAddress = addressParts.join(', ');
      }

      // Get domain from arguments or infer from role
      String userDomain = 'agriculture';
      if (_selectedUserType.toString().toLowerCase().contains('fish') || 
          _selectedUserType == UserType.hatchery) {
        userDomain = 'fisheries';
      }

      UserModel user = UserModel(
        id: userId,
        name: _nameController.text,
        phone: widget.phone.isNotEmpty 
            ? (widget.phone.startsWith('+880') ? widget.phone : '+880${widget.phone.replaceFirst(RegExp(r'^\+?880?'), '')}') 
            : (_phoneController.text.isEmpty ? '' : '+880${_phoneController.text}'),
        email: widget.userId.isNotEmpty ? null : _emailController.text.trim(),
        userType: _selectedUserType,
        status: UserStatus.active,
        address: finalAddress, // Legacy formatted full address
        district: _selectedDistrict,
        upazila: _selectedUpazila,
        unionName: _selectedUnion,
        village: villageName,
        createdAt: DateTime.now(),
        domain: userDomain,
      );

      debugPrint('📝 Creating user profile in Firestore...');
      debugPrint(
          '   Fields to save: id, name, email, phone, userType, domain, address, district, status, createdAt');

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

      // Save preferences to preserve role across sessions
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('selected_domain', userDomain);
        await prefs.setString('selected_role', _selectedUserType.name);
      } catch (_) {}

      // Load user in provider
      debugPrint('📝 Loading user in provider...');
      await userProvider.loadUser(userId);
      debugPrint('✅ User loaded in provider');

      if (widget.userId.isEmpty) {
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
      } else {
        Get.snackbar(
          'প্রোফাইল তৈরি সফল! ✅',
          'আপনার অ্যাকাউন্ট সফলভাবে তৈরি হয়েছে।',
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          icon: const Icon(Icons.check_circle, color: Colors.green),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }

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
    final bool isBn = LanguageProvider.isBn(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    final bgGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF12121A), Color(0xFF1E1E2C)],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade50, Colors.white],
          );

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: isDark ? const Color(0xFF2A2A3C) : Colors.grey.shade100,
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
        title: Text(isBn ? 'নিবন্ধন' : 'Register', style: const TextStyle(fontWeight: FontWeight.bold)),
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
          // Language Switcher (বাংলা / ENG)
          Consumer<LanguageProvider>(
            builder: (context, langProvider, _) {
              final isBangla = langProvider.isBangla;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white12 : Colors.black.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => langProvider.toggleLanguage(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.language,
                          size: 18,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isBangla ? 'বাংলা' : 'English',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {
              Get.changeThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650),
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
                          isBn ? 'নতুন অ্যাকাউন্ট তৈরি করুন' : 'Create Account',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isBn ? 'নিচের তথ্যগুলো পূরণ করে শুরু করুন' : 'Enter your details below to get started',
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
                            labelText: isBn ? 'পূর্ণ নাম *' : 'Full Name *',
                            hintText: isBn ? 'আপনার নাম লিখুন' : 'Enter your name',
                            prefixIcon: Icon(Icons.person_outline, color: primaryColor),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return isBn ? 'আপনার নাম লিখুন' : 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        if (widget.userId.isEmpty) ...[
                          // Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: textColor),
                            decoration: inputDecoration.copyWith(
                              labelText: isBn ? 'ইমেইল *' : 'Email Address *',
                              hintText: 'user@example.com',
                              prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return isBn ? 'ইমেইল দিন' : 'Please enter email';
                              }
                              if (!value.contains('@')) {
                                return isBn ? 'সঠিক ইমেইল দিন' : 'Please enter valid email';
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
                              labelText: isBn ? 'পাসওয়ার্ড *' : 'Password *',
                              hintText: isBn ? 'কমপক্ষে ৬ ডিজিট দিন' : 'At least 6 characters',
                              prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return isBn ? 'পাসওয়ার্ড লিখুন' : 'Please enter password';
                              }
                              if (value.length < 6) {
                                return isBn ? 'পাসওয়ার্ড কমপক্ষে ৬ সংখ্যার হতে হবে' : 'Password must be at least 6 characters';
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
                              labelText: isBn ? 'পাসওয়ার্ড নিশ্চিত করুন *' : 'Confirm Password *',
                              prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return isBn ? 'পাসওয়ার্ড নিশ্চিত করুন' : 'Please confirm password';
                              }
                              if (value != _passwordController.text) {
                                return isBn ? 'পাসওয়ার্ড মেলেনি' : 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Phone (Optional for Email flow)
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.text,
                            style: TextStyle(color: textColor),
                            decoration: inputDecoration.copyWith(
                              labelText: isBn ? 'মোবাইল নাম্বার (ঐচ্ছিক)' : 'Mobile Number (Optional)',
                              hintText: '17XXXXXXXX',
                              prefixIcon: Icon(Icons.phone_outlined, color: primaryColor),
                              prefixText: '+880 ',
                              prefixStyle: TextStyle(color: textColor, fontSize: 16),
                            ),
                          ),
                        ] else ...[
                          // Phone (Readonly for Phone Auth flow)
                          TextFormField(
                            initialValue: widget.phone,
                            readOnly: true,
                            style: TextStyle(color: Colors.grey.shade600),
                            decoration: inputDecoration.copyWith(
                              labelText: isBn ? 'মোবাইল নাম্বার (যাচাইকৃত)' : 'Mobile Number (Verified)',
                              prefixIcon: const Icon(Icons.verified_outlined, color: Colors.green),
                              prefixText: '',
                              prefixStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                              filled: true,
                              fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),

                        // User Type (Only show if not pre-selected via arguments)
                        if (Get.arguments?['role'] == null)
                          DropdownButtonFormField<UserType>(
                            value: _selectedUserType,
                            dropdownColor: cardColor,
                            isExpanded: true,
                            style: TextStyle(color: textColor, fontSize: 15),
                            decoration: inputDecoration.copyWith(
                              labelText: isBn ? 'আপনার ভূমিকা নির্বাচন করুন' : 'Who are you? (Role)',
                              prefixIcon: Icon(Icons.person_pin_outlined, color: primaryColor),
                            ),
                            items: [
                              DropdownMenuItem(value: UserType.farmer, child: Text(isBn ? '🌾 কৃষক (Farmer)' : '🌾 Farmer (Agriculture)')),
                              DropdownMenuItem(value: UserType.buyer, child: Text(isBn ? '🛍️ পাইকারি ক্রেতা (Buyer)' : '🛍️ Buyer (Agriculture)')),
                              DropdownMenuItem(value: UserType.driver, child: Text(isBn ? '🚚 পরিবহন চালক (Driver)' : '🚚 Driver (Agriculture)')),
                              DropdownMenuItem(value: UserType.serviceProvider, child: Text(isBn ? '🚜 কৃষি সেবা প্রদানকারী' : '🚜 Service Provider')),
                              DropdownMenuItem(value: UserType.company, child: Text(isBn ? '🏢 কোম্পানি (Company)' : '🏢 Company')),
                              DropdownMenuItem(value: UserType.fishFarmer, child: Text(isBn ? '🐟 মৎস্য চাষী (Fish Farmer)' : '🐟 Fish Farmer')),
                              DropdownMenuItem(value: UserType.fishBuyer, child: Text(isBn ? '🛒 মৎস্য ক্রেতা (Fish Buyer)' : '🛒 Fish Buyer')),
                              DropdownMenuItem(value: UserType.hatchery, child: Text(isBn ? '🔬 হ্যাচারি মালিক' : '🔬 Hatchery Owner')),
                              DropdownMenuItem(value: UserType.fishExpert, child: Text(isBn ? '🩺 মৎস্য বিশেষজ্ঞ' : '🩺 Fisheries Expert')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedUserType = value);
                              }
                            },
                          ),
                        if (Get.arguments?['role'] == null)
                          const SizedBox(height: 24),

                        // Division
                        SearchableDropdown(
                          hint: isBn ? 'বিভাগ নির্বাচন করুন' : 'Select Division',
                          value: _selectedDivision,
                          items: BDLocationData.divisions,
                          icon: Icons.map_outlined,
                          onChanged: (value) {
                            setState(() {
                              _selectedDivision = value;
                              _selectedDistrict = null;
                              _selectedUpazila = null;
                              _selectedUnion = null;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // District
                        SearchableDropdown(
                          hint: isBn ? 'জেলা নির্বাচন করুন' : 'Select District',
                          value: _selectedDistrict,
                          items: _districts,
                          icon: Icons.location_city_outlined,
                          onChanged: (value) {
                            setState(() {
                              _selectedDistrict = value;
                              _selectedUpazila = null;
                              _selectedUnion = null;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Upazila
                        SearchableDropdown(
                          hint: isBn ? 'উপজেলা নির্বাচন করুন' : 'Select Upazila',
                          value: _selectedUpazila,
                          items: _upazilas,
                          icon: Icons.location_on_outlined,
                          onChanged: (value) {
                            setState(() {
                              _selectedUpazila = value;
                              _selectedUnion = null;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Union
                        SearchableDropdown(
                          hint: isBn ? 'ইউনিয়ন নির্বাচন করুন' : 'Select Union',
                          value: _selectedUnion,
                          items: _unions,
                          icon: Icons.holiday_village_outlined,
                          onChanged: (value) {
                            setState(() => _selectedUnion = value);
                          },
                        ),
                        const SizedBox(height: 20),

                        // Address (Village / Road)
                        TextFormField(
                          controller: _addressController,
                          maxLines: 2,
                          style: TextStyle(color: textColor),
                          decoration: inputDecoration.copyWith(
                            labelText: isBn ? 'গ্রাম / রোড / ঠিকানা' : 'Village / Road / House',
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(bottom: 24.0),
                              child: Icon(Icons.home_outlined, color: primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Register button (Full Width, 52px height)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shadowColor: primaryColor.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.how_to_reg_rounded, size: 20),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          isBn ? 'অ্যাকাউন্ট তৈরি করুন' : 'Create Account',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isBn ? 'ইতিমধ্যে অ্যাকাউন্ট আছে? ' : 'Already have an account? ',
                              style: TextStyle(color: subTextColor),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.offAll(() => const LoginScreen());
                              },
                              child: Text(
                                isBn ? 'লগইন করুন' : 'Sign In',
                                style: const TextStyle(fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
