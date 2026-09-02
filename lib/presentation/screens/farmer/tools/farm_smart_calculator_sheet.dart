import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/controllers/farmer_analysis_controller.dart';

/// Masterclass Smart Farm Tools & Scientific Dose Calculator Bottom Sheet
class FarmSmartCalculatorSheet extends StatefulWidget {
  final int initialTabIndex;
  const FarmSmartCalculatorSheet({super.key, this.initialTabIndex = 0});

  static void show(BuildContext context, {int initialTab = 0}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FarmSmartCalculatorSheet(initialTabIndex: initialTab),
    );
  }

  @override
  State<FarmSmartCalculatorSheet> createState() => _FarmSmartCalculatorSheetState();
}

class _FarmSmartCalculatorSheetState extends State<FarmSmartCalculatorSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FarmerAnalysisController controller = Get.find<FarmerAnalysisController>();

  final Color bottleGreen = const Color(0xFF006A4E);
  final Color forestGreen = const Color(0xFF2E7D32);
  final Color darkSlate = const Color(0xFF0F172A);

  // Feeding State
  double _feedBiomassKg = 2500;
  double _waterTempC = 28.5;
  double _customFeedRatePct = 3.2;

  // Fertilizer State
  String _selectedCrop = 'ধান (Boro Rice)';
  double _landArea = 33; // 1 Bigha
  String _areaUnit = 'decimal';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isBn = LanguageProvider.isBn(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
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
          const SizedBox(height: 12),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: bottleGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.calculate_rounded, color: bottleGreen, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBn ? 'স্মার্ট খামার ক্যালকুলেটর ও অপ্টিমাইজার' : 'Smart Farm Calculators & Optimizer',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkSlate,
                        ),
                      ),
                      Text(
                        isBn ? 'অপচয়হীন খাদ্য ও বৈজ্ঞানিক সার প্রয়োগের সঠিক হিসাব' : 'Zero-waste feed & scientific fertilizer dosing',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Tabs
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: bottleGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: darkSlate,
              labelStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: [
                Tab(
                  icon: const Icon(Icons.set_meal_outlined, size: 18),
                  text: isBn ? 'মাছের দৈনিক খাদ্য ও FCR' : 'Fish Feed & FCR',
                ),
                Tab(
                  icon: const Icon(Icons.grass_outlined, size: 18),
                  text: isBn ? 'সার ও পুষ্টি ডোজ' : 'Fertilizer Dosing',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFeedingTab(isBn),
                _buildFertilizerTab(isBn),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: SMART FEEDING & FCR OPTIMIZER
  // ==========================================
  Widget _buildFeedingTab(bool isBn) {
    final feedData = controller.calculateSmartFeed(
      biomassKg: _feedBiomassKg,
      waterTempC: _waterTempC,
      customFeedingRatePct: _customFeedRatePct,
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Feed Summary Result Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [bottleGreen, forestGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: bottleGreen.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isBn ? 'দৈনিক মোট খাবার প্রয়োজন:' : 'Total Daily Feed Required:',
                      style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 13),
                    ),
                    Text(
                      '${(feedData['totalDailyFeedKg'] as double).toStringAsFixed(1)} ${isBn ? "কেজি" : "kg"}',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.amberAccent,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white24, height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFeedDosePill(
                      isBn ? 'সকাল ৮:০০ (৪০%)' : 'Morning 8 AM (40%)',
                      '${(feedData['morningFeedKg'] as double).toStringAsFixed(1)} kg',
                      Icons.wb_sunny_outlined,
                    ),
                    _buildFeedDosePill(
                      isBn ? 'বিকাল ৪:৩০ (৬০%)' : 'Evening 4:30 PM (60%)',
                      '${(feedData['afternoonFeedKg'] as double).toStringAsFixed(1)} kg',
                      Icons.nights_stay_outlined,
                    ),
                    _buildFeedDosePill(
                      isBn ? 'লক্ষ্যমাত্রা FCR' : 'Target FCR',
                      '< ${(feedData['projectedFcr'] as double).toStringAsFixed(2)}',
                      Icons.speed_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Inputs Section
          Text(
            isBn ? 'খামারের প্যারামিটার সেট করুন:' : 'Set Farm Parameters:',
            style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14, color: darkSlate),
          ),
          const SizedBox(height: 10),

          // 1. Total Biomass Slider
          _buildSliderItem(
            label: isBn ? 'পুকুরের আনুমানিক মোট বায়োমাস (মাছ)' : 'Total Estimated Fish Biomass',
            valueStr: '${_feedBiomassKg.toInt()} ${isBn ? "কেজি" : "kg"}',
            value: _feedBiomassKg,
            min: 100,
            max: 10000,
            onChanged: (v) => setState(() => _feedBiomassKg = v),
          ),
          const SizedBox(height: 12),

          // 2. Water Temperature Slider
          _buildSliderItem(
            label: isBn ? 'পানির বর্তমান তাপমাত্রা (IoT রিডিং)' : 'Current Water Temperature',
            valueStr: '${_waterTempC.toStringAsFixed(1)} °C',
            value: _waterTempC,
            min: 15,
            max: 36,
            onChanged: (v) {
              setState(() {
                _waterTempC = v;
                if (_waterTempC >= 28) _customFeedRatePct = 3.2;
                else if (_waterTempC >= 24) _customFeedRatePct = 2.5;
                else if (_waterTempC >= 20) _customFeedRatePct = 1.5;
                else _customFeedRatePct = 0.8;
              });
            },
          ),
          const SizedBox(height: 12),

          // 3. Body Weight Feeding Rate Slider
          _buildSliderItem(
            label: isBn ? 'দৈহিক ওজনের খাদ্য হার (% Body Weight)' : 'Feeding Rate (% of Body Weight)',
            valueStr: '${_customFeedRatePct.toStringAsFixed(1)}%',
            value: _customFeedRatePct,
            min: 0.5,
            max: 6.0,
            onChanged: (v) => setState(() => _customFeedRatePct = v),
          ),
          const SizedBox(height: 14),

          // Scientific Guidance Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isBn
                        ? '💡 বৈজ্ঞানিক পরামর্শ: শীতকালে বা তাপমাত্রা ২০°C-এর নিচে নামলে খাবারের পরিমাণ ৪০-৫০% কমিয়ে দিন যাতে পুকুরের তলদেশে খাবার পচে অ্যামোনিয়া গ্যাস সৃষ্টি না হয়।'
                        : '💡 Advisory: Reduce feed by 40-50% if water temperature drops below 20°C to prevent bottom accumulation and ammonia spikes.',
                    style: GoogleFonts.hindSiliguri(fontSize: 11.5, color: Colors.blue.shade900, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedDosePill(String title, String val, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 4),
        Text(val, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        Text(title, style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  // ==========================================
  // TAB 2: SCIENTIFIC FERTILIZER & NUTRIENT DOSING
  // ==========================================
  Widget _buildFertilizerTab(bool isBn) {
    final dose = controller.calculateFertilizerDose(
      cropType: _selectedCrop,
      landArea: _landArea,
      areaUnit: _areaUnit,
    );

    final crops = isBn
        ? ['ধান (Boro Rice)', 'আলু (Potato)', 'টমেটো ও সবজি (Tomato & Veg)', 'ভুট্টা (Maize)', 'সরিষা (Mustard)']
        : ['Boro Rice', 'Potato', 'Tomato & Veg', 'Maize', 'Mustard'];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selectors
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCrop,
                  decoration: InputDecoration(
                    labelText: isBn ? 'ফসলের ধরন' : 'Crop Type',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  items: crops
                      .map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.hindSiliguri(fontSize: 12))))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCrop = v ?? _selectedCrop),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: _areaUnit,
                  decoration: InputDecoration(
                    labelText: isBn ? 'জমির একক' : 'Unit',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  items: [
                    DropdownMenuItem(value: 'decimal', child: Text(isBn ? 'শতক' : 'Decimal', style: GoogleFonts.hindSiliguri(fontSize: 12))),
                    DropdownMenuItem(value: 'bigha', child: Text(isBn ? 'বিঘা (৩৩ শতক)' : 'Bigha (33 Dec)', style: GoogleFonts.hindSiliguri(fontSize: 12))),
                    DropdownMenuItem(value: 'acre', child: Text(isBn ? 'একর (১০০ শতক)' : 'Acre (100 Dec)', style: GoogleFonts.hindSiliguri(fontSize: 12))),
                  ],
                  onChanged: (v) => setState(() => _areaUnit = v ?? _areaUnit),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Land Size Slider
          _buildSliderItem(
            label: isBn ? 'জমির মোট পরিমাণ' : 'Total Land Size',
            valueStr: '${_landArea.toInt()} ${_areaUnit == "decimal" ? (isBn ? "শতক" : "Dec") : (_areaUnit == "bigha" ? (isBn ? "বিঘা" : "Bigha") : (isBn ? "একর" : "Acre"))}',
            value: _landArea,
            min: 1,
            max: 200,
            onChanged: (v) => setState(() => _landArea = v),
          ),
          const SizedBox(height: 16),

          // Dose Results Grid
          Text(
            isBn ? 'সুপারিশকৃত বৈজ্ঞানিক সারের পরিমাণ:' : 'Recommended Fertilizer Doses:',
            style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14, color: darkSlate),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(child: _buildFertilizerTile(isBn ? 'ইউরিয়া (Urea)' : 'Urea', '${(dose['ureaKg'] as double).toStringAsFixed(1)} kg', Colors.blue)),
              const SizedBox(width: 8),
              Expanded(child: _buildFertilizerTile(isBn ? 'টিএসপি (TSP)' : 'TSP', '${(dose['tspKg'] as double).toStringAsFixed(1)} kg', Colors.brown)),
              const SizedBox(width: 8),
              Expanded(child: _buildFertilizerTile(isBn ? 'এমওপি (MoP)' : 'MoP Potash', '${(dose['mopKg'] as double).toStringAsFixed(1)} kg', Colors.red.shade700)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildFertilizerTile(isBn ? 'জিপসাম (Gypsum)' : 'Gypsum', '${(dose['gypsumKg'] as double).toStringAsFixed(1)} kg', Colors.teal)),
              const SizedBox(width: 8),
              Expanded(child: _buildFertilizerTile(isBn ? 'জিংক (Zinc)' : 'Zinc Sulphate', '${(dose['zincKg'] as double).toStringAsFixed(2)} kg', Colors.orange.shade800)),
            ],
          ),
          const SizedBox(height: 14),

          // Urea Application Schedule Split
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.schedule, color: Color(0xFF2E7D32), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      isBn ? 'ইউরিয়া প্রয়োগের ৩টি ধাপ (Split Application):' : 'Urea Split Application Schedule:',
                      style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isBn
                      ? '১. জমি প্রস্তুতকালে (বেসাল): ${(dose['ureaSplitBasal'] as double).toStringAsFixed(1)} কেজি\n'
                        '২. চারা রোপণের ২০-২৫ দিনে (প্রথম উপরি): ${(dose['ureaSplitFirstTop'] as double).toStringAsFixed(1)} কেজি\n'
                        '৩. কাইচ থোড় আসার ৫-৭ দিন পূর্বে (দ্বিতীয় উপরি): ${(dose['ureaSplitSecondTop'] as double).toStringAsFixed(1)} কেজি'
                      : '1. Basal at Land Prep: ${(dose['ureaSplitBasal'] as double).toStringAsFixed(1)} kg\n'
                        '2. 1st Top Dressing (20-25 DAT): ${(dose['ureaSplitFirstTop'] as double).toStringAsFixed(1)} kg\n'
                        '3. 2nd Top Dressing (Panicle Initiation): ${(dose['ureaSplitSecondTop'] as double).toStringAsFixed(1)} kg',
                  style: GoogleFonts.hindSiliguri(fontSize: 12, height: 1.4, color: darkSlate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFertilizerTile(String name, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.w600, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(amount, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: darkSlate)),
        ],
      ),
    );
  }

  Widget _buildSliderItem({
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
            Text(label, style: GoogleFonts.hindSiliguri(fontSize: 12.5, fontWeight: FontWeight.w600, color: darkSlate)),
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
}
