import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/core/controllers/user_controller.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/presentation/screens/transport/transport_screen.dart';
import 'package:agrolinkbd/presentation/screens/wallet/wallet_screen.dart';
import 'package:agrolinkbd/presentation/screens/buyer/saved_farmers_screen.dart';

/// Buyer Profile Screen — completely separate from Farmer profile
class BuyerProfileScreen extends StatelessWidget {
  const BuyerProfileScreen({super.key});

  static const Color _primaryBlue = Color(0xFF1976D2);
  static const Color _darkBlue = Color(0xFF0D47A1);

  @override
  Widget build(BuildContext context) {
    final userController = Get.isRegistered<UserController>()
        ? Get.find<UserController>()
        : Get.put(UserController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Profile Header
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 24,
                right: 24,
                bottom: 32,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_darkBlue, _primaryBlue],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'আমার প্রোফাইল',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.white70),
                        onPressed: () {
                          Get.snackbar('সম্পাদনা', 'প্রোফাইল সম্পাদনা শীঘ্রই আসছে',
                            backgroundColor: Colors.blue.shade100,
                            colorText: Colors.blue.shade900,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Avatar + Info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white38, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: const Icon(Icons.person, size: 42, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userController.userName.isEmpty
                                  ? 'ক্রেতা'
                                  : userController.userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.verified, size: 14, color: Colors.greenAccent),
                                const SizedBox(width: 4),
                                Text(
                                  'ক্রেতা / ব্যবসায়ী',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userController.userPhone.isEmpty
                                  ? 'ফোন যোগ করুন'
                                  : userController.userPhone,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Stats row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ProfileStat(value: '১৫', label: 'অর্ডার'),
                        _ProfileStatDivider(),
                        _ProfileStat(value: '৳১২,৫০০', label: 'মোট খরচ'),
                        _ProfileStatDivider(),
                        _ProfileStat(value: '৪.৮', label: 'রেটিং'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu sections
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'সেবা সমূহ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.grey.shade800,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark ? [] : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.local_shipping_outlined,
                    iconColor: Colors.orange,
                    title: 'ট্রান্সপোর্ট / পরিবহন',
                    subtitle: 'পণ্য ডেলিভারি সেবা',
                    onTap: () => Get.to(() => const TransportScreen()),
                  ),
                  _buildDivider(isDark),
                  _buildMenuItem(
                    context,
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: Colors.teal,
                    title: 'ওয়ালেট',
                    subtitle: 'ব্যালেন্স ও লেনদেন',
                    onTap: () => Get.to(() => const WalletScreen()),
                  ),
                  _buildDivider(isDark),
                  _buildMenuItem(
                    context,
                    icon: Icons.favorite_border,
                    iconColor: Colors.red,
                    title: 'সংরক্ষিত কৃষক',
                    subtitle: 'প্রিয় কৃষকদের তালিকা',
                    onTap: () => Get.to(() => const SavedFarmersScreen()),
                  ),
                  _buildDivider(isDark),
                  _buildMenuItem(
                    context,
                    icon: Icons.show_chart,
                    iconColor: Colors.green,
                    title: 'বাজার দর',
                    subtitle: 'আজকের বাজার মূল্য',
                    onTap: () {
                      Get.snackbar('শীঘ্রই আসছে', 'বাজার দর শীঘ্রই যুক্ত করা হবে');
                    },
                  ),
                ],
              ),
            ),
          ),

          // Account section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'অ্যাকাউন্ট',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.grey.shade800,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark ? [] : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.person_outline,
                    iconColor: _primaryBlue,
                    title: 'ব্যক্তিগত তথ্য',
                    subtitle: 'নাম, ঠিকানা, ফোন পরিবর্তন',
                    onTap: () {
                      Get.snackbar('শীঘ্রই আসছে', 'প্রোফাইল সম্পাদনা শীঘ্রই যুক্ত করা হবে');
                    },
                  ),
                  _buildDivider(isDark),
                  _buildMenuItem(
                    context,
                    icon: Icons.notifications_none,
                    iconColor: Colors.amber,
                    title: 'বিজ্ঞপ্তি সেটিংস',
                    subtitle: 'নোটিফিকেশন কাস্টমাইজ করুন',
                    onTap: () {
                      Get.snackbar('শীঘ্রই আসছে', 'বিজ্ঞপ্তি সেটিংস শীঘ্রই যুক্ত করা হবে');
                    },
                  ),
                  _buildDivider(isDark),
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline,
                    iconColor: Colors.indigo,
                    title: 'সাহায্য ও সহায়তা',
                    subtitle: 'হেল্পলাইন: ১৬১২৩',
                    onTap: () {
                      Get.snackbar('সাহায্য', 'হেল্পলাইন: ১৬১২৩');
                    },
                  ),
                  _buildDivider(isDark),
                  _buildMenuItem(
                    context,
                    icon: Icons.info_outline,
                    iconColor: Colors.blueGrey,
                    title: 'অ্যাপ সম্পর্কে',
                    subtitle: 'ভার্সন ১.০.০',
                    onTap: () {
                      Get.snackbar('AgroLinkBD', 'ভার্সন ১.০.০ — কৃষি বাজার প্ল্যাটফর্ম');
                    },
                  ),
                ],
              ),
            ),
          ),

          // Logout button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.red.shade900 : Colors.red.shade50,
                    foregroundColor: Colors.red.shade700,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                  ),
                  icon: Icon(Icons.logout, color: Colors.red.shade700),
                  label: Text(
                    'লগ আউট',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.white30 : Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 62,
      color: isDark ? Colors.white12 : Colors.grey.shade100,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('লগ আউট', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('আপনি কি নিশ্চিত যে আপনি লগ আউট করতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('বাতিল', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                await userProvider.signOut();
              } catch (e) {
                Get.snackbar('Error', 'লগ আউট করতে সমস্যা হয়েছে: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('লগ আউট', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// Helper widgets
class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ProfileStatDivider extends StatelessWidget {
  const _ProfileStatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white.withOpacity(0.2),
    );
  }
}
