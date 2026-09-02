import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/data/bangladesh_agri_data.dart';
import 'package:agrolinkbd/core/models/agri_info_model.dart';
import 'package:agrolinkbd/core/services/agri_info_service.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'crop_suitability_screen.dart';
import 'fertilizer_recommendation_screen.dart';
import 'crop_zone_screen.dart';
import 'crop_pattern_screen.dart';
import 'soil_quality_screen.dart';
import 'saved_agri_data_screen.dart';
import 'emergency_weather_services_screen.dart';

class AgriInfoHubScreen extends StatefulWidget {
  final String? initialFeature; // 'suitability', 'fertilizer', 'zone', 'pattern', 'soil', 'saved'
  const AgriInfoHubScreen({super.key, this.initialFeature});

  @override
  State<AgriInfoHubScreen> createState() => _AgriInfoHubScreenState();
}

class _AgriInfoHubScreenState extends State<AgriInfoHubScreen> {
  final AgriInfoService _service = AgriInfoService();
  UpazilaCropData? _selectedData;
  String? _division, _zilla, _upazila;
  bool _isDetecting = false;

  static const Color primaryGreen = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    // If launched from a specific feature card, open that feature after location selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialFeature != null) {
        _showLocationSelector();
      }
    });
  }

  Future<void> _detectGPSLocation() async {
    final bool isBn = LanguageProvider.isBn(context);
    setState(() => _isDetecting = true);
    try {
      final data = await _service.getDataByGPS();
      if (data != null) {
        setState(() {
          _selectedData = data;
          _division = data.division;
          _zilla = data.zilla;
          _upazila = data.upazila;
        });
      } else {
        Get.snackbar(
          isBn ? 'অবস্থান পাওয়া যায়নি' : 'Location Not Found',
          isBn ? 'GPS অনুমতি দিন অথবা ম্যানুয়ালি এলাকা বেছে নিন' : 'Please enable GPS or select region manually',
          backgroundColor: Colors.orange.shade100,
        );
      }
    } catch (e) {
      Get.snackbar(
        isBn ? 'ত্রুটি' : 'Error',
        isBn ? 'অবস্থান নির্ধারণ করা যায়নি' : 'Could not determine location',
      );
    }
    setState(() => _isDetecting = false);
  }

  void _selectManually(String division, String zilla, String upazila) {
    final data = _service.getDataBySelection(
      division: division,
      zilla: zilla,
      upazila: upazila,
    );
    setState(() {
      _selectedData = data;
      _division = division;
      _zilla = zilla;
      _upazila = upazila;
    });
  }

  void _showLocationSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocationSelectorSheet(
        onGPSSelected: _detectGPSLocation,
        onManualSelected: _selectManually,
        selectedDivision: _division,
        selectedZilla: _zilla,
        selectedUpazila: _upazila,
      ),
    );
  }

  void _navigate(Widget screen) {
    final bool isBn = LanguageProvider.isBn(context);
    if (_selectedData == null) {
      Get.snackbar(
        isBn ? 'এলাকা বেছে নিন' : 'Select Region',
        isBn ? 'প্রথমে আপনার উপজেলা নির্বাচন করুন' : 'Please select your upazila first',
        backgroundColor: Colors.orange.shade100,
        icon: const Icon(Icons.location_on, color: Colors.orange),
        duration: const Duration(seconds: 2),
      );
      _showLocationSelector();
      return;
    }
    Get.to(() => screen, transition: Transition.rightToLeft);
  }

  @override
  Widget build(BuildContext context) {
    final bool isBn = LanguageProvider.isBn(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F0),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          isBn ? 'কৃষি তথ্য কেন্দ্র' : 'Agri Info Hub',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outlined, color: Colors.white),
            tooltip: isBn ? 'সংরক্ষিত তথ্য' : 'Saved Info',
            onPressed: () => Get.to(() => const SavedAgriDataScreen()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header gradient with location selector
            _buildLocationHeader(isBn),
            const SizedBox(height: 20),

            // Selected area info card
            if (_selectedData != null) _buildSelectedAreaCard(isBn),
            if (_selectedData == null) _buildNoLocationCard(isBn),

            const SizedBox(height: 20),

            // Feature cards grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBn ? 'কৃষি সেবাসমূহ' : 'Agri Services',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureGrid(isBn),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationHeader(bool isBn) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              // Quick action row
              Row(
                children: [
                  Expanded(
                    child: _buildLocationButton(
                      icon: _isDetecting ? null : Icons.my_location,
                      label: _isDetecting 
                          ? (isBn ? 'অবস্থান খোঁজা হচ্ছে...' : 'Detecting GPS...') 
                          : (isBn ? 'GPS দিয়ে খুঁজুন' : 'Find via GPS'),
                      onTap: _isDetecting ? null : _detectGPSLocation,
                      isLoading: _isDetecting,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLocationButton(
                      icon: Icons.search,
                      label: isBn ? 'এলাকা বেছে নিন' : 'Select Upazila',
                      onTap: _showLocationSelector,
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

  Widget _buildLocationButton({
    IconData? icon,
    required String label,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            else
              Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.hindSiliguri(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedAreaCard(bool isBn) {
    final d = _selectedData!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: primaryGreen.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4)),
          ],
          border: Border.all(color: primaryGreen.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on, color: primaryGreen, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${d.division} › ${d.zilla} › ${d.upazila}',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        isBn ? '${d.cropZoneBn} (${d.cropZone})' : '${d.cropZone} (${d.cropZoneBn})',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _showLocationSelector,
                  child: Text(isBn ? 'পরিবর্তন' : 'Change', style: GoogleFonts.hindSiliguri(color: primaryGreen, fontSize: 13)),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoChip(Icons.grass, isBn ? d.soilProfile.typeBn : d.soilProfile.type, Colors.brown.shade400),
                _buildInfoChip(Icons.water_drop, 'pH ${d.soilProfile.phMin}–${d.soilProfile.phMax}', Colors.blue.shade400),
                _buildInfoChip(Icons.eco, '${d.suitableCrops.length} ${isBn ? 'ফসল' : 'Crops'}', primaryGreen),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade700)),
      ],
    );
  }

  Widget _buildNoLocationCard(bool isBn) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isBn
                    ? 'আপনার উপজেলা বেছে নিন অথবা GPS দিয়ে স্বয়ংক্রিয়ভাবে খুঁজুন'
                    : 'Select your upazila or find automatically using GPS',
                style: GoogleFonts.hindSiliguri(fontSize: 14, color: Colors.orange.shade800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(bool isBn) {
    final features = [
      _FeatureItem(
        isBn ? 'জরুরি সেবা ও আবহাওয়া' : 'Emergency & Weather',
        Icons.warning_amber_rounded,
        const Color(0xFFD32F2F),
        isBn ? 'লাইভ আবহাওয়া ও জরুরি কৃষি হটলাইন' : 'Live weather alerts & emergency hotline',
        () => Get.to(() => const EmergencyWeatherServicesScreen()),
      ),
      _FeatureItem(
        isBn ? 'ফসল উপযোগিতা' : 'Crop Suitability',
        Icons.agriculture,
        const Color(0xFF2E7D32),
        isBn ? 'উপজেলার জন্য সবচেয়ে উপযোগী ফসল' : 'Top recommended crops for this upazila',
        () => _navigate(CropSuitabilityScreen(data: _selectedData)),
      ),
      _FeatureItem(
        isBn ? 'সার সুপারিশ' : 'Fertilizer Advice',
        Icons.science,
        const Color(0xFF558B2F),
        isBn ? 'ফসল অনুযায়ী সারের পরিমাণ ও সময়সূচি' : 'Dosage & schedule by crop type',
        () => _navigate(FertilizerRecommendationScreen(data: _selectedData)),
      ),
      _FeatureItem(
        isBn ? 'ফসল জোন' : 'Crop Zone',
        Icons.map,
        const Color(0xFF1565C0),
        isBn ? 'এলাকার কৃষি অঞ্চল ও জলবায়ু তথ্য' : 'Agro-ecological zone & climate profile',
        () => _navigate(CropZoneScreen(data: _selectedData)),
      ),
      _FeatureItem(
        isBn ? 'ফসল বিন্যাস' : 'Crop Pattern',
        Icons.view_module,
        const Color(0xFFE65100),
        isBn ? 'বর্তমান ও লাভজনক ফসল বিন্যাস' : 'Current & high-yield crop rotation',
        () => _navigate(CropPatternScreen(data: _selectedData)),
      ),
      _FeatureItem(
        isBn ? 'মাটির গুণাগুণ' : 'Soil Health',
        Icons.landscape,
        const Color(0xFF6D4C41),
        isBn ? 'মাটির ধরন, pH ও পুষ্টি বিশ্লেষণ' : 'Soil composition, pH & nutrient health',
        () => _navigate(SoilQualityScreen(data: _selectedData)),
      ),
      _FeatureItem(
        isBn ? 'সংরক্ষিত তথ্য' : 'Saved Agri Data',
        Icons.bookmark,
        const Color(0xFF6A1B9A),
        isBn ? 'আগে দেখা এলাকার তথ্য' : 'Previously saved upazila records',
        () => Get.to(() => const SavedAgriDataScreen()),
      ),
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.05,
      ),
      itemCount: features.length,
      itemBuilder: (ctx, i) => _buildFeatureCard(features[i]),
    );
  }

  Widget _buildFeatureCard(_FeatureItem f) {
    return GestureDetector(
      onTap: f.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: f.color.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 5)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: f.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(f.icon, color: f.color, size: 26),
              ),
              const Spacer(),
              Text(
                f.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                f.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.black54, height: 1.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _FeatureItem(this.title, this.icon, this.color, this.subtitle, this.onTap);
}

// ============================================================
// Location Selector Bottom Sheet
// ============================================================
class LocationSelectorSheet extends StatefulWidget {
  final VoidCallback onGPSSelected;
  final void Function(String div, String zilla, String upazila) onManualSelected;
  final String? selectedDivision, selectedZilla, selectedUpazila;

  const LocationSelectorSheet({
    super.key,
    required this.onGPSSelected,
    required this.onManualSelected,
    this.selectedDivision,
    this.selectedZilla,
    this.selectedUpazila,
  });

  @override
  State<LocationSelectorSheet> createState() => _LocationSelectorSheetState();
}

class _LocationSelectorSheetState extends State<LocationSelectorSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _division, _zilla, _upazila;
  bool _isDetecting = false;

  static const Color primaryGreen = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _division = widget.selectedDivision;
    _zilla = widget.selectedZilla;
    _upazila = widget.selectedUpazila;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _detectGPS() async {
    setState(() => _isDetecting = true);
    Get.back();
    widget.onGPSSelected();
  }

  void _applyManual() {
    final bool isBn = LanguageProvider.isBn(context);
    if (_division == null || _zilla == null || _upazila == null) {
      Get.snackbar(
        isBn ? 'অসম্পূর্ণ নির্বাচন' : 'Incomplete Selection',
        isBn ? 'বিভাগ, জেলা ও উপজেলা বেছে নিন' : 'Please select division, district, and upazila',
      );
      return;
    }
    widget.onManualSelected(_division!, _zilla!, _upazila!);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final bool isBn = LanguageProvider.isBn(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        builder: (_, controller) => Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                isBn ? 'এলাকা নির্বাচন করুন' : 'Select Region',
                style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: primaryGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade600,
                labelStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14),
                tabs: [
                  Tab(text: isBn ? '📍 বর্তমান অবস্থান' : '📍 Current Location'),
                  Tab(text: isBn ? '🔍 এলাকা খুঁজুন' : '🔍 Search Upazila'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // GPS Tab
                  _buildGPSTab(isBn),
                  // Manual Tab
                  _buildManualTab(controller, isBn),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGPSTab(bool isBn) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.my_location, size: 60, color: primaryGreen),
          ),
          const SizedBox(height: 24),
          Text(
            isBn ? 'GPS দিয়ে স্বয়ংক্রিয় অবস্থান' : 'Automatic GPS Location',
            style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Text(
            isBn
                ? 'আপনার বর্তমান GPS অবস্থান ব্যবহার করে নিকটতম উপজেলার কৃষি তথ্য দেখান'
                : 'Display agricultural information for your nearest upazila using GPS',
            textAlign: TextAlign.center,
            style: GoogleFonts.hindSiliguri(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isDetecting ? null : _detectGPS,
              icon: _isDetecting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.gps_fixed),
              label: Text(
                _isDetecting 
                    ? (isBn ? 'খোঁজা হচ্ছে...' : 'Locating...') 
                    : (isBn ? 'আমার অবস্থান ব্যবহার করুন' : 'Use My GPS Location'),
                style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualTab(ScrollController controller, bool isBn) {
    final divisions = BangladeshAgriData.divisions;
    final zillaList = _division != null
        ? BangladeshAgriData.zillasPerDivision[_division] ?? []
        : <String>[];
    final upazilaList = _zilla != null
        ? BangladeshAgriData.upazilasPerZilla[_zilla] ?? []
        : <String>[];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              controller: controller,
              children: [
                _buildDropdown(
                  label: isBn ? 'বিভাগ (Division)' : 'Division',
                  icon: Icons.account_tree,
                  value: _division,
                  items: divisions,
                  hint: isBn ? 'নির্বাচন করুন' : 'Select Division',
                  onChanged: (v) => setState(() { _division = v; _zilla = null; _upazila = null; }),
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: isBn ? 'জেলা (District)' : 'District',
                  icon: Icons.location_city,
                  value: _zilla,
                  items: zillaList,
                  hint: isBn ? 'নির্বাচন করুন' : 'Select District',
                  onChanged: _division == null ? null : (v) => setState(() { _zilla = v; _upazila = null; }),
                  enabled: _division != null,
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: isBn ? 'উপজেলা (Upazila)' : 'Upazila',
                  icon: Icons.place,
                  value: _upazila,
                  items: upazilaList,
                  hint: isBn ? 'নির্বাচন করুন' : 'Select Upazila',
                  onChanged: _zilla == null ? null : (v) => setState(() => _upazila = v),
                  enabled: _zilla != null,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_division != null && _zilla != null && _upazila != null)
                  ? _applyManual
                  : null,
              icon: const Icon(Icons.check_circle),
              label: Text(
                isBn ? 'এই উপজেলার তথ্য দেখুন' : 'View Upazila Info',
                style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required String hint,
    required void Function(String?)? onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade800, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: enabled ? Colors.grey.shade300 : Colors.grey.shade200),
          ),
          child: DropdownButton<String>(
            value: value,
            hint: Text(hint, style: GoogleFonts.hindSiliguri(color: Colors.grey.shade600)),
            isExpanded: true,
            underline: const SizedBox(),
            icon: Icon(Icons.keyboard_arrow_down, color: enabled ? primaryGreen : Colors.grey),
            dropdownColor: Colors.white,
            items: items.map((s) => DropdownMenuItem(
              value: s,
              child: Text(s, style: GoogleFonts.hindSiliguri(fontSize: 15, color: Colors.black87)),
            )).toList(),
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ],
    );
  }
}
