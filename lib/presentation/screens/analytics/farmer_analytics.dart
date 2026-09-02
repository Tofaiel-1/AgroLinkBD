import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/controllers/farmer_analysis_controller.dart';
import 'package:agrolinkbd/presentation/screens/farmer/tools/farm_smart_calculator_sheet.dart';

/// Masterclass Ultra Pro Max Farmer Analytics Dashboard 2.0
/// Fully Bilingual (English / বাংলা) Spatial Multi-Tab Architecture with fl_chart, Live Batches & Trash Bin
class FarmerAnalyticsScreen extends StatefulWidget {
  const FarmerAnalyticsScreen({super.key});

  @override
  State<FarmerAnalyticsScreen> createState() => _FarmerAnalyticsScreenState();
}

class _FarmerAnalyticsScreenState extends State<FarmerAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late final FarmerAnalysisController controller;
  late TabController _tabController;
  final TextEditingController _voiceQueryController = TextEditingController();

  // Colors
  final Color bottleGreen = const Color(0xFF006A4E);
  final Color forestGreen = const Color(0xFF2E7D32);
  final Color harvestYellow = const Color(0xFFF2A900);
  final Color darkSlate = const Color(0xFF0F172A);
  final Color cardBg = Colors.white;
  final Color bgColor = const Color(0xFFF1F5F9);

  @override
  void initState() {
    super.initState();
    controller = Get.put(FarmerAnalysisController());
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        controller.setTab(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _voiceQueryController.dispose();
    super.dispose();
  }

  void _showAddBatchModal(BuildContext context, bool isBn) {
    final nameCtrl = TextEditingController();
    final yieldCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final daysCtrl = TextEditingController(text: '90');
    String selectedType = isBn ? 'মাছ (Fisheries)' : 'Fisheries';

    final categories = isBn
        ? ['মাছ (Fisheries)', 'শস্য (Crops)', 'সবজি (Vegetables)', 'পোল্ট্রি (Poultry)']
        : ['Fisheries', 'Crops', 'Vegetables', 'Poultry'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isBn ? 'নতুন খামার ব্যাচ যুক্ত করুন' : 'Add New Farm Batch',
                        style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold, color: darkSlate),
                      ),
                      IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: InputDecoration(
                      labelText: isBn ? 'ক্যাটাগরি' : 'Category',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: categories
                        .map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.hindSiliguri())))
                        .toList(),
                    onChanged: (val) => setModalState(() => selectedType = val ?? selectedType),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: isBn ? 'ব্যাচের নাম (উদা: পুকুর ১ - রুই মাছ)' : 'Batch Name (e.g. Pond 1 - Rohu Fish)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    style: GoogleFonts.hindSiliguri(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: yieldCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: isBn ? 'লক্ষ্যমাত্রা (কেজি)' : 'Target Yield (kg)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: costCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: isBn ? 'প্রাথমিক ব্যয় (৳)' : 'Initial Cost (BDT)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: daysCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: isBn ? 'মোট চক্রের দিন (Cycle Days)' : 'Cycle Duration (Days)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (nameCtrl.text.trim().isEmpty) return;
                        final newBatch = FarmBatchModel(
                          id: '',
                          userId: controller.currentUserId,
                          farmId: controller.selectedFarmId.value,
                          batchName: nameCtrl.text.trim(),
                          commodityType: selectedType,
                          startDate: DateTime.now(),
                          cycleDurationDays: int.tryParse(daysCtrl.text.trim()) ?? 90,
                          currentBiomassKg: (double.tryParse(yieldCtrl.text.trim()) ?? 1000) * 0.2,
                          feedOrInputConsumedKg: (double.tryParse(costCtrl.text.trim()) ?? 10000) / 100,
                          targetYieldKg: double.tryParse(yieldCtrl.text.trim()) ?? 1000,
                          survivalRatePct: 95.0,
                          totalInvestedCost: double.tryParse(costCtrl.text.trim()) ?? 15000,
                          status: isBn ? 'সক্রিয় (Active)' : 'Active',
                        );
                        Navigator.pop(ctx);
                        await controller.createBatch(newBatch, isBn);
                      },
                      icon: const Icon(Icons.add_task_rounded, color: Colors.white),
                      label: Text(
                        isBn ? 'ব্যাচ সেভ করুন (Firestore Sync)' : 'Save Batch (Firestore Sync)',
                        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(backgroundColor: bottleGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showVoiceAssistantDialog(BuildContext context, bool isBn) {
    final List<String> quickPrompts = isBn
        ? [
            'আমার চলতি মাসের নিট লাভ কত?',
            'সক্রিয় ব্যাচে মাছের FCR স্কোর কত?',
            'পুকুরের পানির অক্সিজেন ও পিএইচ কেমন?',
            'আজকের ফসলের বাজারদর ও পূর্বাভাস কী?',
          ]
        : [
            'What is my net profit this month?',
            'How is my active batch FCR score?',
            'What is the pond water quality status?',
            'What are the live wholesale market rates?',
          ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(modalCtx).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header with pulsing visual
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [bottleGreen, forestGreen],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: bottleGreen.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.mic, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  isBn ? 'Gemini AI ভয়েস সহকারী' : 'Gemini AI Voice Agronomist',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: darkSlate,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '100% Live',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: forestGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              isBn
                                  ? 'খামারের বাস্তব ডেটা ভিত্তিক সঠিক বিশ্লেষণ'
                                  : 'Grounded in your live farm financials & batches',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 11.5,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(modalCtx),
                        icon: const Icon(Icons.close, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Quick Voice Prompts
                  Text(
                    isBn ? '💡 দ্রুত প্রশ্ন করতে ট্যাপ করুন:' : '💡 Tap for Quick Query:',
                    style: GoogleFonts.hindSiliguri(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: quickPrompts.map((p) {
                      return InkWell(
                        onTap: () async {
                          Navigator.pop(modalCtx);
                          final answer = await controller.processVoiceQuery(p, isBn);
                          if (context.mounted) {
                            _showAnswerDialog(context, p, answer, isBn);
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: bottleGreen.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: bottleGreen.withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bolt_rounded, size: 14, color: bottleGreen),
                              const SizedBox(width: 4),
                              Text(
                                p,
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: bottleGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Query Input Field
                  TextField(
                    controller: _voiceQueryController,
                    style: GoogleFonts.hindSiliguri(fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: isBn
                          ? 'আপনার প্রশ্নটি লিখুন বা বলুন...'
                          : 'Type or ask your question here...',
                      hintStyle: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade400),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: bottleGreen, width: 1.5),
                      ),
                      prefixIcon: const Icon(Icons.psychology_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.mic, color: bottleGreen),
                        tooltip: isBn ? 'ভয়েস দিয়ে ইনপুট দিন' : 'Voice Input',
                        onPressed: () {
                          // Prefill top suggested question
                          _voiceQueryController.text = quickPrompts.first;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Submit CTA
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final query = _voiceQueryController.text.trim();
                        if (query.isEmpty) return;
                        Navigator.pop(modalCtx);
                        final answer = await controller.processVoiceQuery(query, isBn);
                        _voiceQueryController.clear();
                        if (context.mounted) {
                          _showAnswerDialog(context, query, answer, isBn);
                        }
                      },
                      icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                      label: Text(
                        isBn ? 'এআই থেকে সঠিক পরামর্শ নিন' : 'Consult Gemini AI',
                        style: GoogleFonts.hindSiliguri(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
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
          );
        },
      ),
    );
  }

  void _showAnswerDialog(BuildContext context, String question, String answer, bool isBn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.amber, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isBn ? 'Gemini AI অডিট রিপোর্ট' : 'Gemini AI Farm Audit',
                style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    '${isBn ? "প্রশ্ন" : "Query"}: "$question"',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    answer,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 13.5,
                      height: 1.45,
                      color: darkSlate,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: answer));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isBn ? 'পরামর্শ কপি করা হয়েছে!' : 'Copied to clipboard!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: Text(
              isBn ? 'কপি' : 'Copy',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: bottleGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              isBn ? 'ঠিক আছে' : 'Got it',
              style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold),
            ),
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
          isBn ? 'খামার বিশ্লেষণ ও স্মার্ট হাব ২.০' : 'Farm Analytics & Smart Hub 2.0',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        backgroundColor: bottleGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
            tooltip: isBn ? 'পিডিএফ অডিট স্টেটমেন্ট' : 'Export PDF Statement',
            onPressed: () => controller.exportPdfStatement(context, isBn),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => controller.onInit(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: harvestYellow,
          indicatorWeight: 3.5,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: [
            Tab(icon: const Icon(Icons.analytics_rounded, size: 20), text: isBn ? 'সারসংক্ষেপ ও চার্ট' : 'Overview & Charts'),
            Tab(icon: const Icon(Icons.grass_rounded, size: 20), text: isBn ? 'ব্যাচ ও সাইকেল' : 'Batches & Cycles'),
            Tab(icon: const Icon(Icons.calculate_rounded, size: 20), text: isBn ? 'লাভ সিমুলেটর' : 'Profit Simulator'),
            Tab(icon: const Icon(Icons.health_and_safety_rounded, size: 20), text: isBn ? 'রোগ ও IoT রাডার' : 'Disease & IoT Radar'),
            Tab(icon: const Icon(Icons.delete_outline_rounded, size: 20), text: isBn ? 'রিসাইকেল বিন' : 'Trash Bin'),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: bottleGreen));
        }

        return TabBarView(
          controller: _tabController,
          physics: const BouncingScrollPhysics(),
          children: [
            _buildTabOverview(context, isBn),
            _buildTabBatches(context, isBn),
            _buildTabSimulator(context, isBn),
            _buildTabDiseaseAndIoT(context, isBn),
            _buildTabTrashBin(context, isBn),
          ],
        );
      }),
    );
  }

  // ==========================================
  // TAB 1: OVERVIEW & fl_chart MULTI-BAR GRAPHS
  // ==========================================
  Widget _buildTabOverview(BuildContext context, bool isBn) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeframe Selectors
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTimeChip(AnalysisTimeframe.thisMonth, isBn ? 'চলতি মাস' : 'This Month'),
                const SizedBox(width: 8),
                _buildTimeChip(AnalysisTimeframe.thisSeason, isBn ? 'চলতি সিজন' : 'This Season'),
                const SizedBox(width: 8),
                _buildTimeChip(AnalysisTimeframe.last3Months, isBn ? '৩ মাস' : '3 Months'),
                const SizedBox(width: 8),
                _buildTimeChip(AnalysisTimeframe.thisYear, isBn ? 'চলতি বছর' : 'This Year'),
                const SizedBox(width: 8),
                _buildTimeChip(AnalysisTimeframe.allTime, isBn ? 'সর্বমোট' : 'All Time'),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // AI Voice Bot Header Banner
          _buildVoiceBanner(context, isBn),
          const SizedBox(height: 14),

          // 3-Metric KPI Grid
          _buildFinancialSummaryCards(isBn),
          const SizedBox(height: 16),

          // Interactive fl_chart Monthly Trend BarChart
          _buildMonthlyBarChartCard(isBn),
          const SizedBox(height: 16),

          // Operating Expense Distribution
          _buildExpenseDistributionCard(isBn),
          const SizedBox(height: 16),

          // Crop ROI Matrix
          _buildCropRoiMatrixCard(isBn),
          const SizedBox(height: 16),

          // Market Price Intelligence
          _buildMarketSellingIntelligenceCard(isBn),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTimeChip(AnalysisTimeframe timeframe, String label) {
    final isSelected = controller.selectedTimeframe.value == timeframe;
    return GestureDetector(
      onTap: () => controller.setTimeframe(timeframe),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? bottleGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? bottleGreen : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : darkSlate,
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceBanner(BuildContext context, bool isBn) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            bottleGreen.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: bottleGreen.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: bottleGreen.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _showVoiceAssistantDialog(context, isBn),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [bottleGreen, forestGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: bottleGreen.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.mic, color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isBn ? 'Gemini AI ভয়েস সহকারী ও ইনসাইটস' : 'Gemini AI Voice Agronomist',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: darkSlate,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.auto_awesome, color: harvestYellow, size: 14),
                      ],
                    ),
                    Text(
                      isBn
                          ? 'লাইভ ডেটা থেকে খামারের সঠিক বিশ্লেষণ ও সিদ্ধান্ত নিন।'
                          : 'Grounded live analysis of profit, FCR & market prices.',
                      style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _showVoiceAssistantDialog(context, isBn),
                style: ElevatedButton.styleFrom(
                  backgroundColor: bottleGreen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text(
                  isBn ? 'কথা বলুন' : 'Ask AI',
                  style: GoogleFonts.hindSiliguri(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0x1F000000)),
          const SizedBox(height: 10),
          // Masterclass Farm Calculator Shortcuts
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => FarmSmartCalculatorSheet.show(context, initialTab: 0),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.set_meal_outlined, size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            isBn ? 'ফিড ও FCR অপ্টিমাইজার' : 'Feed & FCR',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => FarmSmartCalculatorSheet.show(context, initialTab: 1),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.grass_outlined, size: 14, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            isBn ? 'সার ও পুষ্টি ডোজ' : 'Fertilizer Dosing',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E7D32),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummaryCards(bool isBn) {
    final rev = controller.totalRevenue;
    final exp = controller.totalExpense;
    final profit = controller.netProfit;
    final margin = controller.profitMarginPct;

    return Row(
      children: [
        Expanded(child: _buildKpiTile(isBn ? 'মোট আয়' : 'Total Revenue', '৳${rev.toStringAsFixed(0)}', Colors.green.shade700, Icons.arrow_upward_rounded)),
        const SizedBox(width: 8),
        Expanded(child: _buildKpiTile(isBn ? 'মোট ব্যয়' : 'Operating Cost', '৳${exp.toStringAsFixed(0)}', Colors.red.shade700, Icons.arrow_downward_rounded)),
        const SizedBox(width: 8),
        Expanded(child: _buildKpiTile(isBn ? 'নিট লাভ (${margin.toStringAsFixed(0)}%)' : 'Net Profit (${margin.toStringAsFixed(0)}%)', '৳${profit.toStringAsFixed(0)}', bottleGreen, Icons.account_balance_wallet_rounded)),
      ],
    );
  }

  Widget _buildKpiTile(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(child: Text(label, style: GoogleFonts.hindSiliguri(fontSize: 11, color: darkSlate, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // --- fl_chart BarChart ---
  Widget _buildMonthlyBarChartCard(bool isBn) {
    final trends = controller.monthlyFinancialTrend;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: bottleGreen, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isBn ? 'মাসিক আয় vs ব্যয়ের গতিবিধি' : 'Monthly Revenue vs Expense',
                  style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.bold, color: darkSlate),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              _buildLegend(Colors.green.shade600, isBn ? 'আয়' : 'Rev'),
              const SizedBox(width: 6),
              _buildLegend(Colors.red.shade400, isBn ? 'ব্যয়' : 'Exp'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 200000,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: darkSlate,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final isRev = rodIndex == 0;
                      return BarTooltipItem(
                        '${isRev ? (isBn ? "আয়" : "Rev") : (isBn ? "ব্যয়" : "Exp")}: ৳${rod.toY.toInt()}',
                        GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < trends.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              isBn ? trends[idx].monthNameBn : trends[idx].monthNameEn,
                              style: GoogleFonts.hindSiliguri(fontSize: 10, color: Colors.grey.shade700),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (val, meta) {
                        if (val % 50000 == 0) {
                          return Text('${(val / 1000).toInt()}k', style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 50000),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(trends.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(toY: trends[i].revenue, color: Colors.green.shade600, width: 9, borderRadius: BorderRadius.circular(4)),
                      BarChartRodData(toY: trends[i].expense, color: Colors.red.shade400, width: 9, borderRadius: BorderRadius.circular(4)),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
      ],
    );
  }

  Widget _buildExpenseDistributionCard(bool isBn) {
    final breakdown = controller.getExpenseBreakdown(isBn);
    final total = controller.totalExpense;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_outline_rounded, color: forestGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                isBn ? 'খরচের খাতভিত্তিক শতাংশ' : 'Expense Category Breakdown',
                style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: darkSlate),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...breakdown.entries.map((e) {
            final pct = total > 0 ? (e.value / total) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.w500)),
                      Text('৳${e.value.toStringAsFixed(0)} (${(pct * 100).toStringAsFixed(0)}%)', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        e.key.contains('Feed') || e.key.contains('ফিড') ? Colors.blue : (e.key.contains('Fertilizer') || e.key.contains('সার') ? Colors.green : (e.key.contains('Labor') || e.key.contains('শ্রমিক') ? Colors.orange : Colors.purple)),
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

  Widget _buildCropRoiMatrixCard(bool isBn) {
    final list = controller.cropRoiList;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assessment_outlined, color: bottleGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                isBn ? 'ফসলভিত্তিক উৎপাদন ও ROI লাভজনকতা' : 'Commodity Production & ROI Matrix',
                style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: darkSlate),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...list.map((item) {
            final name = isBn ? item.cropNameBn : item.cropNameEn;
            final unit = isBn ? item.unitBn : item.unitEn;
            final status = isBn ? item.statusBn : item.statusEn;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(
                          '${isBn ? "উৎপাদন" : "Yield"}: ${item.yieldAmount.toInt()} $unit | ${isBn ? "ব্যয়" : "Cost"}: ৳${item.cost.toInt()}',
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
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: item.roiPct >= 0 ? Colors.green.shade800 : Colors.red.shade700),
                        ),
                        Text(status, style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.w600)),
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

  Widget _buildMarketSellingIntelligenceCard(bool isBn) {
    final list = controller.marketOpportunities;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storefront_outlined, color: harvestYellow, size: 20),
              const SizedBox(width: 8),
              Text(
                isBn ? 'লাইভ বাজারদর ও সেরা বিক্রয়ের সুযোগ' : 'Live Market Trends & Selling Opportunities',
                style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: darkSlate),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...list.map((m) {
            final crop = isBn ? m.cropBn : m.cropEn;
            final market = isBn ? m.marketBn : m.marketEn;
            final rec = isBn ? m.recommendationBn : m.recommendationEn;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: (m.isFavorable ? Colors.green : Colors.red).withValues(alpha: 0.04), borderRadius: BorderRadius.circular(12), border: Border.all(color: (m.isFavorable ? Colors.green : Colors.red).withValues(alpha: 0.2))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(crop, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(
                        '${isBn ? "বর্তমান" : "Current"} ৳${m.currentPrice.toInt()} ➔ ${isBn ? "৭ দিনে" : "in 7d"} ৳${m.projectedPrice7Days.toInt()}',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: m.isFavorable ? Colors.green.shade800 : Colors.red.shade800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('$market • $rec', style: GoogleFonts.hindSiliguri(fontSize: 11, color: darkSlate, fontWeight: FontWeight.w500)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: REAL-TIME BATCHES & PRODUCTION CYCLES
  // ==========================================
  Widget _buildTabBatches(BuildContext context, bool isBn) {
    final batches = controller.activeBatches;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBatchModal(context, isBn),
        backgroundColor: bottleGreen,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          isBn ? 'নতুন ব্যাচ যোগ করুন' : 'Add New Batch',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn ? 'সক্রিয় খামার ব্যাচ ও চক্র (${batches.length}টি)' : 'Active Farm Batches & Cycles (${batches.length})',
                      style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold, color: darkSlate),
                    ),
                    Text(
                      isBn ? 'রিয়েল-টাইম লাইফসাইকেল, FCR ও বায়োমাস ট্র্যাকিং' : 'Real-time lifecycle, FCR & biomass tracking',
                      style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...batches.map((b) => _buildBatchCard(b, isBn)),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchCard(FarmBatchModel b, bool isBn) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(b.batchName, style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.bold, color: darkSlate)),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                onSelected: (val) {
                  if (val == 'delete') {
                    controller.softDeleteBatch(b.id, isBn);
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Text(isBn ? 'আর্কাইভে পাঠান (Soft Delete)' : 'Move to Trash Bin', style: const TextStyle(color: Colors.red, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: bottleGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(b.commodityType, style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.bold, color: bottleGreen)),
              ),
              const SizedBox(width: 8),
              Text('${isBn ? "শুরু" : "Started"}: ${DateFormat('dd MMM yyyy').format(b.startDate)}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 12),

          // Cycle Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isBn ? '${b.daysElapsed} দিন চলমান / মোট ${b.cycleDurationDays} দিন' : '${b.daysElapsed} days elapsed / Total ${b.cycleDurationDays} days',
                style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.w600, color: darkSlate),
              ),
              Text(
                isBn ? '${(b.progressFraction * 100).toInt()}% সম্পন্ন' : '${(b.progressFraction * 100).toInt()}% Done',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: forestGreen),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(value: b.progressFraction, minHeight: 7, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(forestGreen)),
          ),
          const SizedBox(height: 14),

          // 4 Metric Pill Grid
          Row(
            children: [
              Expanded(child: _buildMiniStat(isBn ? 'বর্তমান বায়োমাস' : 'Current Biomass', '${b.currentBiomassKg.toInt()} kg')),
              const SizedBox(width: 8),
              Expanded(child: _buildMiniStat(isBn ? 'FCR স্কোর' : 'FCR Score', b.fcr.toStringAsFixed(2))),
              const SizedBox(width: 8),
              Expanded(child: _buildMiniStat(isBn ? 'সারভাইভাল রেট' : 'Survival Rate', '${b.survivalRatePct.toStringAsFixed(1)}%')),
              const SizedBox(width: 8),
              Expanded(child: _buildMiniStat(isBn ? 'বিনিয়োগ' : 'Investment', '৳${b.totalInvestedCost.toInt()}')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.hindSiliguri(fontSize: 10, color: Colors.grey.shade700), textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(val, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: darkSlate), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: BREAK-EVEN & PROFIT WHAT-IF SIMULATOR
  // ==========================================
  Widget _buildTabSimulator(BuildContext context, bool isBn) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isBn ? 'ব্রেক-ইভেন ও লাভ-লোকসান সিমুলেটর' : 'Break-Even & Profit Simulator',
            style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold, color: darkSlate),
          ),
          Text(
            isBn ? 'ইনপুট খরচ ও বাজারদর পরিবর্তন করে সম্ভাব্য মার্জিন ও ব্রেক-ইভেন মূল্য পরীক্ষা করুন।' : 'Simulate margin and break-even price by adjusting input costs and market rates.',
            style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          // Simulator Live Result Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [bottleGreen, forestGreen], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isBn ? 'ব্রেক-ইভেন মূল্য (Break-Even):' : 'Break-Even Price:', style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.white70)),
                    Text(
                      '৳${controller.simBreakEvenPrice.toStringAsFixed(1)} ${isBn ? "/কেজি" : "/kg"}',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isBn ? 'এই মূল্যের নিচে বিক্রি করলে লোকসান হবে।' : 'Selling below this price will result in net loss.',
                  style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.white70),
                ),
                const Divider(color: Colors.white24, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSimResultTile(isBn ? 'মোট উৎপাদন ব্যয়' : 'Total Production Cost', '৳${controller.simTotalCost.toStringAsFixed(0)}'),
                    _buildSimResultTile(isBn ? 'প্রত্যাশিত মোট আয়' : 'Expected Gross Revenue', '৳${controller.simTotalRevenue.toStringAsFixed(0)}'),
                    _buildSimResultTile(isBn ? 'প্রত্যাশিত নিট লাভ' : 'Expected Net Profit', '৳${controller.simNetProfit.toStringAsFixed(0)} (${controller.simProfitMarginPct.toStringAsFixed(0)}%)'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Sliders Control Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSliderControl(
                  label: isBn ? 'প্রত্যাশিত মোট উৎপাদন' : 'Expected Total Production',
                  valueStr: '${controller.simExpectedYieldKg.value.toInt()} ${isBn ? "কেজি" : "kg"}',
                  value: controller.simExpectedYieldKg.value,
                  min: 100,
                  max: 10000,
                  onChanged: (v) => controller.simExpectedYieldKg.value = v,
                ),
                const SizedBox(height: 12),
                _buildSliderControl(
                  label: isBn ? 'প্রতি কেজিতে ফিড/সার ও উপাদান ব্যয়' : 'Feed/Fertilizer Cost per KG',
                  valueStr: '৳${controller.simInputCostPerKg.value.toInt()}',
                  value: controller.simInputCostPerKg.value,
                  min: 20,
                  max: 500,
                  onChanged: (v) => controller.simInputCostPerKg.value = v,
                ),
                const SizedBox(height: 12),
                _buildSliderControl(
                  label: isBn ? 'স্থায়ী ওভারহেড ব্যয় (সেচ, বিদ্যুৎ, শ্রম)' : 'Fixed Overhead Cost (Labor, Energy)',
                  valueStr: '৳${controller.simFixedOverheadCost.value.toInt()}',
                  value: controller.simFixedOverheadCost.value,
                  min: 5000,
                  max: 200000,
                  onChanged: (v) => controller.simFixedOverheadCost.value = v,
                ),
                const SizedBox(height: 12),
                _buildSliderControl(
                  label: isBn ? 'প্রত্যাশিত বাজার বিক্রয়মূল্য' : 'Expected Market Selling Price',
                  valueStr: '৳${controller.simSellingPricePerKg.value.toInt()} ${isBn ? "/কেজি" : "/kg"}',
                  value: controller.simSellingPricePerKg.value,
                  min: 30,
                  max: 600,
                  onChanged: (v) => controller.simSellingPricePerKg.value = v,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimResultTile(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.hindSiliguri(fontSize: 10, color: Colors.white70)),
        const SizedBox(height: 2),
        Text(val, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildSliderControl({
    required String label,
    required String valueStr,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.w600, color: darkSlate)),
            Text(valueStr, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: bottleGreen)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: bottleGreen,
          inactiveColor: Colors.grey.shade200,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // ==========================================
  // TAB 4: IoT, SOIL & SEASONAL DISEASE RADAR
  // ==========================================
  Widget _buildTabDiseaseAndIoT(BuildContext context, bool isBn) {
    final water = controller.getWaterQualityMetrics(isBn);
    final alerts = controller.seasonalDiseaseAlerts;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Water & Soil Health Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.water_drop_outlined, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      isBn ? 'পানির গুণমান ও মাটির IoT লাইভ সূচক' : 'Water Quality & Soil IoT Live Metrics',
                      style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.bold, color: darkSlate),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildHealthPill(isBn ? 'অক্সিজেন (DO)' : 'Dissolved O2', '${water['do']['value']} mg/L', Colors.green)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildHealthPill(isBn ? 'পিএইচ (pH)' : 'pH Level', '${water['ph']['value']}', Colors.green)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildHealthPill(isBn ? 'অ্যামোনিয়া' : 'Ammonia', '${water['ammonia']['value']} ppm', Colors.green)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildHealthPill(isBn ? 'তাপমাত্রা' : 'Temperature', '${water['temp']['value']} °C', Colors.blue)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Seasonal Disease Radar
          Text(
            isBn ? 'মৌসুমী রোগ ও কীটপতঙ্গ প্রতিরোধ রাডার' : 'Seasonal Disease & Pest Radar',
            style: GoogleFonts.hindSiliguri(fontSize: 17, fontWeight: FontWeight.bold, color: darkSlate),
          ),
          Text(
            isBn ? 'আবহাওয়ার পরিবর্তনের সাথে রোগ প্রাদুর্ভাব সতর্কতা ও প্রতিকার' : 'Proactive outbreak warnings & recommended remedies with weather shifts',
            style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),

          ...alerts.map((a) {
            final name = isBn ? a.diseaseNameBn : a.diseaseNameEn;
            final target = isBn ? a.targetCommodityBn : a.targetCommodityEn;
            final risk = isBn ? a.riskLevelBn : a.riskLevelEn;
            final symptoms = isBn ? a.symptomsBn : a.symptomsEn;
            final prev = isBn ? a.preventiveActionBn : a.preventiveActionEn;
            final med = isBn ? a.recommendedMedicineBn : a.recommendedMedicineEn;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: a.riskColor.withValues(alpha: 0.3))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(name, style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.bold, color: darkSlate))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: a.riskColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(risk, style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.bold, color: a.riskColor)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${isBn ? "আক্রান্ত ফসল/মাছ" : "Target Commodity"}: $target', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text('${isBn ? "লক্ষণ" : "Symptoms"}: $symptoms', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text('${isBn ? "প্রতিরোধ ব্যবস্থা" : "Prevention"}: $prev', style: GoogleFonts.hindSiliguri(fontSize: 12, color: forestGreen, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${isBn ? "প্রস্তাবিত ওষুধ" : "Recommended Rx"}: $med', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.blue.shade800, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHealthPill(String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.hindSiliguri(fontSize: 10, color: Colors.grey.shade700), textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(val, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 5: ARCHIVED & TRASH BIN (SOFT DELETE RESTORE)
  // ==========================================
  Widget _buildTabTrashBin(BuildContext context, bool isBn) {
    final deleted = controller.deletedBatches;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restore_from_trash_rounded, color: Colors.orange.shade800, size: 24),
              const SizedBox(width: 8),
              Text(
                isBn ? 'আর্কাইভ ও রিসাইকেল বিন (${deleted.length}টি)' : 'Archive & Trash Bin (${deleted.length})',
                style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold, color: darkSlate),
              ),
            ],
          ),
          Text(
            isBn ? 'মুছে ফেলা ব্যাচ বা রেকর্ড এখান থেকে যে কোনো সময় পুনরুদ্ধার করতে পারবেন।' : 'Restore any soft-deleted batch or record back to active lists at any time.',
            style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          if (deleted.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Icon(Icons.delete_sweep_outlined, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      isBn ? 'রিসাইকেল বিন বর্তমানে খালি।' : 'Trash bin is currently empty.',
                      style: GoogleFonts.hindSiliguri(fontSize: 15, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          else
            ...deleted.map((b) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.orange.shade200)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(b.batchName, style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.bold, color: darkSlate))),
                        Text(
                          b.deletedAt != null ? DateFormat('dd MMM, hh:mm a').format(b.deletedAt!) : (isBn ? 'আর্কাইভকৃত' : 'Archived'),
                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${isBn ? "ক্যাটাগরি" : "Category"}: ${b.commodityType} | ${isBn ? "লক্ষ্যমাত্রা" : "Target"}: ${b.targetYieldKg.toInt()} kg',
                      style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => controller.permanentDeleteBatch(b.id, isBn),
                          icon: const Icon(Icons.delete_forever, color: Colors.red, size: 16),
                          label: Text(
                            isBn ? 'স্থায়ীভাবে মুছুন' : 'Delete Forever',
                            style: GoogleFonts.hindSiliguri(color: Colors.red, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => controller.restoreBatch(b.id, isBn),
                          icon: const Icon(Icons.restore_rounded, color: Colors.white, size: 16),
                          label: Text(
                            isBn ? 'পুনরুদ্ধার করুন (Restore)' : 'Restore Record',
                            style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(backgroundColor: bottleGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
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
}
