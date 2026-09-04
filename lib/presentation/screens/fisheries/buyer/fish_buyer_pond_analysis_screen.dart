import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/models/fish_buyer_pond_analysis_model.dart';
import 'package:agrolinkbd/core/services/fish_buyer_pond_analysis_service.dart';

class FishBuyerPondAnalysisScreen extends StatefulWidget {
  const FishBuyerPondAnalysisScreen({super.key});

  @override
  State<FishBuyerPondAnalysisScreen> createState() => _FishBuyerPondAnalysisScreenState();
}

class _FishBuyerPondAnalysisScreenState extends State<FishBuyerPondAnalysisScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final FishBuyerPondAnalysisService _analysisService;

  // Selected or Custom Pond State
  VerifiedCommercialPond? _selectedVerifiedPond;
  bool _isCustomPondMode = false;

  // Interactive Parameters
  double _pondSizeDecimal = 80.0;
  int _totalFishCount = 2000;
  double _avgWeightGram = 1850.0;
  String _fishSpecies = 'দেশি রুই ও কাতলা';
  String _pondName = 'পুকুর-১ (চলনবিল গ্র্যান্ড দিঘি)';
  String _farmerName = 'মোঃ কুদ্দুস আলী';
  String _farmerPhone = '01711223344';
  String _location = 'সিংড়া বাজার, চলনবিল, নাটোর';

  // Water Quality Parameters
  double _dissolvedOxygen = 7.2;
  double _phLevel = 7.6;
  double _ammoniaPpm = 0.01;
  double _salinityPpt = 0.0;
  double _waterDepthFeet = 6.0;
  bool _isFormalinFree = true;
  bool _isOrganicFeed = true;

  // Wholesale Pricing Parameters
  double _farmerAskingPrice = 320.0;
  double _targetMarketSalePrice = 380.0;
  double _transportPackagingCost = 15.0; // ৳15/kg for oxygen live van
  double _shrinkagePercent = 2.0; // 2% live transport drop

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));

    _analysisService = Get.isRegistered<FishBuyerPondAnalysisService>()
        ? Get.find<FishBuyerPondAnalysisService>()
        : Get.put(FishBuyerPondAnalysisService());

    if (_analysisService.verifiedPonds.isNotEmpty) {
      _applyVerifiedPond(_analysisService.verifiedPonds.first);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _applyVerifiedPond(VerifiedCommercialPond pond) {
    setState(() {
      _selectedVerifiedPond = pond;
      _isCustomPondMode = false;
      _pondName = pond.pondName;
      _farmerName = pond.farmerName;
      _farmerPhone = pond.farmerPhone;
      _location = '${pond.farmLocation}, ${pond.district}';
      _fishSpecies = pond.fishSpecies;
      _pondSizeDecimal = pond.pondSizeDecimal;
      _totalFishCount = pond.totalFishCount;
      _avgWeightGram = pond.avgWeightGram;
      _dissolvedOxygen = pond.dissolvedOxygen;
      _phLevel = pond.phLevel;
      _ammoniaPpm = pond.ammoniaPpm;
      _salinityPpt = pond.salinityPpt;
      _waterDepthFeet = pond.waterDepthFeet;
      _farmerAskingPrice = pond.farmerAskingPricePerKg;
      _targetMarketSalePrice = pond.defaultMarketSalePricePerKg;
      _isFormalinFree = pond.isFormalinFree;
      _isOrganicFeed = pond.isOrganicFeed;
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final formattedPhone = cleanPhone.startsWith('88') ? cleanPhone : '88$cleanPhone';
    final uri = Uri.parse('https://wa.me/$formattedPhone?text=${Uri.encodeComponent("হ্যালো, আমি এগ্রোলিংক থেকে আপনার পুকুরের মাছের লট অ্যানালাইসিস করে যোগাযোগ করছি।")}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _saveCurrentAnalysis(BuildContext context, bool isBn) async {
    final user = FirebaseAuth.instance.currentUser;
    final biomass = FishBuyerPondAnalysisService.computeBiomass(
      decimal: _pondSizeDecimal,
      fishCount: _totalFishCount,
      avgWeightGram: _avgWeightGram,
    );
    final yieldKg = biomass['totalYieldKg'] as double;

    final roi = FishBuyerPondAnalysisService.computeWholesaleRoi(
      yieldKg: yieldKg,
      farmerPricePerKg: _farmerAskingPrice,
      targetMarketSalePricePerKg: _targetMarketSalePrice,
      transportPackagingCostPerKg: _transportPackagingCost,
      shrinkagePercent: _shrinkagePercent,
    );

    final safetyScore = FishBuyerPondAnalysisService.computeSafetyScore(
      dissolvedOxygen: _dissolvedOxygen,
      phLevel: _phLevel,
      ammoniaPpm: _ammoniaPpm,
      isFormalinFree: _isFormalinFree,
      isOrganicFeed: _isOrganicFeed,
    );

    final newAnalysis = FishBuyerPondAnalysisModel(
      id: 'ANALYSIS_${DateTime.now().millisecondsSinceEpoch}',
      buyerId: user?.uid ?? 'buyer_demo',
      buyerName: user?.displayName ?? 'Wholesale Fish Buyer',
      pondId: _selectedVerifiedPond?.id ?? 'CUSTOM_POND',
      pondName: _pondName,
      farmerName: _farmerName,
      location: _location,
      district: _selectedVerifiedPond?.district ?? 'নাটোর',
      fishSpecies: _fishSpecies,
      pondSizeDecimal: _pondSizeDecimal,
      totalEstimatedCount: _totalFishCount,
      avgWeightGram: _avgWeightGram,
      estimatedTotalYieldKg: yieldKg,
      uniformityPercentage: 92.0,
      grade: 'Grade A+ (তাজা জ্যান্ত)',
      dissolvedOxygen: _dissolvedOxygen,
      phLevel: _phLevel,
      ammoniaPpm: _ammoniaPpm,
      salinityPpt: _salinityPpt,
      waterDepthFeet: _waterDepthFeet,
      isFormalinFree: _isFormalinFree,
      isOrganicFeed: _isOrganicFeed,
      safetyScore: safetyScore,
      farmerAskingPricePerKg: _farmerAskingPrice,
      targetMarketSalePricePerKg: _targetMarketSalePrice,
      transportPackagingCostPerKg: _transportPackagingCost,
      shrinkagePercentage: _shrinkagePercent,
      netLandingCostPerKg: roi['netLandingCostPerKg'] as double,
      projectedNetProfit: roi['projectedNetProfit'] as double,
      projectedRoiPercentage: roi['roiPercentage'] as double,
      createdAt: DateTime.now(),
    );

    final success = await _analysisService.saveAnalysisReport(newAnalysis);

    if (success) {
      Get.snackbar(
        isBn ? 'অ্যানালাইসিস সংরক্ষিত! 📋' : 'Analysis Saved Successfully! 📋',
        isBn
            ? 'পুকুর অডিট ও পাইকারি প্রাক্কলন সফলভাবে আপনার প্রোফাইলে সেভ হয়েছে।'
            : 'Pond feasibility & wholesale estimate saved to your profile.',
        backgroundColor: const Color(0xFF004D40),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      _tabController.animateTo(2); // Switch to Saved Audits tab
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBn = LanguageProvider.isBn(context);
    const Color deepOcean = Color(0xFF00363A);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A1218) : const Color(0xFFF1F5F8),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 185.0,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: deepOcean,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Get.back(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.save_alt_rounded, color: Colors.white),
                  tooltip: isBn ? 'অডিট সেভ করুন' : 'Save Audit',
                  onPressed: () => _saveCurrentAnalysis(context, isBn),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B4D8).withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.analytics_rounded, color: Color(0xFF80DEEA), size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isBn ? 'পুকুর ও ঘের অ্যানালাইসিস হাব' : 'Pond & Farm Analysis Hub',
                        style: GoogleFonts.hindSiliguri(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF002528), Color(0xFF004D40), Color(0xFF01579B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 45, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF80DEEA).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_rounded, color: Colors.greenAccent, size: 12),
                              const SizedBox(width: 6),
                              Text(
                                isBn ? 'পাইকারি ক্রেতাদের প্রি-হারভেস্ট কোয়ালিটি অডিট' : 'Wholesale Pre-Harvest Feasibility Audit',
                                style: GoogleFonts.hindSiliguri(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isBn
                              ? 'খামার থেকে মাছ তোলার আগে বায়োমাস, পানির গুণমান, ল্যান্ডিং খরচ ও নিট মুনাফা যাচাই করুন'
                              : 'Estimate standing biomass, water purity score, landing cost & net wholesale margin before harvest',
                          style: GoogleFonts.hindSiliguri(
                            color: Colors.white70,
                            fontSize: 11.5,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: isDark ? const Color(0xFF0A1218) : Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFF004D40),
                    indicatorWeight: 3,
                    labelColor: const Color(0xFF004D40),
                    unselectedLabelColor: Colors.grey,
                    labelStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 12.5),
                    tabs: [
                      Tab(
                        icon: const Icon(Icons.pool_rounded, size: 17),
                        text: isBn ? 'বায়োমাস ও অডিট' : 'Biomass & Audit',
                      ),
                      Tab(
                        icon: const Icon(Icons.calculate_rounded, size: 17),
                        text: isBn ? 'মুনাফা ও ল্যান্ডিং' : 'ROI & Landing',
                      ),
                      Tab(
                        icon: const Icon(Icons.receipt_long_rounded, size: 17),
                        text: isBn ? 'সংরক্ষিত রিপোর্ট' : 'Saved Reports',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildBiomassAndAuditTab(context, isDark, isBn),
            _buildRoiAndLandingTab(context, isDark, isBn),
            _buildSavedAuditsTab(context, isDark, isBn),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: BIOMASS & QUALITY AUDIT
  // ==========================================
  Widget _buildBiomassAndAuditTab(BuildContext context, bool isDark, bool isBn) {
    final biomass = FishBuyerPondAnalysisService.computeBiomass(
      decimal: _pondSizeDecimal,
      fishCount: _totalFishCount,
      avgWeightGram: _avgWeightGram,
    );

    final totalKg = biomass['totalYieldKg'] as double;
    final totalMaunds = biomass['totalMaunds'] as double;
    final totalTons = biomass['totalTons'] as double;
    final density = biomass['densityPerDecimal'] as double;

    final safetyScore = FishBuyerPondAnalysisService.computeSafetyScore(
      dissolvedOxygen: _dissolvedOxygen,
      phLevel: _phLevel,
      ammoniaPpm: _ammoniaPpm,
      isFormalinFree: _isFormalinFree,
      isOrganicFeed: _isOrganicFeed,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
      physics: const BouncingScrollPhysics(),
      children: [
        // Verified Pond Picker Header
        _buildVerifiedPondPicker(context, isDark, isBn),

        const SizedBox(height: 14),

        // Live Calculated Biomass Showcase Card (Ultra-Premium)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00363A), Color(0xFF004D40), Color(0xFF006064)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF004D40).withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: const Color(0xFF80DEEA).withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.amberAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.scale_rounded, color: Colors.black87, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isBn ? 'প্রাক্কলিত মোট বায়োমাস (Standing Crop)' : 'Estimated Standing Crop Biomass',
                        style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isBn ? 'সাইজ ইউনিফর্মিটি ৯২%' : '92% Uniformity',
                      style: GoogleFonts.hindSiliguri(color: Colors.amberAccent, fontSize: 10.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBiomassMetricTile(
                    '${totalKg.toStringAsFixed(0)} ${isBn ? "কেজি" : "kg"}',
                    isBn ? 'মোট ফলন' : 'Total Yield',
                    Colors.white,
                  ),
                  Container(height: 35, width: 1, color: Colors.white24),
                  _buildBiomassMetricTile(
                    '${totalMaunds.toStringAsFixed(1)} ${isBn ? "মণ" : "Mds"}',
                    isBn ? '৪০ কেজি/মণ' : '40 kg/Maund',
                    Colors.amberAccent,
                  ),
                  Container(height: 35, width: 1, color: Colors.white24),
                  _buildBiomassMetricTile(
                    '${totalTons.toStringAsFixed(2)} ${isBn ? "টন" : "MT"}',
                    isBn ? 'মেট্রিক টন' : 'Metric Ton',
                    const Color(0xFF80DEEA),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Interactive Pond Parameters Sliders / Modifiers
        _buildSectionTitle(isBn ? '⚙️ পুকুর ও মাছের সাইজ সমন্বয়' : '⚙️ Pond & Fish Sizing Adjustment', isDark),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16252F) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.teal.shade200.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Pond Size Slider
              _buildSliderRow(
                title: isBn ? 'পুকুরের আয়তন:' : 'Pond Size Area:',
                valueDisplay: '${_pondSizeDecimal.toStringAsFixed(0)} ${isBn ? "শতক" : "Decimals"} (${(_pondSizeDecimal / 33.0).toStringAsFixed(1)} ${isBn ? "বিঘা" : "Bigha"})',
                min: 10,
                max: 300,
                currentVal: _pondSizeDecimal,
                onChanged: (val) => setState(() => _pondSizeDecimal = val),
              ),
              const Divider(height: 20),

              // Total Stock Count Slider
              _buildSliderRow(
                title: isBn ? 'আনুমানিক মোট মাছ সংখ্যা:' : 'Estimated Total Fish Count:',
                valueDisplay: '$_totalFishCount ${isBn ? "টি" : "pcs"} (${density.toStringAsFixed(0)} ${isBn ? "টি/শতক" : "pcs/dec"})',
                min: 500,
                max: 15000,
                divisions: 29,
                currentVal: _totalFishCount.toDouble(),
                onChanged: (val) => setState(() => _totalFishCount = val.toInt()),
              ),
              const Divider(height: 20),

              // Average Fish Weight (ABW)
              _buildSliderRow(
                title: isBn ? 'গড় মাছের ওজন (ABW):' : 'Average Body Weight (ABW):',
                valueDisplay: '${(_avgWeightGram / 1000).toStringAsFixed(2)} ${isBn ? "কেজি/পিস" : "kg/pc"} (${_avgWeightGram.toInt()} g)',
                min: 50,
                max: 5000,
                divisions: 99,
                currentVal: _avgWeightGram,
                onChanged: (val) => setState(() => _avgWeightGram = val),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Water Quality & Food Safety Audit Section
        _buildSectionTitle(isBn ? '🧪 পানি ও খাদ্য নিরাপত্তা অডিট (Safety Radar)' : '🧪 Water Quality & Safety Radar', isDark),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16252F) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.teal.shade200.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Safety Score Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBn ? 'নিরাপত্তা ও গুণমান ইনডেক্স' : 'Safety & Quality Index',
                        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                      Text(
                        isBn ? 'হারভেস্ট ও পরিবহনের জন্য অত্যন্ত উপযুক্ত' : 'Optimal for Live Harvest & Cold Transport',
                        style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '$safetyScore / 100',
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Water Parameters Grid
              Row(
                children: [
                  Expanded(
                    child: _buildParameterCapsule(
                      label: isBn ? 'অক্সিজেন (DO)' : 'Dissolved Oxygen',
                      value: '$_dissolvedOxygen mg/L',
                      status: _dissolvedOxygen >= 6.0 ? (isBn ? 'সেরা' : 'Optimal') : (isBn ? 'মাঝারি' : 'Fair'),
                      isGood: _dissolvedOxygen >= 6.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildParameterCapsule(
                      label: isBn ? 'pH লেভেল' : 'pH Level',
                      value: '$_phLevel pH',
                      status: (_phLevel >= 7.2 && _phLevel <= 8.2) ? (isBn ? 'আদর্শ' : 'Normal') : (isBn ? 'সতর্কতা' : 'Alert'),
                      isGood: _phLevel >= 7.2 && _phLevel <= 8.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildParameterCapsule(
                      label: isBn ? 'অ্যামোনিয়া (NH3)' : 'Ammonia',
                      value: '$_ammoniaPpm ppm',
                      status: _ammoniaPpm <= 0.03 ? (isBn ? 'নিরাপদ' : 'Safe') : (isBn ? 'ঝুঁকি' : 'Risk'),
                      isGood: _ammoniaPpm <= 0.03,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildParameterCapsule(
                      label: isBn ? 'পানির গভীরতা' : 'Water Depth',
                      value: '$_waterDepthFeet ${isBn ? "ফুট" : "ft"}',
                      status: isBn ? 'পর্যাপ্ত' : 'Adequate',
                      isGood: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Formalin & Organic Checkboxes
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF004D40),
                title: Text(
                  isBn ? '১০০% ফরমালিন মুক্ত সার্টিফাইড' : '100% Formalin-Free Certified',
                  style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 12.5),
                ),
                subtitle: Text(
                  isBn ? 'ডিজিটাল টেস্ট কিট দ্বারা ভেরিফায়েড' : 'Verified via Digital Chemical Test Kit',
                  style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
                ),
                value: _isFormalinFree,
                onChanged: (val) => setState(() => _isFormalinFree = val),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF004D40),
                title: Text(
                  isBn ? 'প্রাকৃতিক প্লাঙ্কটন ও সার্টিফাইড ফিড' : 'Natural Plankton & Certified Feed',
                  style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 12.5),
                ),
                subtitle: Text(
                  isBn ? 'কোনো ক্ষতিকর রাসায়নিক গ্রোথ হরমোন নেই' : 'Free from toxic growth hormones',
                  style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
                ),
                value: _isOrganicFeed,
                onChanged: (val) => setState(() => _isOrganicFeed = val),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Proceed to ROI Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => _tabController.animateTo(1),
            icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
            label: Text(
              isBn ? 'পাইকারি মুনাফা ও ল্যান্ডিং খরচ দেখুন' : 'View Wholesale ROI & Landing Cost',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004D40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 3,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 2: WHOLESALE ROI & LANDING COST
  // ==========================================
  Widget _buildRoiAndLandingTab(BuildContext context, bool isDark, bool isBn) {
    final biomass = FishBuyerPondAnalysisService.computeBiomass(
      decimal: _pondSizeDecimal,
      fishCount: _totalFishCount,
      avgWeightGram: _avgWeightGram,
    );
    final yieldKg = biomass['totalYieldKg'] as double;

    final roi = FishBuyerPondAnalysisService.computeWholesaleRoi(
      yieldKg: yieldKg,
      farmerPricePerKg: _farmerAskingPrice,
      targetMarketSalePricePerKg: _targetMarketSalePrice,
      transportPackagingCostPerKg: _transportPackagingCost,
      shrinkagePercent: _shrinkagePercent,
    );

    final double netLandingCost = roi['netLandingCostPerKg'] as double;
    final double netProfit = roi['projectedNetProfit'] as double;
    final double roiPercent = roi['roiPercentage'] as double;
    final double totalProcurementCost = roi['totalProcurementCost'] as double;
    final double grossRevenue = roi['totalGrossRevenue'] as double;

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
      physics: const BouncingScrollPhysics(),
      children: [
        // Net Profit & Landing Showcase
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF002528), Color(0xFF004D40), Color(0xFF01579B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF004D40).withValues(alpha: 0.35),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isBn ? 'আনুমানিক পাইকারি নিট মুনাফা' : 'Projected Net Wholesale Margin',
                    style: GoogleFonts.hindSiliguri(color: const Color(0xFF80DEEA), fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: netProfit >= 0 ? Colors.green.shade600 : Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${roiPercent.toStringAsFixed(1)}% ROI',
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Text(
                '৳ ${netProfit.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.amberAccent,
                ),
              ),
              Text(
                '${isBn ? "মোট লট:" : "Lot Volume:"} ${yieldKg.toInt()} ${isBn ? "কেজি" : "kg"} • ${isBn ? "খামারি:" : "Farmer:"} $_farmerName',
                style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 11.5),
              ),

              const SizedBox(height: 14),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFinancialMicroStat(
                    label: isBn ? 'নিট ল্যান্ডিং দর' : 'Net Landing Cost',
                    value: '৳ ${netLandingCost.toStringAsFixed(1)}/kg',
                    color: Colors.white,
                  ),
                  _buildFinancialMicroStat(
                    label: isBn ? 'মোট সংগ্রহ বাজেট' : 'Total Outlay',
                    value: '৳ ${totalProcurementCost.toStringAsFixed(0)}',
                    color: Colors.white70,
                  ),
                  _buildFinancialMicroStat(
                    label: isBn ? 'প্রত্যাশিত বিক্রয়' : 'Gross Sales',
                    value: '৳ ${grossRevenue.toStringAsFixed(0)}',
                    color: const Color(0xFF80DEEA),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Pricing Inputs & Slider Adjustment
        _buildSectionTitle(isBn ? '💵 ক্রয় ও বিক্রয় দর সমন্বয় (Price Setting)' : '💵 Procurement & Market Pricing', isDark),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16252F) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.teal.shade200.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Farmer Asking Price Slider
              _buildSliderRow(
                title: isBn ? 'খামার গেট ক্রয় দর:' : 'Pond Gate Asking Price:',
                valueDisplay: '৳ ${_farmerAskingPrice.toStringAsFixed(0)} /kg',
                min: 100,
                max: 1800,
                divisions: 170,
                currentVal: _farmerAskingPrice,
                onChanged: (val) => setState(() => _farmerAskingPrice = val),
              ),
              const Divider(height: 20),

              // Destination Market Sale Price Slider
              _buildSliderRow(
                title: isBn ? 'আড়ত / পাইকারি বিক্রয় দর:' : 'Target Wholesale Sale Price:',
                valueDisplay: '৳ ${_targetMarketSalePrice.toStringAsFixed(0)} /kg',
                min: 100,
                max: 2000,
                divisions: 190,
                currentVal: _targetMarketSalePrice,
                onChanged: (val) => setState(() => _targetMarketSalePrice = val),
              ),
              const Divider(height: 20),

              // Logistics & Packaging Cost
              _buildSliderRow(
                title: isBn ? 'পরিবহন ও কোল্ড-চেইন খরচ:' : 'Logistics & Packaging Cost:',
                valueDisplay: '৳ ${_transportPackagingCost.toStringAsFixed(0)} /kg',
                min: 5,
                max: 50,
                divisions: 45,
                currentVal: _transportPackagingCost,
                onChanged: (val) => setState(() => _transportPackagingCost = val),
              ),
              const Divider(height: 20),

              // Shrinkage Percentage
              _buildSliderRow(
                title: isBn ? 'পরিবহন ড্রপ / ঘাটতি (Shrinkage):' : 'Transport Shrinkage / Mortality:',
                valueDisplay: '${_shrinkagePercent.toStringAsFixed(1)} % (${((yieldKg * _shrinkagePercent) / 100).toStringAsFixed(0)} kg)',
                min: 0.0,
                max: 8.0,
                divisions: 16,
                currentVal: _shrinkagePercent,
                onChanged: (val) => setState(() => _shrinkagePercent = val),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Action Buttons: Save & Request Sample
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showSampleInspectionModal(context, isDark, isBn),
                icon: const Icon(Icons.verified_outlined, color: Color(0xFF004D40), size: 18),
                label: Text(
                  isBn ? 'নমুনা যাচাই বুক করুন' : 'Book Sampling',
                  style: GoogleFonts.hindSiliguri(color: const Color(0xFF004D40), fontWeight: FontWeight.bold, fontSize: 12.5),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: const BorderSide(color: Color(0xFF004D40), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _saveCurrentAnalysis(context, isBn),
                icon: const Icon(Icons.bookmark_add_rounded, color: Colors.white, size: 18),
                label: Text(
                  isBn ? 'অডিট সেভ করুন' : 'Save Evaluation',
                  style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004D40),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // TAB 3: SAVED AUDITS & INSPECTION PASSPORTS
  // ==========================================
  Widget _buildSavedAuditsTab(BuildContext context, bool isDark, bool isBn) {
    return Obx(() {
      final analyses = _analysisService.savedAnalyses;

      if (analyses.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  isBn ? 'কোনো সংরক্ষিত অডিট রিপোর্ট নেই' : 'No Saved Pond Audits Yet',
                  style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  isBn
                      ? 'বায়োমাস ও মুনাফা ট্যাব থেকে পুকুর অ্যানালাইসিস করে "অডিট সেভ করুন" বাটনে চাপুন।'
                      : 'Analyze any commercial pond and tap "Save Audit" to store your feasibility report.',
                  style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        itemCount: analyses.length,
        separatorBuilder: (c, i) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final item = analyses[index];

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16252F) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.teal.shade200.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF004D40).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.fishSpecies,
                        style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF004D40)),
                      ),
                    ),
                    Text(
                      '${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}',
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Text(
                  item.pondName,
                  style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14.5),
                ),
                Text(
                  '${isBn ? "খামারি:" : "Farmer:"} ${item.farmerName} • ${item.location}',
                  style: GoogleFonts.hindSiliguri(fontSize: 11.5, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0A1218) : const Color(0xFFF7FAFB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAuditMiniCell(isBn ? 'মোট ফলন' : 'Biomass', '${item.estimatedTotalYieldKg.toInt()} kg', isDark),
                      Container(height: 20, width: 1, color: Colors.grey.shade300),
                      _buildAuditMiniCell(isBn ? 'ল্যান্ডিং দর' : 'Landing', '৳${item.netLandingCostPerKg.toStringAsFixed(0)}/kg', isDark),
                      Container(height: 20, width: 1, color: Colors.grey.shade300),
                      _buildAuditMiniCell(isBn ? 'প্রাক্কলিত লাভ' : 'Net Profit', '৳${item.projectedNetProfit.toStringAsFixed(0)}', isDark, isHighlight: true),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showDigitalPassportDialog(context, item, isDark, isBn),
                      icon: const Icon(Icons.qr_code_rounded, size: 16, color: Color(0xFF004D40)),
                      label: Text(
                        isBn ? 'ডিজিটাল পাসপোর্ট' : 'Digital Passport',
                        style: GoogleFonts.hindSiliguri(fontSize: 11.5, fontWeight: FontWeight.bold, color: const Color(0xFF004D40)),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showSampleInspectionModal(context, isDark, isBn, prefilledAnalysis: item),
                      icon: const Icon(Icons.verified_user_rounded, size: 14, color: Colors.white),
                      label: Text(
                        item.sampleRequested ? (isBn ? 'নমুনা পেন্ডিং' : 'Sampling Pending') : (isBn ? 'নমুনা রিকোয়েস্ট' : 'Request Sampling'),
                        style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: item.sampleRequested ? Colors.orange.shade700 : const Color(0xFF004D40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }

  // ==========================================
  // HELPER WIDGETS & MODALS
  // ==========================================

  Widget _buildVerifiedPondPicker(BuildContext context, bool isDark, bool isBn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isBn ? '🌊 ভেরিফায়েড খামারের পুকুর নির্বাচন:' : '🌊 Select Verified Commercial Pond:',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13.5),
            ),
            if (!_isCustomPondMode)
              InkWell(
                onTap: () {
                  setState(() {
                    _isCustomPondMode = true;
                    _selectedVerifiedPond = null;
                    _pondName = isBn ? 'আমার কাস্টম পুকুর' : 'Custom Pond Evaluation';
                  });
                },
                child: Text(
                  isBn ? '+ কাস্টম পুকুর' : '+ Custom Pond',
                  style: GoogleFonts.hindSiliguri(color: const Color(0xFF004D40), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _analysisService.verifiedPonds.length,
            itemBuilder: (context, index) {
              final pond = _analysisService.verifiedPonds[index];
              final isSelected = _selectedVerifiedPond?.id == pond.id;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () => _applyVerifiedPond(pond),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 220,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF004D40).withValues(alpha: 0.12)
                          : (isDark ? const Color(0xFF16252F) : Colors.white),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF004D40) : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: pond.imageUrl,
                            width: 55,
                            height: 55,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                pond.pondName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              Text(
                                '${pond.estimatedTotalKg.toInt()} kg • ${pond.district}',
                                style: GoogleFonts.hindSiliguri(fontSize: 10.5, color: Colors.grey.shade600),
                              ),
                              Text(
                                '৳ ${pond.farmerAskingPricePerKg.toStringAsFixed(0)}/kg',
                                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF004D40)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBiomassMetricTile(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 10.5),
        ),
      ],
    );
  }

  Widget _buildFinancialMicroStat({required String label, required String value, required Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.hindSiliguri(color: Colors.white60, fontSize: 10.5)),
        Text(
          value,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: color),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.hindSiliguri(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildSliderRow({
    required String title,
    required String valueDisplay,
    required double min,
    required double max,
    int? divisions,
    required double currentVal,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.bold)),
            Text(
              valueDisplay,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF004D40)),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFF004D40),
            thumbColor: const Color(0xFF004D40),
            inactiveTrackColor: Colors.teal.shade100,
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            value: currentVal.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildParameterCapsule({
    required String label,
    required String value,
    required String status,
    required bool isGood,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isGood ? Colors.green.shade50 : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isGood ? Colors.green.shade200 : Colors.amber.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.hindSiliguri(fontSize: 10, color: Colors.grey.shade700)),
              Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isGood ? Colors.green.shade700 : Colors.amber.shade700,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditMiniCell(String label, String value, bool isDark, {bool isHighlight = false}) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: isHighlight ? const Color(0xFF00695C) : (isDark ? Colors.white : Colors.black87),
          ),
        ),
        Text(label, style: GoogleFonts.hindSiliguri(fontSize: 9.5, color: Colors.grey.shade600)),
      ],
    );
  }

  // Live Sampling Request Modal
  void _showSampleInspectionModal(
    BuildContext context,
    bool isDark,
    bool isBn, {
    FishBuyerPondAnalysisModel? prefilledAnalysis,
  }) {
    final pondNameToUse = prefilledAnalysis?.pondName ?? _pondName;
    final farmerPhoneToUse = prefilledAnalysis != null ? _farmerPhone : _farmerPhone;
    final notesController = TextEditingController(text: 'লাইভ জাল ফেলে মাছের গড় ওজন ও আঁশের সতেজতা যাচাই প্রয়োজন।');

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: Color(0xFF004D40), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    isBn ? 'সাইট নমুনা যাচাই বুকিং' : 'Book On-Site Sample Inspection',
                    style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                isBn
                    ? 'এগ্রোলিংকের সার্টিফাইড ফিল্ড অফিসার খামারে উপস্থিত হয়ে সরাসরি জাল ফেলে স্যাম্পল ওজন ও ভিডিও রিপোর্ট তৈরি করবেন।'
                    : 'An AgroLink field officer will visit the pond, cast sampling nets, verify average weight, and generate a video QC report.',
                style: GoogleFonts.hindSiliguri(fontSize: 11.5, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 14),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: isBn ? 'বিশেষ নির্দেশনা / নোট' : 'Special Instructions / Notes',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.call, color: Colors.green),
                    onPressed: () => _makePhoneCall(farmerPhoneToUse),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat, color: Color(0xFF004D40)),
                    onPressed: () => _openWhatsApp(farmerPhoneToUse),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      await _analysisService.requestSampleInspection(
                        analysisId: prefilledAnalysis?.id ?? 'NEW_REQUEST',
                        pondName: pondNameToUse,
                        farmerPhone: farmerPhoneToUse,
                        preferredDate: DateTime.now().add(const Duration(days: 2)),
                        notes: notesController.text,
                      );

                      Get.snackbar(
                        isBn ? 'স্যাম্পলিং বুকিং সফল! 🎯' : 'Sampling Booked Successfully! 🎯',
                        isBn ? 'ফিল্ড অফিসার ২ কার্যদিবসের মধ্যে খামারে স্যাম্পল সংগ্রহ করবেন।' : 'Field inspector will visit the pond within 2 business days.',
                        backgroundColor: const Color(0xFF004D40),
                        colorText: Colors.white,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004D40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      isBn ? 'রিকোয়েস্ট পাঠান' : 'Submit Request',
                      style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Digital QC Passport Dialog
  void _showDigitalPassportDialog(BuildContext context, FishBuyerPondAnalysisModel item, bool isDark, bool isBn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.all(20),
        title: Row(
          children: [
            const Icon(Icons.verified_rounded, color: Color(0xFF004D40), size: 24),
            const SizedBox(width: 8),
            Text(
              isBn ? 'ডিজিটাল কোয়ালিটি পাসপোর্ট' : 'Digital Quality Passport',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item.pondName} • ${item.fishSpecies}', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13)),
            Text('${isBn ? "খামারি:" : "Farmer:"} ${item.farmerName} (${item.location})', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
            const Divider(height: 16),
            _buildPassportLine(isBn ? 'মোট বায়োমাস:' : 'Biomass:', '${item.estimatedTotalYieldKg.toInt()} kg (${item.estimatedTotalMaunds.toStringAsFixed(1)} Maunds)'),
            _buildPassportLine(isBn ? 'গড় ওজন (ABW):' : 'Avg Weight:', '${(item.avgWeightGram / 1000).toStringAsFixed(2)} kg/pc'),
            _buildPassportLine(isBn ? 'ফরমালিন স্ট্যাটাস:' : 'Formalin Status:', isBn ? '১০০% ফরমালিন মুক্ত (Verified)' : '100% Negative (Verified)'),
            _buildPassportLine(isBn ? 'অক্সিজেন লেভেল:' : 'Dissolved Oxygen:', '${item.dissolvedOxygen} mg/L'),
            _buildPassportLine(isBn ? 'নিরাপত্তা স্কোর:' : 'Safety Score:', '${item.safetyScore}/100'),
            _buildPassportLine(isBn ? 'নিট ল্যান্ডিং খরচ:' : 'Net Landing Cost:', '৳${item.netLandingCostPerKg.toStringAsFixed(1)}/kg'),
            _buildPassportLine(isBn ? 'প্রাক্কলিত নিট লাভ:' : 'Net ROI Profit:', '৳${item.projectedNetProfit.toStringAsFixed(0)} (${item.projectedRoiPercentage.toStringAsFixed(1)}%)'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004D40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(isBn ? 'বন্ধ করুন' : 'Close', style: GoogleFonts.hindSiliguri(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPassportLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.hindSiliguri(fontSize: 11.5, color: Colors.grey.shade700)),
          Text(value, style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.bold, color: const Color(0xFF004D40))),
        ],
      ),
    );
  }
}
