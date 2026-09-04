import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:agrolinkbd/core/controllers/pond_controller.dart';
import 'package:agrolinkbd/core/models/pond_model.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/pond_management/add_pond_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/pond_management/edit_pond_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/pond_management/pond_detail_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/ai_doctor/ai_fish_doctor_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/fcr_calculator/fish_growth_fcr_simulator_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/premium/satellite_pond_radar_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/premium/fish_water_telemetry_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/premium/bank_project_report_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/auction/create_fish_auction_screen.dart';
import 'package:agrolinkbd/presentation/screens/marketplace/fish_marketplace_screen.dart';

class PondManagementScreen extends StatefulWidget {
  const PondManagementScreen({super.key});

  @override
  State<PondManagementScreen> createState() => _PondManagementScreenState();
}

class _PondManagementScreenState extends State<PondManagementScreen> with SingleTickerProviderStateMixin {
  late final PondController _pondController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pondController = Get.isRegistered<PondController>()
        ? Get.find<PondController>()
        : Get.put(PondController());

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showInstantMarketSellDialog(PondModel pond, bool isBn) {
    final quantityController = TextEditingController(
      text: (pond.currentTotalBiomassKg * 0.8).round().toString(),
    );
    final priceController = TextEditingController(
      text: pond.expectedMarketPricePerKg.round().toString(),
    );

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006064).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.storefront, color: Color(0xFF006064), size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn ? 'সরাসরি বড় মাছ বাজারে বিক্রি' : 'Sell Directly to Fish Market',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${pond.name} • ${pond.fishSpecies}',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade50, Colors.cyan.shade50],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          isBn ? 'পুকুরের মোট বায়োমাস' : 'Total Biomass',
                          style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade700),
                        ),
                        Text(
                          isBn ? '${pond.currentTotalBiomassKg.toStringAsFixed(0)} কেজি' : '${pond.currentTotalBiomassKg.toStringAsFixed(0)} kg',
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF006064)),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 32, color: Colors.teal.shade200),
                    Column(
                      children: [
                        Text(
                          isBn ? 'গড় একক ওজন' : 'Avg. Unit Weight',
                          style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade700),
                        ),
                        Text(
                          isBn ? '${pond.avgWeightGrams.toStringAsFixed(0)} গ্রাম' : '${pond.avgWeightGrams.toStringAsFixed(0)} g',
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                isBn ? 'বিক্রয়যোগ্য লটের পরিমাণ (কেজি):' : 'Saleable Lot Quantity (kg):',
                style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.scale, color: Color(0xFF006064)),
                  suffixText: isBn ? 'কেজি' : 'kg',
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                isBn ? 'প্রতি কেজি পাইকারি দর (৳):' : 'Wholesale Price per kg (৳):',
                style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.monetization_on, color: Colors.teal),
                  suffixText: '৳/kg',
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        Get.to(() => const CreateFishAuctionScreen());
                      },
                      icon: const Icon(Icons.gavel, size: 18),
                      label: Text(
                        isBn ? 'লাইভ ডাক (নিলাম)' : 'Live Auction',
                        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: const BorderSide(color: Color(0xFF006064), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        Get.snackbar(
                          isBn ? 'সফলভাবে বাজারে তালিকাভুক্ত!' : 'Listed Successfully!',
                          isBn
                              ? 'আপনার ${pond.name} এর মাছ সফলভাবে বিগ ফিশ মার্কেটে আপলোড হয়েছে।'
                              : '${pond.name} fish listed on Big Fish Market. Buyers can now order directly.',
                          backgroundColor: const Color(0xFF006064),
                          colorText: Colors.white,
                          icon: const Icon(Icons.verified, color: Colors.white),
                          duration: const Duration(seconds: 4),
                        );
                        Get.to(() => const FishMarketplaceScreen());
                      },
                      icon: const Icon(Icons.check_circle, color: Colors.white, size: 18),
                      label: Text(
                        isBn ? 'বাজারে প্রকাশ করুন' : 'Publish to Market',
                        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006064),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBn = LanguageProvider.isBn(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color deepAqua = Color(0xFF006064);
    const Color cyanGlow = Color(0xFF00E5FF);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B141B) : const Color(0xFFF2F6F9),
      body: RefreshIndicator(
        onRefresh: () async => await _pondController.refreshPonds(),
        color: deepAqua,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: deepAqua,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              title: Row(
                children: [
                  Icon(Icons.water, color: cyanGlow, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    isBn ? 'স্মার্ট ফিশ ফার্ম হাব' : 'Smart Fish Farm Hub',
                    style: GoogleFonts.hindSiliguri(
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00363A), Color(0xFF006064), Color(0xFF0288D1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.store_mall_directory_rounded, color: Colors.white),
                tooltip: isBn ? 'বিগ ফিশ মার্কেটপ্লেস' : 'Fish Marketplace',
                onPressed: () => Get.to(() => const FishMarketplaceScreen()),
              ),
              IconButton(
                icon: const Icon(Icons.satellite_alt, color: Colors.white),
                tooltip: isBn ? 'স্যাটেলাইট রেডার' : 'Satellite Radar',
                onPressed: () => Get.to(() => const SatellitePondRadarScreen()),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Obx(() => _buildExecutiveSummaryBanner(context, isDark, isBn)),
            ),
          ),

          SliverToBoxAdapter(
            child: _buildQuickToolsStrip(context, isDark, isBn),
          ),

          SliverToBoxAdapter(
            child: _buildFilterChips(isBn),
          ),

          Obx(() {
            final pondsList = _pondController.filteredPonds;
            if (pondsList.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(isBn),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildProMaxPondCard(context, pondsList[index], isDark, isBn);
                  },
                  childCount: pondsList.length,
                ),
              ),
            );
          }),

          const SliverToBoxAdapter(
            child: SizedBox(height: 90),
          ),
        ],
      ),
    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const AddPondScreen()),
        backgroundColor: deepAqua,
        elevation: 6,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          isBn ? 'নতুন পুকুর / ট্যাংক' : 'New Pond / Tank',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildExecutiveSummaryBanner(BuildContext context, bool isDark, bool isBn) {
    final totalBiomass = _pondController.totalFarmBiomassKg;
    final totalValuation = _pondController.totalFarmValuation;
    final avgDO = _pondController.averageDissolvedOxygen;
    final totalPonds = _pondController.ponds.length;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004D40), Color(0xFF006064), Color(0xFF01579B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004D40).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.waves,
              size: 140,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.insights, color: Color(0xFF80DEEA), size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isBn ? 'ফার্ম এক্সিকিউটিভ ড্যাশবোর্ড' : 'Farm Executive Dashboard',
                          style: GoogleFonts.hindSiliguri(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isBn ? 'লাইভ সেন্সর সক্রিয়' : 'Live Sensors Active',
                            style: GoogleFonts.hindSiliguri(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBn ? 'প্রত্যাশিত বাজার মূল্য (Valuation)' : 'Expected Market Valuation',
                            style: GoogleFonts.hindSiliguri(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '৳${totalValuation.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBn ? 'মোট বায়োমাস (Biomass)' : 'Total Biomass',
                            style: GoogleFonts.hindSiliguri(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isBn ? '${totalBiomass.toStringAsFixed(0)} কেজি' : '${totalBiomass.toStringAsFixed(0)} kg',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF80DEEA),
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMiniBadge(Icons.pool, isBn ? '$totalPonds টি সক্রিয় ইউনিট' : '$totalPonds Active Units'),
                    _buildMiniBadge(Icons.air, 'DO: ${avgDO.toStringAsFixed(1)} mg/L'),
                    _buildMiniBadge(Icons.health_and_safety, isBn ? '৯৬% ওয়াটার হেলথ' : '96% Water Health'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF80DEEA), size: 14),
        const SizedBox(width: 5),
        Text(
          text,
          style: GoogleFonts.hindSiliguri(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickToolsStrip(BuildContext context, bool isDark, bool isBn) {
    final tools = [
      {
        'title': isBn ? 'বিগ ফিশ মার্কেট' : 'Big Fish Market',
        'sub': isBn ? 'সরাসরি বিক্রয়' : 'Direct Sale',
        'icon': Icons.storefront_rounded,
        'color': const Color(0xFF00897B),
        'onTap': () => Get.to(() => const FishMarketplaceScreen()),
      },
      {
        'title': isBn ? 'লাইভ নিলাম ডাক' : 'Live Auction',
        'sub': isBn ? 'আড়তদার নিলাম' : 'Wholesale Auction',
        'icon': Icons.gavel_rounded,
        'color': const Color(0xFFD81B60),
        'onTap': () => Get.to(() => const CreateFishAuctionScreen()),
      },
      {
        'title': isBn ? 'AI ফিশ ডক্টর' : 'AI Fish Doctor',
        'sub': isBn ? 'রোগ ও ওয়াটার স্ক্যান' : 'Disease & Water Scan',
        'icon': Icons.medical_services_rounded,
        'color': const Color(0xFF0288D1),
        'onTap': () => Get.to(() => const AIFishDoctorScreen()),
      },
      {
        'title': isBn ? 'FCR ও গ্রোথ' : 'FCR & Growth',
        'sub': isBn ? 'বৃদ্ধি সিমুলেটর' : 'Growth Simulator',
        'icon': Icons.auto_graph_rounded,
        'color': const Color(0xFF7B1FA2),
        'onTap': () => Get.to(() => const FishGrowthFcrSimulatorScreen()),
      },
      {
        'title': isBn ? 'টেলিমেট্রি সেন্সর' : 'Telemetry Sensor',
        'sub': isBn ? 'রিয়েল-টাইম ডেটা' : 'Real-time Data',
        'icon': Icons.sensors_rounded,
        'color': const Color(0xFFF57C00),
        'onTap': () => Get.to(() => const FishWaterTelemetryScreen()),
      },
      {
        'title': isBn ? 'ব্যাংক রিপোর্ট' : 'Bank Report',
        'sub': isBn ? 'ঋণ ও প্রজেক্ট ফাইল' : 'Loan & Project',
        'icon': Icons.description_rounded,
        'color': const Color(0xFF388E3C),
        'onTap': () => Get.to(() => const BankProjectReportScreen()),
      },
    ];

    return Container(
      height: 94,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: tools.length,
        itemBuilder: (context, index) {
          final tool = tools[index];
          final color = tool['color'] as Color;

          return GestureDetector(
            onTap: tool['onTap'] as VoidCallback,
            child: Container(
              width: 140,
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16252F) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: color.withOpacity(isDark ? 0.3 : 0.15),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(tool['icon'] as IconData, color: color, size: 22),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tool['title'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          tool['sub'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
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

  Widget _buildFilterChips(bool isBn) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Obx(() {
        final current = _pondController.selectedFilter.value;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildFilterChip('all', isBn ? 'সব পুকুর (${_pondController.ponds.length})' : 'All (${_pondController.ponds.length})', current),
              _buildFilterChip('optimal', isBn ? '🟢 সর্বোত্তম ও স্বাভাবিক' : '🟢 Optimal', current),
              _buildFilterChip('ready', isBn ? '🔵 হারভেস্ট প্রস্তুত' : '🔵 Harvest Ready', current),
              _buildFilterChip('warning', isBn ? '🟡 বিশেষ পর্যবেক্ষণ' : '🟡 Watch List', current),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterChip(String key, String label, String current) {
    final isSelected = current == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
        selected: isSelected,
        onSelected: (val) {
          _pondController.selectedFilter.value = key;
        },
        backgroundColor: Colors.transparent,
        selectedColor: const Color(0xFF006064),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? const Color(0xFF006064) : Colors.grey.shade300,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  Widget _buildProMaxPondCard(BuildContext context, PondModel pond, bool isDark, bool isBn) {
    final bool isReady = pond.status == 'হারভেস্ট প্রস্তুত';
    final bool isWarning = pond.status == 'সতর্কতা' || pond.status == 'ঝুঁকিপূর্ণ';

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16252F) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 14,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: isReady
              ? const Color(0xFF0288D1).withOpacity(0.6)
              : (isWarning ? Colors.orange.withOpacity(0.5) : Colors.transparent),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => Get.to(() => PondDetailScreen(pond: pond)),
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: CachedNetworkImage(
                      imageUrl: pond.imageUrl,
                      height: 155,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 155,
                        color: Colors.grey.shade300,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 155,
                        color: const Color(0xFF006064),
                        child: const Icon(Icons.pool, size: 50, color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                            Colors.black.withOpacity(0.75),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isReady
                            ? const Color(0xFF0288D1).withOpacity(0.9)
                            : (isWarning ? Colors.orange.shade800.withOpacity(0.9) : Colors.teal.shade800.withOpacity(0.9)),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isReady ? Icons.check_circle : (isWarning ? Icons.warning : Icons.check_circle_outline),
                            color: Colors.white,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            pond.status,
                            style: GoogleFonts.hindSiliguri(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 14,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.amber, size: 13),
                              const SizedBox(width: 4),
                              Text(
                                pond.location,
                                style: GoogleFonts.hindSiliguri(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          height: 28,
                          width: 28,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                          ),
                          child: PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.more_vert, color: Colors.white, size: 16),
                            onSelected: (val) {
                              if (val == 'edit') {
                                Get.to(() => EditPondScreen(pond: pond));
                              } else if (val == 'delete') {
                                Get.defaultDialog(
                                  title: isBn ? 'পুকুর / ট্যাংক মুছে ফেলুন' : 'Delete Pond / Tank',
                                  titleStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.red.shade700),
                                  content: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Text(
                                      isBn
                                          ? 'আপনি কি নিশ্চিত যে "${pond.name}" স্থায়ীভাবে ফায়ারবেস থেকে মুছে ফেলতে চান?'
                                          : 'Are you sure you want to permanently delete "${pond.name}"?',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.hindSiliguri(fontSize: 13.5),
                                    ),
                                  ),
                                  confirm: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade700,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: () async {
                                      Get.back();
                                      await _pondController.deletePond(pond.id);
                                      Get.snackbar(
                                        isBn ? 'মুছে ফেলা হয়েছে' : 'Deleted',
                                        isBn ? '${pond.name} সফলভাবে মুছে ফেলা হয়েছে।' : '${pond.name} has been deleted.',
                                        backgroundColor: Colors.red.shade700,
                                        colorText: Colors.white,
                                      );
                                    },
                                    child: Text(isBn ? 'মুছে ফেলুন' : 'Delete', style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                  cancel: OutlinedButton(
                                    onPressed: () => Get.back(),
                                    child: Text(isBn ? 'বাতিল' : 'Cancel', style: GoogleFonts.hindSiliguri()),
                                  ),
                                );
                              }
                            },
                            itemBuilder: (ctx) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    const Icon(Icons.edit, size: 18, color: Colors.teal),
                                    const SizedBox(width: 8),
                                    Text(isBn ? 'সম্পাদনা করুন' : 'Edit', style: GoogleFonts.hindSiliguri()),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    const Icon(Icons.delete_forever, size: 18, color: Colors.red),
                                    const SizedBox(width: 8),
                                    Text(isBn ? 'মুছে ফেলুন' : 'Delete', style: GoogleFonts.hindSiliguri(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 14,
                    right: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pond.name,
                          style: GoogleFonts.hindSiliguri(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            shadows: [const Shadow(color: Colors.black87, blurRadius: 4)],
                          ),
                        ),
                        Text(
                          isBn
                              ? '${pond.fishSpecies} • ${pond.area} • ${pond.totalFishCount} টি মাছ'
                              : '${pond.fishSpecies} • ${pond.area} • ${pond.totalFishCount} fish',
                          style: GoogleFonts.hindSiliguri(
                            color: const Color(0xFF80DEEA),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            shadows: [const Shadow(color: Colors.black87, blurRadius: 4)],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006064).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        pond.farmCategory,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF006064),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified, size: 12, color: Colors.green),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                pond.bioSecurityGrade,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F1A22) : const Color(0xFFF4F9FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.teal.shade100,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTelemetryItem(
                        context,
                        isBn ? 'অক্সিজেন (DO)' : 'Oxygen (DO)',
                        '${pond.dissolvedOxygen.toStringAsFixed(1)} mg/L',
                        Icons.air,
                        pond.dissolvedOxygen >= 5.5 ? Colors.teal : Colors.red,
                      ),
                      Container(width: 1, height: 30, color: Colors.grey.shade300),
                      _buildTelemetryItem(
                        context,
                        isBn ? 'pH মাত্রা' : 'pH Level',
                        pond.ph.toStringAsFixed(1),
                        Icons.science,
                        pond.ph >= 7.0 && pond.ph <= 8.5 ? Colors.blue.shade700 : Colors.orange,
                      ),
                      Container(width: 1, height: 30, color: Colors.grey.shade300),
                      _buildTelemetryItem(
                        context,
                        isBn ? 'তাপমাত্রা' : 'Temperature',
                        '${pond.temperature.toStringAsFixed(1)}°C',
                        Icons.thermostat,
                        Colors.deepOrange,
                      ),
                      Container(width: 1, height: 30, color: Colors.grey.shade300),
                      _buildTelemetryItem(
                        context,
                        isBn ? 'অ্যামোনিয়া' : 'Ammonia',
                        '${pond.ammonia.toStringAsFixed(3)}',
                        Icons.bubble_chart,
                        pond.ammonia <= 0.02 ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.timelapse, size: 14, color: Colors.teal),
                            const SizedBox(width: 4),
                            Text(
                              isBn ? 'পর্যায়: ${pond.growthStage}' : 'Stage: ${pond.growthStage}',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade800,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          isReady
                              ? (isBn ? 'হারভেস্ট এর উপযুক্ত' : 'Ready for Harvest')
                              : (isBn ? '${pond.daysRemainingForHarvest} দিন পর হারভেস্ট' : '${pond.daysRemainingForHarvest} days to harvest'),
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isReady ? const Color(0xFF0288D1) : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pond.progressPercentage,
                        minHeight: 7,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isReady ? const Color(0xFF0288D1) : const Color(0xFF006064),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            isBn
                                ? 'FCR: ${pond.fcr} • সারভাইভাল: ${pond.survivalRatePercent}% • ফিড: ${pond.dailyFeedingKg} কেজি/দিন'
                                : 'FCR: ${pond.fcr} • Survival: ${pond.survivalRatePercent}% • Feed: ${pond.dailyFeedingKg} kg/day',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 11,
                              color: Colors.blueGrey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBn ? 'বর্তমান বায়োমাস' : 'Current Biomass',
                              style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
                            ),
                            Text(
                              isBn
                                  ? '${pond.currentTotalBiomassKg.toStringAsFixed(0)} কেজি (${pond.avgWeightGrams.toStringAsFixed(0)} গ্রাম/পিস)'
                                  : '${pond.currentTotalBiomassKg.toStringAsFixed(0)} kg (${pond.avgWeightGrams.toStringAsFixed(0)} g/fish)',
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isBn ? 'প্রত্যাশিত বিক্রয়মূল্য' : 'Projected Valuation',
                              style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
                            ),
                            Text(
                              '৳${pond.projectedValuation.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF006064)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => _pondController.toggleAerator(pond.id),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: pond.aeratorOn ? const Color(0xFFE0F7FA) : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: pond.aeratorOn ? const Color(0xFF00ACC1) : Colors.grey.shade400,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.mode_fan_off_rounded,
                              size: 15,
                              color: pond.aeratorOn ? const Color(0xFF006064) : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              pond.aeratorOn
                                  ? (isBn ? 'অ্যারেটর চালু' : 'Aerator ON')
                                  : (isBn ? 'অ্যারেটর বন্ধ' : 'Aerator OFF'),
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: pond.aeratorOn ? const Color(0xFF006064) : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _showInstantMarketSellDialog(pond, isBn),
                      icon: const Icon(Icons.storefront, size: 15, color: Colors.white),
                      label: Text(
                        isBn ? 'বাজারে বিক্রি' : 'Sell Now',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006064),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => Get.to(() => PondDetailScreen(pond: pond)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFF0288D1)),
                      ),
                      child: Text(
                        isBn ? 'বিশ্লেষণ' : 'Analytics',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0288D1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTelemetryItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 3),
            Text(
              label,
              style: GoogleFonts.hindSiliguri(
                fontSize: 10.5,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isBn) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color deepAqua = Color(0xFF006064);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF0D222A), const Color(0xFF00363A)]
                    : [const Color(0xFFE0F7FA), const Color(0xFFB2EBF2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.teal.withValues(alpha: 0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    color: deepAqua.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: deepAqua, width: 2),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.pool_rounded,
                      size: 48,
                      color: deepAqua,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isBn ? 'স্বাগতম! আপনার ফার্মে কোনো পুকুর বা ট্যাংক নেই' : 'Welcome! You have no ponds or tanks.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF004D40),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isBn
                      ? 'আপনার অ্যাকুয়াকালচার ফার্মকে আধুনিক ও স্মার্ট করতে প্রথম বাণিজ্যিক পুকুর বা বায়োফ্লক ট্যাংক যুক্ত করুন।'
                      : 'Add your first commercial pond or biofloc tank to modernize your aquaculture farm.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Get.to(() => const AddPondScreen()),
                    icon: const Icon(Icons.add_circle, color: Colors.white, size: 22),
                    label: Text(
                      isBn ? '➕ আপনার প্রথম পুকুর / ট্যাংক যুক্ত করুন' : '➕ Add your first pond / tank',
                      style: GoogleFonts.hindSiliguri(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: deepAqua,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 5,
                      shadowColor: deepAqua.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4-Pillar Smart Aquaculture Feature Highlights
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'স্মার্ট মৎস্য ব্যবস্থাপনার সুবিধাসমূহ:',
              style: GoogleFonts.hindSiliguri(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildEmptyFeatureCard(
                  '📡 IoT সেন্সর ট্র্যাকিং',
                  'অক্সিজেন (DO), pH ও অ্যামোনিয়া রিয়েল-টাইম মনিটর',
                  Icons.sensors,
                  const Color(0xFF0288D1),
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEmptyFeatureCard(
                  '🛡️ বায়োসিকিউরিটি',
                  'শতভাগ রোগমুক্ত গ্রেড A+ কোয়ালিটি সার্টিফিকেট',
                  Icons.verified_user_rounded,
                  Colors.green.shade700,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildEmptyFeatureCard(
                  '📊 FCR ও গ্রোথ',
                  'ফিড রূপান্তর হার ও হারভেস্ট টাইমলাইন সিমুলেটর',
                  Icons.auto_graph_rounded,
                  const Color(0xFF7B1FA2),
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEmptyFeatureCard(
                  '🐟 বিগ ফিশ মার্কেট',
                  'সরাসরি দেশের বড় আড়তদারদের কাছে ১-ট্যাপে সেল',
                  Icons.storefront_rounded,
                  const Color(0xFFE65100),
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFeatureCard(String title, String desc, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16252F) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.hindSiliguri(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: GoogleFonts.hindSiliguri(
              fontSize: 11,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

