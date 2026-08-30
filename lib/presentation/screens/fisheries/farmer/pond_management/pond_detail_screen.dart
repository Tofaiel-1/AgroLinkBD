import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:agrolinkbd/core/models/pond_model.dart';
import 'package:agrolinkbd/core/controllers/pond_controller.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/ai_doctor/ai_fish_doctor_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/fcr_calculator/fish_growth_fcr_simulator_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/auction/create_fish_auction_screen.dart';
import 'package:agrolinkbd/presentation/screens/marketplace/fish_marketplace_screen.dart';

import 'package:agrolinkbd/presentation/screens/fisheries/farmer/pond_management/edit_pond_screen.dart';

class PondDetailScreen extends StatefulWidget {
  final PondModel pond;

  const PondDetailScreen({super.key, required this.pond});

  @override
  State<PondDetailScreen> createState() => _PondDetailScreenState();
}

class _PondDetailScreenState extends State<PondDetailScreen> with SingleTickerProviderStateMixin {
  late final PondController _pondController;
  late TabController _tabController;
  late PondModel _currentPond;

  @override
  void initState() {
    super.initState();
    _currentPond = widget.pond;
    _pondController = Get.isRegistered<PondController>()
        ? Get.find<PondController>()
        : Get.put(PondController());
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _confirmDeletePond() {
    Get.defaultDialog(
      title: 'পুকুর / ট্যাংক মুছে ফেলুন',
      titleStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.red.shade700),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'আপনি কি নিশ্চিত যে "${_currentPond.name}" স্থায়ীভাবে ফায়ারবেস থেকে মুছে ফেলতে চান? সমস্ত তথ্য মুছে যাবে।',
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
          Get.back(); // close dialog
          await _pondController.deletePond(_currentPond.id);
          Get.back(); // exit screen
          Get.snackbar(
            'মুছে ফেলা হয়েছে',
            '${_currentPond.name} সফলভাবে মুছে ফেলা হয়েছে।',
            backgroundColor: Colors.red.shade700,
            colorText: Colors.white,
          );
        },
        child: Text('মুছে ফেলুন', style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        child: Text('বাতিল', style: GoogleFonts.hindSiliguri()),
      ),
    );
  }

  Future<void> _navigateToEditPond() async {
    final updated = await Get.to<PondModel>(() => EditPondScreen(pond: _currentPond));
    if (updated != null && mounted) {
      setState(() {
        _currentPond = updated;
      });
    }
  }

  void _showAddActivityDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final amountController = TextEditingController();
    String selectedType = 'Feed';
    bool isIncome = false;
    final formKey = GlobalKey<FormState>();

    Get.defaultDialog(
      title: 'নতুন লেনদেন ও কার্যক্রম যোগ',
      titleStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 17),
      content: StatefulBuilder(
        builder: (context, setDialogState) {
          return Form(
            key: formKey,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ChoiceChip(
                      label: Text('ফার্ম ব্যয় (খরচ)', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                      selected: !isIncome,
                      selectedColor: Colors.red.shade100,
                      onSelected: (val) => setDialogState(() => isIncome = false),
                    ),
                    ChoiceChip(
                      label: Text('মাছ বিক্রয় (আয়)', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                      selected: isIncome,
                      selectedColor: Colors.green.shade100,
                      onSelected: (val) => setDialogState(() => isIncome = true),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  items: [
                    DropdownMenuItem(value: 'Feed', child: Text('খাদ্য ও ফিড (Feed)', style: GoogleFonts.hindSiliguri())),
                    DropdownMenuItem(value: 'Medicine', child: Text('ওষুধ ও প্রোবায়োটিক (Medicine)', style: GoogleFonts.hindSiliguri())),
                    DropdownMenuItem(value: 'Stock', child: Text('পোনা ক্রয় ও স্টক (Stock)', style: GoogleFonts.hindSiliguri())),
                    DropdownMenuItem(value: 'Maintenance', child: Text('শ্রমিক ও রক্ষণাবেক্ষণ', style: GoogleFonts.hindSiliguri())),
                    DropdownMenuItem(value: 'Harvest', child: Text('মাছ ধরা ও নেট খরচ', style: GoogleFonts.hindSiliguri())),
                    DropdownMenuItem(value: 'Sale', child: Text('মাছ বিক্রির টাকা (Sale)', style: GoogleFonts.hindSiliguri())),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedType = val);
                  },
                  decoration: InputDecoration(
                    labelText: 'ক্যাটাগরি',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'শিরোনাম (যেমন: ভাসমান ফিড ১০ বস্তা)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  validator: (v) => v!.isEmpty ? 'প্রয়োজনীয়' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'সংক্ষিপ্ত বিবরণ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: isIncome ? 'প্রাপ্ত টাকা (৳)' : 'খরচের পরিমাণ (৳)',
                    prefixText: '৳ ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'টাকার পরিমাণ দিন' : null,
                ),
              ],
            ),
          );
        },
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF006064),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          if (formKey.currentState!.validate()) {
            _pondController.addActivity(
              widget.pond.id,
              titleController.text,
              descController.text,
              double.tryParse(amountController.text) ?? 0.0,
              selectedType,
              isIncome: isIncome,
            );
            Get.back();
            setState(() {});
            Get.snackbar(
              'সফলভাবে সংরক্ষিত',
              'নতুন কার্যক্রমের রেকর্ড যুক্ত হয়েছে!',
              backgroundColor: const Color(0xFF006064),
              colorText: Colors.white,
              icon: const Icon(Icons.check_circle, color: Colors.white),
            );
          }
        },
        child: Text('সংরক্ষণ', style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        child: Text('বাতিল', style: GoogleFonts.hindSiliguri()),
      ),
    );
  }

  void _showInstantMarketSellDialog() {
    final quantityController = TextEditingController(
      text: (widget.pond.currentTotalBiomassKg * 0.8).round().toString(),
    );
    final priceController = TextEditingController(
      text: widget.pond.expectedMarketPricePerKg.round().toString(),
    );

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                  decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10)),
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
                          'বিগ ফিশ মার্কেটে সরাসরি বিক্রয়',
                          style: GoogleFonts.hindSiliguri(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${widget.pond.name} • ${widget.pond.fishSpecies}',
                          style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('বিক্রয়যোগ্য লটের পরিমাণ (কেজি):', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.scale, color: Color(0xFF006064)),
                  suffixText: 'কেজি',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),
              Text('প্রতি কেজি পাইকারি দর (৳):', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.monetization_on, color: Colors.teal),
                  suffixText: '৳/কেজি',
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
                      label: Text('লাইভ ডাক (নিলাম)', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        Get.snackbar(
                          'সফলভাবে তালিকাভুক্ত!',
                          'আপনার পুকুরের মাছ সফলভাবে বিগ ফিশ মার্কেটে আপলোড হয়েছে। পাইকারি ক্রেতারা দ্রুত যোগাযোগ করবে।',
                          backgroundColor: const Color(0xFF006064),
                          colorText: Colors.white,
                          icon: const Icon(Icons.verified, color: Colors.white),
                        );
                        Get.to(() => const FishMarketplaceScreen());
                      },
                      icon: const Icon(Icons.check_circle, color: Colors.white, size: 18),
                      label: Text('বাজারে তুলুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006064),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color deepAqua = Color(0xFF006064);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B141B) : const Color(0xFFF2F6F9),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 220.0,
              floating: false,
              pinned: true,
              backgroundColor: deepAqua,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  _currentPond.name,
                  style: GoogleFonts.hindSiliguri(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                    shadows: [const Shadow(color: Colors.black87, blurRadius: 4)],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: _currentPond.imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (c, u, e) => Container(color: deepAqua),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 50,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0288D1).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_currentPond.fishSpecies} • ${_currentPond.area}',
                          style: GoogleFonts.hindSiliguri(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 24),
                  tooltip: 'সম্পাদনা করুন',
                  onPressed: _navigateToEditPond,
                ),
                IconButton(
                  icon: const Icon(Icons.medical_services_outlined, color: Colors.white),
                  tooltip: 'এআই ফিশ ডক্টর',
                  onPressed: () => Get.to(() => const AIFishDoctorScreen()),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (val) {
                    if (val == 'edit') {
                      _navigateToEditPond();
                    } else if (val == 'market') {
                      Get.to(() => const FishMarketplaceScreen());
                    } else if (val == 'delete') {
                      _confirmDeletePond();
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 18, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text('সম্পাদনা করুন', style: GoogleFonts.hindSiliguri()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'market',
                      child: Row(
                        children: [
                          const Icon(Icons.storefront, size: 18, color: Color(0xFF0288D1)),
                          const SizedBox(width: 8),
                          Text('বিগ ফিশ মার্কেট', style: GoogleFonts.hindSiliguri()),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_forever, size: 18, color: Colors.red),
                          const SizedBox(width: 8),
                          Text('পুকুর মুছে ফেলুন', style: GoogleFonts.hindSiliguri(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF80DEEA),
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(icon: Icon(Icons.sensors, size: 18), text: 'সেন্সর ও বৃদ্ধি'),
                  Tab(icon: Icon(Icons.analytics_rounded, size: 18), text: 'আয়-ব্যয় ও লভ্যাংশ'),
                  Tab(icon: Icon(Icons.history, size: 18), text: 'কার্যক্রম ইতিহাস'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildSensorsAndGrowthTab(isDark),
            _buildFinancialAndValuationTab(isDark),
            _buildActivitiesTab(isDark),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16252F) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _showAddActivityDialog,
                icon: Icon(Icons.add, size: 18, color: deepAqua),
                label: Text('খরচ / আয় যোগ', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: deepAqua)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: deepAqua, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showInstantMarketSellDialog,
                icon: const Icon(Icons.storefront, size: 18, color: Colors.white),
                label: Text('বাজারে বিক্রি করুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: deepAqua,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 1: SENSORS & GROWTH HUD
  Widget _buildSensorsAndGrowthTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enterprise Farm Spec & Bio-Security Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16252F) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(color: Colors.teal.shade200.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified, color: Colors.teal, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          _currentPond.bioSecurityGrade,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade800,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006064).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _currentPond.farmCategory,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF006064),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('পানির উৎস', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
                          Text(_currentPond.waterSource, style: GoogleFonts.hindSiliguri(fontSize: 12.5, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ফার্ম ম্যানেজার', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
                          Text('${_currentPond.farmManagerName} (${_currentPond.managerPhone})', style: GoogleFonts.hindSiliguri(fontSize: 12.5, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F1A22) : Colors.teal.shade50.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'FCR: ${_currentPond.fcr} • সারভাইভাল: ${_currentPond.survivalRatePercent}%',
                        style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF006064)),
                      ),
                      Text(
                        'দৈনিক ফিড: ${_currentPond.dailyFeedingKg} কেজি',
                        style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal.shade800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 6-Quadrant Sensor HUD
          Text(
            'রিয়েল-টাইম ওয়াটার সেন্সর টেলিমেট্রি (IoT)',
            style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSensorTile(
                  'অক্সিজেন (DO)',
                  '${_currentPond.dissolvedOxygen.toStringAsFixed(1)} mg/L',
                  'আদর্শ সীমা: ৫.০ - ৮.০',
                  Icons.air,
                  Colors.teal,
                  isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSensorTile(
                  'pH লেভেল',
                  _currentPond.ph.toStringAsFixed(1),
                  'আদর্শ সীমা: ৭.২ - ৮.২',
                  Icons.science,
                  Colors.blue,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSensorTile(
                  'পানির তাপমাত্রা',
                  '${_currentPond.temperature.toStringAsFixed(1)} °C',
                  'আদর্শ সীমা: ২৬° - ৩১°C',
                  Icons.thermostat,
                  Colors.deepOrange,
                  isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSensorTile(
                  'অ্যামোনিয়া (NH3)',
                  '${_currentPond.ammonia.toStringAsFixed(3)} ppm',
                  'আদর্শ সীমা: < ০.০২',
                  Icons.bubble_chart,
                  _currentPond.ammonia <= 0.02 ? Colors.green : Colors.red,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSensorTile(
                  'নাইট্রাইট (NO2)',
                  '${_currentPond.nitrite.toStringAsFixed(3)} mg/L',
                  'আদর্শ সীমা: < ০.০১',
                  Icons.opacity,
                  Colors.indigo,
                  isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSensorTile(
                  'ক্ষারত্ব (Alkalinity)',
                  '${_currentPond.alkalinity.toStringAsFixed(0)} mg/L',
                  'আদর্শ সীমা: ১০০ - ১৮০',
                  Icons.water_drop,
                  Colors.cyan.shade700,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Smart Aerator & Equipment Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16252F) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.teal.shade200.withValues(alpha: 0.4)),
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.teal.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.mode_fan_off_rounded, color: Colors.teal, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'টারবাইন অ্যারেটর ও অটো-ফিডার (${_currentPond.aeratorCount}টি ইউনিট)',
                          style: GoogleFonts.hindSiliguri(fontSize: 14.5, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Switch.adaptive(
                      value: _currentPond.aeratorOn,
                      activeColor: const Color(0xFF006064),
                      onChanged: (val) {
                        setState(() {
                          _pondController.toggleAerator(_currentPond.id);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _currentPond.aeratorOn
                      ? 'টারবাইন অ্যারেটর সক্রিয়। প্রতি ঘন্টায় পানির দ্রবীভূত অক্সিজেন ০.৮ mg/L বৃদ্ধি পাচ্ছে।'
                      : 'অ্যারেটর বন্ধ রয়েছে। রাতে অক্সিজেনের ঘাটতি এড়াতে অ্যারেটর চালু রাখুন।',
                  style: GoogleFonts.hindSiliguri(fontSize: 12.5, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Growth Cycle Progress
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16252F) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('মাছের বৃদ্ধি পর্যায় ও হারভেস্ট টাইমলাইন', style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('বর্তমান গড় ওজন: ${_currentPond.avgWeightGrams.toStringAsFixed(0)} গ্রাম', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
                    Text('টার্গেট: ${_currentPond.targetHarvestWeightGrams.toStringAsFixed(0)} গ্রাম', style: GoogleFonts.hindSiliguri(color: Colors.teal, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _currentPond.progressPercentage,
                    minHeight: 9,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF006064)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('চাষ শুরু: ${_currentPond.daysSinceStocked} দিন আগে', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600)),
                    Text('হারভেস্ট বাকি: ${_currentPond.daysRemainingForHarvest} দিন', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Shortcut to FCR Simulator
          ElevatedButton.icon(
            onPressed: () => Get.to(() => const FishGrowthFcrSimulatorScreen()),
            icon: const Icon(Icons.auto_graph_rounded, color: Colors.white),
            label: Text('FCR ও ফিড কনভার্সন সিমুলেটর খুলুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006064),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorTile(String label, String value, String sub, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16252F) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: GoogleFonts.hindSiliguri(fontSize: 10.5, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // TAB 2: FINANCIAL & VALUATION
  Widget _buildFinancialAndValuationTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Projected Valuation Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF004D40), Color(0xFF006064)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: const Color(0xFF004D40).withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('প্রত্যাশিত মোট বিক্রয়মূল্য (Market Valuation)', style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  '৳${_currentPond.projectedValuation.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('মোট মাছ সংখ্যা', style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 11)),
                        Text('${_currentPond.totalFishCount} টি', style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('মোট ওজন (বায়োমাস)', style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 11)),
                        Text('${_currentPond.currentTotalBiomassKg.toStringAsFixed(0)} কেজি', style: GoogleFonts.poppins(color: const Color(0xFF80DEEA), fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('পাইকারি গড় দর', style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 11)),
                        Text('৳${_currentPond.expectedMarketPricePerKg.toStringAsFixed(0)}/কেজি', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // P&L Balance Breakdown
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF16252F) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('মোট খরচ', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.red.shade700)),
                      const SizedBox(height: 4),
                      Text('৳${_currentPond.totalCost.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF16252F) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('এখন পর্যন্ত আয়', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.green.shade700)),
                      const SizedBox(height: 4),
                      Text('৳${_currentPond.totalIncome.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Net Projected Margin
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16252F) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('প্রত্যাশিত নীট লাভ (Net Margin)', style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.bold)),
                    Text('সব খরচ বাদে আনুমানিক মুনাফা', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
                Text(
                  '৳${_currentPond.estimatedNetProfit.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.teal.shade800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 3: ACTIVITIES LIST
  Widget _buildActivitiesTab(bool isDark) {
    if (_currentPond.activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 70, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('কোনো খরচের বা বিক্রয়ের রেকর্ড নেই', style: GoogleFonts.hindSiliguri(fontSize: 16, color: Colors.grey.shade600)),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _showAddActivityDialog,
              icon: const Icon(Icons.add),
              label: Text('প্রথম লেনদেন যোগ করুন', style: GoogleFonts.hindSiliguri()),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006064)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: widget.pond.activities.length,
      itemBuilder: (context, index) {
        final activity = widget.pond.activities[widget.pond.activities.length - 1 - index];
        final isIncome = activity.isIncome;

        return Card(
          color: isDark ? const Color(0xFF16252F) : Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isIncome ? Colors.green : Colors.red).withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _getIconForType(activity.type),
                color: isIncome ? Colors.green.shade700 : Colors.red.shade700,
                size: 24,
              ),
            ),
            title: Text(activity.title, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14.5)),
            subtitle: Text(
              '${DateFormat('dd MMM yyyy').format(activity.date)} • ${activity.description}',
              style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
            ),
            trailing: Text(
              '${isIncome ? '+' : '-'}৳${activity.amount.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isIncome ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Stock': return Icons.set_meal;
      case 'Feed': return Icons.inventory_2;
      case 'Medicine': return Icons.health_and_safety;
      case 'Harvest': return Icons.phishing;
      case 'Sale': return Icons.monetization_on;
      default: return Icons.receipt;
    }
  }
}

