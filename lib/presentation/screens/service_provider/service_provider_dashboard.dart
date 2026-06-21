import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agrolinkbd/core/providers/service_provider_providers.dart';
import 'package:agrolinkbd/core/models/service_model.dart';
import 'package:agrolinkbd/presentation/screens/service_provider/manage_services_screen.dart';

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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('লগ আউট'),
        content: const Text('আপনি কি নিশ্চিত যে আপনি লগ আউট করতে চান?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('না')),
          ElevatedButton(
            onPressed: () {
              // Handle logout logic
              Navigator.pop(context);
              Get.offAllNamed('/auth/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('হ্যাঁ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsyncValue = ref.watch(providerServicesStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // ============================================
            // HEADER
            // ============================================
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: const Color(0xFF4527A0),
              actions: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_rounded, color: Colors.white),
                      onPressed: () {},
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '2',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'logout') _showLogoutDialog(context);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'logout', child: Row(
                      children: [Icon(Icons.logout, size: 18), SizedBox(width: 8), Text('লগ আউট')],
                    )),
                  ],
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.more_vert, color: Colors.white),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF4527A0), Color(0xFF7B1FA2)],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -40,
                        top: -40,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -30,
                        bottom: -30,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    image: const DecorationImage(
                                      image: NetworkImage('https://ui-avatars.com/api/?name=SP&background=E1BEE7&color=4A148C'),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'স্বাগতম, সেবা প্রদানকারী',
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '🟢 অনলাইনে আছেন',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.greenAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildHeaderStat('মোট আয়', '৳ ২৫,০০০'),
                                _buildHeaderStat('সম্পন্ন সেবা', '৪২ টি'),
                                _buildHeaderStat('রেটিং', '⭐ ৪.৮'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ============================================
            // QUICK ACTION GRID
            // ============================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'কুইক অ্যাকশন',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.4,
                      children: [
                        _buildActionCard(
                          icon: Icons.design_services_rounded,
                          title: 'সেবা পরিচালনা',
                          subtitle: 'আপনার সেবা সমূহ',
                          color: const Color(0xFF4527A0),
                          onTap: () => Get.to(() => const ManageServicesScreen()),
                        ),
                        _buildActionCard(
                          icon: Icons.book_online_rounded,
                          title: 'বুকিং রিকোয়েস্ট',
                          subtitle: 'নতুন ৩ টি বুকিং',
                          color: const Color(0xFFE65100),
                          onTap: () {}, // To implement
                        ),
                        _buildActionCard(
                          icon: Icons.account_balance_wallet_rounded,
                          title: 'উপার্জন',
                          subtitle: 'ওয়ালেট ও পেমেন্ট',
                          color: const Color(0xFF2E7D32),
                          onTap: () {}, // To implement
                        ),
                        _buildActionCard(
                          icon: Icons.analytics_rounded,
                          title: 'রিপোর্ট',
                          subtitle: 'মাসিক হিসাব',
                          color: const Color(0xFF1565C0),
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
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'আপনার সক্রিয় সেবা',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => const ManageServicesScreen()),
                      child: Text('সব দেখুন', style: GoogleFonts.poppins(color: const Color(0xFF4527A0))),
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
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.add_box_rounded, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text('এখনো কোনো সেবা যোগ করেননি', style: GoogleFonts.poppins(color: Colors.grey.shade600)),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () => Get.to(() => const ManageServicesScreen()),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF4527A0),
                              side: const BorderSide(color: Color(0xFF4527A0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('নতুন সেবা যোগ করুন'),
                          ),
                        ],
                      ),
                    );
                  }

                  return SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        return _buildServicePreviewCard(services[index]);
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withOpacity(0.8))),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicePreviewCard(ServiceModel service) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFF4527A0).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              image: service.imageUrl != null && service.imageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(service.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: service.imageUrl == null || service.imageUrl!.isEmpty
                ? const Center(child: Icon(Icons.design_services, size: 40, color: Colors.grey))
                : null,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '৳${service.price.toStringAsFixed(0)} ${service.priceUnit}',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF7B1FA2)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('${service.rating}', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade700)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: service.status == ServiceStatus.active ? Colors.green.shade50 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        service.status == ServiceStatus.active ? 'সক্রিয়' : 'নিষ্ক্রিয়',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
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
