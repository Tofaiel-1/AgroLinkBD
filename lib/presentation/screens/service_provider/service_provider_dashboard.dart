import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/providers/service_provider_providers.dart';
import 'package:agrolinkbd/core/models/service_provider_models.dart';
import 'package:agrolinkbd/presentation/screens/service_provider/manage_services_screen.dart';
import 'package:agrolinkbd/presentation/screens/service_provider/portfolio_gallery_screen.dart';
import 'package:agrolinkbd/presentation/screens/service_provider/service_provider_products_screen.dart';
import 'package:agrolinkbd/presentation/screens/service_provider/add_service_product_screen.dart';
import 'package:agrolinkbd/presentation/screens/service_provider/service_provider_earnings_screen.dart';
import 'package:agrolinkbd/presentation/screens/service_provider/premium_features/booking_calendar_screen.dart';
import 'package:agrolinkbd/presentation/screens/service_provider/premium_features/ai_assistant_screen.dart';
import 'package:agrolinkbd/presentation/screens/service_provider/premium_features/client_crm_screen.dart';
import 'package:agrolinkbd/presentation/screens/service_provider/premium_features/tele_consultation_prescription_screen.dart';
import 'package:agrolinkbd/presentation/screens/service_provider/premium_features/service_provider_lead_engine_screen.dart';
import 'package:agrolinkbd/presentation/screens/subscription/vip_subscription_paywall_screen.dart';
import 'package:agrolinkbd/presentation/screens/profile/profile_settings.dart';
import 'package:agrolinkbd/presentation/screens/card/card_preview_screen.dart' as agrolinkbd;

class ServiceProviderDashboard extends ConsumerStatefulWidget {
  const ServiceProviderDashboard({super.key});

  @override
  ConsumerState<ServiceProviderDashboard> createState() => _ServiceProviderDashboardState();
}

class _ServiceProviderDashboardState extends ConsumerState<ServiceProviderDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

  void _showLogoutDialog(BuildContext context, bool isBn) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isBn ? 'লগ আউট' : 'Logout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isBn ? 'আপনি কি নিশ্চিত যে আপনি লগ আউট করতে চান?' : 'Are you sure you want to log out?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              isBn ? 'না' : 'No',
              style: GoogleFonts.poppins(color: Colors.grey.shade700),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Get.offAllNamed('/auth/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              isBn ? 'হ্যাঁ' : 'Yes',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBn = LanguageProvider.isBn(context);
    final allProducts = ref.watch(serviceProductProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ============================================
            // COMPACT HEADER (No wallet/stats cards)
            // ============================================
            SliverAppBar(
              expandedHeight: 85,
              pinned: true,
              stretch: false,
              backgroundColor: const Color(0xFF2B32B2),
              elevation: 0,
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.settings_rounded, color: Colors.white, size: 18),
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    onPressed: () => Get.to(() => const ProfileSettings()),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'logout') _showLogoutDialog(context, isBn);
                      if (value == 'card') Get.to(() => const agrolinkbd.CardPreviewScreen());
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'card',
                        child: Row(
                          children: [
                            const Icon(Icons.credit_card_rounded, size: 18, color: Color(0xFF2B32B2)),
                            const SizedBox(width: 10),
                            Text(isBn ? 'ডিজিটাল কার্ড' : 'Digital ID Card',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            const Icon(Icons.logout, size: 18, color: Colors.redAccent),
                            const SizedBox(width: 10),
                            Text(isBn ? 'লগ আউট' : 'Logout',
                                style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(Icons.more_vert, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2B32B2),
                        Color(0xFF1488CC),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => Get.to(() => const agrolinkbd.CardPreviewScreen()),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                image: const DecorationImage(
                                  image: NetworkImage(
                                      'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788535890/photo_2026-09-04_21-31-17_mb01h0.jpg'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isBn ? 'স্বাগতম, সেবা প্রদানকারী' : 'Welcome, Service Provider',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                            color: Colors.greenAccent, shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isBn ? 'অনলাইনে আছেন' : 'Online',
                                        style: GoogleFonts.poppins(
                                            fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                                      ),
                                    ],
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
              ),
            ),

            // ============================================
            // COMPACT INCOME ANALYSIS (Small in Size)
            // ============================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2B32B2).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.analytics_rounded, size: 14, color: Color(0xFF2B32B2)),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isBn ? 'আয় বিশ্লেষণ' : 'Income Analysis',
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Get.to(() => const ServiceProviderEarningsScreen()),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF2B32B2).withValues(alpha: 0.2)),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4)
                              ],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  isBn ? 'গত ৭ দিন' : 'Last 7 Days',
                                  style: GoogleFonts.poppins(
                                      fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF2B32B2)),
                                ),
                                const SizedBox(width: 3),
                                const Icon(Icons.arrow_forward_ios_rounded, size: 9, color: Color(0xFF2B32B2)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Small size chart container
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2B32B2).withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isBn ? 'সর্বমোট আয়' : 'Total Revenue',
                                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    isBn ? '৳ ২৬,৭৫০' : '৳ 26,750',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.trending_up_rounded, size: 12, color: Colors.green),
                                    const SizedBox(width: 2),
                                    Text(
                                      isBn ? '+১৮.৫%' : '+18.5%',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Compact Sparkline
                          SizedBox(
                            height: 44,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 2000,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey.shade100,
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                titlesData: const FlTitlesData(
                                  show: false,
                                ),
                                borderData: FlBorderData(show: false),
                                minX: 0,
                                maxX: 6,
                                minY: 0,
                                maxY: 6000,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: const [
                                      FlSpot(0, 2000),
                                      FlSpot(1, 3500),
                                      FlSpot(2, 2800),
                                      FlSpot(3, 4800),
                                      FlSpot(4, 3900),
                                      FlSpot(5, 5500),
                                      FlSpot(6, 4200),
                                    ],
                                    isCurved: true,
                                    curveSmoothness: 0.35,
                                    color: const Color(0xFF2B32B2),
                                    barWidth: 2.5,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter: (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 2.5,
                                          color: Colors.white,
                                          strokeWidth: 1.8,
                                          strokeColor: const Color(0xFF2B32B2),
                                        );
                                      },
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF2B32B2).withValues(alpha: 0.22),
                                          const Color(0xFF2B32B2).withValues(alpha: 0.0),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          // Compact Days Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: (isBn
                                    ? ['শনি', 'রবি', 'সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র']
                                    : ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'])
                                .map((day) => Text(
                                      day,
                                      style: GoogleFonts.poppins(
                                          color: Colors.grey.shade500, fontSize: 8.5, fontWeight: FontWeight.w600),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ============================================
            // MERGED PREMIUM FEATURES (4 FEATURES IN A LINE)
            // ============================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8E2DE2).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.auto_awesome_rounded, size: 14, color: Color(0xFF8E2DE2)),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isBn ? 'প্রিমিয়াম ফিচার্স ও গ্যালারি' : 'Premium Features & Gallery',
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Grid of 4 features per line - PORTFOLIO IS MOVED TO THE VERY TOP!
                    GridView.count(
                      crossAxisCount: 4,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 0.82,
                      children: [
                        // #1 PORTFOLIO GALLERY (Higher Up at top row position 1)
                        _buildMergedFeatureItem(
                          icon: Icons.photo_library_rounded,
                          title: isBn ? 'পোর্টফোলিও' : 'Portfolio',
                          gradient: const [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                          onTap: () => Get.to(() => const PortfolioGalleryScreen()),
                        ),
                        _buildMergedFeatureItem(
                          icon: Icons.design_services_rounded,
                          title: isBn ? 'সেবা পরিচালনা' : 'Manage',
                          gradient: const [Color(0xFF6A11CB), Color(0xFF2575FC)],
                          onTap: () => Get.to(() => const ManageServicesScreen()),
                        ),
                        _buildMergedFeatureItem(
                          icon: Icons.medical_services_rounded,
                          title: isBn ? 'প্রেসক্রিপশন' : 'Digital Rx',
                          gradient: const [Color(0xFF004D40), Color(0xFF00796B)],
                          onTap: () => Get.to(() => const TeleConsultationPrescriptionScreen()),
                        ),
                        _buildMergedFeatureItem(
                          icon: Icons.people_alt_rounded,
                          title: isBn ? 'গ্রাহক CRM' : 'Client CRM',
                          gradient: const [Color(0xFF00B4DB), Color(0xFF0083B0)],
                          onTap: () => Get.to(() => const ClientCrmScreen()),
                        ),
                        _buildMergedFeatureItem(
                          icon: Icons.calendar_month_rounded,
                          title: isBn ? 'ক্যালেন্ডার' : 'Calendar',
                          gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                          onTap: () => Get.to(() => const BookingCalendarScreen()),
                        ),
                        _buildMergedFeatureItem(
                          icon: Icons.smart_toy_rounded,
                          title: isBn ? 'স্মার্ট এআই' : 'Smart AI',
                          gradient: const [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                          onTap: () => Get.to(() => const AiAssistantScreen()),
                        ),
                        _buildMergedFeatureItem(
                          icon: Icons.bolt_rounded,
                          title: isBn ? 'ভিআইপি লিড' : 'VIP Leads',
                          gradient: const [Color(0xFF283593), Color(0xFF3F51B5)],
                          onTap: () => Get.to(() => const ServiceProviderLeadEngineScreen()),
                        ),
                        _buildMergedFeatureItem(
                          icon: Icons.workspace_premium_rounded,
                          title: isBn ? 'ভিআইপি পাস' : 'VIP Pass',
                          gradient: const [Color(0xFFF2994A), Color(0xFFF2C94C)],
                          onTap: () => Get.to(() => const VipSubscriptionPaywallScreen()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ============================================
            // MY PRODUCTS (আমার পণ্য) (1 LINE = 4 + ADD BUTTON)
            // ============================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0288D1).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.inventory_2_rounded, size: 14, color: Color(0xFF0288D1)),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isBn ? 'আমার পণ্য' : 'My Products',
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => Get.to(() => const AddServiceProductScreen()),
                              icon: const Icon(Icons.add_circle_rounded, size: 13, color: Colors.white),
                              label: Text(
                                isBn ? '+ পণ্য যোগ' : '+ Add',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2B32B2),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 1,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 6),
                            OutlinedButton.icon(
                              onPressed: () => Get.to(() => const ServiceProviderProductsScreen()),
                              icon: const Icon(Icons.arrow_forward_rounded, size: 11, color: Color(0xFF2B32B2)),
                              label: Text(
                                isBn ? 'সব দেখুন' : 'View All',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2B32B2),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF2B32B2), width: 1.2),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // 1 Line = 4 Products Grid
                    GridView.count(
                      crossAxisCount: 4,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 0.65,
                      children: [
                        ...allProducts.take(3).map((p) => _buildProductItemCard(p, isBn)),
                        // 4th slot: Add product quick action card
                        _buildAddProductCard(isBn),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),
          ],
        ),
      ),
    );
  }

  /// Merged 4-in-a-line feature card
  Widget _buildMergedFeatureItem({
    required IconData icon,
    required String title,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: gradient.first.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Product Item Card for 1-line 4-grid with Real Product Image
  Widget _buildProductItemCard(ServiceProduct product, bool isBn) {
    final hasImage = product.images.isNotEmpty && product.images.first.isNotEmpty;

    return GestureDetector(
      onTap: () => Get.to(() => const ServiceProviderProductsScreen()),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container with Real Product Image
            Container(
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF2B32B2).withValues(alpha: 0.07),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                image: hasImage
                    ? DecorationImage(
                        image: NetworkImage(product.images.first),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: !hasImage
                  ? Center(
                      child: Icon(
                        _getProductCategoryIcon(product.category),
                        color: const Color(0xFF2B32B2),
                        size: 22,
                      ),
                    )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.getName(isBn),
                    style: GoogleFonts.poppins(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '৳${product.price.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2B32B2),
                    ),
                  ),
                  Text(
                    '${product.stockQuantity} ${isBn ? 'মজুদ' : 'Stock'}',
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Add product tile for the 4th slot
  Widget _buildAddProductCard(bool isBn) {
    return GestureDetector(
      onTap: () => Get.to(() => const AddServiceProductScreen()),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2B32B2).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF2B32B2).withValues(alpha: 0.4),
            style: BorderStyle.solid,
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF2B32B2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(height: 4),
            Text(
              isBn ? '+ পণ্য যোগ' : '+ Add',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2B32B2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getProductCategoryIcon(ServiceProductCategory category) {
    switch (category) {
      case ServiceProductCategory.fertilizer:
        return Icons.eco_rounded;
      case ServiceProductCategory.pesticide:
        return Icons.sanitizer_rounded;
      case ServiceProductCategory.tractor:
        return Icons.agriculture_rounded;
      case ServiceProductCategory.seed:
        return Icons.grass_rounded;
      case ServiceProductCategory.equipment:
        return Icons.home_repair_service_rounded;
      case ServiceProductCategory.advisory:
        return Icons.assignment_rounded;
    }
  }
}
