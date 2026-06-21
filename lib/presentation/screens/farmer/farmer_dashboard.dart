import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Farmer Role Dashboard
/// Displays farm overview, stats, recent activity, and quick actions
class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard>
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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=1000&auto=format&fit=crop'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black12, BlendMode.darken),
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Menu & Profile
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.black87, size: 30),
                            onPressed: () {
                              ScaffoldState? rootScaffold = context.findRootAncestorStateOfType<ScaffoldState>();
                              rootScaffold?.openDrawer();
                            },
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8),
                              ],
                            ),
                            child: const CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/44.jpg'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Welcome Text
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'স্বাগতম, কৃষক আব্দুর রহমান! 👨‍🌾',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                shadows: const [Shadow(color: Colors.white, blurRadius: 10)],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'আপনার AgroLinkBD খামার পোর্টাল - সামগ্রিক চিত্র',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 120), // Space to show the background field
                      
                      // Row 1: Balance & Orders
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _balanceCard()),
                          const SizedBox(width: 12),
                          Expanded(child: _ordersCard()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Row 2: Sales & Satisfaction
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _salesCard()),
                          const SizedBox(width: 12),
                          Expanded(child: _satisfactionCard()),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 260, // Fixed height for perfect alignment
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _balanceCard() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('আপনার বর্তমান\nব্যালেন্স', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 8),
                    Text('৳ ১২,৫০০', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ],
                ),
              ),
              const Icon(Icons.account_balance_wallet, color: Colors.brown, size: 36),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildListRow('🍅', 'টমেটো বিক্রি', '৳৩,০০০'),
          const SizedBox(height: 8),
          _buildListRow('🍚', 'চাল বিক্রি', '৳৯,৫০০'),
          const SizedBox(height: 8),
          _buildListRow('🌾', 'সার ক্রয়', '৳-২,০০০'),
        ],
      ),
    );
  }

  Widget _buildListRow(String emoji, String title, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87)),
          ],
        ),
        Text(amount, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _ordersCard() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('প্রক্রিয়াধীন\nঅর্ডারসমূহ', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
          const Spacer(),
          Center(
            child: Icon(Icons.local_shipping, size: 50, color: Colors.orange.shade700),
          ),
          const Spacer(),
          Text('8', style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 4),
          Text('ডেলিভারির জন্য প্রস্তুত: ৫টি\nপ্যাকিং করা হচ্ছে: ৩টি', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _salesCard() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.trending_up, color: Colors.green),
          ),
          const Spacer(),
          Text('সাম্প্রতিক বিক্রি', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          Text('৳ ৪৫,০০০', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('এই মাসের মোট বিক্রি', style: GoogleFonts.poppins(fontSize: 10, color: Colors.black87)),
              Text('২৪টি পণ্য', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _satisfactionCard() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('গ্রাহক সন্তুষ্টি', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87))),
              const CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg')),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Text('4.8', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(width: 4),
              Row(children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.amber, size: 14))),
            ],
          ),
          Text('২৫ জন গ্রাহক মতামত দিয়েছেন', style: GoogleFonts.poppins(fontSize: 10, color: Colors.black87)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• সেরা মান!', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87)),
                const SizedBox(height: 2),
                Text('• সময়মতো ডেলিভারি!', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
