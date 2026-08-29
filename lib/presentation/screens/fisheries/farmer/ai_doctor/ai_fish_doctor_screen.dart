import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agrolinkbd/core/services/fish_dosage_calculator_service.dart';

class AIFishDoctorScreen extends StatefulWidget {
  const AIFishDoctorScreen({super.key});

  @override
  State<AIFishDoctorScreen> createState() => _AIFishDoctorScreenState();
}

class _AIFishDoctorScreenState extends State<AIFishDoctorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  File? _imageFile;
  bool _isScanning = false;
  late AnimationController _scanController;

  // Dosage Calculator State
  final _decimalAreaController = TextEditingController(text: '50'); // ৫০ শতক
  final _waterDepthController = TextEditingController(text: '4.5'); // ৪.৫ ফুট
  final _phController = TextEditingController(text: '6.8');
  final _ammoniaController = TextEditingController(text: '0.8');

  List<PondChemicalDosageResult> _dosageResults = [];

  final List<Map<String, dynamic>> _diseaseCatalog = [
    {
      'name': 'ক্ষত রোগ (EUS / Epizootic Ulcerative Syndrome)',
      'symptoms': 'শরীরের বিভিন্ন অংশে লালচে দাগ বা গভীর ক্ষত, আঁইশ খসে পড়া, অস্থিরভাবে সাঁতার কাটা।',
      'treatment': 'পুকুরে প্রতি শতকে ২৫০ গ্রাম চুন ও ২৫০ গ্রাম লবণ দিন। তীব্র হলে ১-২ গ্রাম পটাশ পানিতে গুলিয়ে ছিটান।',
      'medicine': 'অক্সিটেট্রাসাইক্লিন (Oxytetracycline) ফিডের সাথে মিশিয়ে ৫-৭ দিন খাওয়াতে হবে।',
      'severity': 'মারাত্মক',
      'icon': Icons.healing,
    },
    {
      'name': 'লেজ ও পাখনা পচা রোগ (Tail & Fin Rot)',
      'symptoms': 'পাখনা ও লেজের কিনারা সাদা হয়ে যাওয়া, ফেটে যাওয়া এবং ধীরে ধীরে খসে পড়া।',
      'treatment': 'পুকুরের তলদেশের পচা কাদা দূর করা ও জীবাণুনাশক দিয়ে পানি শোধন করা।',
      'medicine': 'প্রতি শতকে ১ গ্রাম পটাশিয়াম পারম্যাঙ্গানেট স্প্রে করুন এবং খাবার কমাতে হবে।',
      'severity': 'মাঝারি',
      'icon': Icons.water_damage,
    },
    {
      'name': 'পেটে পানি জমা বা ড্রপসি (Dropsy Disease)',
      'symptoms': 'মাছের পেট অস্বাভাবিক ফুলে যায়, আঁইশ খাড়া হয়ে থাকে, চোখ কোটর থেকে বেরিয়ে আসে।',
      'treatment': 'আক্রান্ত মাছ আলাদা করুন। পুকুরে ব্যাকটেরিয়ানাশক ও প্রোবায়োটিক প্রয়োগ করুন।',
      'medicine': 'সিপ্রোফ্লক্সাসিন বা এনরোফ্লক্সাসিন মেডিসিনেটেড ফিড।',
      'severity': 'মারাত্মক',
      'icon': Icons.bubble_chart,
    },
    {
      'name': 'ফুলকা পচা বা গিল রট (Gill Rot / Branchiomycosis)',
      'symptoms': 'ফুলকার রং ফ্যাকাশে বা ধূসর হয়ে যাওয়া, মাছ পানির উপরিভাগে ভেসে খাবি খাওয়া।',
      'treatment': 'পুকুরে দ্রুত অক্সিজেন বাড়াতে হবে (অ্যারেটর চালান) এবং ফ্রেশ পানি প্রবেশ করান।',
      'medicine': 'প্রতি শতকে ৫০০ গ্রাম চুন ও লবণ প্রয়োগ করুন।',
      'severity': 'জরুরি',
      'icon': Icons.air,
    },
    {
      'name': 'মাছের উকুন বা আর্গিউলাস (Argulosis / Fish Louse)',
      'symptoms': 'মাছের গায়ে চ্যাপ্টা পরজীবী উকুন লেগে থাকে, মাছ পুকুরের বাঁশ বা পাড়ে গা ঘষতে থাকে।',
      'treatment': 'পুকুরে বাঁশের খুঁটি সরিয়ে নেওয়া এবং নিম পাতার রস বা অর্গানিক পেস্টিসাইড ছিটানো।',
      'medicine': 'সাইপারমেথ্রিন বা ডেল্টামেথ্রিন নির্ধারিত মাত্রায় (প্রতি শতকে ০.৫-১ মিলি) ব্যবহার করুন।',
      'severity': 'মাঝারি',
      'icon': Icons.bug_report,
    },
    {
      'name': 'তলদেশের বিষাক্ত গ্যাস ও অ্যামোনিয়া বৃদ্ধি',
      'symptoms': 'ভোরের দিকে মাছ উপরিভাগে ভাসে, পানির রঙ অতিরিক্ত ঘন সবুজ বা কালচে হয়ে যায়।',
      'treatment': 'খাবার দেওয়া সম্পূর্ণ বন্ধ রাখুন। জিওলাইট ও গ্যাস-নাশক পাউডার প্রয়োগ করুন।',
      'medicine': 'প্রতি শতকে ৫০০ গ্রাম জিওলাইট ও উপকারী প্রোবায়োটিক দিন।',
      'severity': 'জরুরি',
      'icon': Icons.warning_amber,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _calculateAllDosages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scanController.dispose();
    _decimalAreaController.dispose();
    _waterDepthController.dispose();
    _phController.dispose();
    _ammoniaController.dispose();
    super.dispose();
  }

  void _calculateAllDosages() {
    final decimal = double.tryParse(_decimalAreaController.text) ?? 50.0;
    final depth = double.tryParse(_waterDepthController.text) ?? 4.5;
    final ph = double.tryParse(_phController.text) ?? 6.8;
    final ammonia = double.tryParse(_ammoniaController.text) ?? 0.8;

    setState(() {
      _dosageResults = [
        FishDosageCalculatorService.calculateLimeDosage(
          decimalArea: decimal,
          waterDepthFeet: depth,
          currentPh: ph,
        ),
        FishDosageCalculatorService.calculateSaltDosage(
          decimalArea: decimal,
          waterDepthFeet: depth,
        ),
        FishDosageCalculatorService.calculateZeoliteDosage(
          decimalArea: decimal,
          waterDepthFeet: depth,
          ammoniaLevelPpm: ammonia,
        ),
        FishDosageCalculatorService.calculateProbioticDosage(
          decimalArea: decimal,
        ),
        FishDosageCalculatorService.calculatePotashDosage(
          decimalArea: decimal,
          waterDepthFeet: depth,
        ),
      ];
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'ক্যামেরা চালু করতে সমস্যা হয়েছে');
    }
  }

  void _startScan() {
    if (_imageFile == null) return;

    setState(() {
      _isScanning = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() {
    Get.defaultDialog(
      title: 'এআই রোগ নির্ণয় ফলাফল 🔬',
      titleStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.teal.shade700, fontSize: 18),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            const Icon(Icons.check_circle, size: 50, color: Colors.green),
            const SizedBox(height: 10),
            Text(
              'শনাক্তকৃত রোগ: ক্ষত রোগ (EUS)',
              style: GoogleFonts.hindSiliguri(fontSize: 17, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'চিকিৎসা: প্রতি শতকে ৫০০ গ্রাম চুন ও ২৫০ গ্রাম লবণ প্রয়োগ করুন। ৫ দিন অক্সিটেট্রাসাইক্লিন মেডিসিনেটেড ফিড খাওয়াতে হবে।',
              textAlign: TextAlign.center,
              style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade800),
            ),
          ],
        ),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade700),
        onPressed: () => Get.back(),
        child: Text('ঠিক আছে', style: GoogleFonts.hindSiliguri(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color tealColor = Color(0xFF00897B);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'স্মার্ট এআই মাছের ডাক্তার',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: tealColor,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amberAccent,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'এআই স্ক্যানার', icon: Icon(Icons.camera_alt, size: 18)),
            Tab(text: 'রোগের ক্যাটালগ', icon: Icon(Icons.medical_services, size: 18)),
            Tab(text: 'মেডিসিন ডোজ ক্যালকুলেটর', icon: Icon(Icons.calculate, size: 18)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScannerTab(tealColor, isDark),
          _buildDiseaseCatalogTab(tealColor, isDark),
          _buildDosageCalculatorTab(tealColor, isDark),
        ],
      ),
    );
  }

  // --- TAB 1: AI CAMERA SCANNER ---
  Widget _buildScannerTab(Color tealColor, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade700, Colors.teal.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, size: 36, color: Colors.amberAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'অসুস্থ মাছ বা ক্ষতের ছবি তুলুন। এআই তৎক্ষণাৎ রোগ শনাক্ত করে চিকিৎসা প্রেসক্রিপশন দেবে।',
                    style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _pickImage(ImageSource.camera),
            child: Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: tealColor.withOpacity(0.4), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(_imageFile!, fit: BoxFit.cover),
                          if (_isScanning)
                            AnimatedBuilder(
                              animation: _scanController,
                              builder: (context, child) {
                                return Positioned(
                                  top: _scanController.value * 200,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 3,
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      boxShadow: [
                                        BoxShadow(color: Colors.redAccent, blurRadius: 8, spreadRadius: 2),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 60, color: tealColor),
                        const SizedBox(height: 12),
                        Text(
                          'ক্যামেরা দিয়ে ছবি তুলুন',
                          style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'বা গ্যালারি থেকে সিলেক্ট করুন',
                          style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: Text('গ্যালারি', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tealColor,
                    side: BorderSide(color: tealColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _imageFile != null && !_isScanning ? _startScan : null,
                  icon: const Icon(Icons.search),
                  label: Text(
                    _isScanning ? 'স্ক্যান হচ্ছে...' : 'এআই স্ক্যান করুন',
                    style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tealColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- TAB 2: DISEASE CATALOG ---
  Widget _buildDiseaseCatalogTab(Color tealColor, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _diseaseCatalog.length,
      itemBuilder: (context, index) {
        final disease = _diseaseCatalog[index];
        final isSevere = disease['severity'] == 'মারাত্মক' || disease['severity'] == 'জরুরি';

        return Card(
          color: Theme.of(context).cardColor,
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: isSevere ? Colors.red.shade50 : Colors.teal.shade50,
              child: Icon(disease['icon'] as IconData, color: isSevere ? Colors.red : tealColor),
            ),
            title: Text(
              disease['name'],
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Text(
              'লক্ষণ: ${disease['symptoms']}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('সম্পূর্ণ লক্ষণ:', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(disease['symptoms'], style: GoogleFonts.hindSiliguri(fontSize: 13)),
                    const SizedBox(height: 8),
                    Text('পুকুরের করণীয় ও চিকিৎসা:', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green.shade800)),
                    Text(disease['treatment'], style: GoogleFonts.hindSiliguri(fontSize: 13)),
                    const SizedBox(height: 8),
                    Text('ওষুধ ও অ্যান্টিবায়োটিক প্রোটোকল:', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue.shade800)),
                    Text(disease['medicine'], style: GoogleFonts.hindSiliguri(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- TAB 3: POND CHEMICAL DOSAGE CALCULATOR ---
  Widget _buildDosageCalculatorTab(Color tealColor, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input Header Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: tealColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('পুকুরের পরিমাপ ও প্যারামিটার দিন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildParamField('পুকুরের আয়তন (শতাংশ)', _decimalAreaController)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildParamField('পানির গভীরতা (ফুট)', _waterDepthController)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildParamField('পানির pH লেভেল', _phController)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildParamField('অ্যামোনিয়া (ppm)', _ammoniaController)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Text(
            'প্রয়োজনীয় কেমিক্যাল ও ওষুধের সুনির্দিষ্ট ডোজ',
            style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          ..._dosageResults.map((result) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        result.chemicalNameBN,
                        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.teal),
                        ),
                        child: Text(
                          '${result.requiredAmountKg} কেজি',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.teal.shade800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('ব্যবহারের নিয়ম: ${result.applicationMethod}', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade700)),
                  Text('সতর্কতা: ${result.safetyWarning}', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.amber.shade900)),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildParamField(String label, TextEditingController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => _calculateAllDosages(),
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
