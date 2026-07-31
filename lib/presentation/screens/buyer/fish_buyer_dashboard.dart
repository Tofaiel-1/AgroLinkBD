import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/presentation/widgets/premium_dashboard_widgets.dart';
import 'package:agrolinkbd/presentation/screens/marketplace/fish_marketplace_screen.dart';
import 'package:agrolinkbd/presentation/screens/buyer/shopping_cart_screen.dart';
import 'package:agrolinkbd/presentation/screens/buyer/fish_buyer_orders_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Fish Buyer Dashboard - Ultra Pro Edition
/// Special dashboard for buyers looking specifically for fish with smart features.
class FishBuyerDashboard extends StatefulWidget {
  const FishBuyerDashboard({super.key});

  @override
  State<FishBuyerDashboard> createState() => _FishBuyerDashboardState();
}

class _FishBuyerDashboardState extends State<FishBuyerDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ============================================
            // HEADER - Fish Buyer Greeting (Glassmorphism)
            // ============================================
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF0277BD),
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Dynamic background gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [const Color(0xFF0D47A1), const Color(0xFF01579B)]
                              : [const Color(0xFF0277BD), const Color(0xFF4FC3F7)],
                        ),
                      ),
                    ),
                    // Decorative circles
                    Positioned(
                      right: -50,
                      top: -50,
                      child: CircleAvatar(
                        radius: 100,
                        backgroundColor: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    // Glassmorphism Content
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'স্বাগতম, মৎস্য ক্রেতা! 🐟',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'আপনার জন্য তাজা মাছের সমাহার',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Quick Action Button
                            InkWell(
                              onTap: () {
                                Get.to(() => const FishMarketplaceScreen());
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.search, color: Colors.white, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'মাছের বাজার দেখুন...',
                                          style: GoogleFonts.hindSiliguri(
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ============================================
            // BODY CONTENT
            // ============================================
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weather / Harvest Alert Banner
                    _buildAlertBanner(isDark),
                    const SizedBox(height: 24),

                    // Stats Grid
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        PremiumStatCard(
                          icon: Icons.local_shipping,
                          color: const Color(0xFF0277BD),
                          label: 'সক্রিয় অর্ডার',
                          value: '২',
                          subtitle: 'আজ ডেলিভারি',
                          onTap: () => Get.to(() => const FishBuyerOrdersScreen()),
                        ),
                        PremiumStatCard(
                          icon: Icons.shopping_cart,
                          color: const Color(0xFF00695C),
                          label: 'কার্ট',
                          value: '৩',
                          subtitle: 'আইটেম',
                          onTap: () => Get.to(() => const ShoppingCartScreen()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Live Market Trends
                    _buildSectionHeader('লাইভ মার্কেট ট্রেন্ড', isDark),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 80,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildTrendCard('ইলিশ', '৳১২০০', '+৫%', true, isDark),
                          _buildTrendCard('রুই', '৳৩৫০', '-২%', false, isDark),
                          _buildTrendCard('চিংড়ি', '৳৮০০', '+১%', true, isDark),
                          _buildTrendCard('কাতলা', '৳৪০০', '০%', true, isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // AI Smart Recommendations
                    _buildSectionHeader('আপনার জন্য প্রস্তাবিত (AI)', isDark, icon: Icons.auto_awesome),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 140,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildAICategoryCard('দেশি রুই (তাজা)', 'খামার থেকে সরাসরি', Icons.set_meal, isDark),
                          _buildAICategoryCard('পদ্মার ইলিশ', 'প্রিমিয়াম কোয়ালিটি', Icons.water, isDark),
                          _buildAICategoryCard('গলদা চিংড়ি', 'বড় সাইজ', Icons.waves, isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: const Color(0xFFFBC02D), size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: GoogleFonts.hindSiliguri(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF34495E) : const Color(0xFFBBDEFB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'আবহাওয়া আপডেট',
                  style: GoogleFonts.hindSiliguri(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  'আগামীকাল বৃষ্টির সম্ভাবনা রয়েছে। সামুদ্রিক মাছের সরবরাহ কমতে পারে।',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(String name, String price, String change, bool isUp, bool isDark) {
    final color = isUp ? Colors.green : Colors.red;
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: GoogleFonts.hindSiliguri(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 13,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
              Row(
                children: [
                  Icon(isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: color, size: 16),
                  Text(
                    change,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAICategoryCard(String name, String subtitle, IconData icon, bool isDark) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0277BD).withOpacity(isDark ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF0277BD), size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: GoogleFonts.hindSiliguri(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: GoogleFonts.hindSiliguri(
              fontSize: 11,
              color: const Color(0xFF0277BD),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
