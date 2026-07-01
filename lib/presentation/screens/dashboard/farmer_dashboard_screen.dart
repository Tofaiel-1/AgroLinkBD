import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/controllers/user_controller.dart';
import 'package:agrolinkbd/presentation/screens/crops/crop_management_screen.dart';
import 'package:agrolinkbd/presentation/screens/marketplace/marketplace_screen.dart';
import 'package:agrolinkbd/presentation/screens/transport/transport_screen.dart';
import 'package:agrolinkbd/presentation/screens/disease/disease_detection_screen.dart';
import 'package:agrolinkbd/presentation/screens/ai/ai_assistant_screen.dart';
import 'package:agrolinkbd/presentation/screens/profile/profile_screen.dart';
import 'package:agrolinkbd/presentation/widgets/secure_balance_widget.dart';
import 'package:agrolinkbd/presentation/widgets/global_announcement_banner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agrolinkbd/core/services/card_service.dart';
import 'package:agrolinkbd/presentation/screens/card/card_preview_screen.dart' as agrolinkbd;

class FarmerDashboardScreen extends StatelessWidget {
  const FarmerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        title: const Text(
          'Farmer Dashboard',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Get.to(() => const ProfileScreen()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Banner with Profile and Balance
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade700, Colors.green.shade500],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Side: Profile Image, Name, and Role
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Get.to(() => const agrolinkbd.CardPreviewScreen());
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white,
                              child: Obx(() => Text(
                                userController.userName.isEmpty ? 'F' : userController.userName.value[0].toUpperCase(),
                                style: TextStyle(color: Colors.green.shade700, fontSize: 20, fontWeight: FontWeight.bold),
                              )),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(() => Text(
                                    userController.userName.isEmpty ? "Farmer" : userController.userName.value,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'কৃষক (Farmer)',
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Right Side: Main Balance
                  if (FirebaseAuth.instance.currentUser != null)
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
                      builder: (context, snapshot) {
                        double balance = 0.0;
                        String? mainBalancePin;
                        if (snapshot.hasData && snapshot.data!.data() != null) {
                          final data = snapshot.data!.data() as Map<String, dynamic>;
                          balance = (data['mainBalance'] ?? 0.0).toDouble();
                          mainBalancePin = data['mainBalancePin'];
                        }
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.account_balance_wallet, color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              SecureBalanceWidget(
                                balance: balance,
                                pin: mainBalancePin,
                                pinFieldType: 'mainBalance',
                                textColor: Colors.green.shade700,
                                fontSize: 14.0,
                                label: 'Tap for Balance',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),

            // My Farm Summary Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'আমার খামার',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          '৫',
                          'চলমান ফসল',
                          Icons.grass,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          '১২',
                          'বিক্রিত পণ্য',
                          Icons.shopping_bag,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Farmer Specific Features
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Farmer Services',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildFeatureCard(
                        'আমার ফসল',
                        Icons.agriculture,
                        Colors.green,
                        () => Get.to(() => const CropManagementScreen()),
                      ),
                      _buildFeatureCard(
                        'পণ্য বিক্রয়',
                        Icons.store,
                        Colors.orange,
                        () => Get.to(() => const MarketplaceScreen()),
                      ),
                      _buildFeatureCard(
                        'রোগ নির্ণয়',
                        Icons.camera_alt,
                        Colors.red,
                        () => Get.to(() => const DiseaseDetectionScreen()),
                      ),
                      _buildFeatureCard(
                        'পরিবহন সেবা',
                        Icons.local_shipping,
                        Colors.blue,
                        () => Get.to(() => const TransportScreen()),
                      ),
                      _buildFeatureCard(
                        'AI সহায়ক',
                        Icons.smart_toy,
                        Colors.purple,
                        () => Get.to(() => const AIAssistantScreen()),
                      ),
                      _buildFeatureCard(
                        'আমার ওয়ালেট',
                        Icons.account_balance_wallet,
                        Colors.teal,
                        () => Get.to(() => const WalletScreen()),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Weather Widget
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.wb_sunny, size: 50, color: Colors.white),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'আজকের আবহাওয়া',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '৩২°C',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'রোদ ও মেঘলা',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _buildFarmerBottomNav(),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmerBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF2E7D32),
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'হোম',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.agriculture),
          label: 'ফসল',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: 'বিক্রয়',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'ওয়ালেট',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 1:
            Get.to(() => const CropManagementScreen());
            break;
          case 2:
            Get.to(() => const MarketplaceScreen());
            break;
          case 3:
            Get.to(() => const WalletScreen());
            break;
        }
      },
    );
  }
}
