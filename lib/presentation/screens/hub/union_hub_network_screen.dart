import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/models/union_hub_model.dart';
import 'package:agrolinkbd/core/models/qc_inspection_model.dart';
import 'package:agrolinkbd/core/services/union_hub_service.dart';
import 'package:agrolinkbd/core/constants/bd_union_data.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';

// ══════════════════════════════════════════════════════════
// UNION HUB NETWORK SCREEN — MASTERCLASS 5-TAB UI
// Covers every Union in Bangladesh with full bilingual support
// Dark/Light mode with zero overflow
// ══════════════════════════════════════════════════════════

class UnionHubNetworkScreen extends StatefulWidget {
  final String? initialDistrict;
  final String? initialUpazila;

  const UnionHubNetworkScreen({
    super.key,
    this.initialDistrict,
    this.initialUpazila,
  });

  @override
  State<UnionHubNetworkScreen> createState() => _UnionHubNetworkScreenState();
}

class _UnionHubNetworkScreenState extends State<UnionHubNetworkScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UnionHubService _service = UnionHubService();

  // Directory state
  String _selectedDivision = 'All';
  String _selectedDistrict = 'All';
  String _searchQuery = '';
  List<UnionHubModel> _filteredHubs = [];
  bool _isLoadingHubs = true;

  // Route Calculator state
  UnionHubModel? _originHub;
  UnionHubModel? _destHub;
  double _cargoKg = 50.0;
  bool _isColdChain = false;
  UnionHubLogisticsQuote? _quote;

  // QC Checker state
  final _qcSearchCtrl = TextEditingController();
  QcInspectionModel? _qcResult;

  // Drop-off Pass state
  UnionHubModel? _passHub;
  String _passToken = '';

  // Live Dashboard state
  Map<String, dynamic> _dashStats = {};
  String _dashDistrict = 'Patuakhali';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _selectedDistrict = widget.initialDistrict ?? 'All';
    _loadHubs();
    _loadDashStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _qcSearchCtrl.dispose();
    super.dispose();
  }

  void _loadHubs() {
    setState(() => _isLoadingHubs = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      List<UnionHubModel> hubs;
      if (_selectedDivision != 'All') {
        hubs = _service.getHubsByDivision(_selectedDivision);
      } else if (_selectedDistrict != 'All') {
        hubs = _service.getHubsByDistrict(_selectedDistrict);
      } else {
        hubs = _service.getAllHubs();
      }
      if (_searchQuery.isNotEmpty) {
        hubs = _service.searchHubs(_searchQuery);
      }
      setState(() {
        _filteredHubs = hubs;
        _isLoadingHubs = false;
        if (_filteredHubs.isNotEmpty) {
          _originHub ??= _filteredHubs.first;
          _destHub ??= _filteredHubs.length > 1 ? _filteredHubs[1] : _filteredHubs.first;
          _passHub ??= _filteredHubs.first;
        }
      });
    });
  }

  void _loadDashStats() {
    final stats = _service.getDistrictHubStats(_dashDistrict);
    setState(() => _dashStats = stats);
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final isBn = langProvider.isBangla;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final surface = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final accent = const Color(0xFF16A34A);
    final accentLight = const Color(0xFF4ADE80);

    return Scaffold(
      backgroundColor: bg,
      body: NestedScrollView(
        headerSliverBuilder: (context, inner) => [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF0F172A) : accent,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF14532D), const Color(0xFF0F172A)]
                        : [const Color(0xFF16A34A), const Color(0xFF065F46)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        Row(children: [
                          const Icon(Icons.account_balance, color: Colors.white70, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isBn ? '🏡 ইউনিয়ন হাব নেটওয়ার্ক' : '🏡 Union Hub Network',
                              style: GoogleFonts.hind(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]),
                        const SizedBox(height: 4),
                        Text(
                          isBn
                              ? 'বাংলাদেশের প্রতিটি ইউনিয়নে AgroLink হাব'
                              : 'AgroLink hub in every union across Bangladesh',
                          style: GoogleFonts.hind(color: Colors.white70, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(46),
              child: Container(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: accent,
                  indicatorWeight: 3,
                  labelColor: accent,
                  unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  labelStyle: GoogleFonts.hind(fontSize: 12, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: GoogleFonts.hind(fontSize: 11),
                  tabs: [
                    Tab(text: isBn ? '🗂 ডিরেক্টরি' : '🗂 Directory'),
                    Tab(text: isBn ? '🔍 QC সার্টিফিকেট' : '🔍 QC Certificate'),
                    Tab(text: isBn ? '🚛 রুট ক্যালকুলেটর' : '🚛 Route Calc'),
                    Tab(text: isBn ? '📦 ড্রপ-অফ পাস' : '📦 Drop-off Pass'),
                    Tab(text: isBn ? '📊 লাইভ ড্যাশবোর্ড' : '📊 Live Dashboard'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDirectoryTab(isBn, isDark, surface, textPrimary, accent, accentLight),
            _buildQcTab(isBn, isDark, surface, textPrimary, accent),
            _buildRouteTab(isBn, isDark, surface, textPrimary, accent),
            _buildDropOffTab(isBn, isDark, surface, textPrimary, accent),
            _buildDashboardTab(isBn, isDark, surface, textPrimary, accent),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // TAB 1: DIRECTORY
  // ══════════════════════════════════════════════════

  Widget _buildDirectoryTab(bool isBn, bool isDark, Color surface, Color textPrimary, Color accent, Color accentLight) {
    final textSecondary = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    return Column(
      children: [
        // Filter bar
        Container(
          color: surface,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(children: [
            // Search
            TextField(
              style: GoogleFonts.hind(color: textPrimary),
              decoration: InputDecoration(
                hintText: isBn ? 'ইউনিয়ন, উপজেলা বা জেলা খুঁজুন...' : 'Search union, upazila or district...',
                hintStyle: GoogleFonts.hind(color: textSecondary, fontSize: 13),
                prefixIcon: Icon(Icons.search, color: textSecondary, size: 20),
                filled: true,
                fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              onChanged: (v) { _searchQuery = v; _loadHubs(); },
            ),
            const SizedBox(height: 8),
            Row(children: [
              // Division filter
              Expanded(child: _buildDropdown(
                isBn ? 'বিভাগ' : 'Division',
                _selectedDivision,
                ['All', ...BDUnionData.divisions],
                isDark, textPrimary, surface,
                (val) { setState(() { _selectedDivision = val!; _selectedDistrict = 'All'; }); _loadHubs(); },
              )),
              const SizedBox(width: 8),
              // District filter
              Expanded(child: _buildDropdown(
                isBn ? 'জেলা' : 'District',
                _selectedDistrict,
                ['All', ...BDUnionData.districtsWithUnionData],
                isDark, textPrimary, surface,
                (val) { setState(() => _selectedDistrict = val!); _loadHubs(); },
              )),
            ]),
          ]),
        ),
        // Count badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          alignment: Alignment.centerLeft,
          child: Text(
            _isLoadingHubs
                ? (isBn ? 'লোড হচ্ছে...' : 'Loading...')
                : (isBn ? '${_filteredHubs.length}টি ইউনিয়ন হাব পাওয়া গেছে' : '${_filteredHubs.length} union hubs found'),
            style: GoogleFonts.hind(color: textSecondary, fontSize: 12),
          ),
        ),
        // Hub list
        Expanded(
          child: _isLoadingHubs
              ? Center(child: CircularProgressIndicator(color: accent))
              : _filteredHubs.isEmpty
                  ? Center(child: Text(
                      isBn ? 'কোনো হাব পাওয়া যায়নি' : 'No hubs found',
                      style: GoogleFonts.hind(color: textSecondary),
                    ))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                      itemCount: _filteredHubs.length,
                      itemBuilder: (ctx, i) => _buildHubCard(_filteredHubs[i], isBn, isDark, surface, textPrimary, accent),
                    ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, bool isDark, Color textPrimary, Color surface, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: GoogleFonts.hind(color: textPrimary, fontSize: 12),
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildHubCard(UnionHubModel hub, bool isBn, bool isDark, Color surface, Color textPrimary, Color accent) {
    final textSecondary = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final tierColor = hub.tier == 'Gold'
        ? const Color(0xFFF59E0B)
        : hub.tier == 'Silver'
            ? Colors.grey.shade500
            : const Color(0xFFB45309);

    Color statusColor;
    String statusLabel;
    switch (hub.statusKey) {
      case 'full':
        statusColor = Colors.red.shade400;
        statusLabel = isBn ? 'পূর্ণ' : 'Full';
        break;
      case 'busy':
        statusColor = Colors.orange.shade400;
        statusLabel = isBn ? 'ব্যস্ত' : 'Busy';
        break;
      case 'inactive':
        statusColor = Colors.grey.shade400;
        statusLabel = isBn ? 'নিষ্ক্রিয়' : 'Inactive';
        break;
      default:
        statusColor = Colors.green.shade400;
        statusLabel = isBn ? 'সক্রিয়' : 'Available';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(children: [
              // Hub Icon
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.warehouse, color: accent, size: 22),
              ),
              const SizedBox(width: 10),
              // Hub name & location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn ? hub.fullNameBn : hub.fullName,
                      style: GoogleFonts.hind(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      isBn ? hub.locationFullBn : hub.locationFull,
                      style: GoogleFonts.hind(color: textSecondary, fontSize: 11),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Tier badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: tierColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                child: Text(
                  isBn ? hub.tierBn : hub.tier,
                  style: GoogleFonts.hind(color: tierColor, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            // Stats row
            Row(children: [
              _hubStat(Icons.inventory_2, '${hub.activeOrders}', isBn ? 'অর্ডার' : 'Orders', textSecondary),
              const SizedBox(width: 12),
              _hubStat(Icons.star, hub.rating.toStringAsFixed(1), isBn ? 'রেটিং' : 'Rating', textSecondary),
              const SizedBox(width: 12),
              _hubStat(Icons.speed, '${hub.utilizationPercent.toStringAsFixed(0)}%', isBn ? 'ব্যবহার' : 'Utilization', textSecondary),
              const Spacer(),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(statusLabel, style: GoogleFonts.hind(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700)),
                ]),
              ),
            ]),
            const SizedBox(height: 8),
            // Capabilities
            Wrap(
              spacing: 6, runSpacing: 4,
              children: [
                if (hub.hasColdStorage) _capChip('❄️ ${isBn ? 'কোল্ড স্টোরেজ' : 'Cold Storage'}', isDark),
                if (hub.hasPackagingUnit) _capChip('📦 ${isBn ? 'প্যাকেজিং' : 'Packaging'}', isDark),
                if (hub.hasWeighbridge) _capChip('⚖️ ${isBn ? 'ওজন মেশিন' : 'Weighbridge'}', isDark),
                if (hub.hasQrScanner) _capChip('📱 QR', isDark),
              ],
            ),
            const SizedBox(height: 8),
            // Hub code & Manager
            Row(children: [
              Icon(Icons.qr_code, size: 13, color: textSecondary),
              const SizedBox(width: 4),
              Text(hub.hubCode, style: GoogleFonts.robotoMono(color: textSecondary, fontSize: 10)),
              const SizedBox(width: 12),
              Icon(Icons.person_outline, size: 13, color: textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(hub.managerName, style: GoogleFonts.hind(color: textSecondary, fontSize: 10), overflow: TextOverflow.ellipsis),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _hubStat(IconData icon, String value, String label, Color textSecondary) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 12, color: textSecondary),
        const SizedBox(width: 3),
        Text(value, style: GoogleFonts.hind(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
      Text(label, style: GoogleFonts.hind(color: textSecondary, fontSize: 9)),
    ]);
  }

  Widget _capChip(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: GoogleFonts.hind(fontSize: 10, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700)),
    );
  }

  // ══════════════════════════════════════════════════
  // TAB 2: QC CERTIFICATE CHECKER
  // ══════════════════════════════════════════════════

  Widget _buildQcTab(bool isBn, bool isDark, Color surface, Color textPrimary, Color accent) {
    final textSecondary = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Search box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Text(
              isBn ? '🔍 QC সার্টিফিকেট যাচাই করুন' : '🔍 Verify QC Certificate',
              style: GoogleFonts.hind(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              isBn ? 'অর্ডার আইডি বা ব্যাচ কোড দিয়ে সার্টিফিকেট চেক করুন' : 'Enter Order ID or Batch Code to verify certificate',
              style: GoogleFonts.hind(color: textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _qcSearchCtrl,
              style: GoogleFonts.robotoMono(color: textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: isBn ? 'যেমন: ORD-2024-00123 বা BATCH-...' : 'e.g. ORD-2024-00123 or BATCH-...',
                hintStyle: GoogleFonts.hind(color: textSecondary, fontSize: 12),
                filled: true,
                fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: accent),
                  onPressed: _doQcSearch,
                ),
              ),
              onSubmitted: (_) => _doQcSearch(),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.verified_outlined, size: 18),
                label: Text(isBn ? 'সার্টিফিকেট যাচাই করুন' : 'Verify Certificate', style: GoogleFonts.hind(fontWeight: FontWeight.w700)),
                onPressed: _doQcSearch,
              ),
            ),
          ]),
        ),

        const SizedBox(height: 16),

        // QC Result
        if (_qcResult != null) _buildQcCertCard(_qcResult!, isBn, isDark, surface, textPrimary, accent),
        if (_qcResult == null)
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: Column(children: [
              Icon(Icons.document_scanner_outlined, size: 64, color: textSecondary),
              const SizedBox(height: 12),
              Text(
                isBn ? 'QC রিপোর্ট দেখতে উপরে অর্ডার আইডি টাইপ করুন' : 'Type an Order ID above to view QC report',
                style: GoogleFonts.hind(color: textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Demo button
              TextButton(
                onPressed: () {
                  _qcSearchCtrl.text = 'ORD-DEMO-${DateTime.now().millisecondsSinceEpoch % 10000}';
                  _doQcSearch();
                },
                child: Text(isBn ? '🎯 ডেমো সার্টিফিকেট দেখুন' : '🎯 View Demo Certificate', style: GoogleFonts.hind(color: accent)),
              ),
            ]),
          ),
      ]),
    );
  }

  void _doQcSearch() {
    if (_filteredHubs.isEmpty) return;
    final orderId = _qcSearchCtrl.text.trim().isEmpty
        ? 'ORD-DEMO-${DateTime.now().millisecondsSinceEpoch}'
        : _qcSearchCtrl.text.trim();
    final hub = _filteredHubs.first;
    final result = _service.generateQcInspection(
      orderId: orderId,
      weightKg: 50.0,
      hub: hub,
    );
    setState(() => _qcResult = result);
  }

  Widget _buildQcCertCard(QcInspectionModel qc, bool isBn, bool isDark, Color surface, Color textPrimary, Color accent) {
    final textSecondary = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final isApproved = qc.isApproved;
    final statusColor = isApproved ? Colors.green.shade500 : Colors.red.shade400;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Icon(isApproved ? Icons.verified : Icons.cancel_outlined, color: statusColor, size: 28),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              isBn ? (isApproved ? '✅ QC অনুমোদিত' : '❌ QC প্রত্যাখ্যাত') : (isApproved ? '✅ QC Approved' : '❌ QC Rejected'),
              style: GoogleFonts.hind(color: statusColor, fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              isBn ? qc.getGrade(true) : qc.grade,
              style: GoogleFonts.hind(color: textSecondary, fontSize: 12),
            ),
          ])),
          // Copy batch code
          IconButton(
            icon: Icon(Icons.copy, size: 16, color: textSecondary),
            tooltip: isBn ? 'কপি করুন' : 'Copy',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: qc.batchCode));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isBn ? 'ব্যাচ কোড কপি হয়েছে' : 'Batch code copied'), duration: const Duration(seconds: 2)),
              );
            },
          ),
        ]),

        const Divider(height: 20),

        // Metrics grid
        Wrap(spacing: 10, runSpacing: 10, children: [
          _qcMetric(isBn ? 'সতেজতা' : 'Freshness', '${qc.freshnessScore}%', Icons.eco, Colors.green, isDark),
          _qcMetric(isBn ? 'আর্দ্রতা' : 'Moisture', '${qc.moisturePercent}%', Icons.water_drop, Colors.blue, isDark),
          _qcMetric(isBn ? 'ত্রুটি' : 'Defect', '${qc.defectPercent}%', Icons.warning_amber, Colors.orange, isDark),
          _qcMetric(isBn ? 'ওজন' : 'Weight', '${qc.testedWeightKg} kg', Icons.scale, accent, isDark),
        ]),

        const SizedBox(height: 12),

        // Details
        _qcDetailRow(isBn ? 'অর্ডার আইডি' : 'Order ID', qc.orderId, textPrimary, textSecondary),
        _qcDetailRow(isBn ? 'ব্যাচ কোড' : 'Batch Code', qc.batchCode, textPrimary, textSecondary),
        _qcDetailRow(isBn ? 'সিল কোড' : 'Seal Code', qc.tamperProofSealCode, textPrimary, textSecondary),
        _qcDetailRow(isBn ? 'হাব' : 'Hub', isBn ? qc.hubName : qc.hubNameEn, textPrimary, textSecondary),
        _qcDetailRow(isBn ? 'পরিদর্শক' : 'Inspector', qc.inspectorName, textPrimary, textSecondary),
        _qcDetailRow(isBn ? 'প্যাকেজিং' : 'Packaging', isBn ? qc.getPackagingType(true) : qc.packagingType, textPrimary, textSecondary),
        _qcDetailRow(
          isBn ? 'পরিদর্শনের সময়' : 'Inspection Time',
          '${qc.inspectedAt.day}/${qc.inspectedAt.month}/${qc.inspectedAt.year} ${qc.inspectedAt.hour}:${qc.inspectedAt.minute.toString().padLeft(2, '0')}',
          textPrimary, textSecondary,
        ),

        const SizedBox(height: 12),

        // Notes
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            isBn ? qc.getNotes(true) : qc.notes,
            style: GoogleFonts.hind(color: textPrimary, fontSize: 12),
          ),
        ),

        const SizedBox(height: 12),

        // QR Code
        Center(child: QrImageView(
          data: 'AGRO-QC|${qc.orderId}|${qc.batchCode}|${qc.grade}|${qc.tamperProofSealCode}',
          version: QrVersions.auto,
          size: 120,
          backgroundColor: Colors.white,
          eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
          dataModuleStyle: QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
        )),
        Center(child: Text(isBn ? 'QC যাচাইয়ের QR কোড' : 'QR Code for QC Verification',
          style: GoogleFonts.hind(color: textSecondary, fontSize: 10))),
      ]),
    );
  }

  Widget _qcMetric(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.hind(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        Text(label, style: GoogleFonts.hind(color: color.withValues(alpha: 0.8), fontSize: 9), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _qcDetailRow(String label, String value, Color textPrimary, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 110, child: Text(label, style: GoogleFonts.hind(color: textSecondary, fontSize: 12))),
        Expanded(child: Text(': $value', style: GoogleFonts.hind(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  // ══════════════════════════════════════════════════
  // TAB 3: ROUTE CALCULATOR
  // ══════════════════════════════════════════════════

  Widget _buildRouteTab(bool isBn, bool isDark, Color surface, Color textPrimary, Color accent) {
    final textSecondary = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    if (_filteredHubs.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.warehouse_outlined, size: 60, color: textSecondary),
        const SizedBox(height: 12),
        Text(isBn ? 'প্রথমে ডিরেক্টরি থেকে হাব লোড করুন' : 'Load hubs from Directory tab first',
          style: GoogleFonts.hind(color: textSecondary), textAlign: TextAlign.center),
      ]));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Origin
        _sectionHeader(isBn ? '📍 উৎপত্তি হাব' : '📍 Origin Hub', textPrimary),
        const SizedBox(height: 8),
        _buildHubSelector(_originHub, isBn, isDark, surface, textPrimary, accent, (hub) => setState(() => _originHub = hub)),

        const SizedBox(height: 16),

        // Destination
        _sectionHeader(isBn ? '🎯 গন্তব্য হাব' : '🎯 Destination Hub', textPrimary),
        const SizedBox(height: 8),
        _buildHubSelector(_destHub, isBn, isDark, surface, textPrimary, accent, (hub) => setState(() => _destHub = hub)),

        const SizedBox(height: 16),

        // Weight Slider
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.scale, color: accent, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isBn ? 'পণ্যের ওজন: ${_cargoKg.toStringAsFixed(0)} কেজি' : 'Cargo Weight: ${_cargoKg.toStringAsFixed(0)} kg',
                  style: GoogleFonts.hind(color: textPrimary, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
            Slider(
              value: _cargoKg,
              min: 5, max: 1000,
              divisions: 199,
              activeColor: accent,
              inactiveColor: accent.withValues(alpha: 0.2),
              onChanged: (v) => setState(() => _cargoKg = v),
            ),
          ]),
        ),

        const SizedBox(height: 12),

        // Cold Chain Toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Icon(Icons.ac_unit, color: _isColdChain ? Colors.blue.shade400 : textSecondary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isBn ? 'কোল্ড চেইন ট্রান্সপোর্ট' : 'Cold Chain Transport',
                style: GoogleFonts.hind(color: textPrimary, fontWeight: FontWeight.w600),
              ),
            ),
            Switch(value: _isColdChain, activeThumbColor: Colors.blue.shade400, onChanged: (v) => setState(() => _isColdChain = v)),
          ]),
        ),

        const SizedBox(height: 16),

        // Calculate button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.calculate_outlined, size: 20),
            label: Text(
              isBn ? 'ভাড়া হিসাব করুন' : 'Calculate Fare',
              style: GoogleFonts.hind(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            onPressed: () {
              if (_originHub == null || _destHub == null) return;
              final q = _service.calculateLogisticsQuote(
                origin: _originHub!,
                destination: _destHub!,
                cargoWeightKg: _cargoKg,
                isColdChain: _isColdChain,
              );
              setState(() => _quote = q);
            },
          ),
        ),

        // Fare Breakdown
        if (_quote != null) ...[
          const SizedBox(height: 20),
          _buildFareCard(_quote!, isBn, isDark, surface, textPrimary, accent),
        ],
      ]),
    );
  }

  Widget _buildHubSelector(UnionHubModel? selected, bool isBn, bool isDark, Color surface, Color textPrimary, Color accent, ValueChanged<UnionHubModel> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<UnionHubModel>(
          value: _filteredHubs.contains(selected) ? selected : _filteredHubs.first,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          style: GoogleFonts.hind(color: textPrimary, fontSize: 13),
          items: _filteredHubs.map((h) => DropdownMenuItem(
            value: h,
            child: Text(isBn ? h.fullNameBn : h.fullName, overflow: TextOverflow.ellipsis),
          )).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }

  Widget _buildFareCard(UnionHubLogisticsQuote q, bool isBn, bool isDark, Color surface, Color textPrimary, Color accent) {
    final textSecondary = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final transitBadgeColor = q.transitType == 'direct'
        ? Colors.green.shade500
        : q.transitType == 'via-upazila'
            ? Colors.orange.shade500
            : Colors.red.shade400;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(isBn ? '💰 ভাড়া বিবরণ' : '💰 Fare Breakdown', style: GoogleFonts.hind(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
        const Divider(height: 16),

        // Route type badge
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: transitBadgeColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(
              q.transitType == 'direct'
                  ? (isBn ? '⚡ সরাসরি' : '⚡ Direct')
                  : q.transitType == 'via-upazila'
                      ? (isBn ? '🏢 উপজেলা হাব হয়ে' : '🏢 Via Upazila Hub')
                      : (isBn ? '🏙️ জেলা গেটওয়ে হয়ে' : '🏙️ Via District Gateway'),
              style: GoogleFonts.hind(color: transitBadgeColor, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${q.distanceKm} km  •  ETA: ${q.etaHours}h',
              style: GoogleFonts.hind(color: textSecondary, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]),
        const SizedBox(height: 12),

        // Route description
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
          child: Text(
            isBn ? q.routeDescriptionBn : q.routeDescription,
            style: GoogleFonts.hind(color: textPrimary, fontSize: 11),
            maxLines: 3, overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 12),

        // Fare items
        _fareRow(isBn ? 'বেস ভাড়া' : 'Base Fare', q.baseFareBDT, textPrimary, textSecondary),
        _fareRow(isBn ? 'দূরত্ব ভাড়া' : 'Distance Fare', q.distanceFareBDT, textPrimary, textSecondary),
        _fareRow(isBn ? 'ওজন ভাড়া' : 'Weight Fare', q.weightFareBDT, textPrimary, textSecondary),
        if (q.isColdChain) _fareRow(isBn ? 'কোল্ড চেইন সারচার্জ' : 'Cold Chain Surcharge', q.coldChainSurcharge, textPrimary, textSecondary),
        _fareRow(isBn ? 'প্যাকেজিং ফি' : 'Packaging Fee', q.packagingFee, textPrimary, textSecondary),
        _fareRow(isBn ? 'QC ফি' : 'QC Fee', q.qcFee, textPrimary, textSecondary),
        const Divider(height: 16),
        Row(children: [
          Expanded(child: Text(isBn ? '💵 মোট ভাড়া' : '💵 Total Fare',
            style: GoogleFonts.hind(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w800))),
          Text('৳ ${q.totalFareBDT.toStringAsFixed(0)}',
            style: GoogleFonts.hind(color: accent, fontSize: 18, fontWeight: FontWeight.w900)),
        ]),
      ]),
    );
  }

  Widget _fareRow(String label, double amount, Color textPrimary, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Expanded(child: Text(label, style: GoogleFonts.hind(color: textSecondary, fontSize: 12), overflow: TextOverflow.ellipsis)),
        Text('৳ ${amount.toStringAsFixed(0)}', style: GoogleFonts.hind(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  // ══════════════════════════════════════════════════
  // TAB 4: FARMER DROP-OFF PASS
  // ══════════════════════════════════════════════════

  Widget _buildDropOffTab(bool isBn, bool isDark, Color surface, Color textPrimary, Color accent) {
    final textSecondary = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final expiry = DateTime.now().add(const Duration(hours: 24));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Hub selector
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isBn ? '🏡 হাব নির্বাচন করুন' : '🏡 Select Hub',
              style: GoogleFonts.hind(color: textPrimary, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (_filteredHubs.isNotEmpty)
              _buildHubSelector(_passHub, isBn, isDark, surface, textPrimary, accent, (hub) {
                setState(() { _passHub = hub; _passToken = ''; });
              }),
          ]),
        ),
        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.qr_code_2, size: 22),
            label: Text(isBn ? 'ড্রপ-অফ পাস তৈরি করুন' : 'Generate Drop-off Pass',
              style: GoogleFonts.hind(fontWeight: FontWeight.w700, fontSize: 15)),
            onPressed: () {
              final token = 'PASS-${DateTime.now().millisecondsSinceEpoch % 1000000}';
              setState(() => _passToken = token);
            },
          ),
        ),

        if (_passToken.isNotEmpty && _passHub != null) ...[
          const SizedBox(height: 20),
          // Pass Card
          Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withValues(alpha: 0.5), width: 2),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              // Header with green gradient bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF16A34A), Color(0xFF065F46)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(children: [
                  Text('🏡 AgroLink Union Hub', style: GoogleFonts.hind(color: Colors.white70, fontSize: 12)),
                  Text(
                    isBn ? 'কৃষক ড্রপ-অফ পাস' : 'Farmer Drop-off Pass',
                    style: GoogleFonts.hind(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ]),
              ),
              const SizedBox(height: 16),

              // QR Code
              QrImageView(
                data: _passHub!.qrPayload + '|TOKEN:$_passToken',
                version: QrVersions.auto,
                size: 160,
                backgroundColor: Colors.white,
                eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                dataModuleStyle: QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
              ),
              const SizedBox(height: 10),

              // Token
              Text(_passToken, style: GoogleFonts.robotoMono(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(isBn ? 'টোকেন নম্বর' : 'Token Number', style: GoogleFonts.hind(color: textSecondary, fontSize: 11)),

              const Divider(height: 20),

              // Details
              _passDetail(isBn ? '🏡 হাব' : '🏡 Hub', isBn ? _passHub!.fullNameBn : _passHub!.fullName, textPrimary, textSecondary),
              _passDetail(isBn ? '📍 ইউনিয়ন' : '📍 Union', isBn ? _passHub!.unionNameBn : _passHub!.unionName, textPrimary, textSecondary),
              _passDetail(isBn ? '🏷️ হাব কোড' : '🏷️ Hub Code', _passHub!.hubCode, textPrimary, textSecondary),
              _passDetail(isBn ? '👨 ম্যানেজার' : '👨 Manager', _passHub!.managerName, textPrimary, textSecondary),
              _passDetail(isBn ? '📞 ফোন' : '📞 Phone', _passHub!.managerPhone, textPrimary, textSecondary),
              _passDetail(
                isBn ? '⏰ মেয়াদ শেষ' : '⏰ Valid Until',
                '${expiry.day}/${expiry.month}/${expiry.year} ${expiry.hour}:${expiry.minute.toString().padLeft(2, '0')}',
                textPrimary, textSecondary,
              ),

              const SizedBox(height: 12),

              // Instructions
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isBn
                      ? '📌 এই পাসটি আপনার নিকটতম ইউনিয়ন হাবে দেখান। হাব স্টাফ আপনার পণ্য গ্রহণ করে QC পরীক্ষা করবেন এবং একটি QC সার্টিফিকেট ইস্যু করবেন।'
                      : '📌 Show this pass at your nearest Union Hub. Hub staff will receive your produce, perform QC inspection, and issue a QC Certificate.',
                  style: GoogleFonts.hind(color: textPrimary, fontSize: 11),
                ),
              ),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _passDetail(String label, String value, Color textPrimary, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 100, child: Text(label, style: GoogleFonts.hind(color: textSecondary, fontSize: 12))),
        Expanded(child: Text(': $value', style: GoogleFonts.hind(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  // ══════════════════════════════════════════════════
  // TAB 5: LIVE DASHBOARD
  // ══════════════════════════════════════════════════

  Widget _buildDashboardTab(bool isBn, bool isDark, Color surface, Color textPrimary, Color accent) {
    final textSecondary = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // District selector
        Row(children: [
          Expanded(
            child: Text(isBn ? '📊 জেলা হাব ড্যাশবোর্ড' : '📊 District Hub Dashboard',
              style: GoogleFonts.hind(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 8),
        _buildDropdown(
          isBn ? 'জেলা বাছাই করুন' : 'Select District',
          _dashDistrict,
          BDUnionData.districtsWithUnionData,
          isDark, textPrimary, surface,
          (val) { setState(() => _dashDistrict = val!); _loadDashStats(); },
        ),
        const SizedBox(height: 16),

        // Stat cards grid
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12, mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _dashCard(
              isBn ? 'মোট হাব' : 'Total Hubs',
              '${_dashStats['total'] ?? 0}',
              Icons.warehouse,
              const Color(0xFF6366F1),
              isDark, surface, textPrimary,
            ),
            _dashCard(
              isBn ? 'সক্রিয় হাব' : 'Active Hubs',
              '${_dashStats['active'] ?? 0}',
              Icons.check_circle_outline,
              const Color(0xFF16A34A),
              isDark, surface, textPrimary,
            ),
            _dashCard(
              isBn ? 'কোল্ড স্টোরেজ' : 'Cold Storage',
              '${_dashStats['coldStorage'] ?? 0}',
              Icons.ac_unit,
              const Color(0xFF0EA5E9),
              isDark, surface, textPrimary,
            ),
            _dashCard(
              isBn ? 'গড় রেটিং' : 'Avg. Rating',
              '${_dashStats['avgRating'] ?? 0}⭐',
              Icons.star_outline,
              const Color(0xFFF59E0B),
              isDark, surface, textPrimary,
            ),
            _dashCard(
              isBn ? 'সক্রিয় অর্ডার' : 'Active Orders',
              '${_dashStats['totalActiveOrders'] ?? 0}',
              Icons.shopping_bag_outlined,
              const Color(0xFFEC4899),
              isDark, surface, textPrimary,
            ),
            _dashCard(
              isBn ? 'গড় ব্যবহার' : 'Avg. Utilization',
              '${_dashStats['avgUtilization'] ?? 0}%',
              Icons.speed,
              const Color(0xFFEF4444),
              isDark, surface, textPrimary,
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Network hierarchy visual
        _sectionHeader(isBn ? '🔗 হাব নেটওয়ার্ক হায়ারার্কি' : '🔗 Hub Network Hierarchy', textPrimary),
        const SizedBox(height: 12),
        _buildHierarchyVisual(isBn, isDark, surface, textPrimary, accent, textSecondary),

        const SizedBox(height: 20),

        // Recent hubs
        _sectionHeader(isBn ? '🏡 জেলার হাব সমূহ' : '🏡 Hubs in District', textPrimary),
        const SizedBox(height: 8),
        ..._service.getHubsByDistrict(_dashDistrict).take(5).map(
          (hub) => _buildHubMiniCard(hub, isBn, isDark, surface, textPrimary, accent)
        ),

        const SizedBox(height: 80),
      ]),
    );
  }

  Widget _dashCard(String label, String value, IconData icon, Color color, bool isDark, Color surface, Color textPrimary) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 16),
          ),
        ]),
        const Spacer(),
        Text(value, style: GoogleFonts.hind(color: textPrimary, fontSize: 22, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
        Text(label, style: GoogleFonts.hind(color: color, fontSize: 11), overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  Widget _buildHierarchyVisual(bool isBn, bool isDark, Color surface, Color textPrimary, Color accent, Color textSecondary) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        _hierLevel('🌾 ${isBn ? 'কৃষক' : 'Farmer'}', isBn ? 'গ্রাম / ওয়ার্ড' : 'Village / Ward', Colors.green.shade400, textPrimary, textSecondary),
        _hierArrow(accent),
        _hierLevel('🏡 ${isBn ? 'ইউনিয়ন হাব' : 'Union Hub'}', isBn ? '৪,৫৫০+ ইউনিয়ন জুড়ে' : '4,550+ Unions covered', accent, textPrimary, textSecondary),
        _hierArrow(accent),
        _hierLevel('🏢 ${isBn ? 'উপজেলা হাব' : 'Upazila Hub'}', isBn ? '৪৯৫টি উপজেলা' : '495 Upazilas', Colors.blue.shade400, textPrimary, textSecondary),
        _hierArrow(accent),
        _hierLevel('🏙️ ${isBn ? 'জেলা গেটওয়ে' : 'District Gateway'}', isBn ? '৬৪টি জেলা' : '64 Districts', Colors.purple.shade400, textPrimary, textSecondary),
        _hierArrow(accent),
        _hierLevel('🌆 ${isBn ? 'বিভাগীয় কেন্দ্র' : 'Division Hub'}', isBn ? '৮টি বিভাগ' : '8 Divisions', Colors.orange.shade400, textPrimary, textSecondary),
        _hierArrow(accent),
        _hierLevel('🛒 ${isBn ? 'ক্রেতা' : 'Buyer'}', isBn ? 'OTP মুক্তি + এস্ক্রো পেমেন্ট' : 'OTP Release + Escrow Payment', Colors.red.shade400, textPrimary, textSecondary),
      ]),
    );
  }

  Widget _hierLevel(String title, String subtitle, Color color, Color textPrimary, Color textSecondary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        Container(width: 3, height: 32, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.hind(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
          Text(subtitle, style: GoogleFonts.hind(color: textSecondary, fontSize: 11), overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }

  Widget _hierArrow(Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Center(child: Icon(Icons.keyboard_arrow_down, color: accent, size: 20)),
    );
  }

  Widget _sectionHeader(String title, Color textPrimary) {
    return Text(title, style: GoogleFonts.hind(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w700));
  }
}

// Mini hub card for dashboard
extension _HubCardDash on _UnionHubNetworkScreenState {
  Widget _buildHubMiniCard(UnionHubModel hub, bool isBn, bool isDark, Color surface, Color textPrimary, Color accent) {
    final textSecondary = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
          child: Icon(Icons.warehouse, color: accent, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isBn ? hub.fullNameBn : hub.fullName,
            style: GoogleFonts.hind(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(hub.hubCode,
            style: GoogleFonts.robotoMono(color: textSecondary, fontSize: 10),
            overflow: TextOverflow.ellipsis),
        ])),
        const SizedBox(width: 6),
        Text('${hub.activeOrders} ${isBn ? 'অর্ডার' : 'orders'}',
          style: GoogleFonts.hind(color: accent, fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
