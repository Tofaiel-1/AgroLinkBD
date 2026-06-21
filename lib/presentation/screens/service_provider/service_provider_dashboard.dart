import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:agrolinkbd/core/providers/service_provider_providers.dart';
import 'package:agrolinkbd/core/models/service_model.dart';
import 'package:agrolinkbd/presentation/screens/service_provider/manage_services_screen.dart';
import 'package:agrolinkbd/presentation/screens/service_provider/portfolio_gallery_screen.dart';
import 'dart:ui';

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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('লগ আউট', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('আপনি কি নিশ্চিত যে আপনি লগ আউট করতে চান?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text('না', style: GoogleFonts.poppins(color: Colors.grey.shade700))
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.offAllNamed('/auth/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            child: Text('হ্যাঁ', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsyncValue = ref.watch(providerServicesStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ============================================
            // PREMIUM HEADER
            // ============================================
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              stretch: true,
              backgroundColor: const Color(0xFF2B32B2),
              elevation: 0,
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_active_rounded, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'logout') _showLogoutDialog(context);
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'logout', child: Row(
                        children: [
                          const Icon(Icons.logout, size: 20, color: Colors.redAccent), 
                          const SizedBox(width: 12), 
                          Text('লগ আউট', style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold))
                        ],
                      )),
                    ],
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.more_vert, color: Colors.white),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Dynamic Gradient Background
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF2B32B2), // Deep Blue
                            Color(0xFF1488CC), // Light Blue
                          ],
                        ),
                      ),
                    ),
                    // Decorative Circles
                    Positioned(
                      top: -50,
                      right: -30,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -80,
                      left: -50,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    // Content
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 65,
                                  height: 65,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
                                    ],
                                    image: const DecorationImage(
                                      image: NetworkImage('https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&q=80&w=150'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'স্বাগতম, সেবা প্রদানকারী',
                                        style: GoogleFonts.poppins(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.greenAccent.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 8, height: 8,
                                              decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'অনলাইনে আছেন',
                                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            // Glassmorphism Stats Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildHeaderStat('মোট আয়', '৳ ৮৫,০০০', Icons.account_balance_wallet_rounded),
                                      Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                                      _buildHeaderStat('সেবা সম্পন্ন', '১৪২ টি', Icons.task_alt_rounded),
                                      Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                                      _buildHeaderStat('রেটিং', '৪.৯', Icons.star_rounded, iconColor: Colors.amber),
                                    ],
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
            // ANALYSIS CHART SECTION
            // ============================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'আয় বিশ্লেষণ',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
                            ],
                          ),
                          child: Text(
                            'গত ৭ দিন',
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF2B32B2)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 220,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2B32B2).withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1000,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.shade200,
                                strokeWidth: 1,
                                dashArray: [5, 5],
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  const days = ['শনি', 'রবি', 'সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র'];
                                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(days[value.toInt()], style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 11)),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 2000,
                                reservedSize: 42,
                                getTitlesWidget: (value, meta) {
                                  if (value == 0) return const Text('');
                                  return Text('${(value / 1000).toStringAsFixed(0)}k', 
                                    style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 11));
                                },
                              ),
                            ),
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
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.white,
                                    strokeWidth: 3,
                                    strokeColor: const Color(0xFF2B32B2),
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF2B32B2).withOpacity(0.3),
                                    const Color(0xFF2B32B2).withOpacity(0.0),
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
                  ],
                ),
              ),
            ),

            // ============================================
            // QUICK ACTION GRID
            // ============================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'কুইক অ্যাকশন',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.1,
                      children: [
                        _buildActionCard(
                          icon: Icons.design_services_rounded,
                          title: 'সেবা পরিচালনা',
                          subtitle: 'নতুন সেবা যোগ করুন',
                          gradient: const [Color(0xFF6A11CB), Color(0xFF2575FC)],
                          onTap: () => Get.to(() => const ManageServicesScreen()),
                        ),
                        _buildActionCard(
                          icon: Icons.photo_library_rounded,
                          title: 'পোর্টফোলিও',
                          subtitle: 'আপনার কাজ দেখান',
                          gradient: const [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                          onTap: () => Get.to(() => const PortfolioGalleryScreen()),
                        ),
                        _buildActionCard(
                          icon: Icons.book_online_rounded,
                          title: 'অর্ডার ও বুকিং',
                          subtitle: 'নতুন ৫ টি অর্ডার',
                          gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                          onTap: () {}, // To implement
                        ),
                        _buildActionCard(
                          icon: Icons.account_balance_wallet_rounded,
                          title: 'উপার্জন ও পে আউট',
                          subtitle: 'ব্যালেন্স দেখুন',
                          gradient: const [Color(0xFFF2994A), Color(0xFFF2C94C)],
                          onTap: () {}, // To implement
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ============================================
            // ACTIVE SERVICES OVERVIEW
            // ============================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'আপনার সক্রিয় সেবা',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => const ManageServicesScreen()),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF2B32B2).withOpacity(0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text('সব দেখুন', style: GoogleFonts.poppins(color: const Color(0xFF2B32B2), fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
            
            SliverToBoxAdapter(
              child: servicesAsyncValue.when(
                data: (services) {
                  if (services.isEmpty) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2B32B2).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add_photo_alternate_rounded, size: 48, color: Color(0xFF2B32B2)),
                          ),
                          const SizedBox(height: 16),
                          Text('এখনো কোনো সেবা যোগ করেননি', style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 14)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => Get.to(() => const ManageServicesScreen()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2B32B2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: const Text('নতুন সেবা যোগ করুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  }

                  return SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        return _buildServicePreviewCard(services[index]);
                      },
                    ),
                  );
                },
                loading: () => const Center(child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: Color(0xFF2B32B2)),
                )),
                error: (e, s) => Center(child: Text('Error: $e')),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon, {Color? iconColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor ?? Colors.white, size: 22),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withOpacity(0.8))),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -15,
              top: -15,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gradient.first.withOpacity(0.1),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: gradient.first.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4)),
                      ]
                    ),
                    child: Icon(icon, color: Colors.white, size: 26),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicePreviewCard(ServiceModel service) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(left: 4, right: 12, bottom: 10, top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFF2B32B2).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              image: service.imageUrl != null && service.imageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(service.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: service.imageUrl == null || service.imageUrl!.isEmpty
                ? const Center(child: Icon(Icons.design_services_rounded, size: 40, color: Color(0xFF2B32B2)))
                : null,
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '৳${service.price.toStringAsFixed(0)} ${service.priceUnit}',
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1488CC)),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('${service.rating}', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: service.status == ServiceStatus.active ? Colors.green.shade50 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        service.status == ServiceStatus.active ? 'সক্রিয়' : 'নিষ্ক্রিয়',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: service.status == ServiceStatus.active ? Colors.green.shade700 : Colors.grey.shade600,
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
}
