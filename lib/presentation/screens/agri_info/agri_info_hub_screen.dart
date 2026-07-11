import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/data/bangladesh_agri_data.dart';
import 'package:agrolinkbd/core/models/agri_info_model.dart';
import 'package:agrolinkbd/core/services/agri_info_service.dart';
import 'crop_suitability_screen.dart';
import 'fertilizer_recommendation_screen.dart';
import 'crop_zone_screen.dart';
import 'crop_pattern_screen.dart';
import 'soil_quality_screen.dart';
import 'saved_agri_data_screen.dart';

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
        Get.snackbar('অবস্থান পাওয়া যায়নি', 'GPS অনুমতি দিন অথবা ম্যানুয়ালি এলাকা বেছে নিন',
            backgroundColor: Colors.orange.shade100);
      }
    } catch (e) {
      Get.snackbar('ত্রুটি', 'অবস্থান নির্ধারণ করা যায়নি');
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
    if (_selectedData == null) {
      Get.snackbar(
        'এলাকা বেছে নিন',
        'প্রথমে আপনার উপজেলা নির্বাচন করুন',
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
          'কৃষি তথ্য কেন্দ্র',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outlined, color: Colors.white),
            tooltip: 'সংরক্ষিত তথ্য',
            onPressed: () => Get.to(() => const SavedAgriDataScreen()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header gradient with location selector
            _buildLocationHeader(),
            const SizedBox(height: 20),

            // Selected area info card
            if (_selectedData != null) _buildSelectedAreaCard(),
            if (_selectedData == null) _buildNoLocationCard(),

            const SizedBox(height: 20),

            // Feature cards grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'কৃষি সেবাসমূহ',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureGrid(),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationHeader() {
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
                      label: _isDetecting ? 'অবস্থান খোঁজা হচ্ছে...' : 'GPS দিয়ে খুঁজুন',
                      onTap: _isDetecting ? null : _detectGPSLocation,
                      isLoading: _isDetecting,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLocationButton(
                      icon: Icons.search,
                      label: 'এলাকা বেছে নিন',
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
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.5)),
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

  Widget _buildSelectedAreaCard() {
    final d = _selectedData!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: primaryGreen.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4)),
          ],
          border: Border.all(color: primaryGreen.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.1),
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
                        '${d.cropZoneBn} (${d.cropZone})',
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
                  child: Text('পরিবর্তন', style: GoogleFonts.hindSiliguri(color: primaryGreen, fontSize: 13)),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoChip(Icons.grass, d.soilProfile.typeBn, Colors.brown.shade400),
                _buildInfoChip(Icons.water_drop, 'pH ${d.soilProfile.phMin}–${d.soilProfile.phMax}', Colors.blue.shade400),
                _buildInfoChip(Icons.eco, '${d.suitableCrops.length} ফসল', primaryGreen),
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

  Widget _buildNoLocationCard() {
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
                'আপনার উপজেলা বেছে নিন অথবা GPS দিয়ে স্বয়ংক্রিয়ভাবে খুঁজুন',
                style: GoogleFonts.hindSiliguri(fontSize: 14, color: Colors.orange.shade800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    final features = [
      _FeatureItem('ফসল উপযোগিতা', Icons.agriculture, const Color(0xFF2E7D32),
          'আপনার এলাকায় কোন ফসল সবচেয়ে উপযুক্ত',
          () => _navigate(CropSuitabilityScreen(data: _selectedData))),
      _FeatureItem('সার সুপারিশ', Icons.science, const Color(0xFF558B2F),
          'ফসল অনুযায়ী সারের পরিমাণ ও সময়সূচি',
          () => _navigate(FertilizerRecommendationScreen(data: _selectedData))),
      _FeatureItem('ফসল জোন', Icons.map, const Color(0xFF1565C0),
          'এলাকার কৃষি অঞ্চল ও জলবায়ু তথ্য',
          () => _navigate(CropZoneScreen(data: _selectedData))),
      _FeatureItem('ফসল বিন্যাস', Icons.view_module, const Color(0xFFE65100),
          'বর্তমান ও লাভজনক ফসল বিন্যাস',
          () => _navigate(CropPatternScreen(data: _selectedData))),
      _FeatureItem('মাটির গুণাগুণ', Icons.landscape, const Color(0xFF6D4C41),
          'মাটির ধরন, pH ও পুষ্টি বিশ্লেষণ',
          () => _navigate(SoilQualityScreen(data: _selectedData))),
      _FeatureItem('সংরক্ষিত তথ্য', Icons.bookmark, const Color(0xFF6A1B9A),
          'আগে দেখা এলাকার তথ্য',
          () => Get.to(() => const SavedAgriDataScreen())),
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.1,
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
            BoxShadow(color: f.color.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 5)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: f.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(f.icon, color: f.color, size: 28),
              ),
              const Spacer(),
              Text(
                f.title,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                f.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.black54, height: 1.3),
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
    if (_division == null || _zilla == null || _upazila == null) {
      Get.snackbar('অসম্পূর্ণ নির্বাচন', 'বিভাগ, জেলা ও উপজেলা বেছে নিন');
      return;
    }
    widget.onManualSelected(_division!, _zilla!, _upazila!);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
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
                'এলাকা নির্বাচন করুন',
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
                tabs: const [
                  Tab(text: '📍 বর্তমান অবস্থান'),
                  Tab(text: '🔍 এলাকা খুঁজুন'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // GPS Tab
                  _buildGPSTab(),
                  // Manual Tab
                  _buildManualTab(controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGPSTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.my_location, size: 60, color: primaryGreen),
          ),
          const SizedBox(height: 24),
          Text(
            'GPS দিয়ে স্বয়ংক্রিয় অবস্থান',
            style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Text(
            'আপনার বর্তমান GPS অবস্থান ব্যবহার করে নিকটতম উপজেলার কৃষি তথ্য দেখান',
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
                _isDetecting ? 'খোঁজা হচ্ছে...' : 'আমার অবস্থান ব্যবহার করুন',
                style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
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

  Widget _buildManualTab(ScrollController controller) {
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
                  label: 'বিভাগ (Division)',
                  icon: Icons.account_tree,
                  value: _division,
                  items: divisions,
                  onChanged: (v) => setState(() { _division = v; _zilla = null; _upazila = null; }),
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'জেলা (District)',
                  icon: Icons.location_city,
                  value: _zilla,
                  items: zillaList,
                  onChanged: _division == null ? null : (v) => setState(() { _zilla = v; _upazila = null; }),
                  enabled: _division != null,
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'উপজেলা (Upazila)',
                  icon: Icons.place,
                  value: _upazila,
                  items: upazilaList,
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
                'এই উপজেলার তথ্য দেখুন',
                style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
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
            hint: Text('নির্বাচন করুন', style: GoogleFonts.hindSiliguri(color: Colors.grey.shade600)),
            isExpanded: true,
            underline: const SizedBox(),
            icon: Icon(Icons.keyboard_arrow_down, color: enabled ? primaryGreen : Colors.grey),
            dropdownColor: Colors.white, // Ensure popup background is white
            items: items.map((s) => DropdownMenuItem(
              value: s,
              child: Text(s, style: GoogleFonts.hindSiliguri(fontSize: 15, color: Colors.black87)), // Ensure text is black
            )).toList(),
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ],
    );
  }
}
