import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agrolinkbd/core/services/fish_dosage_calculator_service.dart';
import 'package:agrolinkbd/core/services/fish_disease_ai_service.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/ai_doctor/fish_disease_result_screen.dart';

class AIFishDoctorScreen extends StatefulWidget {
  const AIFishDoctorScreen({super.key});

  @override
  State<AIFishDoctorScreen> createState() => _AIFishDoctorScreenState();
}

class _AIFishDoctorScreenState extends State<AIFishDoctorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  File? _imageFile;

  // Dosage Calculator State
  final _decimalAreaController = TextEditingController(text: '50');
  final _waterDepthController = TextEditingController(text: '4.5');
  final _phController = TextEditingController(text: '6.8');
  final _ammoniaController = TextEditingController(text: '0.8');

  List<PondChemicalDosageResult> _dosageResults = [];

  // Symptom Checker State
  String _selectedSpecies = 'রুই / কার্প জাতীয় মাছ';
  final List<String> _availableSpecies = [
    'রুই / কার্প জাতীয় মাছ',
    'পাঙ্গাশ / ক্যাটফিশ',
    'তেলাপিয়া',
    'শিং / মাগুর',
    'পাবদা / গুলশা',
    'কই মাছ',
    'চিংড়ি (গলদা/বাগদা)',
  ];

  final List<Map<String, dynamic>> _symptomOptions = [
    {'name': 'ত্বকে লালচে ছোপ বা গভীর আলসার ক্ষত', 'icon': Icons.healing, 'selected': false},
    {'name': 'পাখনা ও লেজ পচে ফেটে যাওয়া', 'icon': Icons.water_damage, 'selected': false},
    {'name': 'পেট অস্বাভাবিক ফুলে যাওয়া ও আঁইশ খাড়া হওয়া', 'icon': Icons.bubble_chart, 'selected': false},
    {'name': 'ফুলকা ফ্যাকাশে/ধূসর ও পানিতে খাবি খাওয়া', 'icon': Icons.air, 'selected': false},
    {'name': 'মাছের গায়ে ছোট গোল উকুন ও পাড়ে গা ঘষা', 'icon': Icons.bug_report, 'selected': false},
    {'name': 'শরীরে সাদা গুটি গুটি দাগ (ইচ)', 'icon': Icons.grain, 'selected': false},
    {'name': 'চোখ অস্বাভাবিক ফুলে কোটর থেকে বের হওয়া', 'icon': Icons.remove_red_eye, 'selected': false},
    {'name': 'মাছের শরীরে সুতার মতো ঝুলে থাকা কৃমি (লার্নিয়া)', 'icon': Icons.pest_control, 'selected': false},
  ];

  Map<String, dynamic>? _symptomDiagnosisResult;

  final List<Map<String, dynamic>> _diseaseCatalog = [
    {
      'name': 'ক্ষত রোগ (EUS / Epizootic Ulcerative Syndrome)',
      'symptoms': 'শরীরের বিভিন্ন অংশে লালচে দাগ বা গভীর ক্ষত, আঁইশ খসে পড়া, অস্থিরভাবে সাঁতার কাটা।',
      'treatment': 'পুকুরে প্রতি শতকে ২৫০ গ্রাম চুন ও ২৫০ গ্রাম লবণ দিন। তীব্র হলে ১-২ গ্রাম পটাশ পানিতে গুলিয়ে ছিটান।',
      'medicine': 'অক্সিটেট্রাসাইক্লিন (Oxytetracycline) ফিডের সাথে মিশিয়ে ৫-৭ দিন খাওয়াতে হবে।',
      'severity': 'মারাত্মক',
      'icon': Icons.healing,
      'category': 'ছত্রাক ও ব্যাকটেরিয়া',
    },
    {
      'name': 'লেজ ও পাখনা পচা রোগ (Tail & Fin Rot)',
      'symptoms': 'পাখনা ও লেজের কিনারা সাদা হয়ে যাওয়া, ফেটে যাওয়া এবং ধীরে ধীরে খসে পড়া।',
      'treatment': 'পুকুরের তলদেশের পচা কাদা দূর করা ও জীবাণুনাশক দিয়ে পানি শোধন করা।',
      'medicine': 'প্রতি শতকে ১ গ্রাম পটাশিয়াম পারম্যাঙ্গানেট স্প্রে করুন এবং খাবার কমাতে হবে।',
      'severity': 'মাঝারি',
      'icon': Icons.water_damage,
      'category': 'ব্যাকটেরিয়া',
    },
    {
      'name': 'পেটে পানি জমা বা ড্রপসি (Dropsy Disease)',
      'symptoms': 'মাছের পেট অস্বাভাবিক ফুলে যায়, আঁইশ খাড়া হয়ে থাকে, চোখ কোটর থেকে বেরিয়ে আসে।',
      'treatment': 'আক্রান্ত মাছ আলাদা করুন। পুকুরে ব্যাকটেরিয়ানাশক ও প্রোবায়োটিক প্রয়োগ করুন।',
      'medicine': 'সিপ্রোফ্লক্সাসিন বা এনরোফ্লক্সাসিন মেডিসিনেটেড ফিড।',
      'severity': 'মারাত্মক',
      'icon': Icons.bubble_chart,
      'category': 'ব্যাকটেরিয়া',
    },
    {
      'name': 'ফুলকা পচা বা গিল রট (Gill Rot / Branchiomycosis)',
      'symptoms': 'ফুলকার রং ফ্যাকাশে বা ধূসর হয়ে যাওয়া, মাছ পানির উপরিভাগে ভেসে খাবি খাওয়া।',
      'treatment': 'পুকুরে দ্রুত অক্সিজেন বাড়াতে হবে (অ্যারেটর চালান) এবং ফ্রেশ পানি প্রবেশ করান।',
      'medicine': 'প্রতি শতকে ৫০০ গ্রাম চুন ও লবণ প্রয়োগ করুন।',
      'severity': 'জরুরি',
      'icon': Icons.air,
      'category': 'ছত্রাক ও গ্যাস',
    },
    {
      'name': 'মাছের উকুন বা আর্গিউলাস (Argulosis / Fish Louse)',
      'symptoms': 'মাছের গায়ে চ্যাপ্টা পরজীবী উকুন লেগে থাকে, মাছ পুকুরের বাঁশ বা পাড়ে গা ঘষতে থাকে।',
      'treatment': 'পুকুরে বাঁশের খুঁটি সরিয়ে নেওয়া এবং নিম পাতার রস বা অর্গানিক পেস্টিসাইড ছিটানো।',
      'medicine': 'সাইপারমেথ্রিন বা ডেল্টামেথ্রিন নির্ধারিত মাত্রায় (প্রতি শতকে ০.৫-১ মিলি) ব্যবহার করুন।',
      'severity': 'মাঝারি',
      'icon': Icons.bug_report,
      'category': 'পরজীবী',
    },
    {
      'name': 'সাদা দাগ রোগ বা ইচ (Ich / White Spot Disease)',
      'symptoms': 'ত্বক ও পাখনায় ক্ষুদ্র ক্ষুদ্র সাদা দানার মতো দাগ, মাছ অলসভাবে পুকুরের কোণে ভাসে।',
      'treatment': 'পানির তাপমাত্রা বৃদ্ধি করা এবং পানিতে মিথিলিন ব্লু বা লবণ প্রয়োগ করা।',
      'medicine': 'প্রতি শতকে ৩০০ গ্রাম লবণ ও ফরমালিন নির্দেশিত মাত্রায় ব্যবহার করুন।',
      'severity': 'মাঝারি',
      'icon': Icons.grain,
      'category': 'প্রোটোজোয়া',
    },
    {
      'name': 'তলদেশের বিষাক্ত গ্যাস ও অ্যামোনিয়া বৃদ্ধি',
      'symptoms': 'ভোরের দিকে মাছ উপরিভাগে ভাসে, পানির রঙ অতিরিক্ত ঘন সবুজ বা কালচে হয়ে যায়।',
      'treatment': 'খাবার দেওয়া সম্পূর্ণ বন্ধ রাখুন। জিওলাইট ও গ্যাস-নাশক পাউডার প্রয়োগ করুন।',
      'medicine': 'প্রতি শতকে ৫০০ গ্রাম জিওলাইট ও উপকারী প্রোবায়োটিক দিন।',
      'severity': 'জরুরি',
      'icon': Icons.warning_amber,
      'category': 'পরিবেশগত',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _calculateAllDosages();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 90,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      Get.snackbar('ত্রুটি', 'ক্যামেরা চালু করতে সমস্যা হয়েছে');
    }
  }

  void _launchAiScan() {
    if (_imageFile == null) {
      Get.snackbar('সতর্কতা', 'অনুগ্রহ করে প্রথমে মাছের ছবি নির্বাচন করুন');
      return;
    }

    Get.to(() => FishDiseaseResultScreen(imagePath: _imageFile!.path));
  }

  void _runSymptomDiagnosis() {
    final selected = _symptomOptions
        .where((s) => s['selected'] == true)
        .map((s) => s['name'] as String)
        .toList();

    final result = FishDiseaseAiService.diagnoseBySymptoms(
      species: _selectedSpecies,
      selectedSymptoms: selected,
      pondPh: double.tryParse(_phController.text),
      waterAmmonia: double.tryParse(_ammoniaController.text),
    );

    setState(() {
      _symptomDiagnosisResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color tealColor = Color(0xFF00897B);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'স্মার্ট এআই মাছের ডাক্তার 🩺',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: tealColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amberAccent,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.hindSiliguri(fontSize: 12),
          tabs: const [
            Tab(text: 'এআই স্ক্যানার', icon: Icon(Icons.camera_alt, size: 18)),
            Tab(text: 'লক্ষণভিত্তিক ডাক্তার', icon: Icon(Icons.psychology, size: 18)),
            Tab(text: 'রোগের ক্যাটালগ ও ডোজ', icon: Icon(Icons.medical_services, size: 18)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScannerTab(tealColor, isDark),
          _buildSymptomCheckerTab(tealColor, isDark),
          _buildDiseaseCatalogAndDosageTab(tealColor, isDark),
        ],
      ),
    );
  }

  // ============================================
  // TAB 1: AI CAMERA SCANNER (ULTRA PRO MAX)
  // ============================================
  Widget _buildScannerTab(Color tealColor, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade800, Colors.teal.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, size: 36, color: Colors.amberAccent),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'রিয়েল-টাইম এআই ভিশন ডায়াগনসিস',
                        style: GoogleFonts.hindSiliguri(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'মাছের ক্ষতের ছবি তুলুন। এআই মাছের প্রজাতি, সুস্থতা ও সঠিক প্রেসক্রিপশন তৈরি করবে।',
                        style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Image Box
          GestureDetector(
            onTap: () => _pickImage(ImageSource.camera),
            child: Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: tealColor.withValues(alpha: 0.4), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _imageFile != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle, color: Colors.greenAccent, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'ছবি সিলেক্টেড',
                                  style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: tealColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.camera_enhance_rounded, size: 48, color: tealColor),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'ক্যামেরা দিয়ে ছবি তুলুন',
                          style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'বা গ্যালারি থেকে ছবি নির্বাচন করুন',
                          style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text('গ্যালারি', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tealColor,
                    side: BorderSide(color: tealColor, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _imageFile != null ? _launchAiScan : null,
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: Text(
                    'এআই স্ক্যান করুন',
                    style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tealColor,
                    disabledBackgroundColor: Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Photographic Guidelines for Farmer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'নির্ভুল ফলাফলের জন্য ছবি তোলার টিপস:',
                      style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildGuideItem('🐟 মাছটিকে পানি থেকে তুলে সমতল ও পরিষ্কার আলোতে রাখুন।'),
                _buildGuideItem('🔍 ক্ষতের দাগ, ফুলকা বা পাখনার কাছাকাছি রেখে পরিষ্কার ফোকাস করুন।'),
                _buildGuideItem('🚫 মানুষ, গাছপালা বা অপ্রাসঙ্গিক বস্তুর ছবি এআই প্রত্যাখ্যান করবে।'),
                _buildGuideItem('✨ মাছ সুস্থ হলে এআই সুস্থতার সনদ ও বৃদ্ধির যত্ন বাতলে দেবে।'),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ============================================
  // TAB 2: INTERACTIVE SYMPTOM CHECKER
  // ============================================
  Widget _buildSymptomCheckerTab(Color tealColor, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade800, Colors.indigo.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(Icons.psychology, size: 32, color: Colors.amberAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'লক্ষণভিত্তিক এআই ডায়াগনসিস',
                        style: GoogleFonts.hindSiliguri(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ছবি ছাড়া সরাসরি লক্ষণ নির্বাচন করে তাত্ক্ষণিক প্রেসক্রিপশন পান।',
                        style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Species Selector
          Text(
            '১. মাছের প্রজাতি নির্বাচন করুন:',
            style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: tealColor.withValues(alpha: 0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSpecies,
                isExpanded: true,
                items: _availableSpecies.map((species) {
                  return DropdownMenuItem<String>(
                    value: species,
                    child: Text(species, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSpecies = val);
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Symptoms Selection
          Text(
            '২. দৃশ্যমান লক্ষণসমূহ টিক দিন (একাধিক হতে পারে):',
            style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          ..._symptomOptions.map((symptom) {
            final isChecked = symptom['selected'] == true;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isChecked
                    ? tealColor.withValues(alpha: 0.08)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isChecked ? tealColor : Colors.grey.withValues(alpha: 0.2),
                  width: isChecked ? 1.5 : 1,
                ),
              ),
              child: CheckboxListTile(
                value: isChecked,
                activeColor: tealColor,
                onChanged: (val) {
                  setState(() => symptom['selected'] = val ?? false);
                },
                secondary: Icon(
                  symptom['icon'] as IconData,
                  color: isChecked ? tealColor : Colors.grey,
                  size: 24,
                ),
                title: Text(
                  symptom['name'] as String,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 13,
                    fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: _runSymptomDiagnosis,
            icon: const Icon(Icons.medical_information),
            label: Text(
              'রোগ নির্ণয় ও প্রেসক্রিপশন দেখুন',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: tealColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),

          // Diagnosis Result Display
          if (_symptomDiagnosisResult != null) ...[
            const SizedBox(height: 24),
            _buildSymptomResultCard(_symptomDiagnosisResult!, tealColor, isDark),
          ],

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSymptomResultCard(Map<String, dynamic> data, Color teal, bool isDark) {
    final disease = data['disease_name'] ?? 'রোগ';
    final severity = data['severity'] ?? 'N/A';
    final reasoning = data['reasoning'] ?? '';
    final water = (data['water_treatment'] as List?)?.cast<String>() ?? [];
    final med = (data['medication_prescription'] as List?)?.cast<String>() ?? [];
    final herbal = (data['herbal_remedy'] as List?)?.cast<String>() ?? [];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: teal, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: teal.withValues(alpha: 0.1),
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
              Text('ডায়াগনস্টিক রিপোর্ট 📋', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'তীব্রতা: $severity',
                  style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            disease,
            style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold, color: teal),
          ),
          const SizedBox(height: 6),
          Text(reasoning, style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade700)),
          const Divider(height: 24),

          Text('💧 পুকুর শোধন:', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          ...water.map((w) => Text('• $w', style: GoogleFonts.hindSiliguri(fontSize: 12))),

          const SizedBox(height: 12),
          Text('💊 মেডিসিন ও ফিড ডোজ:', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red.shade800)),
          const SizedBox(height: 4),
          ...med.map((m) => Text('• $m', style: GoogleFonts.hindSiliguri(fontSize: 12))),

          if (herbal.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('🌿 ভেষজ চিকিৎসা:', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green.shade800)),
            const SizedBox(height: 4),
            ...herbal.map((h) => Text('• $h', style: GoogleFonts.hindSiliguri(fontSize: 12))),
          ],
        ],
      ),
    );
  }

  // ============================================
  // TAB 3: DISEASE CATALOG & CHEMICAL CALCULATOR
  // ============================================
  Widget _buildDiseaseCatalogAndDosageTab(Color tealColor, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dosage Calculator Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tealColor.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calculate, color: tealColor, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'পুকুরের আয়তন অনুযায়ী কেমিক্যাল ডোজ হিসাব',
                      style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Quick Size Chips
                Row(
                  children: [
                    Text('দ্রুত সাইজ:', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 8),
                    _buildQuickSizeChip('২০ শতক', 20.0),
                    const SizedBox(width: 6),
                    _buildQuickSizeChip('৫০ শতক', 50.0),
                    const SizedBox(width: 6),
                    _buildQuickSizeChip('১০০ শতক', 100.0),
                  ],
                ),
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
            'প্রয়োজনীয় কেমিক্যাল ডোজ তালিকা',
            style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          ..._dosageResults.map((result) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.teal),
                        ),
                        child: Text(
                          '${result.requiredAmountKg} কেজি',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('প্রয়োগ নিয়ম: ${result.applicationMethod}', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade700)),
                  Text('সতর্কতা: ${result.safetyWarning}', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.amber.shade900)),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 24),

          // Disease Encyclopedia List
          Text(
            'মৎস্য রোগের পূর্ণাঙ্গ ক্যাটালগ ও চিকিৎসা',
            style: GoogleFonts.hindSiliguri(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ..._diseaseCatalog.map((disease) {
            final isSevere = disease['severity'] == 'মারাত্মক' || disease['severity'] == 'জরুরি';
            return Card(
              color: Theme.of(context).cardColor,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 1,
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: isSevere ? Colors.red.shade50 : Colors.teal.shade50,
                  child: Icon(disease['icon'] as IconData, color: isSevere ? Colors.red : tealColor),
                ),
                title: Text(
                  disease['name'],
                  style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  'ক্যাটেগরি: ${disease['category']} • তীব্রতা: ${disease['severity']}',
                  style: GoogleFonts.hindSiliguri(fontSize: 11, color: isSevere ? Colors.red.shade700 : Colors.grey.shade600),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('লক্ষণ:', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(disease['symptoms'], style: GoogleFonts.hindSiliguri(fontSize: 12)),
                        const SizedBox(height: 8),
                        Text('পুকুরের যত্ন ও শোধন:', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green.shade800)),
                        Text(disease['treatment'], style: GoogleFonts.hindSiliguri(fontSize: 12)),
                        const SizedBox(height: 8),
                        Text('মেডিসিন প্রোটোকল:', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue.shade800)),
                        Text(disease['medicine'], style: GoogleFonts.hindSiliguri(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildQuickSizeChip(String label, double size) {
    return InkWell(
      onTap: () {
        _decimalAreaController.text = size.toStringAsFixed(0);
        _calculateAllDosages();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.teal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.hindSiliguri(fontSize: 11, color: const Color(0xFF00897B), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildGuideItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade700, height: 1.3),
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
