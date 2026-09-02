import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/controllers/farmer_analysis_controller.dart';

/// Masterclass Ultra Pro Max Farmer Analytics Dashboard
/// "Bento Box" Spatial Grid & Real-Time Intelligence Engine
class FarmerAnalyticsScreen extends StatefulWidget {
  const FarmerAnalyticsScreen({super.key});

  @override
  State<FarmerAnalyticsScreen> createState() => _FarmerAnalyticsScreenState();
}

class _FarmerAnalyticsScreenState extends State<FarmerAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late final FarmerAnalysisController controller;
  late AnimationController _animationController;
  final TextEditingController _voiceQueryController = TextEditingController();

  // Color Palette
  final Color bottleGreen = const Color(0xFF006A4E);
  final Color forestGreen = const Color(0xFF2E7D32);
  final Color harvestYellow = const Color(0xFFF2A900);
  final Color darkSlate = const Color(0xFF1E293B);
  final Color bgColor = const Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    controller = Get.put(FarmerAnalysisController());
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _voiceQueryController.dispose();
    super.dispose();
  }

  void _showVoiceAssistantDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: bottleGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.mic, color: bottleGreen, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'এআই খামার সহকারী (AI Voice Bot)',
                        style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: darkSlate),
                      ),
                      Text(
                        'আপনার খামার সংক্রান্ত যেকোনো প্রশ্ন লিখুন বা বলুন',
                        style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _voiceQueryController,
                style: GoogleFonts.hindSiliguri(),
                decoration: InputDecoration(
                  hintText: 'উদা: "চলতি মাসে আমার মোট লাভ কত?", "টমেটোর দর কেমন?"',
                  hintStyle: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade400),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  prefixIcon: const Icon(Icons.psychology_outlined),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final query = _voiceQueryController.text.trim();
                    if (query.isEmpty) return;
                    Navigator.pop(ctx);
                    final answer = await controller.processVoiceQuery(query);
                    _voiceQueryController.clear();
                    _showAnswerDialog(context, query, answer);
                  },
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  label: Text(
                    'বিশ্লেষণ ফলাফল জানুন',
                    style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bottleGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAnswerDialog(BuildContext context, String question, String answer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: harvestYellow, size: 24),
            const SizedBox(width: 8),
            Text('এআই বিশ্লেষণ রিপোর্ট', style: GoogleFonts.hindSiliguri(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
              child: Text('প্রশ্ন: "$question"', style: GoogleFonts.hindSiliguri(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey.shade800)),
            ),
            const SizedBox(height: 14),
            Text(answer, style: GoogleFonts.hindSiliguri(fontSize: 14, height: 1.4, color: darkSlate)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: bottleGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text('ঠিক আছে', style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isBn = LanguageProvider.isBn(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          isBn ? 'খামার বিশ্লেষণ ও ইনসাইটস' : 'Farm Analytics & Insights',
          style: GoogleFonts.hindSiliguri(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 19,
          ),
        ),
        backgroundColor: bottleGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
            tooltip: isBn ? 'পিডিএফ অডিট স্টেটমেন্ট' : 'Export PDF Statement',
            onPressed: () => controller.exportPdfStatement(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => controller.onInit(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              bottleGreen.withValues(alpha: 0.04),
              bgColor,
            ],
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator(color: bottleGreen));
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Timeframe & Filter Chips Strip
                _buildFilterControls(context),
                const SizedBox(height: 14),

                // 2. Executive Hero Bento (AI Voice Assistant + Health Score + SMS Sync)
                _buildExecutiveHeroCard(context),
                const SizedBox(height: 14),

                // 3. Financial Intelligence & Profit Margins (Revenue, Expense, Net Margin)
                _buildFinancialIntelligenceCard(context),
                const SizedBox(height: 14),

                // 4. Operating Expense Breakdown (Interactive category bars)
                _buildExpenseDistributionCard(context),
                const SizedBox(height: 14),

                // 5. Crop-wise Production & ROI Performance Matrix
                _buildCropRoiMatrixCard(context),
                const SizedBox(height: 14),

                // 6. Market Price Intelligence & Optimal Selling Window Engine
                _buildMarketSellingIntelligenceCard(context),
                const SizedBox(height: 14),

                // 7. Soil & Water IoT Health Index
                _buildSoilAndWaterHealthCard(context),
                const SizedBox(height: 14),

                // 8. Actionable AI Smart Advisory Cards
                _buildActionableAdvisorySection(context),
                const SizedBox(height: 14),

                // 9. Bank Loan & Audit Export Banner
                _buildPdfExportBanner(context),
                const SizedBox(height: 24),
              ],
            ),
          );
        }),
      ),
    );
  }

  // --- 1. FILTER CONTROLS ---
  Widget _buildFilterControls(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildTimeChip(AnalysisTimeframe.thisMonth, 'চলতি মাস (This Month)'),
          const SizedBox(width: 8),
          _buildTimeChip(AnalysisTimeframe.thisSeason, 'চলতি সিজন (This Season)'),
          const SizedBox(width: 8),
          _buildTimeChip(AnalysisTimeframe.last3Months, 'বিগত ৩ মাস (Quarter)'),
          const SizedBox(width: 8),
          _buildTimeChip(AnalysisTimeframe.thisYear, 'চলতি বছর (Annual)'),
          const SizedBox(width: 8),
          _buildTimeChip(AnalysisTimeframe.allTime, 'সর্বমোট (All Time)'),
        ],
      ),
    );
  }

  Widget _buildTimeChip(AnalysisTimeframe timeframe, String label) {
    final isSelected = controller.selectedTimeframe.value == timeframe;
    return GestureDetector(
      onTap: () => controller.setTimeframe(timeframe),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? bottleGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? bottleGreen : Colors.grey.shade300),
          boxShadow: [
            if (isSelected)
              BoxShadow(color: bottleGreen.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade800,
          ),
        ),
      ),
    );
  }

  // --- 2. EXECUTIVE HERO BENTO ---
  Widget _buildExecutiveHeroCard(BuildContext context) {
    final health = controller.farmHealthScore;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Voice Assistant Button
          GestureDetector(
            onTap: () => _showVoiceAssistantDialog(context),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [forestGreen, bottleGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(color: bottleGreen.withValues(alpha: 0.35), blurRadius: 8, spreadRadius: 1),
                    ],
                  ),
                  child: const Icon(Icons.mic_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(height: 6),
                Text('ভয়েস সহকারী 🎙️', style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Farm Health Circular Gauge
          Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value: health / 100,
                      strokeWidth: 6,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(harvestYellow),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text('$health%', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: bottleGreen)),
                ],
              ),
              const SizedBox(height: 6),
              Text('খামার স্বাস্থ্য সূচক', style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),

          // Offline SMS Sync
          Column(
            children: [
              Switch(
                value: controller.offlineSmsSyncEnabled.value,
                onChanged: controller.toggleOfflineSms,
                activeTrackColor: bottleGreen,
              ),
              Text('অফলাইন এসএমএস', style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            ],
          ),
        ],
      ),
    );
  }

  // --- 3. FINANCIAL INTELLIGENCE CARD ---
  Widget _buildFinancialIntelligenceCard(BuildContext context) {
    final rev = controller.totalRevenue;
    final exp = controller.totalExpense;
    final profit = controller.netProfit;
    final margin = controller.profitMarginPct;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet_rounded, color: bottleGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'আর্থিক লাভ-লোকসান ও মার্জিন',
                    style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: darkSlate),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (profit >= 0 ? Colors.green : Colors.red).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  profit >= 0 ? 'মুনাফা ${margin.toStringAsFixed(1)}%' : 'লোকসান ${margin.toStringAsFixed(1)}%',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: profit >= 0 ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3 Metric Grid
          Row(
            children: [
              Expanded(child: _buildMetricTile('মোট আয়', '৳${rev.toStringAsFixed(0)}', Colors.green.shade700, Icons.trending_up)),
              const SizedBox(width: 8),
              Expanded(child: _buildMetricTile('পরিচালন ব্যয়', '৳${exp.toStringAsFixed(0)}', Colors.red.shade700, Icons.trending_down)),
              const SizedBox(width: 8),
              Expanded(child: _buildMetricTile('নিট লাভ', '৳${profit.toStringAsFixed(0)}', bottleGreen, Icons.account_balance)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(title, style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- 4. EXPENSE DISTRIBUTION CARD ---
  Widget _buildExpenseDistributionCard(BuildContext context) {
    final breakdown = controller.expenseBreakdown;
    final total = controller.totalExpense;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_outline_rounded, color: forestGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'খরচের খাত ও শতাংশ বিশ্লেষণ',
                style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: darkSlate),
              ),
            ],
          ),
          const SizedBox(height: 14),

          ...breakdown.entries.map((e) {
            final pct = total > 0 ? (e.value / total) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.w500)),
                      Text(
                        '৳${e.value.toStringAsFixed(0)} (${(pct * 100).toStringAsFixed(0)}%)',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: darkSlate),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 7,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        e.key.contains('ফিড') ? Colors.blue : (e.key.contains('সার') ? Colors.green : (e.key.contains('শ্রমিক') ? Colors.orange : Colors.purple)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- 5. CROP ROI MATRIX CARD ---
  Widget _buildCropRoiMatrixCard(BuildContext context) {
    final list = controller.cropRoiList;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assessment_outlined, color: bottleGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'ফসলভিত্তিক উৎপাদন ও ROI ম্যাট্রিক্স',
                style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: darkSlate),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...list.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.cropName, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(
                          'উৎপাদন: ${item.yieldAmount.toInt()} ${item.unit} | ব্যয়: ৳${item.cost.toInt()}',
                          style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'ROI ${item.roiPct.toStringAsFixed(1)}%',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: item.roiPct >= 0 ? Colors.green.shade800 : Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(item.status, style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- 6. MARKET SELLING INTELLIGENCE CARD ---
  Widget _buildMarketSellingIntelligenceCard(BuildContext context) {
    final list = controller.marketOpportunities;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storefront_outlined, color: harvestYellow, size: 20),
              const SizedBox(width: 8),
              Text(
                'বাজারদর পূর্বাভাস ও সেরা বিক্রয়ের সুযোগ',
                style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: darkSlate),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...list.map((m) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (m.isFavorable ? Colors.green : Colors.red).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: (m.isFavorable ? Colors.green : Colors.red).withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(m.crop, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(
                        'বর্তমান ৳${m.currentPrice.toInt()} ➔ ৭ দিনে ৳${m.projectedPrice7Days.toInt()} (${m.priceChangePct >= 0 ? '+' : ''}${m.priceChangePct.toStringAsFixed(1)}%)',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: m.priceChangePct >= 0 ? Colors.green.shade800 : Colors.red.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('আড়ত: ${m.market}', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade700)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(m.isFavorable ? Icons.check_circle : Icons.warning_amber, size: 14, color: m.isFavorable ? Colors.green : Colors.orange),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          m.recommendation,
                          style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.w600, color: darkSlate),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- 7. SOIL & WATER HEALTH CARD ---
  Widget _buildSoilAndWaterHealthCard(BuildContext context) {
    final water = controller.waterQualityMetrics;
    final soil = controller.soilNutrientMetrics;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop_outlined, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'পানি ও মাটির IoT স্বাস্থ্য সূচক',
                style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: darkSlate),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Water 4 KPI Grid
          Row(
            children: [
              Expanded(child: _buildHealthPill('অক্সিজেন (DO)', '${water['do']['value']} ${water['do']['unit']}', Colors.green)),
              const SizedBox(width: 8),
              Expanded(child: _buildHealthPill('পিএইচ (pH)', '${water['ph']['value']}', Colors.green)),
              const SizedBox(width: 8),
              Expanded(child: _buildHealthPill('অ্যামোনিয়া', '${water['ammonia']['value']}', Colors.green)),
              const SizedBox(width: 8),
              Expanded(child: _buildHealthPill('তাপমাত্রা', '${water['temp']['value']}', Colors.blue)),
            ],
          ),
          const SizedBox(height: 14),

          // Soil N-P-K
          Text('মাটির পুষ্টি ও উর্বরতা লেভেল (N-P-K):', style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: _buildSoilBar('নাইট্রোজেন (N)', soil['nitrogen']['level'], Colors.green)),
              const SizedBox(width: 8),
              Expanded(child: _buildSoilBar('ফসফরাস (P)', soil['phosphorus']['level'], Colors.orange)),
              const SizedBox(width: 8),
              Expanded(child: _buildSoilBar('পটাশিয়াম (K)', soil['potassium']['level'], Colors.blue)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthPill(String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.hindSiliguri(fontSize: 10, color: Colors.grey.shade700)),
          const SizedBox(height: 2),
          Text(val, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildSoilBar(String title, double level, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: level, minHeight: 6, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(color)),
        ),
      ],
    );
  }

  // --- 8. ACTIONABLE ADVISORY SECTION ---
  Widget _buildActionableAdvisorySection(BuildContext context) {
    final advisories = controller.smartAdvisories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb_outline_rounded, color: harvestYellow, size: 20),
            const SizedBox(width: 8),
            Text(
              'স্মার্ট খামার সুপারিশ ও অ্যাকশন',
              style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: darkSlate),
            ),
          ],
        ),
        const SizedBox(height: 10),

        ...advisories.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: item.color.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: item.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.bold, color: darkSlate)),
                      const SizedBox(height: 2),
                      Text(item.description, style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: item.onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.color,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(item.actionLabel, style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // --- 9. PDF EXPORT BANNER ---
  Widget _buildPdfExportBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bottleGreen, forestGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: bottleGreen.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ব্যাংক ঋণ ও অডিট স্টেটমেন্ট',
                  style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  'কৃষি ব্যাংক লোন বা সাবসিডির জন্য ১-ক্লিকে সার্টিফাইড রিপোর্ট পান।',
                  style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.white.withValues(alpha: 0.9)),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => controller.exportPdfStatement(context),
            icon: const Icon(Icons.download_rounded, size: 16, color: Color(0xFF006A4E)),
            label: Text('PDF', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF006A4E))),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}
