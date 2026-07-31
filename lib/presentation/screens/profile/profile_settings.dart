import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/models/user_model.dart';
import 'package:agrolinkbd/core/services/user_rating_service.dart';
import 'package:url_launcher/url_launcher.dart';

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
                      '${user?.totalOrders ?? 0} বার',
                      'মোট লেনদেন',
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
                      'পরিশোধিত',
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
                      'ট্রাস্ট স্কোর',
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
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'Settings',
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
                    'Dark Mode',
                    'Enable dark theme',
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
                    'Notifications',
                    'Get push notifications',
                    Icons.notifications,
                    _notifications,
                    (value) {
                      setState(() => _notifications = value);
                      _savePreference('notifications', value);
                      _showPreferenceSnackbar(
                          'Notifications ${value ? 'enabled' : 'disabled'}');
                    },
                    context,
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    'Location Services',
                    'Share your location',
                    Icons.location_on,
                    _locationServices,
                    (value) {
                      setState(() => _locationServices = value);
                      _savePreference('locationServices', value);
                      _showPreferenceSnackbar(
                          'Location ${value ? 'enabled' : 'disabled'}');
                    },
                    context,
                  ),
                ],
              ),
            ),
          ),

          // Account Section
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Account',
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
                    'Edit Profile',
                    'Update Your Information',
                    Icons.edit,
                    _showEditProfileDialog,
                    context,
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    'Language',
                    _language,
                    Icons.language,
                    _showLanguageDialog,
                    context,
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    'Security',
                    'Password and privacy',
                    Icons.security,
                    _showChangePasswordDialog,
                    context,
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    'Payment Methods',
                    'Your payment options',
                    Icons.payment,
                    _showPaymentMethodsDialog,
                    context,
                  ),
                ],
              ),
            ),
          ),

          // Help & Support
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Help & Support',
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
                    'Help Center',
                    'FAQ and guides',
                    Icons.help_outline,
                    _showFAQDialog,
                    context,
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    'Contact Us',
                    'Get direct support',
                    Icons.contact_support,
                    _showContactDialog,
                    context,
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    'Report Issue',
                    'Report a problem',
                    Icons.report_problem,
                    _showReportDialog,
                    context,
                  ),
                  const Divider(height: 1),
                  _buildMenuTile(
                    'About App',
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(
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
          color: primaryColor.withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.08),
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
                  primaryColor.withOpacity(0.18),
                  primaryColor.withOpacity(0.05),
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
                        '${trustScore.toStringAsFixed(0)}% সর্বজনীন বিশ্বস্ততা ও ট্রাস্ট স্কোর',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        trustScore >= 95
                            ? '💎 প্ল্যাটিনাম বিশ্বস্ত সদস্য • ১০০% নিরাপদ লেনদেন'
                            : (trustScore >= 85
                                ? '🥇 গোল্ড বিশ্বস্ত সদস্য • প্রমাণিত ও নিরাপদ'
                                : (trustScore >= 70
                                    ? '🥈 সিলভার সদস্য • নির্ভরযোগ্য'
                                    : '🥉 ব্রোঞ্জ সদস্য • প্রাথমিক পর্যায়')),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (trustScore >= 85 ? Colors.green : Colors.blue)
                        .withOpacity(0.15),
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

          // Root Rating & Clean Verified Summary (কোনো হাবিজাবি তথ্য ছাড়া ১টি রুট রেটিং ও ৩টি ব্যাজ)
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
                      Column(
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
                          Text(
                            totalRatings == 0
                                ? '৫.০ / ৫.০ ⭐️ (১০০% বিশ্বস্ততা)'
                                : '${rating.toStringAsFixed(1)} / 5.0 ⭐️ (${trustScore.toStringAsFixed(0)}% বিশ্বস্ততা)',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
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

                // 3 Clean Verified Summary Chips/Pills (habijabi information user er kase thakbe na)
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

                // Universal 360° Interactive Action Buttons (sobai sobar theke rating pabe & fraud report)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          UserRatingService.showUniversalRateModal(
                            context: context,
                            targetUserId: user?.id ?? 'demo_id',
                            targetUserName: user?.name ?? 'সদস্য',
                            reviewerId: 'current_user_id',
                            reviewerName: 'সক্রিয় সদস্য',
                            onRatingSubmitted: () {
                              setState(() {});
                              if (user?.id != null) {
                                Provider.of<UserProvider>(context, listen: false)
                                    .loadUser(user!.id);
                              }
                            },
                          );
                        },
                        icon: const Icon(Icons.star, size: 18),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('মূল্যায়ন করুন'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          UserRatingService.showFraudPenaltyDialog(
                            context: context,
                            targetUserId: user?.id ?? 'demo_id',
                            targetUserName: user?.name ?? 'সদস্য',
                            reporterId: 'current_user_id',
                            reporterName: 'সক্রিয় সদস্য',
                            onPenaltySubmitted: () {
                              setState(() {});
                              if (user?.id != null) {
                                Provider.of<UserProvider>(context, listen: false)
                                    .loadUser(user!.id);
                              }
                            },
                          );
                        },
                        icon: const Icon(Icons.gavel, size: 18),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('রিপোর্ট / জরিমানা'),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/buyer-orders');
                        },
                        icon: const Icon(Icons.history, size: 18),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('লেনদেনের ইতিহাস'),
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
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('পেমেন্ট রিপোর্ট'),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(color: primaryColor),
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

  Widget _buildActivityDetailRow(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    Color iconColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
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
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(dialogContext).colorScheme.surface,
        title: Text(
          'Select Language',
          style: Theme.of(dialogContext).textTheme.headlineSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('বাংলা'),
              value: 'বাংলা',
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(dialogContext);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
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
          'Logout',
          style: Theme.of(dialogContext).textTheme.headlineSmall,
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: Theme.of(dialogContext).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
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
            child: const Text('Logout'),
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
