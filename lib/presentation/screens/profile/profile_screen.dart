import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/presentation/screens/auth/login_screen.dart';
import 'package:agrolinkbd/presentation/screens/crops/crop_management_screen.dart';
import 'package:agrolinkbd/core/controllers/user_controller.dart';
import 'package:agrolinkbd/presentation/screens/marketplace/marketplace_screen.dart';
import 'package:agrolinkbd/presentation/screens/transport/transport_screen.dart';
import 'package:agrolinkbd/presentation/screens/wallet/wallet_screen.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'প্রোফাইল',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Get.snackbar(
                  'প্রোফাইল সম্পাদনা', 'প্রোফাইল সম্পাদনা শুরু হচ্ছে...');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade700, Colors.green.shade500],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => Text(
                        userController.userName.isEmpty
                            ? 'নতুন ইউজার'
                            : userController.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                  const SizedBox(height: 4),
                  Obx(() {
                    String roleText = '';
                    switch (userController.userRole) {
                      case UserRole.farmer:
                        roleText = 'কৃষক';
                        break;
                      case UserRole.buyer:
                        roleText = 'ক্রেতা/ব্যবসায়ী';
                        break;
                      case UserRole.expert:
                        roleText = 'বিশেষজ্ঞ';
                        break;
                      default:
                        roleText = 'ব্যবহারকারী';
                    }
                    String location = userController.userLocation.isEmpty
                        ? 'বগুড়া, বাংলাদেশ'
                        : userController.userLocation;
                    return Text(
                      '$roleText | $location',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                        userController.userPhone.isEmpty
                            ? '০১৭১२३४५६७८'
                            : userController.userPhone,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Stats Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                      child: _buildStatCard('১২', 'বিজ্ঞাপন', Icons.store)),
                  const SizedBox(width: 12),
                  Expanded(
                      child:
                          _buildStatCard('৮', 'অর্ডার', Icons.shopping_cart)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('৪.৮', 'রেটিং', Icons.star)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Menu Items
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildMenuItem(Icons.person_outline, 'ব্যক্তিগত তথ্য', () {}),
                  const Divider(height: 1),
                  _buildMenuItem(Icons.local_shipping, 'ট্রান্সপোর্ট', () {
                    Get.to(() => const TransportScreen());
                  }),
                  const Divider(height: 1),
                  _buildMenuItem(Icons.shopping_cart, 'কিনুন (Marketplace)', () {
                    Get.to(() => const MarketplaceScreen());
                  }),
                  const Divider(height: 1),
                  _buildMenuItem(Icons.receipt_long, 'আমার অর্ডার', () {
                    Get.snackbar('শীঘ্রই আসছে', 'অর্ডার ট্র্যাকিং শীঘ্রই যুক্ত করা হবে');
                  }),
                  const Divider(height: 1),
                  _buildMenuItem(Icons.account_balance_wallet, 'ওয়ালেট', () {
                    Get.to(() => const WalletScreen());
                  }),
                  const Divider(height: 1),
                  _buildMenuItem(Icons.show_chart, 'বাজার দর', () {
                    Get.snackbar('শীঘ্রই আসছে', 'বাজার দর শীঘ্রই যুক্ত করা হবে');
                  }),
                  const Divider(height: 1),
                  _buildMenuItem(Icons.agriculture, 'আমার ফসল', () {
                    Get.to(() => const CropManagementScreen());
                  }),
                  const Divider(height: 1),
                  _buildMenuItem(
                      Icons.shopping_bag_outlined, 'আমার বিজ্ঞাপন', () {}),
                  const Divider(height: 1),
                  _buildMenuItem(Icons.history, 'লেনদেন ইতিহাস', () {}),
                  const Divider(height: 1),
                  _buildMenuItem(
                      Icons.notifications_outlined, 'বিজ্ঞপ্তি', () {}),
                  const Divider(height: 1),
                  _buildMenuItem(Icons.language, 'ভাষা পরিবর্তন', () {}),
                  const Divider(height: 1),
                  _buildMenuItem(
                      Icons.help_outline, 'সাহায্য ও সহায়তা', () {}),
                  const Divider(height: 1),
                  _buildMenuItem(Icons.info_outline, 'অ্যাপ সম্পর্কে', () {}),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Logout Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  userController.logout();
                  Get.offAll(() => const LoginScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'লগ আউট',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.green.shade700, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.green.shade700),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
