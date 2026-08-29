import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/models/user_model.dart';
import 'package:agrolinkbd/core/services/user_rating_service.dart';
import 'package:agrolinkbd/core/services/pdf/user_report_service.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:printing/printing.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _locationServices = true;
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Load saved preferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _notifications = prefs.getBool('notifications') ?? true;
      _locationServices = prefs.getBool('locationServices') ?? true;
      _language = prefs.getString('language') ?? 'English';
    });
  }

  // Save preferences
  Future<void> _savePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  Color _getRolePrimaryColor(BuildContext context) {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.currentUser;
      if (user != null) {
        switch (user.userType) {
          case UserType.buyer:
            return const Color(0xFF1976D2); // Blue
          case UserType.fishBuyer:
          case UserType.fishFarmer:
          case UserType.fishDriver:
          case UserType.fishServiceProvider:
          case UserType.fishCompany:
          case UserType.fishExpert:
          case UserType.hatchery:
            return const Color(0xFF0277BD); // Deep water blue
          case UserType.driver:
            return const Color(0xFFF57C00); // Orange
          case UserType.serviceProvider:
            return const Color(0xFF7B1FA2); // Purple
          case UserType.company:
          case UserType.seller:
            return const Color(0xFF0D47A1); // Dark Blue
          case UserType.farmer:
          default:
            return const Color(0xFF2E7D32); // Agriculture Green
        }
      }
    } catch (_) {}
    return Theme.of(context).primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        // Show profile if user is logged in
        if (userProvider.isLoggedIn && userProvider.currentUser != null) {
          return _buildProfileUI(context, isDarkMode, userProvider);
        }

        // Show login prompt if not logged in
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 80,
                  color: _getRolePrimaryColor(context).withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  'You are not logged in',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  'Please login to view your profile',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Go to Login'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileUI(
      BuildContext context, bool isDarkMode, UserProvider userProvider) {
    final user = userProvider.currentUser;
    final userName = user?.name ?? 'User';
    final userEmail = user?.email ?? 'No email';
    final primaryColor = _getRolePrimaryColor(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Profile Header
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor,
                      primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50), // Account for status bar
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.white,
                              width: 3,
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white24,
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: TextStyle(
                        fontSize: 14,
                        color: (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.white)
                            .withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Stats Row
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: _buildStatItem(
                      '${user?.totalOrders ?? 0} ${LanguageProvider.isBn(context) ? "বার" : "orders"}',
                      LanguageProvider.isBn(context) ? 'মোট লেনদেন' : 'Total Orders',
                      Icons.shopping_bag,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: Theme.of(context).dividerColor,
                  ),
                  Expanded(
                    child: _buildStatItem(
                      '৳ ${(user?.totalSpent ?? 0.0).toStringAsFixed(0)}',
                      LanguageProvider.isBn(context) ? 'পরিশোধিত' : 'Total Spent',
                      Icons.payments,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: Theme.of(context).dividerColor,
                  ),
                  Expanded(
                    child: _buildStatItem(
                      '${UserRatingService.calculateTrustScore(user ?? UserModel(id: "", name: "", phone: "", email: "", userType: UserType.farmer, status: UserStatus.active, createdAt: DateTime.now())).toStringAsFixed(0)}%',
                      LanguageProvider.isBn(context) ? 'ট্রাস্ট স্কোর' : 'Trust Score',
                      Icons.verified_user,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Universal 360° Trust & Credibility Card (For ALL roles: Farmer, Buyer, Driver, Service Provider, Company)
          SliverToBoxAdapter(
            child: _buildUniversalTrustCard(context, user, primaryColor),
          ),

          // Settings Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                LanguageProvider.isBn(context) ? 'সেটিংস' : 'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Settings List
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSwitchTile(
                    LanguageProvider.isBn(context) ? 'ডার্ক মোড' : 'Dark Mode',
                    LanguageProvider.isBn(context) ? 'ডার্ক থিম চালু করুন' : 'Enable dark theme',
                    Icons.dark_mode,
                    _darkMode,
                    (value) {
                      setState(() => _darkMode = value);
                      _savePreference('darkMode', value);
                      Get.changeThemeMode(
                          _darkMode ? ThemeMode.dark : ThemeMode.light);
                    },
                    context,
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    LanguageProvider.isBn(context) ? 'নোটিফিকেশন' : 'Notifications',
                    LanguageProvider.isBn(context) ? 'পুশ নোটিফিকেশন পান' : 'Get push notifications',
                    Icons.notifications,
                    _notifications,
                    (value) {
                      setState(() => _notifications = value);
                      _savePreference('notifications', value);
                      _showPreferenceSnackbar(
                          LanguageProvider.isBn(context) ? 'নোটিফিকেশন ${value ? "চালু" : "বন্ধ"}' : 'Notifications ${value ? "enabled" : "disabled"}');
                    },
                    context,
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    LanguageProvider.isBn(context) ? 'লোকেশন সার্ভিস' : 'Location Services',
                    LanguageProvider.isBn(context) ? 'আপনার অবস্থান শেয়ার করুন' : 'Share your location',
                    Icons.location_on,
                    _locationServices,
                    (value) {
                      setState(() => _locationServices = value);
                      _savePreference('locationServices', value);
                      _showPreferenceSnackbar(
                          LanguageProvider.isBn(context) ? 'লোকেশন ${value ? "চালু" : "বন্ধ"}' : 'Location ${value ? "enabled" : "disabled"}');
                    },
                    context,
                  ),
                ],
              ),
            ),
          ),

          // Account Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                LanguageProvider.isBn(context) ? 'অ্যাকাউন্ট' : 'Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Account Options
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuTile(
                    LanguageProvider.isBn(context) ? 'প্রোফাইল সম্পাদনা' : 'Edit Profile',
                    LanguageProvider.isBn(context) ? 'আপনার তথ্য আপডেট করুন' : 'Update Your Information',
                    Icons.edit,
                    _showEditProfileDialog,
                    context,
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    Provider.of<LanguageProvider>(context).isBangla ? 'ভাষা' : 'Language',
                    Provider.of<LanguageProvider>(context).isBangla ? 'বাংলা' : 'English',
                    Icons.language,
                    _showLanguageDialog,
                    context,
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    LanguageProvider.isBn(context) ? 'নিরাপত্তা' : 'Security',
                    LanguageProvider.isBn(context) ? 'পাসওয়ার্ড এবং গোপনীয়তা' : 'Password and privacy',
                    Icons.security,
                    _showChangePasswordDialog,
                    context,
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    LanguageProvider.isBn(context) ? 'পেমেন্ট মাধ্যম' : 'Payment Methods',
                    LanguageProvider.isBn(context) ? 'আপনার পেমেন্ট অপশন' : 'Your payment options',
                    Icons.payment,
                    _showPaymentMethodsDialog,
                    context,
                  ),
                ],
              ),
            ),
          ),

          // Help & Support
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                LanguageProvider.isBn(context) ? 'সাহায্য ও সাপোর্ট' : 'Help & Support',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuTile(
                    LanguageProvider.isBn(context) ? 'হেল্প সেন্টার' : 'Help Center',
                    LanguageProvider.isBn(context) ? 'সাধারণ প্রশ্ন ও গাইড' : 'FAQ and guides',
                    Icons.help_outline,
                    _showFAQDialog,
                    context,
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    LanguageProvider.isBn(context) ? 'যোগাযোগ করুন' : 'Contact Us',
                    LanguageProvider.isBn(context) ? 'সরাসরি সাপোর্ট পান' : 'Get direct support',
                    Icons.contact_support,
                    _showContactDialog,
                    context,
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    LanguageProvider.isBn(context) ? 'কারিগরি সমস্যা জানান' : 'Report Technical Issue',
                    LanguageProvider.isBn(context) ? 'অ্যাপে কোনো সমস্যা থাকলে জানান' : 'Report an app problem',
                    Icons.bug_report_outlined,
                    _showReportDialog,
                    context,
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    LanguageProvider.isBn(context) ? 'অন্য ব্যবহারকারীর বিরুদ্ধে অভিযোগ' : 'Report User / Dispute',
                    LanguageProvider.isBn(context) ? 'প্রতারণা, বাতিল বা অনিয়মের রিপোর্ট সুপার অ্যাডমিনে পাঠান' : 'Submit user complaint to Super Admin',
                    Icons.gavel_rounded,
                    () => _showUserDisputeReportDialog(context),
                    context,
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    LanguageProvider.isBn(context) ? 'অ্যাপ সম্পর্কে' : 'About App',
                    'Version 1.0.0',
                    Icons.info_outline,
                    _showAboutDialog,
                    context,
                  ),
                ],
              ),
            ),
          ),

          // Logout Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  _showLogoutDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout),
                    const SizedBox(width: 8),
                    Text(
                      LanguageProvider.isBn(context) ? 'লগ আউট' : 'Logout',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Builder(
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUniversalTrustCard(
      BuildContext context, UserModel? user, Color primaryColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final int totalOrders = user?.totalOrders ?? 0;
    final double totalSpent = user?.totalSpent ?? 0.0;
    final double rating = user?.rating ?? 0.0;
    final int totalRatings = user?.totalRatings ?? 0;

    final double trustScore = UserRatingService.calculateTrustScore(
        user ?? UserModel(id: "", name: "", phone: "", email: "", userType: UserType.farmer, status: UserStatus.active, createdAt: DateTime.now()));
    final int fraudReports = user?.fraudReports ?? 0;
    final int cancelledOrders = user?.cancelledOrders ?? 0;
    final int paymentDefaults = user?.paymentDefaults ?? 0;
    final int lateDeliveries = user?.lateDeliveries ?? 0;
    final int totalPenalties = fraudReports + cancelledOrders + paymentDefaults + lateDeliveries;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.18),
                  primaryColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_user,
                  color: primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${trustScore.toStringAsFixed(0)}% ${LanguageProvider.isBn(context) ? "সর্বজনীন বিশ্বস্ততা ও ট্রাস্ট স্কোর" : "Universal Trust Score"}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        trustScore >= 95
                            ? (LanguageProvider.isBn(context) ? '💎 প্ল্যাটিনাম বিশ্বস্ত সদস্য • ১০০% নিরাপদ লেনদেন' : '💎 Platinum Member • 100% Safe')
                            : (trustScore >= 85
                                ? (LanguageProvider.isBn(context) ? '🥇 গোল্ড বিশ্বস্ত সদস্য • প্রমাণিত ও নিরাপদ' : '🥇 Gold Member • Verified & Safe')
                                : (trustScore >= 70
                                    ? (LanguageProvider.isBn(context) ? '🥈 সিলভার সদস্য • নির্ভরযোগ্য' : '🥈 Silver Member • Reliable')
                                    : (LanguageProvider.isBn(context) ? '🥉 ব্রোঞ্জ সদস্য • প্রাথমিক পর্যায়' : '🥉 Bronze Member • Starter'))),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (trustScore >= 85 ? Colors.green : Colors.blue)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: trustScore >= 85 ? Colors.green : Colors.blue,
                        width: 1),
                  ),
                  child: Text(
                    trustScore >= 95 ? 'PLATINUM' : (trustScore >= 85 ? 'GOLD' : 'VERIFIED'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: trustScore >= 85 ? Colors.green : Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Root Rating & Clean Verified Summary
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Clean Root Rating Summary Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'মূল রেটিং (Root Trust Rating)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                totalRatings == 0
                                    ? '৫.০ / ৫.০ ⭐️ (১০০% বিশ্বস্ততা)'
                                    : '${rating.toStringAsFixed(1)} / 5.0 ⭐️ (${trustScore.toStringAsFixed(0)}% বিশ্বস্ততা)',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified,
                                color: Colors.green, size: 15),
                            SizedBox(width: 4),
                            Text(
                              'ভেরিফাইড',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 3 Clean Verified Summary Chips/Pills
                Row(
                  children: [
                    Expanded(
                      child: _buildCleanTrustBadge(
                        Icons.work_outline,
                        'ভেরিফাইড কাজ',
                        totalOrders == 0
                            ? '০ টি সম্পন্ন'
                            : '$totalOrders টি সফল কাজ',
                        Colors.blue,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCleanTrustBadge(
                        Icons.payments_outlined,
                        'নিরাপদ লেনদেন',
                        totalSpent == 0
                            ? '৳ ০ লেনদেন'
                            : '৳ ${totalSpent.toStringAsFixed(0)} সফল',
                        Colors.green,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCleanTrustBadge(
                        totalPenalties == 0
                            ? Icons.verified_user_outlined
                            : Icons.warning_amber_rounded,
                        'রেকর্ড স্ট্যাটাস',
                        totalPenalties == 0
                            ? '১০০% ক্লিন রেকর্ড'
                            : '$totalPenalties টি রিপোর্ট',
                        totalPenalties == 0 ? Colors.teal : Colors.red,
                        isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // User's Own Trust & Transaction Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/buyer-orders');
                        },
                        icon: const Icon(Icons.history, size: 18),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(LanguageProvider.isBn(context) ? 'লেনদেনের ইতিহাস' : 'Transaction History'),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(color: primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/buyer-payment-history');
                        },
                        icon: const Icon(Icons.receipt_long, size: 18),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(LanguageProvider.isBn(context) ? 'পেমেন্ট রিপোর্ট' : 'Payment Report'),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(color: primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _generateUserActivityReport(user),
                        icon: const Icon(Icons.picture_as_pdf, size: 18),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(LanguageProvider.isBn(context) ? 'অ্যাক্টিভিটি রিপোর্ট' : 'Activity Report'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showUserDisputeReportDialog(context),
                        icon: const Icon(Icons.report_gmailerrorred_rounded, size: 18),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(LanguageProvider.isBn(context) ? 'অভিযোগ / রিপোর্ট' : 'Report / Dispute'),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          side: BorderSide(color: Colors.red.shade400),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanTrustBadge(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
    BuildContext context,
  ) {
    final roleColor = _getRolePrimaryColor(context);
    return Material(
      color: Colors.transparent,
      child: ListTile(
        dense: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: roleColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: roleColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: roleColor,
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    BuildContext context,
  ) {
    final roleColor = _getRolePrimaryColor(context);
    return Material(
      color: Colors.transparent,
      child: ListTile(
        dense: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: roleColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: roleColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }

  void _showLanguageDialog() {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final currentLang = langProvider.isBangla ? 'বাংলা' : 'English';
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(dialogContext).colorScheme.surface,
        title: Text(
          langProvider.isBangla ? 'ভাষা নির্বাচন করুন' : 'Select Language',
          style: Theme.of(dialogContext).textTheme.headlineSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('বাংলা'),
              value: 'বাংলা',
              groupValue: currentLang,
              onChanged: (value) {
                langProvider.setLanguage('বাংলা');
                setState(() => _language = 'বাংলা');
                Navigator.pop(dialogContext);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: currentLang,
              onChanged: (value) {
                langProvider.setLanguage('English');
                setState(() => _language = 'English');
                Navigator.pop(dialogContext);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(dialogContext).colorScheme.surface,
        title: Text(
          LanguageProvider.isBn(context) ? 'লগ আউট' : 'Logout',
          style: Theme.of(dialogContext).textTheme.headlineSmall,
        ),
        content: Text(
          LanguageProvider.isBn(context) ? 'আপনি কি নিশ্চিত যে আপনি লগ আউট করতে চান?' : 'Are you sure you want to logout?',
          style: Theme.of(dialogContext).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(LanguageProvider.isBn(context) ? 'বাতিল' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final userProvider =
                    Provider.of<UserProvider>(dialogContext, listen: false);
                await userProvider.signOut();
                // AppRouter will detect auth state change and redirect to LoginScreen
              } catch (e) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text('Logout error: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(LanguageProvider.isBn(context) ? 'লগ আউট' : 'Logout'),
          ),
        ],
      ),
    );
  }

  // Edit Profile Dialog
  void _showEditProfileDialog() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');
    final locationController = TextEditingController(text: user?.address ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) {
        final roleColor = _getRolePrimaryColor(dialogContext);
        return AlertDialog(
          backgroundColor: Theme.of(dialogContext).colorScheme.surface,
          title: Text(
            'Edit Profile',
            style: Theme.of(dialogContext).textTheme.headlineSmall,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person, color: roleColor),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Email (Cannot change)',
                    prefixIcon: Icon(Icons.email, color: roleColor),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone, color: roleColor),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    prefixIcon: Icon(Icons.location_on, color: roleColor),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Save updated profile
              if (user != null) {
                final updatedUser = user.copyWith(
                  name: nameController.text,
                  phone: phoneController.text,
                  address: locationController.text,
                );
                userProvider.updateUser(updatedUser);
              }
              Navigator.pop(dialogContext);
              _showPreferenceSnackbar('Profile updated successfully');
            },
            child: const Text('Save Changes'),
          ),
        ],
      );
      },
    );
  }

  // Change Password Dialog
  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final roleColor = _getRolePrimaryColor(dialogContext);
        return AlertDialog(
          backgroundColor: Theme.of(dialogContext).colorScheme.surface,
          title: Text(
            'Change Password',
            style: Theme.of(dialogContext).textTheme.headlineSmall,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: Icon(Icons.lock, color: roleColor),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: Icon(Icons.lock, color: roleColor),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: Icon(Icons.lock, color: roleColor),
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showPreferenceSnackbar('Password changed successfully');
            },
            child: const Text('Change Password'),
          ),
        ],
      );
      },
    );
  }

  // Payment Methods Dialog
  void _showPaymentMethodsDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(dialogContext).colorScheme.surface,
        title: Text(
          'Payment Methods',
          style: Theme.of(dialogContext).textTheme.headlineSmall,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPaymentMethodTile('Credit Card', '•••• •••• •••• 4242'),
              _buildPaymentMethodTile('Debit Card', '•••• •••• •••• 8888'),
              _buildPaymentMethodTile('Mobile Wallet', 'Bkash: 01XXXXXXXXX'),
              Divider(color: Theme.of(dialogContext).dividerColor),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(Icons.add_circle,
                    color: _getRolePrimaryColor(dialogContext)),
                title: const Text('Add Payment Method'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _showPreferenceSnackbar('Redirecting to payment setup');
                },
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // FAQ Dialog
  void _showFAQDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(dialogContext).colorScheme.surface,
        title: Text(
          'Frequently Asked Questions',
          style: Theme.of(dialogContext).textTheme.headlineSmall,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFAQItem(
                'How do I update my profile?',
                'Go to Settings > Edit Profile to update your information.',
              ),
              const SizedBox(height: 12),
              _buildFAQItem(
                'How do I change my password?',
                'Go to Settings > Security > Change Password to update your password.',
              ),
              const SizedBox(height: 12),
              _buildFAQItem(
                'How do I report an issue?',
                'Go to Help & Support > Report Issue to submit a problem report.',
              ),
              const SizedBox(height: 12),
              _buildFAQItem(
                'How do I contact support?',
                'Go to Help & Support > Contact Us to reach our support team.',
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Contact Dialog
  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(dialogContext).colorScheme.surface,
        title: Text(
          'Contact Support',
          style: Theme.of(dialogContext).textTheme.headlineSmall,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.email,
                    color: Theme.of(dialogContext).primaryColor),
                title: const Text('Email Support'),
                subtitle: const Text('support@agrolinkbd.com'),
                onTap: () => _launchEmail('support@agrolinkbd.com'),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(Icons.phone,
                    color: Theme.of(dialogContext).primaryColor),
                title: const Text('Phone Support'),
                subtitle: const Text('+880 17 XXXX XXXX'),
                onTap: () => _launchPhone('+8801700000000'),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(Icons.language,
                    color: Theme.of(dialogContext).primaryColor),
                title: const Text('Website'),
                subtitle: const Text('www.agrolinkbd.com'),
                onTap: () => _launchURL('https://www.agrolinkbd.com'),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Generate Activity Report for user's own profile
  Future<void> _generateUserActivityReport(UserModel? user) async {
    if (user == null) return;
    try {
      final pdfBytes = await UserReportService.fetchAndGenerateUserReport(
        userName: user.name,
        userId: user.id,
        userRole: user.userType.name,
        period: ReportPeriod.monthly,
      );

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text('${user.name} - Activity Report Preview')),
            body: PdfPreview(
              build: (format) => pdfBytes,
              canChangeOrientation: false,
              canChangePageFormat: false,
              allowPrinting: true,
              allowSharing: true,
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating report: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Dispute & Report Dialog against another user (Submits to Super Admin)
  void _showUserDisputeReportDialog(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে প্রথমে লগইন করুন!'), backgroundColor: Colors.red),
      );
      return;
    }

    final targetUserQueryController = TextEditingController();
    final targetNameController = TextEditingController();
    final orderRefController = TextEditingController();
    final descriptionController = TextEditingController();

    int selectedPenaltyType = 1;
    String selectedRole = 'farmer';

    final List<Map<String, dynamic>> penaltyCategories = [
      {
        'id': 1,
        'category': 'ভুয়া ওজন বা নিম্নমানের পণ্য (Quality Fraud)',
        'label': '🚫 ভুয়া ওজন বা নিম্নমানের পণ্য (Quality Fraud)',
        'desc': 'প্রদত্ত মাছ/পণ্যের ওজন কম, ভেজাল বা মানহীন ছিল',
      },
      {
        'id': 2,
        'category': 'অর্ডার বাতিল বা গ্রহণ না করা (Breach of Contract)',
        'label': '❌ কনফার্ম করার পর অর্ডার বাতিল বা প্রত্যাখ্যান',
        'desc': 'অর্ডার কনফার্ম করার পর কারণ ছাড়া বাতিল বা পণ্য নেয়নি',
      },
      {
        'id': 3,
        'category': 'পেমেন্ট বকেয়া বা প্রতারণা (Payment Default)',
        'label': '💸 পেমেন্ট বকেয়া বা লেনদেনে জালিয়াতি',
        'desc': 'বকেয়া টাকা দেয়নি বা চেক বাউন্স বা মিথ্যা পেমেন্ট দেখিয়েছে',
      },
      {
        'id': 4,
        'category': 'ডেলিভারি বিলম্ব বা নো-শো (Trip Failure)',
        'label': '⏰ নির্ধারিত সময়ে ট্রিপ ড্রপ বা নো-শো',
        'desc': 'ড্রাইভার উপস্থিত হয়নি বা মালামাল পরিবহন করেনি',
      },
      {
        'id': 5,
        'category': 'অসদাচরণ বা হুমকি (Harassment/Misbehavior)',
        'label': '⚠️ অসদাচরণ, হুমকি বা মিথ্যা তথ্য প্রদান',
        'desc': 'ফোনে বা সরাসরি দুর্ব্যবহার বা প্রতারণামূলক মিথ্যা তথ্য দিয়েছে',
      },
      {
        'id': 6,
        'category': 'অন্যান্য চুক্তিভঙ্গ (Other Policy Breach)',
        'label': '📑 অন্যান্য চুক্তিভঙ্গ বা গুরুতর অনিয়ম',
        'desc': 'প্ল্যাটফর্মের নীতিমালা ভঙ্গকারী অন্যান্য সমস্যা',
      },
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final selectedCategory = penaltyCategories.firstWhere(
            (c) => c['id'] == selectedPenaltyType,
            orElse: () => penaltyCategories.first,
          );

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.gavel_rounded, color: Colors.red, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    LanguageProvider.isBn(context) ? 'অভিযোগ ও রিপোর্ট দাখিল' : 'File User Dispute / Report',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                  ),
                ),
              ],
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade700, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.shield_outlined, color: Colors.amber.shade900, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              LanguageProvider.isBn(context)
                                  ? 'এই রিপোর্টটি সুপার অ্যাডমিনের কাছে যাবে। সুপার অ্যাডমিন প্রমাণ যাচাই করে অভিযুক্তের বিরুদ্ধে ব্যবস্থা নিবেন।'
                                  : 'This report will be submitted to Super Admin for verification and penalty enforcement.',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Target User Identifier (Phone / User ID)
                    Text(
                      LanguageProvider.isBn(context) ? 'অভিযুক্ত ব্যক্তির ফোন নম্বর বা ইউজার আইডি (বাধ্যতামূলক):' : 'Accused User Phone / User ID (Required):',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: targetUserQueryController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'যেমন: 017XXXXXXXX বা USR-901',
                        prefixIcon: const Icon(Icons.person_search_outlined, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Target User Name / Role
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LanguageProvider.isBn(context) ? 'অভিযুক্ত ব্যক্তির নাম:' : 'Accused Name:',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: targetNameController,
                                decoration: InputDecoration(
                                  hintText: 'নাম (জানা থাকলে)',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LanguageProvider.isBn(context) ? 'রোল:' : 'Role:',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value: selectedRole,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'farmer', child: Text('কৃষক', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: 'fishFarmer', child: Text('মাছ চাষী', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: 'buyer', child: Text('ক্রেতা', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: 'fishBuyer', child: Text('মাছ ক্রেতা', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: 'driver', child: Text('ড্রাইভার', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: 'serviceProvider', child: Text('সেবা প্রদানকারী', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: 'company', child: Text('কোম্পানি', style: TextStyle(fontSize: 12))),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => selectedRole = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Violation Category Selection
                    Text(
                      LanguageProvider.isBn(context) ? 'অভিযোগের সুনির্দিষ্ট কারণ (বাধ্যতামূলক):' : 'Specific Violation Reason (Required):',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    ...penaltyCategories.map((cat) {
                      return RadioListTile<int>(
                        title: Text(
                          cat['label'],
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          cat['desc'],
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        value: cat['id'] as int,
                        groupValue: selectedPenaltyType,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        dense: true,
                        onChanged: (val) {
                          if (val != null) setState(() => selectedPenaltyType = val);
                        },
                      );
                    }),
                    const SizedBox(height: 10),

                    // Order / Reference ID (Optional)
                    TextField(
                      controller: orderRefController,
                      decoration: InputDecoration(
                        labelText: LanguageProvider.isBn(context) ? 'অর্ডার / ট্রিপ / রেফারেন্স নম্বর (যদি থাকে)' : 'Order/Trip Reference ID (Optional)',
                        hintText: 'যেমন: ORD-8812 / TRP-104',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Detailed Description / Evidence
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: LanguageProvider.isBn(context) ? 'বিস্তারিত বিবরণ ও প্রমাণ (বাধ্যতামূলক)' : 'Detailed Description & Evidence (Required)',
                        hintText: 'ঘটনাটি কখন ঘটেছে এবং কী অনিয়ম হয়েছে বিস্তারিত লিখুন...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(LanguageProvider.isBn(context) ? 'বাতিল' : 'Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () async {
                  final targetInput = targetUserQueryController.text.trim();
                  final description = descriptionController.text.trim();

                  if (targetInput.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('অনুগ্রহ করে অভিযুক্ত ব্যক্তির ফোন বা আইডি দিন!'), backgroundColor: Colors.orange),
                    );
                    return;
                  }

                  // Check self-reporting
                  if (targetInput == currentUser.id || targetInput == currentUser.phone || targetInput == currentUser.email) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('⚠️ আপনি নিজের বিরুদ্ধে অভিযোগ বা জরিমানা রিপোর্ট করতে পারবেন না!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (description.isEmpty || description.length < 5) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('অনুগ্রহ করে বিস্তারিত বিবরণ লিখুন (কমপক্ষে ৫ অক্ষর)!'), backgroundColor: Colors.orange),
                    );
                    return;
                  }

                  Navigator.pop(dialogContext);

                  final success = await UserRatingService().submitUserDisputeReport(
                    targetUserId: targetInput,
                    targetUserName: targetNameController.text.trim().isNotEmpty ? targetNameController.text.trim() : targetInput,
                    targetUserRole: selectedRole,
                    targetUserPhone: targetInput,
                    reporterId: currentUser.id,
                    reporterName: currentUser.name,
                    reporterRole: currentUser.userType.name,
                    reporterPhone: currentUser.phone,
                    penaltyType: selectedPenaltyType,
                    category: selectedCategory['category'] ?? 'General Dispute',
                    reason: description,
                    orderReference: orderRefController.text.trim(),
                  );

                  if (success) {
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text('অভিযোগ দাখিল সফল'),
                            ],
                          ),
                          content: const Text(
                            'আপনার অভিযোগটি সফলভাবে সুপার অ্যাডমিনের পর্যালোচনায় জমা হয়েছে। সুপার অ্যাডমিন তথ্য যাচাই করে অভিযুক্ত ব্যক্তির বিরুদ্ধে ব্যবস্থা গ্রহণ করবেন।',
                            style: TextStyle(fontSize: 13),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('ঠিক আছে'),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('রিপোর্ট জমা দিতে সমস্যা হয়েছে। পুনরায় চেষ্টা করুন।'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                child: Text(LanguageProvider.isBn(context) ? 'সুপার অ্যাডমিনে পাঠান' : 'Submit to Super Admin'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Report Issue Dialog
  void _showReportDialog() {
    final reportController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(dialogContext).colorScheme.surface,
        title: Text(
          'Report an Issue',
          style: Theme.of(dialogContext).textTheme.headlineSmall,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Help us improve by reporting any issues you encounter.',
                style: Theme.of(dialogContext).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reportController,
                decoration: InputDecoration(
                  labelText: 'Describe the issue',
                  hintText: 'Tell us what problem you faced...',
                  prefixIcon: Icon(Icons.edit,
                      color: _getRolePrimaryColor(dialogContext)),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              reportController.dispose();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showPreferenceSnackbar(
                  'Issue reported successfully. Thank you!');
              reportController.dispose();
            },
            child: const Text('Submit Report'),
          ),
        ],
      ),
    );
  }

  // About App Dialog
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(dialogContext).colorScheme.surface,
        title: Text(
          'About AgroLinkBD',
          style: Theme.of(dialogContext).textTheme.headlineSmall,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.agriculture,
                size: 64,
                color: _getRolePrimaryColor(dialogContext),
              ),
              const SizedBox(height: 16),
              Text(
                'AgroLinkBD',
                style: Theme.of(dialogContext).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Version 1.0.0',
                style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(dialogContext).textTheme.bodySmall?.color,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Connecting farmers and buyers for better agricultural commerce in Bangladesh.',
                textAlign: TextAlign.center,
                style: Theme.of(dialogContext).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Divider(color: Theme.of(dialogContext).dividerColor),
              const SizedBox(height: 8),
              Text(
                'Contact Information',
                style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Email: info@agrolinkbd.com\nPhone: +880 XXXX XXXX XXX\nWebsite: www.agrolinkbd.com',
                textAlign: TextAlign.center,
                style: Theme.of(dialogContext).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Helper: Payment Method Tile
  Widget _buildPaymentMethodTile(String method, String detail) {
    final roleColor = _getRolePrimaryColor(context);
    return ListTile(
      leading: Icon(Icons.payment, color: roleColor),
      title: Text(method),
      subtitle: Text(detail),
      trailing: Icon(Icons.check_circle, color: roleColor),
    );
  }

  // Helper: FAQ Item
  Widget _buildFAQItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  // Helper: Show preference snackbar
  void _showPreferenceSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: _getRolePrimaryColor(context),
      ),
    );
  }

  // Helper: Launch URL
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      _showPreferenceSnackbar('Could not open link');
    }
  }

  // Helper: Launch Email
  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri(scheme: 'mailto', path: email);
    try {
      await launchUrl(uri);
    } catch (e) {
      _showPreferenceSnackbar('Could not open email');
    }
  }

  // Helper: Launch Phone
  Future<void> _launchPhone(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    try {
      await launchUrl(uri);
    } catch (e) {
      _showPreferenceSnackbar('Could not open phone dialer');
    }
  }
}
