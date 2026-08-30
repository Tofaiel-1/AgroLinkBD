import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:agrolinkbd/core/services/fish_disease_ai_service.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/expert_advice/expert_advice_screen.dart';

class FishDiseaseResultScreen extends StatefulWidget {
  final String imagePath;

  const FishDiseaseResultScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<FishDiseaseResultScreen> createState() => _FishDiseaseResultScreenState();
}

class _FishDiseaseResultScreenState extends State<FishDiseaseResultScreen>
    with SingleTickerProviderStateMixin {
  bool _isAnalyzing = true;
  Map<String, dynamic>? _aiResult;
  String? _errorMessage;
  int _analysisStep = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<String> _analysisSteps = [
    '১. ছবির মান ও রেজ্যুলেশন যাচাই করা হচ্ছে...',
    '২. মাছের উপস্থিতি ও প্রজাতি শনাক্তকরণ...',
    '৩. ত্বক, ফুলকা, পাখনা ও ক্ষত বিশ্লেষণ...',
    '৪. মৎস্য প্যাথলজি ও প্রেসক্রিপশন তৈরি...',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startStepSimulation();
    _runAiDiagnosis();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startStepSimulation() async {
    for (int i = 0; i < _analysisSteps.length; i++) {
      if (!mounted || !_isAnalyzing) break;
      setState(() => _analysisStep = i);
      await Future.delayed(const Duration(milliseconds: 800));
    }
  }

  Future<void> _runAiDiagnosis() async {
    try {
      final result = await FishDiseaseAiService.analyzeFishImage(widget.imagePath);
      if (mounted) {
        setState(() {
          _aiResult = result;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isAnalyzing = false;
        });
      }
    }
  }

  void _sharePrescription(Map<String, dynamic> data) {
    final disease = data['disease_name'] ?? 'মাছের রোগ';
    final species = data['species_identified'] ?? 'মাছ';
    final severity = data['severity'] ?? 'N/A';
    final waterList = (data['water_treatment'] as List?)?.join('\n- ') ?? '';
    final medList = (data['medication_prescription'] as List?)?.join('\n- ') ?? '';

    final shareText = """
🐟 এগ্রোলিংক বিডি - এআই মৎস্য প্রেসক্রিপশন 🩺
━━━━━━━━━━━━━━━━━━━━
📌 আক্রান্ত প্রজাতি: $species
📌 শনাক্তকৃত রোগ: $disease
📌 তীব্রতা: $severity

💧 পুকুর শোধন ও পানির ব্যবস্থা:
- $waterList

💊 মেডিসিন ও খাদ্য ডোজ:
- $medList

🌿 এআই ফিশ ডক্টর - এগ্রোলিংক বিডি (স্মার্ট মৎস্য সেবা)
""";
    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryTeal = Color(0xFF00897B);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: Text(
          'এআই মৎস্য ডায়াগনস্টিক রিপোর্ট',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (!_isAnalyzing && _aiResult != null && _aiResult!['fish_detected'] == true)
            IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: () => _sharePrescription(_aiResult!),
              tooltip: 'শেয়ার করুন',
            ),
        ],
      ),
      body: _isAnalyzing
          ? _buildAnalyzingHUD(primaryTeal, isDark)
          : (_errorMessage != null
              ? _buildErrorView(isDark)
              : _buildResultContent(_aiResult!, primaryTeal, isDark)),
    );
  }

  // ============================================
  // 1. SCANNING HUD & ANIMATED PROCESSING
  // ============================================
  Widget _buildAnalyzingHUD(Color teal, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: teal.withValues(alpha: 0.3), width: 4),
                      gradient: RadialGradient(
                        colors: [teal.withValues(alpha: 0.2), Colors.transparent],
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.file(
                      File(widget.imagePath),
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Positioned.fill(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.amberAccent),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'স্মার্ট এআই ভিশন বিশ্লেষণ চলছে',
              style: GoogleFonts.hindSiliguri(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _analysisSteps[_analysisStep],
                key: ValueKey<int>(_analysisStep),
                style: GoogleFonts.hindSiliguri(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: teal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.security, size: 16, color: Color(0xFF00897B)),
                  const SizedBox(width: 6),
                  Text(
                    'ডিপ লার্নিং ভিশন মডেল ২.৫',
                    style: GoogleFonts.poppins(fontSize: 11, color: teal, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // 2. ERROR VIEW
  // ============================================
  Widget _buildErrorView(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'বিশ্লেষণে সমস্যা হয়েছে',
              style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'সার্ভারে সংযোগ পেতে সমস্যা হয়েছে।',
              textAlign: TextAlign.center,
              style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isAnalyzing = true;
                  _errorMessage = null;
                });
                _startStepSimulation();
                _runAiDiagnosis();
              },
              icon: const Icon(Icons.refresh),
              label: Text('পুনরায় চেষ্টা করুন', style: GoogleFonts.hindSiliguri()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // 3. MAIN RESULT VIEW CONTROLLER
  // ============================================
  Widget _buildResultContent(Map<String, dynamic> data, Color primaryTeal, bool isDark) {
    final bool fishDetected = data['fish_detected'] == true;
    final bool isHealthy = data['is_healthy'] == true;
    final String imageQuality = data['image_quality'] ?? 'Good';

    if (!fishDetected) {
      return _buildNonFishRejectionCard(data, isDark);
    }

    if (isHealthy) {
      return _buildHealthyFishView(data, primaryTeal, isDark);
    }

    return _buildDiseasedFishView(data, primaryTeal, isDark, imageQuality);
  }

  // ============================================
  // 4. INVALID / NON-FISH REJECTION UI
  // ============================================
  Widget _buildNonFishRejectionCard(Map<String, dynamic> data, bool isDark) {
    final detectedObj = data['detected_object_type'] ?? 'অপ্রাসঙ্গিক বস্তু';
    final rejectionMsg = data['rejection_message'] ??
        'এটি কোনো মাছ বা জলজ প্রাণীর ছবি নয়। দয়া করে আক্রান্ত বা সন্দেহভাজন মাছের স্পষ্ট ছবি তুলুন।';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Image Preview Container with Rejected Tag
          Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(
                  File(widget.imagePath),
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cancel, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'মাছ শনাক্ত হয়নি',
                      style: GoogleFonts.hindSiliguri(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Detailed Rejection Alert Box
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A1515) : const Color(0xFFFFF3F3),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'ছবিতে কোনো মাছ পাওয়া যায়নি!',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'চিহ্নিত অবজেক্ট: $detectedObj',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade900,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  rejectionMsg,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Photography Tips for Farmer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'সঠিক ছবি তোলার নিয়ম:',
                      style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildGuideBullet('১. আক্রান্ত মাছটিকে পানি থেকে তুলে পরিষ্কার আলোতে রাখুন।'),
                _buildGuideBullet('২. মাছের ক্ষত, পাখনা বা ফুলকার অংশ ফোকাসে রেখে ছবি তুলুন।'),
                _buildGuideBullet('৩. ঘোলা বা অন্ধকার ছবি এড়িয়ে চলুন।'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: Text('পুনরায় ছবি তুলুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00897B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================
  // 5. 100% HEALTHY / FRESH FISH VIEW
  // ============================================
  Widget _buildHealthyFishView(Map<String, dynamic> data, Color teal, bool isDark) {
    final species = data['species_identified'] ?? 'দেশীয় মাছ';
    final reasoning = data['reasoning'] ??
        'মাছের আঁইশ উজ্জ্বল, পাখনা অক্ষত এবং ফুলকার রঙ স্বাস্থ্যকর লাল। কোনো রোগজীবাণু বা ক্ষতের চিহ্ন মেলেনি।';
    final waterList = (data['water_treatment'] as List?)?.cast<String>() ?? [];
    final feedList = (data['medication_prescription'] as List?)?.cast<String>() ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Header
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.file(
              File(widget.imagePath),
              width: double.infinity,
              height: 210,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 18),

          // Success Healthy Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified, color: Colors.white, size: 26),
                        const SizedBox(width: 8),
                        Text(
                          'মাছটি সম্পূর্ণ সুস্থ ও সতেজ',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '১০০% রোগমুক্ত',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'প্রজাতি: $species',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B5E20),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  reasoning,
                  style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.white.withValues(alpha: 0.95)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Proactive Care Section
          Text(
            'সুস্থতা বজায় রাখার পরামর্শ',
            style: GoogleFonts.hindSiliguri(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          _buildSectionCard(
            title: 'পুকুরের পানির পরিচর্যা',
            icon: Icons.water_drop,
            iconColor: Colors.blue,
            items: waterList.isNotEmpty
                ? waterList
                : [
                    'পানির পিএইচ ৭.৫-৮.২ এর মধ্যে স্বাভাবিক রাখতে মাসে প্রতি শতকে ২০০ গ্রাম চুন দিন।',
                    'পুকুরে দ্রবীভূত অক্সিজেন ৫ পিপিএম এর উপরে বজায় রাখুন।'
                  ],
            isDark: isDark,
          ),

          const SizedBox(height: 12),

          _buildSectionCard(
            title: 'উত্তম পুষ্টি ও গ্রোথ ম্যানেজমেন্ট',
            icon: Icons.fastfood,
            iconColor: Colors.orange,
            items: feedList.isNotEmpty
                ? feedList
                : [
                    'মাছের দেহের ওজনের ৩-৫% হারে প্রোটিনসমৃদ্ধ পরিমিত খাবার দিন।',
                    'খাবারের অপচয় রোধ করুন যাতে তলদেশে বিষাক্ত গ্যাস না জমে।'
                  ],
            isDark: isDark,
          ),

          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.check_circle_outline),
            label: Text('ড্যাশবোর্ডে ফিরে যান', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: teal,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // 6. DISEASED FISH FULL MEDICAL PRESCRIPTION
  // ============================================
  Widget _buildDiseasedFishView(
    Map<String, dynamic> data,
    Color teal,
    bool isDark,
    String quality,
  ) {
    final diseaseBn = data['disease_name'] ?? 'শনাক্তকৃত রোগ';
    final diseaseEn = data['disease_name_en'] ?? 'Pathological Condition';
    final species = data['species_identified'] ?? 'মাছ';
    final severity = data['severity'] ?? 'মাঝারি';
    final confidence = data['disease_confidence'] ?? 90;
    final symptoms = (data['observed_symptoms'] as List?)?.cast<String>() ?? [];
    final causes = (data['possible_causes'] as List?)?.cast<String>() ?? [];
    final reasoning = data['reasoning'] ?? '';
    final waterTreatments = (data['water_treatment'] as List?)?.cast<String>() ?? [];
    final medications = (data['medication_prescription'] as List?)?.cast<String>() ?? [];
    final herbal = (data['herbal_remedy'] as List?)?.cast<String>() ?? [];
    final preventions = (data['prevention_guidelines'] as List?)?.cast<String>() ?? [];

    Color severityColor = Colors.orange;
    if (severity.contains('মারাত্মক') || severity.contains('Critical')) {
      severityColor = Colors.red.shade700;
    } else if (severity.contains('মৃদু') || severity.contains('Mild')) {
      severityColor = Colors.amber.shade700;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Preview
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.file(
              File(widget.imagePath),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),

          // Main Clinical Header Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: severityColor.withValues(alpha: 0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: severityColor.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: severityColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_rounded, color: severityColor, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'তীব্রতা: $severity',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: severityColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: teal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'নির্ভুলতা $confidence%',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: teal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  diseaseBn,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  diseaseEn,
                  style: GoogleFonts.poppins(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'শনাক্তকৃত মাছ: $species',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.cyanAccent : Colors.teal.shade800,
                    ),
                  ),
                ),
                if (reasoning.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    reasoning,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 13,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Symptoms & Causes
          if (symptoms.isNotEmpty || causes.isNotEmpty)
            _buildSectionCard(
              title: 'দৃশ্যমান লক্ষণ ও মূল কারণ',
              icon: Icons.search_rounded,
              iconColor: Colors.purple,
              items: [...symptoms, ...causes.map((c) => 'সম্ভাব্য কারণ: $c')],
              isDark: isDark,
            ),

          const SizedBox(height: 14),

          // Pond & Water Treatment
          _buildSectionCard(
            title: '💧 পুকুর শোধন ও পানির জরুরি ব্যবস্থা',
            icon: Icons.water_drop,
            iconColor: Colors.blue,
            items: waterTreatments.isNotEmpty
                ? waterTreatments
                : [
                    'প্রতি শতকে ২৫০ গ্রাম চুন ও ২৫০ গ্রাম লবণ পানিতে গুলিয়ে ছিটান।',
                    'পানির অতিরিক্ত গ্যাস বের করতে জাল টানুন ও অ্যারেটর চালান।'
                  ],
            isDark: isDark,
            highlightColor: Colors.blue.withValues(alpha: 0.05),
          ),

          const SizedBox(height: 14),

          // Medication Prescription & Feed Mix
          _buildSectionCard(
            title: '💊 মেডিসিন ও খাদ্য অ্যান্টিবায়োটিক ডোজ',
            icon: Icons.medical_services_rounded,
            iconColor: Colors.redAccent,
            items: medications.isNotEmpty
                ? medications
                : [
                    'প্রতি কেজি ফিডের সাথে ৩ গ্রাম অক্সিটেট্রাসাইক্লিন ও ভিটামিন-সি মিশিয়ে ৫-৭ দিন দিন।',
                    'টিমসেন বা অ্যাকোয়া-গার্ড নির্ধারিত মাত্রায় প্রয়োগ করুন।'
                  ],
            isDark: isDark,
            highlightColor: Colors.red.withValues(alpha: 0.05),
          ),

          const SizedBox(height: 14),

          // Herbal & Organic
          if (herbal.isNotEmpty)
            _buildSectionCard(
              title: '🌿 ভেষজ ও প্রাকৃতিক প্রতিকার',
              icon: Icons.eco,
              iconColor: Colors.green,
              items: herbal,
              isDark: isDark,
            ),

          const SizedBox(height: 14),

          // Prevention Guidelines
          if (preventions.isNotEmpty)
            _buildSectionCard(
              title: '🛡️ প্রতিরোধ ও দীর্ঘমেয়াদী সুরক্ষা',
              icon: Icons.security,
              iconColor: Colors.teal,
              items: preventions,
              isDark: isDark,
            ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Get.to(() => const ExpertAdviceScreen()),
                  icon: const Icon(Icons.support_agent),
                  label: Text('বিশেষজ্ঞ কল', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: teal,
                    side: BorderSide(color: teal),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _sharePrescription(data),
                  icon: const Icon(Icons.share),
                  label: Text('প্রেসক্রিপশন শেয়ার', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ============================================
  // 7. HELPER WIDGETS
  // ============================================
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> items,
    required bool isDark,
    Color? highlightColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlightColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: iconColor, fontWeight: FontWeight.bold, fontSize: 16)),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 13,
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildGuideBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        text,
        style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade700),
      ),
    );
  }
}
