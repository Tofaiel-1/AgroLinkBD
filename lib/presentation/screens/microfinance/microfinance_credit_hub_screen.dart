import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'microfinance_kyc_screen.dart';

// ─────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────
const _kBg        = Color(0xFF0D1B3E);
const _kGlass     = Color(0x0DFFFFFF);
const _kBorder    = Color(0x1AFFFFFF);
const _kGreen     = Color(0xFF10B981);
const _kBlue      = Color(0xFF3B82F6);
const _kAmber     = Color(0xFFF59E0B);
const _kPurple    = Color(0xFF8B5CF6);
const _kText      = Colors.white;
const _kSubtext   = Color(0xFFAEB8CC);

// ─────────────────────────────────────────────
// Loan category model
// ─────────────────────────────────────────────
class _LoanCategory {
  final String title;
  final String subtitle;
  final String amount;
  final String rate;
  final String tenure;
  final IconData icon;
  final Color color;
  final String role;

  const _LoanCategory({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.rate,
    required this.tenure,
    required this.icon,
    required this.color,
    required this.role,
  });
}

const _categories = [
  _LoanCategory(
    title: 'Farmer Crop Loan',
    subtitle: 'Seasonal crop financing',
    amount: '৳1,00,000',
    rate: '7% p.a.',
    tenure: '12 months',
    icon: Icons.grass_rounded,
    color: _kGreen,
    role: 'farmer',
  ),
  _LoanCategory(
    title: 'Buyer Capital Loan',
    subtitle: 'Inventory & procurement',
    amount: '৳5,00,000',
    rate: '9% p.a.',
    tenure: '24 months',
    icon: Icons.shopping_bag_rounded,
    color: _kBlue,
    role: 'buyer',
  ),
  _LoanCategory(
    title: 'Driver Maintenance Loan',
    subtitle: 'Vehicle repair & upgrade',
    amount: '৳50,000',
    rate: '8% p.a.',
    tenure: '18 months',
    icon: Icons.local_shipping_rounded,
    color: _kAmber,
    role: 'driver',
  ),
  _LoanCategory(
    title: 'Corporate Finance',
    subtitle: 'Business expansion credit',
    amount: '৳25,00,000',
    rate: '6% p.a.',
    tenure: '60 months',
    icon: Icons.corporate_fare_rounded,
    color: _kPurple,
    role: 'company',
  ),
];

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────
class MicrofinanceCreditHubScreen extends StatefulWidget {
  final String userRole; // farmer | buyer | driver | company | admin
  final String userName;
  const MicrofinanceCreditHubScreen({
    super.key,
    this.userRole = 'farmer',
    this.userName = 'Tofaiel',
  });

  @override
  State<MicrofinanceCreditHubScreen> createState() =>
      _MicrofinanceCreditHubScreenState();
}

class _MicrofinanceCreditHubScreenState
    extends State<MicrofinanceCreditHubScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;
  int _selectedTab = 0;

  List<_LoanCategory> get _visibleCategories =>
      widget.userRole == 'admin'
          ? _categories
          : _categories.where((c) => c.role == widget.userRole).toList()
            ..addAll(_categories.where((c) => c.role != widget.userRole));

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          _buildOrbs(),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildCreditLimitCard()),
                SliverToBoxAdapter(child: _buildSectionLabel('Loan Products')),
                SliverToBoxAdapter(child: _buildCategoryTabs()),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _buildCategoryCard(
                        _visibleCategories[i], i),
                      childCount: _visibleCategories.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Ambient glowing orbs ──────────────────
  Widget _buildOrbs() {
    return Stack(children: [
      Positioned(
        top: -80, left: -80,
        child: _orb(260, _kGreen.withOpacity(0.12)),
      ),
      Positioned(
        bottom: -100, right: -60,
        child: _orb(320, _kBlue.withOpacity(0.10)),
      ),
    ]);
  }

  Widget _orb(double size, Color color) => Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  // ── Header ───────────────────────────────
  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: _glassIcon(Icons.arrow_back_ios_new_rounded),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: const TextStyle(color: _kSubtext, fontSize: 13)),
                Text(
                  widget.userName,
                  style: const TextStyle(
                    color: _kText, fontSize: 20,
                    fontWeight: FontWeight.w700, letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          _glassIcon(Icons.notifications_none_rounded),
          const SizedBox(width: 10),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kGreen, Color(0xFF059669)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: _kGreen.withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 4)),
              ],
            ),
            child: const Center(
              child: Text('T', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassIcon(IconData icon) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: _kGlass,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder),
            ),
            child: Icon(icon, color: _kText, size: 20),
          ),
        ),
      );

  // ── Credit Limit Card ─────────────────────
  Widget _buildCreditLimitCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _kGreen.withOpacity(0.18),
                  _kBlue.withOpacity(0.12),
                ],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _kGreen.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(color: _kGreen.withOpacity(0.15), blurRadius: 30),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Credit Limit',
                          style: TextStyle(color: _kSubtext, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      const Text('৳ 2,50,000',
                          style: TextStyle(
                              color: _kText, fontSize: 30,
                              fontWeight: FontWeight.w800, letterSpacing: -1)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          AnimatedBuilder(
                            animation: _pulse,
                            builder: (_, __) => Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _kGreen.withOpacity(_pulse.value),
                                boxShadow: [BoxShadow(color: _kGreen, blurRadius: 6 * _pulse.value)],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('Active & Verified',
                              style: TextStyle(color: _kGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _limitPill('Used', '৳80,000', _kAmber),
                          const SizedBox(width: 10),
                          _limitPill('Available', '৳1,70,000', _kGreen),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _buildArcProgress(0.32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _limitPill(String label, String value, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 10)),
          Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      );

  Widget _buildArcProgress(double progress) {
    return SizedBox(
      width: 90, height: 90,
      child: CustomPaint(
        painter: _ArcPainter(progress: progress),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${(progress * 100).round()}%',
                  style: const TextStyle(color: _kText, fontSize: 18, fontWeight: FontWeight.w800)),
              const Text('Used', style: TextStyle(color: _kSubtext, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section label ─────────────────────────
  Widget _buildSectionLabel(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Text(text,
            style: const TextStyle(
                color: _kText, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.4)),
      );

  // ── Category tabs ─────────────────────────
  Widget _buildCategoryTabs() {
    final tabs = ['All', 'Farmer', 'Buyer', 'Driver', 'Company'];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final active = _selectedTab == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: active ? _kGreen : _kGlass,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? _kGreen : _kBorder),
                boxShadow: active
                    ? [BoxShadow(color: _kGreen.withOpacity(0.3), blurRadius: 10)]
                    : null,
              ),
              child: Center(
                child: Text(tabs[i],
                    style: TextStyle(
                        color: active ? Colors.white : _kSubtext,
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Category card ─────────────────────────
  Widget _buildCategoryCard(_LoanCategory cat, int index) {
    final isHighlighted = cat.role == widget.userRole;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? cat.color.withOpacity(0.10)
                  : _kGlass,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isHighlighted ? cat.color.withOpacity(0.4) : _kBorder,
              ),
              boxShadow: isHighlighted
                  ? [BoxShadow(color: cat.color.withOpacity(0.12), blurRadius: 20)]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: cat.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cat.color.withOpacity(0.3)),
                  ),
                  child: Icon(cat.icon, color: cat.color, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(cat.title,
                                style: const TextStyle(
                                    color: _kText, fontSize: 15, fontWeight: FontWeight.w600)),
                          ),
                          if (isHighlighted)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: cat.color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('Your Plan',
                                  style: TextStyle(color: cat.color, fontSize: 10, fontWeight: FontWeight.w700)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(cat.subtitle,
                          style: const TextStyle(color: _kSubtext, fontSize: 12)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _infoChip(Icons.currency_exchange_rounded, cat.amount, cat.color),
                          const SizedBox(width: 8),
                          _infoChip(Icons.percent_rounded, cat.rate, cat.color),
                          const SizedBox(width: 8),
                          _infoChip(Icons.calendar_month_rounded, cat.tenure, cat.color),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(() => MicrofinanceKycScreen(
                              loanType: cat.title,
                              userRole: cat.role,
                            ));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cat.color,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            shadowColor: cat.color.withOpacity(0.5),
                          ),
                          child: const Text('Apply Now',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
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
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 11),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

// ─────────────────────────────────────────────
// Custom arc painter for credit utilisation
// ─────────────────────────────────────────────
class _ArcPainter extends CustomPainter {
  final double progress;
  const _ArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const startAngle = -math.pi / 2 + 0.4;
    const sweepMax  = 2 * math.pi - 0.8;

    // Track
    canvas.drawArc(
      rect.deflate(4),
      startAngle,
      sweepMax,
      false,
      Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );

    // Progress
    canvas.drawArc(
      rect.deflate(4),
      startAngle,
      sweepMax * progress,
      false,
      Paint()
        ..shader = const LinearGradient(
          colors: [_kGreen, Color(0xFF34D399)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) => old.progress != progress;
}
