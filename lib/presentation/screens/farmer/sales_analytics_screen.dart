import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ultra-Premium Visionary Farmer Analytics Dashboard
/// "Bento Box" Spatial Grid System
class SalesAnalyticsScreen extends StatefulWidget {
  const SalesAnalyticsScreen({super.key});

  @override
  State<SalesAnalyticsScreen> createState() => _SalesAnalyticsScreenState();
}

class _SalesAnalyticsScreenState extends State<SalesAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _tickerScrollController;

  // Colors
  final Color bottleGreen = const Color(0xFF006A4E);
  final Color harvestYellow = const Color(0xFFF2A900);
  final Color cleanWhite = const Color(0xFFFFFFFF);
  final Color bgColor = const Color(0xFFF5F7FA);

  bool _offlineSmsEnabled = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _tickerScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTickerScroll();
    });
  }

  void _startTickerScroll() async {
    while (mounted) {
      if (_tickerScrollController.hasClients) {
        double maxExtent = _tickerScrollController.position.maxScrollExtent;
        await _tickerScrollController.animateTo(
          maxExtent,
          duration: Duration(seconds: (maxExtent / 30).round() > 0 ? (maxExtent / 30).round() : 5),
          curve: Curves.linear,
        );
        if (mounted && _tickerScrollController.hasClients) {
          _tickerScrollController.jumpTo(0);
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tickerScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'খামার বিশ্লেষণ',
          style: GoogleFonts.hindSiliguri(
            fontWeight: FontWeight.bold,
            color: bottleGreen,
          ),
        ),
        backgroundColor: cleanWhite,
        elevation: 0,
        iconTheme: IconThemeData(color: bottleGreen),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              bgColor,
              const Color(0xFFE8F5E9),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. The Brain (Top Row)
              _buildGlassBentoCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Voice Bot
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            bottleGreen.withOpacity(0.8),
                            bottleGreen,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: bottleGreen.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mic_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    // Farm Health Circular Progress
                    Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0, end: 0.85),
                                duration: const Duration(seconds: 2),
                                builder: (context, value, child) {
                                  return CircularProgressIndicator(
                                    value: value,
                                    strokeWidth: 8,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation<Color>(harvestYellow),
                                    strokeCap: StrokeCap.round,
                                  );
                                },
                              ),
                            ),
                            Text(
                              '৮৫%',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: bottleGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'জমির স্বাস্থ্য',
                          style: GoogleFonts.hindSiliguri(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    // Offline SMS Toggle
                    Column(
                      children: [
                        Switch(
                          value: _offlineSmsEnabled,
                          onChanged: (val) {
                            setState(() => _offlineSmsEnabled = val);
                          },
                          activeColor: harvestYellow,
                          activeTrackColor: bottleGreen.withOpacity(0.2),
                          inactiveThumbColor: Colors.grey,
                          inactiveTrackColor: Colors.grey.shade300,
                        ),
                        Text(
                          'অফলাইন এসএমএস',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Market & Finance (Middle Large Block)
              _buildGlassBentoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'বাজার দর (Market Trends)',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: bottleGreen,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'লাইভ',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Mock Neon Line Chart (Simplified via bars for visual)
                    SizedBox(
                      height: 100,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildChartBar('ধান', 80, '৳১২০০', Colors.blue),
                          _buildChartBar('আলু', 40, '৳৩৫', Colors.red),
                          _buildChartBar('পেঁয়াজ', 90, '৳৯০', bottleGreen),
                          _buildChartBar('টমেটো', 30, '৳৩০', harvestYellow),
                          _buildChartBar('রসুন', 100, '৳১৮০', Colors.purple),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 12),
                    // Finance Progress Bars
                    _buildFinanceRow(
                      'কৃষি বিনিয়োগ (Micro-Invest)',
                      '৳৫,০০০',
                      0.6,
                      Icons.account_balance_wallet,
                      bottleGreen,
                    ),
                    const SizedBox(height: 16),
                    _buildFinanceRow(
                      'ফসল বীমা (Crop Insurance)',
                      'সক্রিয়',
                      1.0,
                      Icons.security,
                      harvestYellow,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. IoT & Soil (Middle Small Blocks)
              Row(
                children: [
                  Expanded(
                    child: _buildGlassBentoCard(
                      child: Column(
                        children: [
                          Icon(Icons.water_drop, color: Colors.blue.shade400, size: 36),
                          const SizedBox(height: 8),
                          Text(
                            'মাটির আর্দ্রতা',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '৬০% (স্বাভাবিক)',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Fake 3D mini-map (Container styling)
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF81C784), Color(0xFF388E3C)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.map, color: Colors.white, size: 28),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildGlassBentoCard(
                      child: Column(
                        children: [
                          Icon(Icons.science, color: Colors.purple.shade400, size: 36),
                          const SizedBox(height: 8),
                          Text(
                            'সার ক্যালকুলেটর',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'AI প্রস্তাবিত',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildFertilizerBadge('Urea', Colors.blue),
                              _buildFertilizerBadge('Potash', Colors.orange),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. Logistics & Govt (Bottom Row)
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildGlassBentoCard(
                      child: Column(
                        children: [
                          const Icon(Icons.ac_unit, color: Colors.cyan, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'হিমাগার বুকিং',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.cyan.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'বগুড়া',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.cyan.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildGlassBentoCard(
                      padding: const EdgeInsets.all(0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              color: Colors.red.shade50,
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Icon(Icons.campaign, color: Colors.red.shade700, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    'সরকারি কৃষি ভর্তুকি',
                                    style: GoogleFonts.hindSiliguri(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 60,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              color: Colors.red.shade600,
                              alignment: Alignment.center,
                              child: ListView.builder(
                                controller: _tickerScrollController,
                                scrollDirection: Axis.horizontal,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: 10, // loop
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 32, top: 16),
                                    child: Text(
                                      '• বোরো ধানের জন্য ৩০% সরকারি ভর্তুকি ঘোষণা করা হয়েছে। আজই আবেদন করুন।   ',
                                      style: GoogleFonts.hindSiliguri(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassBentoCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }

  Widget _buildChartBar(String label, double height, String value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: height),
          duration: const Duration(milliseconds: 1500),
          builder: (context, val, child) {
            return Container(
              width: 30,
              height: val,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.7), color],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildFinanceRow(String title, String value, double progress, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 1500),
                  builder: (context, val, child) {
                    return LinearProgressIndicator(
                      value: val,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFertilizerBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color.withOpacity(0.9),
        ),
      ),
    );
  }
}
