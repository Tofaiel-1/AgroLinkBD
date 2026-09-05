import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/providers/admin_provider.dart';
import 'package:agrolinkbd/core/services/auth_service.dart';
import 'package:agrolinkbd/core/controllers/user_controller.dart';
import 'package:agrolinkbd/core/models/user_model.dart';
import 'package:agrolinkbd/presentation/screens/app_router.dart';
import 'package:agrolinkbd/presentation/screens/admin/admin_login_screen.dart';
import 'package:agrolinkbd/core/constants/bd_location_data.dart';
import 'package:agrolinkbd/presentation/widgets/searchable_dropdown.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';

class LoginScreen extends StatefulWidget {
  final String? initialDomain;
  final String? initialRole;

  const LoginScreen({
    super.key,
    this.initialDomain,
    this.initialRole,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Registration controllers (for same-screen role-based register)
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isRegisterMode = false;
  bool _isLoading = false;
  bool _otpSent = false;
  String? _verificationId;
  bool _useEmailLogin = true; // Auto-select email login by default
  bool _obscurePassword = true;

  // Domain & Role Selection
  String _selectedDomain = 'fisheries'; // 'agriculture' or 'fisheries'
  UserType _selectedRole = UserType.fishFarmer;

  // Location for registration
  String? _selectedDivision;
  String? _selectedDistrict;
  String? _selectedUpazila;
  String? _selectedUnion;

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
  void initState() {
    super.initState();
    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDomain = widget.initialDomain ?? prefs.getString('selected_domain') ?? Get.arguments?['domain'];
    final savedRoleStr = widget.initialRole ?? prefs.getString('selected_role') ?? Get.arguments?['role'];

    if (savedDomain != null && (savedDomain == 'fisheries' || savedDomain == 'agriculture')) {
      _selectedDomain = savedDomain;
    }

    if (savedRoleStr != null) {
      final clean = savedRoleStr.replaceAll('UserType.', '').replaceAll('_', '').toLowerCase();
      if (clean == 'fishfarmer' || clean == 'fishfarming' || clean == 'fish_farmer') {
        _selectedDomain = 'fisheries';
        _selectedRole = UserType.fishFarmer;
      } else if (clean == 'fishbuyer' || clean == 'fish_buyer') {
        _selectedDomain = 'fisheries';
        _selectedRole = UserType.fishBuyer;
      } else if (clean == 'fishdriver' || clean == 'fish_driver') {
        _selectedDomain = 'fisheries';
        _selectedRole = UserType.fishDriver;
      } else if (clean == 'fishserviceprovider' || clean == 'fish_service_provider') {
        _selectedDomain = 'fisheries';
        _selectedRole = UserType.fishServiceProvider;
      } else if (clean == 'fishcompany' || clean == 'fish_company') {
        _selectedDomain = 'fisheries';
        _selectedRole = UserType.fishCompany;
      } else if (clean == 'fishexpert' || clean == 'fish_expert') {
        _selectedDomain = 'fisheries';
        _selectedRole = UserType.fishExpert;
      } else if (clean == 'hatchery') {
        _selectedDomain = 'fisheries';
        _selectedRole = UserType.hatchery;
      } else if (clean == 'driver') {
        _selectedDomain = 'agriculture';
        _selectedRole = UserType.driver;
      } else if (clean == 'buyer') {
        _selectedDomain = 'agriculture';
        _selectedRole = UserType.buyer;
      } else if (clean == 'farmer') {
        _selectedDomain = 'agriculture';
        _selectedRole = UserType.farmer;
      } else if (clean == 'serviceprovider' || clean == 'service_provider') {
        _selectedDomain = 'agriculture';
        _selectedRole = UserType.serviceProvider;
      } else if (clean == 'company') {
        _selectedDomain = 'agriculture';
        _selectedRole = UserType.company;
      } else if (clean == 'seller') {
        _selectedDomain = 'agriculture';
        _selectedRole = UserType.seller;
      } else if (clean == 'expert') {
        _selectedDomain = 'agriculture';
        _selectedRole = UserType.expert;
      } else {
        _selectedRole = UserType.values.firstWhere(
          (e) => e.name.toLowerCase() == clean,
          orElse: () => _selectedDomain == 'fisheries' ? UserType.fishFarmer : UserType.farmer,
        );
        _selectedDomain = (_selectedRole.name.toLowerCase().contains('fish') || _selectedRole == UserType.hatchery)
            ? 'fisheries'
            : 'agriculture';
      }
    } else {
      _selectedRole = _selectedDomain == 'fisheries' ? UserType.fishFarmer : UserType.farmer;
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_domain', _selectedDomain);
    await prefs.setString('selected_role', _selectedRole.name);
  }

  void _onDomainChanged(String domain) {
    setState(() {
      _selectedDomain = domain;
      if (domain == 'fisheries') {
        _selectedRole = UserType.fishFarmer;
      } else {
        _selectedRole = UserType.farmer;
      }
    });
    _savePreferences();
  }

  void _onRoleChanged(UserType? role) {
    if (role != null) {
      setState(() {
        _selectedRole = role;
        if (role.name.contains('fish') || role == UserType.hatchery) {
          _selectedDomain = 'fisheries';
        } else {
          _selectedDomain = 'agriculture';
        }
      });
      _savePreferences();
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Color get _primaryColor {
    if (_selectedDomain == 'fisheries') {
      return const Color(0xFF0288D1); // Deep Water Blue
    }
    return const Color(0xFF2E7D32); // Agriculture Green
  }

  Color get _accentColor {
    if (_selectedDomain == 'fisheries') {
      return const Color(0xFF00ACC1); // Aqua
    }
    return const Color(0xFF43A047);
  }

  UserRole _mapUserTypeToUserRole(UserType type) {
    switch (type) {
      case UserType.farmer:
        return UserRole.farmer;
      case UserType.buyer:
        return UserRole.buyer;
      case UserType.driver:
        return UserRole.driver;
      case UserType.serviceProvider:
        return UserRole.serviceProvider;
      case UserType.company:
        return UserRole.company;
      case UserType.seller:
        return UserRole.seller;
      case UserType.expert:
        return UserRole.expert;
      case UserType.fishFarmer:
        return UserRole.fishFarmer;
      case UserType.fishBuyer:
        return UserRole.fishBuyer;
      case UserType.fishDriver:
        return UserRole.fishDriver;
      case UserType.fishServiceProvider:
        return UserRole.fishServiceProvider;
      case UserType.fishCompany:
        return UserRole.fishCompany;
      case UserType.fishExpert:
        return UserRole.fishExpert;
      case UserType.hatchery:
        return UserRole.hatchery;
    }
  }

  UserType _resolveUserType({
    required UserType existingType,
    required String domain,
    required String name,
    required String email,
    required UserType selectedRole,
  }) {
    final cleanName = name.toLowerCase();
    final cleanEmail = email.toLowerCase();
    final isFisheries = domain == 'fisheries' ||
        cleanName.contains('fish') ||
        cleanEmail.contains('fish') ||
        cleanName.contains('মৎস্য') ||
        cleanName.contains('মাছ');

    if (cleanName.contains('driver') || cleanName.contains('চালক') || cleanName.contains('পরিবহন') || cleanEmail.contains('driver')) {
      return isFisheries ? UserType.fishDriver : UserType.driver;
    }
    if (cleanName.contains('service') || cleanEmail.contains('service') || cleanName.contains('সেবা')) {
      return isFisheries ? UserType.fishServiceProvider : UserType.serviceProvider;
    }
    if (cleanName.contains('buyer') || cleanEmail.contains('buyer') || cleanName.contains('ক্রেতা') || cleanName.contains('পাইকারি')) {
      return isFisheries ? UserType.fishBuyer : UserType.buyer;
    }
    if (cleanName.contains('company') || cleanEmail.contains('company') || cleanName.contains('কোম্পানি')) {
      return isFisheries ? UserType.fishCompany : UserType.company;
    }
    if (cleanName.contains('expert') || cleanEmail.contains('expert') || cleanName.contains('বিশেষজ্ঞ')) {
      return isFisheries ? UserType.fishExpert : UserType.expert;
    }
    if (cleanName.contains('hatchery') || cleanEmail.contains('hatchery') || cleanName.contains('হ্যাচারি')) {
      return UserType.hatchery;
    }
    if (cleanName.contains('farmer') || cleanEmail.contains('farmer') || cleanName.contains('খামারি') || cleanName.contains('চাষী')) {
      return isFisheries ? UserType.fishFarmer : UserType.farmer;
    }

    if (selectedRole != UserType.farmer && selectedRole != UserType.fishFarmer && selectedRole != existingType) {
      return selectedRole;
    }

    return existingType;
  }

  Future<void> _forgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      Get.snackbar(
        'ইমেইল প্রয়োজন',
        'পাসওয়ার্ড রিসেট করতে আপনার ইমেইল দিন',
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
        'ইমেইল পাঠানো হয়েছে ✅',
        'আপনার ইমেইল চেক করুন এবং রিসেট লিংকে ক্লিক করুন',
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
        'ত্রুটি ❌',
        e.toString(),
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        icon: const Icon(Icons.error, color: Colors.red),
      );
    }
  }

  // Handle Login with Email
  Future<void> _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text;

      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      String userId = _authService.currentUser!.uid;

      // Admin check
      try {
        final adminDoc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(userId)
            .get();

        if (adminDoc.exists) {
          adminProvider.setAdminFromDoc(adminDoc);
          if (mounted) setState(() => _isLoading = false);
          Get.offAll(() => const AppRouter());
          return;
        } else {
          adminProvider.clearAdminState();
        }
      } catch (_) {
        adminProvider.clearAdminState();
      }

      // Regular user profile check
      final userController = Get.put(UserController());
      UserModel? userData = await _authService.getUserData(userId);

      if (userData != null) {
        UserType effectiveRole = _resolveUserType(
          existingType: userData.userType,
          domain: userData.domain,
          name: userData.name,
          email: userData.email ?? email,
          selectedRole: _selectedRole,
        );
        String effectiveDomain = userData.domain;
        if (effectiveRole == UserType.fishServiceProvider ||
            effectiveRole == UserType.fishDriver ||
            effectiveRole == UserType.fishBuyer ||
            effectiveRole == UserType.fishFarmer ||
            effectiveRole == UserType.fishCompany ||
            effectiveRole == UserType.fishExpert ||
            effectiveRole == UserType.hatchery) {
          effectiveDomain = 'fisheries';
        }

        if (effectiveRole != userData.userType || effectiveDomain != userData.domain) {
          userData = userData.copyWith(userType: effectiveRole, domain: effectiveDomain);
          await _authService.createOrUpdateUser(userData);
        }

        final role = _mapUserTypeToUserRole(userData.userType);
        userController.setUserData(
          id: userId,
          name: userData.name,
          phone: userData.phone,
          location: userData.district ?? '',
          role: role,
        );

        // Update preferences to match this authenticated user's role
        _selectedDomain = userData.domain;
        _selectedRole = userData.userType;
        await _savePreferences();

        await userProvider.loadUser(userId);
        await _authService.updateLastLogin(userId);

        Get.snackbar(
          'লগইন সফল ✅',
          'স্বাগতম ${userData.name}',
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );

        if (mounted) setState(() => _isLoading = false);
        Get.offAll(() => const AppRouter());
      } else {
        // User authenticated in Auth, but profile document missing in Firestore
        // Auto-detect role from email or selected role
        UserType initialRole = _resolveUserType(
          existingType: _selectedRole,
          domain: _selectedDomain,
          name: email.split('@').first,
          email: email,
          selectedRole: _selectedRole,
        );
        String initialDomain = _selectedDomain;
        if (initialRole == UserType.fishServiceProvider ||
            initialRole == UserType.fishDriver ||
            initialRole == UserType.fishBuyer ||
            initialRole == UserType.fishFarmer ||
            initialRole == UserType.fishCompany ||
            initialRole == UserType.fishExpert ||
            initialRole == UserType.hatchery) {
          initialDomain = 'fisheries';
        }

        final user = UserModel(
          id: userId,
          name: email.split('@').first,
          phone: _phoneController.text.isNotEmpty ? '+880${_phoneController.text.trim()}' : '',
          email: email,
          userType: initialRole,
          domain: initialDomain,
          status: UserStatus.active,
          createdAt: DateTime.now(),
        );
        await _authService.createOrUpdateUser(user);
        await userProvider.loadUser(userId);
        _selectedDomain = initialDomain;
        _selectedRole = initialRole;
        await _savePreferences();

        if (mounted) setState(() => _isLoading = false);
        Get.offAll(() => const AppRouter());
      }
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception:', '').trim();
      Get.snackbar(
        'লগইন ব্যর্থ ❌',
        errorMsg,
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Handle Phone OTP
  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    String phone = '+880${_phoneController.text.trim()}';

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
        Get.snackbar('সফল', 'আপনার ফোনে ৬-ডিজিটের কোড পাঠানো হয়েছে');
      },
      verificationFailed: (error) {
        if (mounted) setState(() => _isLoading = false);
        Get.snackbar('ত্রুটি', error);
      },
    );
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      Get.snackbar('ভুল কোড', 'সঠিক ৬-ডিজিটের কোড দিন');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.verifyOTP(
        verificationId: _verificationId!,
        otp: _otpController.text.trim(),
      );

      String userId = _authService.currentUser!.uid;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final userController = Get.put(UserController());

      adminProvider.clearAdminState();

      UserModel? userData = await _authService.getUserData(userId);

      if (userData != null) {
        UserType effectiveRole = _resolveUserType(
          existingType: userData.userType,
          domain: userData.domain,
          name: userData.name,
          email: userData.email ?? '',
          selectedRole: _selectedRole,
        );
        String effectiveDomain = userData.domain;
        if (effectiveRole == UserType.fishServiceProvider ||
            effectiveRole == UserType.fishDriver ||
            effectiveRole == UserType.fishBuyer ||
            effectiveRole == UserType.fishFarmer ||
            effectiveRole == UserType.fishCompany ||
            effectiveRole == UserType.fishExpert ||
            effectiveRole == UserType.hatchery) {
          effectiveDomain = 'fisheries';
        }

        if (effectiveRole != userData.userType || effectiveDomain != userData.domain) {
          userData = userData.copyWith(userType: effectiveRole, domain: effectiveDomain);
          await _authService.createOrUpdateUser(userData);
        }

        final role = _mapUserTypeToUserRole(userData.userType);
        userController.setUserData(
          id: userId,
          name: userData.name,
          phone: userData.phone,
          location: userData.district ?? '',
          role: role,
        );

        _selectedDomain = userData.domain;
        _selectedRole = userData.userType;
        await _savePreferences();

        await userProvider.loadUser(userId);
        await _authService.updateLastLogin(userId);

        Get.snackbar(
          'লগইন সফল ✅',
          'স্বাগতম ${userData.name}',
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );

        if (mounted) setState(() => _isLoading = false);
        Get.offAll(() => const AppRouter());
      } else {
        // First time phone user without profile
        // Switch to registration mode right on this screen with the verified phone
        if (mounted) {
          setState(() {
            _isRegisterMode = true;
            _isLoading = false;
          });
        }
        Get.snackbar(
          'প্রোফাইল তথ্য দিন',
          'আপনার মোবাইল যাচাই সম্পন্ন হয়েছে। অনুগ্রহ করে প্রোফাইল তথ্য দিন।',
          duration: const Duration(seconds: 4),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.blue.shade100,
          colorText: Colors.blue.shade900,
        );
      }
    } catch (e) {
      Get.snackbar('লগইন ব্যর্থ ❌', e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Handle Role-Based Registration directly on the same screen
  Future<void> _handleSameScreenRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String name = _nameController.text.trim();
      String phoneInput = _phoneController.text.trim();
      String formattedPhone = phoneInput.isNotEmpty ? '+880$phoneInput' : '';
      String email = _emailController.text.trim();
      String password = _passwordController.text;

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      String userId = _authService.currentUser?.uid ?? '';

      if (userId.isEmpty) {
        // Create user with Firebase Auth email/password
        final cred = await _authService.registerWithEmail(
          email: email,
          password: password,
          name: name,
          phone: formattedPhone,
          userType: _selectedRole.name,
        );
        userId = cred.user!.uid;
      }

      // Build address
      List<String> addressParts = [];
      if (_addressController.text.isNotEmpty) addressParts.add(_addressController.text.trim());
      if (_selectedUnion != null && _selectedUnion!.isNotEmpty) addressParts.add(_selectedUnion!);
      if (_selectedUpazila != null && _selectedUpazila!.isNotEmpty) addressParts.add(_selectedUpazila!);
      if (_selectedDistrict != null && _selectedDistrict!.isNotEmpty) addressParts.add(_selectedDistrict!);
      final fullAddress = addressParts.join(', ');

      // Create profile with chosen role & domain!
      final newUser = UserModel(
        id: userId,
        name: name,
        phone: formattedPhone,
        email: email.isNotEmpty ? email : null,
        userType: _selectedRole, // EXACT ROLE
        domain: _selectedDomain, // EXACT DOMAIN
        status: UserStatus.active,
        address: fullAddress,
        district: _selectedDistrict,
        upazila: _selectedUpazila,
        unionName: _selectedUnion,
        village: _addressController.text.trim(),
        createdAt: DateTime.now(),
      );

      await _authService.createOrUpdateUser(newUser);
      await _savePreferences();

      final userController = Get.put(UserController());
      final role = _mapUserTypeToUserRole(_selectedRole);
      userController.setUserRole(role);
      userController.setUserData(
        id: userId,
        name: name,
        phone: formattedPhone,
        location: _selectedDistrict ?? '',
        role: role,
      );

      await userProvider.loadUser(userId);

      String roleName;
      switch (_selectedRole) {
        case UserType.fishFarmer: roleName = 'মৎস্য চাষী'; break;
        case UserType.fishBuyer: roleName = 'মৎস্য পাইকারি ক্রেতা'; break;
        case UserType.fishDriver: roleName = 'মৎস্য পরিবহন চালক'; break;
        case UserType.fishServiceProvider: roleName = 'মৎস্য সেবা প্রদানকারী'; break;
        case UserType.fishCompany: roleName = 'মৎস্য কোম্পানি'; break;
        case UserType.fishExpert: roleName = 'মৎস্য বিশেষজ্ঞ'; break;
        case UserType.hatchery: roleName = 'হ্যাচারি মালিক'; break;
        case UserType.farmer: roleName = 'কৃষক'; break;
        case UserType.buyer: roleName = 'পাইকারি ক্রেতা'; break;
        case UserType.driver: roleName = 'পরিবহন চালক'; break;
        case UserType.serviceProvider: roleName = 'কৃষি সেবা প্রদানকারী'; break;
        case UserType.company: roleName = 'কৃষি কোম্পানি'; break;
        case UserType.seller: roleName = 'বিক্রেতা'; break;
        case UserType.expert: roleName = 'কৃষি বিশেষজ্ঞ'; break;
      }
      Get.snackbar(
        'রেজিস্ট্রেশন সফল ✅',
        'আপনার $roleName অ্যাকাউন্ট তৈরি হয়েছে!',
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );

      if (mounted) setState(() => _isLoading = false);
      Get.offAll(() => const AppRouter());
    } catch (e) {
      Get.snackbar(
        'রেজিস্ট্রেশন ব্যর্থ ❌',
        e.toString().replaceAll('Exception:', '').trim(),
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isBn = LanguageProvider.isBn(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = _primaryColor;
    final accent = _accentColor;

    final bgGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E1E2C), Color(0xFF12121A)],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _selectedDomain == 'fisheries'
                ? [const Color(0xFFE0F7FA), const Color(0xFFF1F8E9), Colors.white]
                : [Colors.green.shade50, Colors.white],
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
          color: primary,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? Colors.white : Colors.black87,
            ),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // DOMAIN SELECTOR: Agriculture on LEFT, Fisheries on RIGHT
                        _buildDomainSelector(isDark, isBn),
                        const SizedBox(height: 20),

                        // LOGO & HEADER
                        Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primary, accent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _selectedDomain == 'fisheries' ? '🐟' : '🌾',
                                style: const TextStyle(fontSize: 38),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          _selectedDomain == 'fisheries'
                              ? (_isRegisterMode ? (isBn ? 'মৎস্য নিবন্ধন' : 'Fisheries Registration') : (isBn ? 'মৎস্য প্ল্যাটফর্ম' : 'Fisheries Platform'))
                              : (_isRegisterMode ? (isBn ? 'কৃষি নিবন্ধন' : 'Agriculture Registration') : (isBn ? 'কৃষি প্ল্যাটফর্ম' : 'Agriculture Platform')),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedDomain == 'fisheries'
                              ? (isBn ? 'AgroLinkBD - মৎস্য ব্যবসায় স্বাগতম' : 'AgroLinkBD - Welcome to Fisheries Trade')
                              : (isBn ? 'AgroLinkBD - কৃষি বাণিজ্যে স্বাগতম' : 'AgroLinkBD - Welcome to Agri Trade'),
                          style: TextStyle(
                            color: subTextColor,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        // ROLE SELECTOR DROPDOWN
                        _buildRoleSelector(inputDecoration, cardColor, textColor, primary, isBn),
                        const SizedBox(height: 18),

                        // MODE TOGGLE: LOGIN vs REGISTER (BEAUTIFULLY STYLED BOX)
                        _buildModeToggle(primary, subTextColor, isDark, isBn),
                        const SizedBox(height: 20),

                        // BODY CONTENT: LOGIN FORM vs REGISTER FORM
                        if (!_isRegisterMode) ...[
                          _buildLoginForm(inputDecoration, textColor, subTextColor, primary, isDark, isBn),
                        ] else ...[
                          _buildRegisterForm(inputDecoration, textColor, subTextColor, primary, isDark, isBn),
                        ],

                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),

                        // DOMAIN-SPECIFIC FEATURES SHOWCASE
                        _buildDynamicFeatureCards(isDark, primary, cardColor, isBn),

                        const SizedBox(height: 16),
                        Divider(color: isDark ? Colors.white10 : Colors.black12),
                        Center(
                          child: TextButton.icon(
                            onPressed: () => Get.to(() => const AdminLoginScreen()),
                            icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
                            label: Text(isBn ? 'অ্যাডমিন প্যানেল এক্সেস' : 'Admin Panel Access'),
                            style: TextButton.styleFrom(
                              foregroundColor: subTextColor,
                            ),
                          ),
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

  // Domain Switcher (Agriculture on LEFT, Fisheries on RIGHT)
  Widget _buildDomainSelector(bool isDark, bool isBn) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          // 1. Agriculture on the LEFT
          Expanded(
            child: GestureDetector(
              onTap: () => _onDomainChanged('agriculture'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedDomain == 'agriculture'
                      ? const Color(0xFF2E7D32)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _selectedDomain == 'agriculture'
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2E7D32).withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🌾 ', style: TextStyle(fontSize: 16)),
                    Flexible(
                      child: Text(
                        isBn ? 'কৃষি (Agriculture)' : 'Agriculture (কৃষি)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _selectedDomain == 'agriculture'
                              ? Colors.white
                              : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                          fontWeight: _selectedDomain == 'agriculture'
                              ? FontWeight.bold
                              : FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // 2. Fisheries on the RIGHT
          Expanded(
            child: GestureDetector(
              onTap: () => _onDomainChanged('fisheries'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedDomain == 'fisheries'
                      ? const Color(0xFF0288D1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _selectedDomain == 'fisheries'
                      ? [
                          BoxShadow(
                            color: const Color(0xFF0288D1).withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🐟 ', style: TextStyle(fontSize: 16)),
                    Flexible(
                      child: Text(
                        isBn ? 'মৎস্য (Fisheries)' : 'Fisheries (মৎস্য)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _selectedDomain == 'fisheries'
                              ? Colors.white
                              : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                          fontWeight: _selectedDomain == 'fisheries'
                              ? FontWeight.bold
                              : FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Role Dropdown (Matching Domain)
  Widget _buildRoleSelector(
    InputDecoration decoration,
    Color cardColor,
    Color textColor,
    Color primaryColor,
    bool isBn,
  ) {
    final fisheriesRoles = [
      DropdownMenuItem(
        value: UserType.fishFarmer,
        child: Text(isBn ? '🐟 মৎস্য চাষী (Fish Farmer)' : '🐟 Fish Farmer (মৎস্য চাষী)'),
      ),
      DropdownMenuItem(
        value: UserType.fishBuyer,
        child: Text(isBn ? '🛒 মৎস্য পাইকারি ক্রেতা (Fish Buyer)' : '🛒 Wholesale Fish Buyer (ক্রেতা)'),
      ),
      DropdownMenuItem(
        value: UserType.hatchery,
        child: Text(isBn ? '🔬 হ্যাচারি মালিক (Hatchery Owner)' : '🔬 Hatchery Owner (হ্যাচারি)'),
      ),
      DropdownMenuItem(
        value: UserType.fishDriver,
        child: Text(isBn ? '🚚 মৎস্য পরিবহন (Fish Transport)' : '🚚 Fish Transport (পরিবহন)'),
      ),
      DropdownMenuItem(
        value: UserType.fishExpert,
        child: Text(isBn ? '🩺 মৎস্য বিশেষজ্ঞ (Fisheries Expert)' : '🩺 Fisheries Expert (বিশেষজ্ঞ)'),
      ),
    ];

    final agriRoles = [
      DropdownMenuItem(
        value: UserType.farmer,
        child: Text(isBn ? '🌾 কৃষক (Farmer)' : '🌾 Farmer (কৃষক)'),
      ),
      DropdownMenuItem(
        value: UserType.buyer,
        child: Text(isBn ? '🛍️ পাইকারি ক্রেতা (Buyer)' : '🛍️ Wholesale Buyer (ক্রেতা)'),
      ),
      DropdownMenuItem(
        value: UserType.driver,
        child: Text(isBn ? '🚚 পরিবহন চালক (Driver)' : '🚚 Transport Driver (চালক)'),
      ),
      DropdownMenuItem(
        value: UserType.serviceProvider,
        child: Text(isBn ? '🚜 কৃষি সেবা প্রদানকারী (Service Provider)' : '🚜 Agri Service Provider (সেবা)'),
      ),
      DropdownMenuItem(
        value: UserType.company,
        child: Text(isBn ? '🏢 কোম্পানি (Company)' : '🏢 Agri Company (কোম্পানি)'),
      ),
    ];

    final currentItems = _selectedDomain == 'fisheries' ? fisheriesRoles : agriRoles;

    return DropdownButtonFormField<UserType>(
      value: _selectedRole,
      dropdownColor: cardColor,
      isExpanded: true,
      style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
      decoration: decoration.copyWith(
        labelText: isBn ? 'আপনার ভূমিকা (Role)' : 'Your Role (ভূমিকা)',
        prefixIcon: Icon(Icons.badge_outlined, color: primaryColor),
      ),
      items: currentItems,
      onChanged: _onRoleChanged,
    );
  }

  // Toggle between Login and Register Mode (Styled Segmented Box)
  Widget _buildModeToggle(Color primaryColor, Color subTextColor, bool isDark, bool isBn) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          // Login / Sign In
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isRegisterMode = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isRegisterMode ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !_isRegisterMode
                      ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.login_rounded,
                      size: 18,
                      color: !_isRegisterMode
                          ? Colors.white
                          : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        isBn ? 'লগইন (Sign In)' : 'Sign In (লগইন)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: !_isRegisterMode
                              ? Colors.white
                              : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                          fontWeight: !_isRegisterMode ? FontWeight.bold : FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Register
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isRegisterMode = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isRegisterMode ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _isRegisterMode
                      ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.how_to_reg_rounded,
                      size: 18,
                      color: _isRegisterMode
                          ? Colors.white
                          : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        isBn ? 'নিবন্ধন (Register)' : 'Register (নিবন্ধন)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _isRegisterMode
                              ? Colors.white
                              : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                          fontWeight: _isRegisterMode ? FontWeight.bold : FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // LOGIN FORM (Email on LEFT, Mobile on RIGHT)
  Widget _buildLoginForm(
    InputDecoration inputDecoration,
    Color textColor,
    Color subTextColor,
    Color primary,
    bool isDark,
    bool isBn,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-tabs for Email vs Mobile Login (Email on LEFT, Mobile on RIGHT in Styled Box)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2C) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              // 1. Email Login on LEFT
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _useEmailLogin = true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _useEmailLogin ? primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: _useEmailLogin
                          ? [
                              BoxShadow(
                                color: primary.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 16,
                          color: _useEmailLogin
                              ? Colors.white
                              : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            isBn ? 'ইমেইল লগইন' : 'Email Login',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _useEmailLogin
                                  ? Colors.white
                                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                              fontWeight: _useEmailLogin ? FontWeight.bold : FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // 2. Mobile Login on RIGHT
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _useEmailLogin = false;
                    _otpSent = false;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !_useEmailLogin ? primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: !_useEmailLogin
                          ? [
                              BoxShadow(
                                color: primary.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone_android_outlined,
                          size: 16,
                          color: !_useEmailLogin
                              ? Colors.white
                              : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            isBn ? 'মোবাইল নাম্বার' : 'Mobile Number',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: !_useEmailLogin
                                  ? Colors.white
                                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                              fontWeight: !_useEmailLogin ? FontWeight.bold : FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        if (_useEmailLogin) ...[
          // Email Login Fields
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: textColor),
            decoration: inputDecoration.copyWith(
              labelText: isBn ? 'ইমেইল এড্রেস' : 'Email Address',
              hintText: 'user@example.com',
              prefixIcon: Icon(Icons.email_outlined, color: primary),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return isBn ? 'ইমেইল দিন' : 'Please enter email';
              }
              if (!value.contains('@')) {
                return isBn ? 'সঠিক ইমেইল দিন' : 'Please enter valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: TextStyle(color: textColor),
            decoration: inputDecoration.copyWith(
              labelText: isBn ? 'পাসওয়ার্ড' : 'Password',
              hintText: isBn ? 'কমপক্ষে ৬ ডিজিট' : 'At least 6 characters',
              prefixIcon: Icon(Icons.lock_outline, color: primary),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return isBn ? 'পাসওয়ার্ড দিন' : 'Please enter password';
              }
              if (value.length < 6) {
                return isBn ? 'পাসওয়ার্ড কমপক্ষে ৬ ডিজিট হতে হবে' : 'Password must be at least 6 digits';
              }
              return null;
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _forgotPassword,
              child: Text(
                isBn ? 'পাসওয়ার্ড ভুলে গেছেন?' : 'Forgot Password?',
                style: TextStyle(color: primary, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildPrimaryButton(
            onPressed: _isLoading ? null : _loginWithEmail,
            text: isBn ? 'লগইন করুন' : 'Sign In',
            icon: Icons.login_rounded,
            isLoading: _isLoading,
          ),
        ] else if (!_otpSent) ...[
          // Phone Input
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: TextStyle(color: textColor),
            decoration: inputDecoration.copyWith(
              labelText: isBn ? 'মোবাইল নাম্বার' : 'Mobile Number',
              hintText: '17XXXXXXXX',
              prefixIcon: Icon(Icons.phone_outlined, color: primary),
              prefixText: '+880 ',
              prefixStyle: TextStyle(color: textColor, fontSize: 16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return isBn ? 'মোবাইল নাম্বার দিন' : 'Please enter phone number';
              }
              if (value.trim().length != 10) {
                return isBn ? 'নাম্বার ১০ ডিজিটের হতে হবে (যেমন, 17XXXXXXXX)' : 'Number must be 10 digits (e.g. 17XXXXXXXX)';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildPrimaryButton(
            onPressed: _isLoading ? null : _sendOTP,
            text: isBn ? 'OTP কোড পাঠান' : 'Send OTP Code',
            icon: Icons.send_rounded,
            isLoading: _isLoading,
          ),
        ] else ...[
          // OTP Verification
          Text(
            isBn
                ? '+880 ${_phoneController.text} নাম্বারে পাঠানো ৬-ডিজিটের কোড দিন'
                : 'Enter 6-digit code sent to +880 ${_phoneController.text}',
            style: TextStyle(color: subTextColor, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor, fontSize: 22, letterSpacing: 8),
            decoration: inputDecoration.copyWith(
              hintText: '------',
              counterText: '',
            ),
          ),
          const SizedBox(height: 20),
          _buildPrimaryButton(
            onPressed: _isLoading ? null : _verifyOTP,
            text: isBn ? 'যাচাই করে লগইন করুন' : 'Verify & Sign In',
            icon: Icons.check_circle_outline,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() => _otpSent = false),
            child: Text(
              isBn ? 'নাম্বার পরিবর্তন করুন' : 'Change Phone Number',
              style: TextStyle(color: primary),
            ),
          ),
        ],

        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isBn ? 'অ্যাকাউন্ট নেই? ' : "Don't have an account? ",
              style: TextStyle(color: subTextColor),
            ),
            TextButton(
              onPressed: () => setState(() => _isRegisterMode = true),
              child: Text(
                isBn ? 'নিবন্ধন করুন' : 'Register Now',
                style: TextStyle(color: primary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ROLE-BASED REGISTER FORM (SAME SCREEN)
  Widget _buildRegisterForm(
    InputDecoration inputDecoration,
    Color textColor,
    Color subTextColor,
    Color primary,
    bool isDark,
    bool isBn,
  ) {
    final roleDisplayName = _selectedRole == UserType.fishFarmer
        ? (isBn ? 'মৎস্য চাষী (Fish Farmer)' : 'Fish Farmer')
        : _selectedRole == UserType.farmer
            ? (isBn ? 'কৃষক (Farmer)' : 'Farmer')
            : _selectedRole.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Role notice banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isBn
                      ? 'আপনি $roleDisplayName হিসেবে নিবন্ধন করছেন।'
                      : 'You are registering as $roleDisplayName.',
                  style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Full Name
        TextFormField(
          controller: _nameController,
          style: TextStyle(color: textColor),
          decoration: inputDecoration.copyWith(
            labelText: isBn ? 'পূর্ণ নাম *' : 'Full Name *',
            hintText: isBn ? 'আপনার নাম লিখুন' : 'Enter your full name',
            prefixIcon: Icon(Icons.person_outline, color: primary),
          ),
          validator: (val) => val == null || val.trim().isEmpty
              ? (isBn ? 'আপনার নাম লিখুন' : 'Please enter your name')
              : null,
        ),
        const SizedBox(height: 14),

        // Phone Number
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: TextStyle(color: textColor),
          decoration: inputDecoration.copyWith(
            labelText: isBn ? 'মোবাইল নাম্বার *' : 'Mobile Number *',
            hintText: '17XXXXXXXX',
            prefixIcon: Icon(Icons.phone_outlined, color: primary),
            prefixText: '+880 ',
            prefixStyle: TextStyle(color: textColor, fontSize: 16),
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return isBn ? 'মোবাইল নাম্বার দিন' : 'Please enter phone number';
            }
            if (val.trim().length != 10) {
              return isBn ? '১০ ডিজিটের নাম্বার দিন' : 'Enter 10-digit number';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),

        // Email
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: textColor),
          decoration: inputDecoration.copyWith(
            labelText: isBn ? 'ইমেইল (ঐচ্ছিক/লগইন)' : 'Email (Optional/Login)',
            hintText: 'user@example.com',
            prefixIcon: Icon(Icons.email_outlined, color: primary),
          ),
        ),
        const SizedBox(height: 14),

        // Password
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: TextStyle(color: textColor),
          decoration: inputDecoration.copyWith(
            labelText: isBn ? 'পাসওয়ার্ড *' : 'Password *',
            hintText: isBn ? 'কমপক্ষে ৬ ডিজিট দিন' : 'At least 6 characters',
            prefixIcon: Icon(Icons.lock_outline, color: primary),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (val) => val == null || val.length < 6
              ? (isBn ? 'কমপক্ষে ৬ ডিজিট দিন' : 'Must be at least 6 digits')
              : null,
        ),
        const SizedBox(height: 14),

        // Location Dropdowns
        SearchableDropdown(
          hint: isBn ? 'বিভাগ নির্বাচন করুন' : 'Select Division',
          value: _selectedDivision,
          items: BDLocationData.divisions,
          icon: Icons.map_outlined,
          onChanged: (val) {
            setState(() {
              _selectedDivision = val;
              _selectedDistrict = null;
              _selectedUpazila = null;
              _selectedUnion = null;
            });
          },
        ),
        const SizedBox(height: 12),

        if (_districts.isNotEmpty) ...[
          SearchableDropdown(
            hint: isBn ? 'জেলা নির্বাচন করুন' : 'Select District',
            value: _selectedDistrict,
            items: _districts,
            icon: Icons.location_city_outlined,
            onChanged: (val) {
              setState(() {
                _selectedDistrict = val;
                _selectedUpazila = null;
                _selectedUnion = null;
              });
            },
          ),
          const SizedBox(height: 12),
        ],

        if (_upazilas.isNotEmpty) ...[
          SearchableDropdown(
            hint: isBn ? 'উপজেলা নির্বাচন করুন' : 'Select Upazila',
            value: _selectedUpazila,
            items: _upazilas,
            icon: Icons.location_on_outlined,
            onChanged: (val) {
              setState(() {
                _selectedUpazila = val;
                _selectedUnion = null;
              });
            },
          ),
          const SizedBox(height: 12),
        ],

        if (_unions.isNotEmpty) ...[
          SearchableDropdown(
            hint: isBn ? 'ইউনিয়ন নির্বাচন করুন' : 'Select Union',
            value: _selectedUnion,
            items: _unions,
            icon: Icons.holiday_village_outlined,
            onChanged: (val) {
              setState(() {
                _selectedUnion = val;
              });
            },
          ),
          const SizedBox(height: 12),
        ],

        // Village/Address
        TextFormField(
          controller: _addressController,
          style: TextStyle(color: textColor),
          decoration: inputDecoration.copyWith(
            labelText: isBn ? 'গ্রাম / রোড / ঠিকানা' : 'Village / Road / Address',
            prefixIcon: Icon(Icons.home_outlined, color: primary),
          ),
        ),
        const SizedBox(height: 20),

        // Register Button
        _buildPrimaryButton(
          onPressed: _isLoading ? null : _handleSameScreenRegister,
          text: isBn ? 'অ্যাকাউন্ট তৈরি করুন' : 'Create Account',
          icon: Icons.how_to_reg_rounded,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isBn ? 'ইতিমধ্যে অ্যাকাউন্ট আছে? ' : 'Already have an account? ',
              style: TextStyle(color: subTextColor),
            ),
            TextButton(
              onPressed: () => setState(() => _isRegisterMode = false),
              child: Text(
                isBn ? 'লগইন করুন' : 'Sign In',
                style: TextStyle(color: primary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Dynamic Feature Highlights based on selected domain
  Widget _buildDynamicFeatureCards(bool isDark, Color primary, Color cardColor, bool isBn) {
    if (_selectedDomain == 'fisheries') {
      return Column(
        children: [
          _buildFeatureCard(
            icon: Icons.water_outlined,
            title: isBn ? 'মৎস্য বাজার ও ট্রেডিং' : 'Fish Marketplace & Trading',
            description: isBn
                ? 'সরাসরি চাষী থেকে পাইকারি মাছ কেনা ও বিক্রির সুবিধা'
                : 'Direct fish wholesale buying & selling from authentic farmers',
            isDark: isDark,
            primaryColor: primary,
          ),
          const SizedBox(height: 10),
          _buildFeatureCard(
            icon: Icons.set_meal_outlined,
            title: isBn ? 'হ্যাচারি ও পোনা সরবরাহ' : 'Hatchery & Fry Supply',
            description: isBn
                ? 'উন্নত জাতের রেনু ও পোনা সংগ্রহ এবং পুকুর ব্যবস্থাপনা'
                : 'Quality fry & fingerling procurement and tank management',
            isDark: isDark,
            primaryColor: primary,
          ),
          const SizedBox(height: 10),
          _buildFeatureCard(
            icon: Icons.local_shipping_outlined,
            title: isBn ? 'মৎস্য অক্সিজেন পরিবহন' : 'Oxygenated Fish Transport',
            description: isBn
                ? 'লাইভ মাছ দ্রুত ও নিরাপদে গন্তব্যে পৌঁছানোর গাড়ি'
                : 'Safe, rapid live fish delivery with oxygen support',
            isDark: isDark,
            primaryColor: primary,
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildFeatureCard(
          icon: Icons.storefront_outlined,
          title: isBn ? 'ফসল বাজার' : 'Agri Crop Marketplace',
          description: isBn
              ? 'সরাসরি কৃষক থেকে পাইকারি পণ্য কিনুন ও বিক্রি করুন'
              : 'Buy & sell wholesale agricultural produce directly from farmers',
          isDark: isDark,
          primaryColor: primary,
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          icon: Icons.agriculture_outlined,
          title: isBn ? 'যন্ত্রপাতি ভাড়া' : 'Machinery & Equipment Rental',
          description: isBn
              ? 'ট্রাক্টর, হারভেস্টার সহজে ভাড়া করুন বা সেবা দিন'
              : 'Rent tractors, harvesters or offer modern farming machinery',
          isDark: isDark,
          primaryColor: primary,
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          icon: Icons.local_shipping_outlined,
          title: isBn ? 'কৃষি পরিবহন সেবা' : 'Agri Logistics & Transport',
          description: isBn
              ? 'ফসল নিরাপদে বাজারে পৌঁছে দিন সহজে'
              : 'Hassle-free dispatch of harvested crops directly to markets',
          isDark: isDark,
          primaryColor: primary,
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
    required Color primaryColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              color: primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback? onPressed,
    required String text,
    required bool isLoading,
    IconData? icon,
  }) {
    final primary = _primaryColor;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: primary.withOpacity(0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
