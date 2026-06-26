import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/presentation/widgets/premium_dashboard_widgets.dart';
import 'package:agrolinkbd/presentation/screens/company/providers/company_provider.dart';
import 'package:agrolinkbd/presentation/screens/microfinance/microfinance_kyc_screen.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/presentation/widgets/report_generation_card.dart';
import 'package:get/get.dart';

/// Company Role Dashboard
/// Displays business overview, active contracts, pending orders, budget stats
class CompanyDashboard extends StatefulWidget {
  const CompanyDashboard({super.key});

  @override
  State<CompanyDashboard> createState() => _CompanyDashboardState();
}

class _CompanyDashboardState extends State<CompanyDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    return Consumer<CompanyProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                // ============================================
                // HEADER
                // ============================================
                SliverAppBar(
                  backgroundColor: const Color(0xFF4169E1),
                  elevation: 0,
                  floating: true,
                  snap: true,
                  expandedHeight: 200,
                  leading: IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF4169E1), Color(0xFF315AC1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.business,
                            size: 40,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ব্যবসায়িক ড্যাশবোর্ড',
                            style: GoogleFonts.openSans(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'আপনার ব্যবসার সারসংক্ষেপ',
                            style: GoogleFonts.openSans(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),

                // ============================================
                // STATS CARDS
                // ============================================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            PremiumStatCard(
                              icon: Icons.handshake_outlined,
                              color: const Color(0xFF1976D2),
                              label: 'সক্রিয় চুক্তি',
                              value: '${provider.activeContractsCount}',
                              subtitle: 'কৃষকদের সাথে',
                            ),
                            PremiumStatCard(
                              icon: Icons.shopping_bag_outlined,
                              color: const Color(0xFFE65100),
                              label: 'অপেক্ষমাণ অর্ডার',
                              value: '${provider.pendingOrdersCount}',
                              subtitle: 'ডেলিভারির অপেক্ষায়',
                            ),
                            PremiumStatCard(
                              icon: Icons.trending_up,
                              color: const Color(0xFF388E3C),
                              label: 'বাজেট ব্যবহৃত',
                              value: '৳ ${(provider.usedBudget / 100000).toStringAsFixed(2)} লাখ',
                              subtitle: 'মোট ${(provider.totalBudget / 100000).toStringAsFixed(0)} লাখ',
                            ),
                            PremiumStatCard(
                              icon: Icons.calendar_month,
                              color: const Color(0xFF7B1FA2),
                              label: 'মাসিক অর্ডার',
                              value: '${provider.monthlyOrdersCount}',
                              subtitle: 'এই মাসে',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        PremiumSectionTitle(
                          title: 'সাপ্লাই চেইন লেনদেন',
                          onSeeAll: () {},
                        ),
                        ...provider.transactions.take(3).map((t) => PremiumTransactionCard(
                          title: t.title,
                          date: t.date,
                          amount: t.amount,
                          isCredit: t.isCredit,
                          status: t.status,
                        )).toList(),
                      ],
                    ),
                  ),
                ),

            // ============================================
            // QUICK ACTIONS
            // ============================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'দ্রুত ক্রিয়া',
                      style: GoogleFonts.openSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionButton(
                            icon: Icons.add_shopping_cart,
                            label: 'নতুন অর্ডার',
                            onTap: () {
                              // Create new order
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionButton(
                            icon: Icons.assignment,
                            label: 'চুক্তি তৈরি করুন',
                            onTap: () {
                              // Create new contract
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionButton(
                            icon: Icons.bar_chart,
                            label: 'রিপোর্ট দেখুন',
                            onTap: () {
                              // View reports
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionButton(
                            icon: Icons.people,
                            label: 'দল পরিচালনা করুন',
                            onTap: () {
                              // Manage team
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionButton(
                            icon: Icons.account_balance_rounded,
                            label: 'মাইক্রোফাইন্যান্স (ঋণ)',
                            onTap: () {
                              final userProvider = Provider.of<UserProvider>(context, listen: false);
                              Get.to(() => MicrofinanceKycScreen(userRole: 'company', loanType: 'Corporate Finance'));
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ============================================
            // ACTIVITY REPORT
            // ============================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    return ReportGenerationCard(
                      userName: userProvider.currentUser?.name ?? 'কোম্পানি',
                      userId: userProvider.currentUser?.uid ?? 'company_demo',
                      userRole: 'company',
                      amount1Label: 'Total Procurement',
                      amount2Label: 'Operating Cost',
                      color: const Color(0xFF4169E1), // Royal Blue for company
                    );
                  }
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ============================================
            // RECENT ACTIVITIES
            // ============================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'সাম্প্রতিক কার্যকলাপ',
                      style: GoogleFonts.openSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActivityItem(
                      title: 'নতুন অর্ডার নিশ্চিত করা হয়েছে',
                      subtitle: 'Order #2024-1234 - রহিম ফার্ম',
                      timestamp: '২ ঘন্টা আগে',
                      icon: Icons.check_circle,
                    ),
                    _buildActivityItem(
                      title: 'চুক্তি আপডেট হয়েছে',
                      subtitle: 'চুক্তি #CF-2024-001 সম্পন্ন হয়েছে',
                      timestamp: '৫ ঘন্টা আগে',
                      icon: Icons.update,
                    ),
                    _buildActivityItem(
                      title: 'ডেলিভারি সম্পন্ন',
                      subtitle:
                          'ড্রাইভার আহমেদ দ্বারা ৩০টি অর্ডার ডেলিভার করা হয়েছে',
                      timestamp: '১ দিন আগে',
                      icon: Icons.local_shipping,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom spacing
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).padding.bottom + 20,
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  // ============================================
  // HELPER WIDGETS
  // ============================================

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.openSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF999999),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.openSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.openSans(
                      fontSize: 11,
                      color: const Color(0xFFBBBBBB),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF4169E1).withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFF4169E1),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required String timestamp,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4169E1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF4169E1),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.openSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.openSans(
                      fontSize: 12,
                      color: const Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              timestamp,
              style: GoogleFonts.openSans(
                fontSize: 10,
                color: const Color(0xFFCCCCCC),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
