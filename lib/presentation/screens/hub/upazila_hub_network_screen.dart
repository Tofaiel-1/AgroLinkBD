import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:agrolinkbd/core/models/upazila_hub_model.dart';
import 'package:agrolinkbd/core/models/qc_inspection_model.dart';
import 'package:agrolinkbd/core/services/upazila_hub_service.dart';
import 'package:agrolinkbd/core/services/location_service.dart';
import 'package:agrolinkbd/core/constants/bd_location_data.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';

class UpazilaHubNetworkScreen extends StatefulWidget {
  final String? initialUpazila;
  final String? initialDistrict;

  const UpazilaHubNetworkScreen({
    super.key,
    this.initialUpazila,
    this.initialDistrict,
  });

  @override
  State<UpazilaHubNetworkScreen> createState() => _UpazilaHubNetworkScreenState();
}

class _UpazilaHubNetworkScreenState extends State<UpazilaHubNetworkScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UpazilaHubService _hubService = UpazilaHubService();

  // Search & Filter state
  String _selectedDivision = 'All';
  String _searchQuery = '';
  UpazilaHubModel? _nearestHub;

  // Logistics Route Calculator state
  late UpazilaHubModel _originHub;
  late UpazilaHubModel _destinationHub;
  double _cargoWeightKg = 50.0;
  bool _isColdChain = false;
  InterHubLogisticsQuote? _calculatedQuote;

  // QC Certificate Checker state
  final TextEditingController _orderIdSearchController = TextEditingController();
  QcInspectionModel? _activeQcReport;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _originHub = _hubService.resolveHubByUpazila(
      widget.initialUpazila ?? 'Dumki',
      districtName: widget.initialDistrict ?? 'Patuakhali',
    );
    _destinationHub = _hubService.resolveHubByUpazila('Savar', districtName: 'Dhaka');

    _recalculateLogisticsQuote();
    _loadInitialQcReport();
    _autoDetectGpsHub();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _orderIdSearchController.dispose();
    super.dispose();
  }

  void _recalculateLogisticsQuote() {
    setState(() {
      _calculatedQuote = _hubService.calculateInterHubLogistics(
        _originHub,
        _destinationHub,
        _cargoWeightKg,
        isColdChain: _isColdChain,
      );
    });
  }

  void _loadInitialQcReport() {
    _activeQcReport = _hubService.generateMockQcInspection(
      'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      'প্রিমিয়াম রূপচাঁদা ও তাজা ইলিশ মাছ',
      _cargoWeightKg,
      _originHub,
    );
  }

  Future<void> _autoDetectGpsHub() async {
    try {
      final loc = await LocationService().getCurrentLocationAddress();
      final hub = _hubService.resolveHubByUpazila(loc.upazila, districtName: loc.district);
      if (mounted) {
        setState(() {
          _nearestHub = hub;
        });
      }
    } catch (e) {
      debugPrint('GPS detection note: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isBn = LanguageProvider.isBn(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isBn ? 'উপজেলা হাব ও কোয়ালিটি কন্ট্রোল' : 'Upazila Hub & QC Network',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              isBn ? 'দেশব্যাপী ৪৯৫+ হাব • শতভাগ কোয়ালিটি নিশ্চয়তা' : '495+ Nationwide Hubs • 100% Quality Guaranteed',
              style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.greenAccent),
            ),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFF15803D),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: isBn ? 'নিকটবর্তী হাব খুঁজুন' : 'Find Nearest Hub',
            onPressed: _autoDetectGpsHub,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.amberAccent,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(icon: const Icon(Icons.hub_outlined, size: 18), text: isBn ? 'হাব ডিরেক্টরি' : 'Hub Directory'),
            Tab(icon: const Icon(Icons.verified_outlined, size: 18), text: isBn ? 'কিউসি সার্টিফিকেট' : 'QC Certificate'),
            Tab(icon: const Icon(Icons.local_shipping_outlined, size: 18), text: isBn ? 'রুট ও ভাড়া ক্যালকুলেটর' : 'Freight Route'),
            Tab(icon: const Icon(Icons.qr_code_scanner, size: 18), text: isBn ? 'ড্রপ-অফ পাস' : 'Drop-off Pass'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHubDirectoryTab(isDark, isBn),
          _buildQcCertificateTab(isDark, isBn),
          _buildLogisticsRouteTab(isDark, isBn),
          _buildFarmerDropOffPassTab(isDark, isBn),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: UPZILA HUB DIRECTORY & GPS RADAR
  // ==========================================
  Widget _buildHubDirectoryTab(bool isDark, bool isBn) {
    final allHubs = _hubService.getAllHubs();
    final filteredHubs = allHubs.where((hub) {
      final matchesDiv = _selectedDivision == 'All' || hub.division == _selectedDivision;
      final query = _searchQuery.toLowerCase();
      final matchesQuery = query.isEmpty ||
          hub.name.toLowerCase().contains(query) ||
          hub.nameEn.toLowerCase().contains(query) ||
          hub.upazila.toLowerCase().contains(query) ||
          hub.upazilaBn.contains(query) ||
          hub.district.toLowerCase().contains(query) ||
          hub.districtBn.contains(query);
      return matchesDiv && matchesQuery;
    }).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nearest Hub Highlight Card
          if (_nearestHub != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF065F46), const Color(0xFF047857)]
                      : [const Color(0xFF15803D), const Color(0xFF16A34A)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.near_me, color: Colors.amberAccent, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              isBn ? 'আপনার সবচেয়ে কাছের হাব' : 'Your Nearest Upazila Hub',
                              style: GoogleFonts.hindSiliguri(
                                color: Colors.amberAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.check_circle, color: Colors.amberAccent, size: 14),
                          ],
                        ),
                        Text(
                          _nearestHub!.getName(isBn),
                          style: GoogleFonts.hindSiliguri(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '📍 ${_nearestHub!.getFormattedAddress(isBn)} • ${_nearestHub!.operatingHours}',
                          style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Search Bar
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            style: GoogleFonts.hindSiliguri(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: isBn ? 'উপজেলা বা জেলা দিয়ে হাব খুঁজুন...' : 'Search hub by Upazila or District...',
              hintStyle: GoogleFonts.hindSiliguri(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              prefixIcon: const Icon(Icons.search, color: Colors.green),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),

          // Division Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', isBn ? 'সকল বিভাগ' : 'All Divisions'),
                ...BDLocationData.divisions.map((div) => _buildFilterChip(div, div)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            isBn ? 'সক্রিয় উপজেলা হাব তালিকা (${filteredHubs.length})' : 'Active Upazila Hubs (${filteredHubs.length})',
            style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 12),

          // Hub Cards List
          ...filteredHubs.map((hub) => _buildHubCard(hub, isDark, isBn)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedDivision == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.w600)),
        selected: isSelected,
        selectedColor: const Color(0xFF16A34A),
        labelStyle: TextStyle(color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.black87)),
        onSelected: (_) => setState(() => _selectedDivision = value),
      ),
    );
  }

  Widget _buildHubCard(UpazilaHubModel hub, bool isDark, bool isBn) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hub.code,
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade600),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    hub.averageRating.toString(),
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hub.getName(isBn),
            style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                hub.getFormattedAddress(isBn),
                style: GoogleFonts.hindSiliguri(fontSize: 13, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: isDark ? Colors.white12 : Colors.grey.shade200, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBn ? 'কোল্ড স্টোরেজ' : 'Cold Storage',
                    style: GoogleFonts.hindSiliguri(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  ),
                  Text(
                    hub.hasColdStorage
                        ? (isBn ? 'সক্রিয় (${hub.coldStorageTempC}° সে)' : 'Active (${hub.coldStorageTempC}°C)')
                        : (isBn ? 'অনুপলব্ধ' : 'Standard'),
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: hub.hasColdStorage ? Colors.cyanAccent.shade700 : Colors.orange,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBn ? 'দৈনিক ক্যাপাসিটি' : 'Daily Capacity',
                    style: GoogleFonts.hindSiliguri(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  ),
                  Text(
                    '${hub.dailyCapacityKg.toStringAsFixed(0)} kg',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBn ? 'সক্রিয় পরিবহন' : 'Active Fleet',
                    style: GoogleFonts.hindSiliguri(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  ),
                  Text(
                    '${hub.activeShipmentsCount} ${isBn ? "টি চালনা" : "Trips"}',
                    style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: LIVE QUALITY CONTROL (QC) INSPECTION
  // ==========================================
  Widget _buildQcCertificateTab(bool isDark, bool isBn) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // QC Search Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _orderIdSearchController,
                  style: GoogleFonts.hindSiliguri(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: isBn ? 'অর্ডার আইডি বা ব্যাচ কোড লিখুন...' : 'Enter Order ID or Batch Code...',
                    prefixIcon: const Icon(Icons.qr_code, color: Colors.green),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final text = _orderIdSearchController.text.trim();
                  if (text.isNotEmpty) {
                    setState(() {
                      _activeQcReport = _hubService.generateMockQcInspection(
                        text,
                        'প্রিমিয়াম কৃষি ও মৎস্য পণ্য',
                        _cargoWeightKg,
                        _originHub,
                      );
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(isBn ? 'যাচাই' : 'Verify', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (_activeQcReport != null) ...[
            // Certificate Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [Colors.white, const Color(0xFFF0FDF4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.green.shade400, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Certificate Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.verified, color: Color(0xFF16A34A), size: 22),
                              const SizedBox(width: 6),
                              Text(
                                isBn ? 'ডিজিটাল কোয়ালিটি সার্টিফিকেট' : 'Official QC Quality Certificate',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF16A34A),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'AgroLink Upazila Hub Verified Quality Standard',
                            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _activeQcReport!.getGrade(isBn),
                          style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: isDark ? Colors.white12 : Colors.grey.shade200),
                  const SizedBox(height: 14),

                  // Metrics Grid (Freshness, Weight, Moisture, Defect)
                  Row(
                    children: [
                      Expanded(
                        child: _buildQcMetricCard(
                          label: isBn ? 'ফ্রেশনেস স্কোর' : 'Freshness Index',
                          value: '${_activeQcReport!.freshnessScore}%',
                          icon: Icons.eco,
                          color: Colors.green,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildQcMetricCard(
                          label: isBn ? 'ডিজিটাল ওজন' : 'Verified Weight',
                          value: '${_activeQcReport!.testedWeightKg} kg',
                          icon: Icons.scale,
                          color: Colors.blue,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQcMetricCard(
                          label: isBn ? 'আর্দ্রতা লেভেল' : 'Moisture Level',
                          value: '${_activeQcReport!.moisturePercent}%',
                          icon: Icons.water_drop,
                          color: Colors.teal,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildQcMetricCard(
                          label: isBn ? 'ডিফেক্ট হার' : 'Defect Rate',
                          value: '${_activeQcReport!.defectPercent}%',
                          icon: Icons.check_circle_outline,
                          color: Colors.amber.shade700,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tamper-Proof Packaging Seal
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lock, color: Colors.orange, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              isBn ? 'টেম্পার-প্রুফ সিকিউরিটি সিল:' : 'Tamper-Proof Security Seal:',
                              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            const Spacer(),
                            Text(
                              _activeQcReport!.tamperProofSealCode,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange.shade800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${isBn ? "প্যাকেজিং প্রকার:" : "Packaging:"} ${_activeQcReport!.getPackagingType(isBn)}',
                          style: GoogleFonts.hindSiliguri(fontSize: 12, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                        ),
                        Text(
                          '${isBn ? "ইনস্পেক্টর:" : "Inspector:"} ${_activeQcReport!.inspectorName} (${_activeQcReport!.getHubName(isBn)})',
                          style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.green.shade600, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // QR Seal
                  Center(
                    child: Column(
                      children: [
                        QrImageView(
                          data: 'AGROLINK-QC:${_activeQcReport!.orderId}:${_activeQcReport!.tamperProofSealCode}',
                          version: QrVersions.auto,
                          size: 110.0,
                          dataModuleStyle: QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          eyeStyle: QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Batch: ${_activeQcReport!.batchCode}',
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQcMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.hindSiliguri(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
              Text(value, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: INTER-HUB FREIGHT ROUTE & FARE
  // ==========================================
  Widget _buildLogisticsRouteTab(bool isDark, bool isBn) {
    final allHubs = _hubService.getAllHubs();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Origin Hub Selector
          Text(isBn ? 'উৎপাদনকারী / প্রেরক উপজেলা হাব (Origin Hub)' : 'Origin Upazila Hub (Farmer Drop-off)',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _originHub.id,
            isExpanded: true,
            items: allHubs.map((h) => DropdownMenuItem(value: h.id, child: Text(h.getName(isBn), style: GoogleFonts.hindSiliguri(fontSize: 14)))).toList(),
            onChanged: (id) {
              if (id != null) {
                setState(() {
                  _originHub = allHubs.firstWhere((h) => h.id == id);
                  _recalculateLogisticsQuote();
                });
              }
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.outbox, color: Colors.green),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 14),

          // Destination Hub Selector
          Text(isBn ? 'গন্তব্য উপজেলা হাব (Destination Hub)' : 'Destination Upazila Hub (Buyer Delivery)',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _destinationHub.id,
            isExpanded: true,
            items: allHubs.map((h) => DropdownMenuItem(value: h.id, child: Text(h.getName(isBn), style: GoogleFonts.hindSiliguri(fontSize: 14)))).toList(),
            onChanged: (id) {
              if (id != null) {
                setState(() {
                  _destinationHub = allHubs.firstWhere((h) => h.id == id);
                  _recalculateLogisticsQuote();
                });
              }
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.inbox, color: Colors.blue),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 14),

          // Cargo Weight Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isBn ? 'পণ্যের মোট ওজন:' : 'Cargo Weight:', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('${_cargoWeightKg.toStringAsFixed(0)} kg', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green.shade600)),
            ],
          ),
          Slider(
            value: _cargoWeightKg,
            min: 5.0,
            max: 500.0,
            divisions: 99,
            activeColor: const Color(0xFF16A34A),
            onChanged: (val) {
              setState(() {
                _cargoWeightKg = val;
                _recalculateLogisticsQuote();
              });
            },
          ),

          // Cold Chain Toggle
          SwitchListTile(
            title: Text(
              isBn ? 'শীতাতপ নিয়ন্ত্রিত কোল্ড-চেইন পরিবহন (৪° সে)' : 'Refrigerated Cold-Chain Transit (4°C)',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            subtitle: Text(
              isBn ? 'মাছ, মাংস ও পচনশীল শাকসবজির জন্য বিশেষায়িত' : 'Recommended for fresh fish, meat & perishables',
              style: GoogleFonts.hindSiliguri(fontSize: 11),
            ),
            value: _isColdChain,
            activeThumbColor: Colors.cyanAccent.shade700,
            onChanged: (val) {
              setState(() {
                _isColdChain = val;
                _recalculateLogisticsQuote();
              });
            },
            secondary: const Icon(Icons.ac_unit, color: Colors.cyan),
          ),
          const SizedBox(height: 16),

          // Calculated Route Card
          if (_calculatedQuote != null)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isBn ? 'উপজেলা হাব লজিস্টিকস হিসাব' : 'Inter-Hub Freight Summary',
                        style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '৳${_calculatedQuote!.totalLogisticsCost.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green.shade800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFareRow(isBn ? 'মোট দূরত্ব (হাব টু হাব)' : 'Hub-to-Hub Distance', '${_calculatedQuote!.distanceKm} km'),
                  _buildFareRow(isBn ? 'আনুমানিক পরিবহন সময়' : 'Estimated Transit Time', '${_calculatedQuote!.transitHours.toStringAsFixed(1)} ${isBn ? "ঘণ্টা" : "Hours"}'),
                  _buildFareRow(isBn ? 'নির্ধারিত পরিবহন যান' : 'Assigned Fleet Type', _calculatedQuote!.getVehicleType(isBn)),
                  _buildFareRow(isBn ? 'প্যাকেজিং ও সিকিউরিটি সিল' : 'Packaging & Barcode Seal', '৳${_calculatedQuote!.packagingFee.toStringAsFixed(0)}'),
                  if (_isColdChain)
                    _buildFareRow(isBn ? 'কোল্ড-চেইন রেফ্রিজারেশন' : 'Cold-Chain Premium', '৳${_calculatedQuote!.coldChainFee.toStringAsFixed(0)}'),
                  Divider(color: isDark ? Colors.white12 : Colors.grey.shade200, height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isBn ? 'হাব পিক-আপ:' : 'Hub Pickup:', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey)),
                      Text(_calculatedQuote!.estimatedPickupTime, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text(isBn ? 'সম্ভাব্য ডেলিভারি:' : 'Delivery ETA:', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey)),
                      Text(_calculatedQuote!.estimatedDeliveryTime, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green.shade600)),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFareRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade600)),
          Text(val, style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 4: FARMER HUB DROP-OFF PASS & TOKEN
  // ==========================================
  Widget _buildFarmerDropOffPassTab(bool isDark, bool isBn) {
    final String token = 'PASS-DUMKI-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [Colors.white, const Color(0xFFF8FAFC)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.green.shade500, width: 2),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn ? 'কৃষক হাব ড্রপ-অফ পাস' : 'Farmer Hub Drop-off Pass',
                          style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                        ),
                        Text(
                          'AgroLink Fast-Track Weighing & Quality Intake',
                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    const Icon(Icons.qr_code_2, size: 36, color: Colors.green),
                  ],
                ),
                const SizedBox(height: 16),
                QrImageView(
                  data: 'AGROLINK-PASS:$token:DUMKI-HUB',
                  version: QrVersions.auto,
                  size: 160.0,
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  token,
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isBn
                            ? '১. ফসল বা মাছ নিয়ে উপজেলা হাবে পৌঁছান\n২. কিউআর কোড স্ক্যান করে দ্রুত ওজন পরীক্ষা করুন\n৩. তাৎক্ষণিক কিউসি গ্রেডিং ও ডিজিটাল রিসিট গ্রহণ করুন'
                            : '1. Bring your produce to the Upazila Hub\n2. Scan this QR for fast digital weighing\n3. Receive instant QC grading & digital intake receipt',
                        style: GoogleFonts.hindSiliguri(fontSize: 12, height: 1.5, color: isDark ? Colors.grey.shade200 : Colors.green.shade900),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
