import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'shared/auth_constants.dart';
import 'role_selection_screen.dart';

class DomainSelectionScreen extends StatelessWidget {
  const DomainSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(AuthConstants.padding24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                const SizedBox(height: 60),
                
                // Animated Logo
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 1000),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.agriculture,
                            size: 60,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Title
                const Text(
                  'স্বাগতম',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AuthConstants.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'AgroLinkBD',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),

                const Text(
                  'আপনার কাজের ক্ষেত্র নির্বাচন করুন',
                  style: TextStyle(
                    fontSize: 16,
                    color: AuthConstants.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),

                // Domain Selection Cards
                _buildDomainCard(
                  context: context,
                  title: 'কৃষি (Agriculture)',
                  subtitle: 'শস্য, সবজি, ফলমূল এবং অন্যান্য',
                  icon: '🌾',
                  color: Colors.green,
                  domain: 'agriculture',
                ),
                const SizedBox(height: 20),
                _buildDomainCard(
                  context: context,
                  title: 'মৎস্য (Fisheries)',
                  subtitle: 'মাছ চাষ, হ্যাচারি, মৎস্য ব্যবসা',
                  icon: '🐟',
                  color: Colors.blue,
                  domain: 'fisheries',
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildDomainCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String icon,
    required MaterialColor color,
    required String domain,
  }) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => RoleSelectionScreen(domain: domain),
          transition: Transition.rightToLeft,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.shade200, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.shade50,
                shape: BoxShape.circle,
              ),
              child: Text(
                icon,
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color.shade300,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
