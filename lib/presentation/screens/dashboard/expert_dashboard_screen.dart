import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/controllers/user_controller.dart';
import 'package:agrolinkbd/presentation/screens/disease/disease_detection_screen.dart';
import 'package:agrolinkbd/presentation/screens/profile/profile_screen.dart';
import 'package:agrolinkbd/presentation/screens/wallet/wallet_screen.dart';

class ExpertDashboardScreen extends StatelessWidget {
  const ExpertDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
        title: const Text(
          'বিশেষজ্ঞ ড্যাশবোর্ড',
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
            // Welcome Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade700, Colors.purple.shade500],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(
                        'স্বাগতম, ${userController.userName.isEmpty ? "বিশেষজ্ঞ" : userController.userName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                  const SizedBox(height: 8),
                  const Text(
                    'কৃষকদের সেবা প্রদান করুন',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Earnings Summary
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
                    'এই মাসের আয়',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Text(
                        '৪৫,০০০',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A1B9A),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'টাকা',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          '২৮',
                          'পরামর্শ দিয়েছেন',
                          Icons.support_agent,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          '৪.৮',
                          'রেটিং',
                          Icons.star,
                          Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Expert Specific Features
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'বিশেষজ্ঞ সেবা',
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
                        'পরামর্শ দিন',
                        Icons.support_agent,
                        Colors.green,
                        () {
                          Get.snackbar(
                            'শীঘ্রই আসছে',
                            'পরামর্শ সেবা শীঘ্রই যুক্ত করা হবে',
                          );
                        },
                      ),
                      _buildFeatureCard(
                        'রোগ বিশ্লেষণ',
                        Icons.health_and_safety,
                        Colors.red,
                        () => Get.to(() => const DiseaseDetectionScreen()),
                      ),
                      _buildFeatureCard(
                        'মাটি বিশ্লেষণ',
                        Icons.science,
                        Colors.blue,
                        () {
                          Get.snackbar(
                            'শীঘ্রই আসছে',
                            'মাটি পরীক্ষা শীঘ্রই যুক্ত করা হবে',
                          );
                        },
                      ),
                      _buildFeatureCard(
                        'প্রশিক্ষণ',
                        Icons.school,
                        Colors.orange,
                        () {
                          Get.snackbar(
                            'শীঘ্রই আসছে',
                            'প্রশিক্ষণ পরিচালনা শীঘ্রই যুক্ত করা হবে',
                          );
                        },
                      ),
                      _buildFeatureCard(
                        'আয় বিবরণী',
                        Icons.account_balance_wallet,
                        Colors.teal,
                        () => Get.to(() => const WalletScreen()),
                      ),
                      _buildFeatureCard(
                        'আমার সেবা',
                        Icons.work,
                        Colors.purple,
                        () {
                          Get.snackbar(
                            'শীঘ্রই আসছে',
                            'সেবা পরিচালনা শীঘ্রই যুক্ত করা হবে',
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Pending Consultations
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'নতুন অনুরোধ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '৫',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'কৃষকদের থেকে ৫টি নতুন পরামর্শ অনুরোধ রয়েছে',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Get.snackbar(
                        'শীঘ্রই আসছে',
                        'অনুরোধ পরিচালনা শীঘ্রই যুক্ত করা হবে',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A),
                    ),
                    child: const Text('অনুরোধ দেখুন'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _buildExpertBottomNav(),
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
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF6A1B9A),
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'হোম',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.support_agent),
          label: 'পরামর্শ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: 'প্রশিক্ষণ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'আয়',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 1:
            Get.snackbar('শীঘ্রই আসছে', 'পরামর্শ সেবা শীঘ্রই যুক্ত করা হবে');
            break;
          case 2:
            Get.snackbar('শীঘ্রই আসছে', 'প্রশিক্ষণ শীঘ্রই যুক্ত করা হবে');
            break;
          case 3:
            Get.to(() => const WalletScreen());
            break;
        }
      },
    );
  }
}
