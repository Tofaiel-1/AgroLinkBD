import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:agrolinkbd/core/services/ai_disease_service.dart';
import 'package:google_fonts/google_fonts.dart';

class DiseaseResultScreen extends StatefulWidget {
  final String imagePath;

  const DiseaseResultScreen({super.key, required this.imagePath});

  @override
  State<DiseaseResultScreen> createState() => _DiseaseResultScreenState();
}

class _DiseaseResultScreenState extends State<DiseaseResultScreen> {
  bool _isAnalyzing = true;
  Map<String, dynamic>? _aiResult;
  bool _isError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    try {
      final aiResponse = await AiDiseaseService.analyzeImage(widget.imagePath);

      if (mounted) {
        if (aiResponse != null && !aiResponse.containsKey('error')) {
          setState(() {
            _aiResult = aiResponse;
            _isAnalyzing = false;
          });
        } else {
          setState(() {
            _isError = true;
            _errorMessage = aiResponse?['error']?.toString() ?? 'অজানা কারণ';
            _isAnalyzing = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isError = true;
          _errorMessage = e.toString();
          _isAnalyzing = false;
        });
      }
    }
  }

  void _fallbackToMockData() {
    setState(() {
      _aiResult = {
        "image_quality": "Good",
        "quality_reason": "ছবিটি পরিষ্কার এবং পাতার গঠন স্পষ্টভাবে দেখা যাচ্ছে। (Demo)",
        "action_required": "",
        "plant_detected": true,
        "plant_part": "Leaf",
        "plant_identified": "টমেটো (Tomato)",
        "plant_confidence": 98,
        "diagnosis_status": "Success",
        "disease_name": "লেট ব্লাইট (Late Blight)",
        "disease_confidence": 94,
        "observed_symptoms": [
          "পাতার প্রান্তে অনিয়মিত কালচে দাগ",
          "দাগের চারদিকে ফ্যাকাশে হলুদ আভা",
          "পাতা দ্রুত শুকিয়ে যাচ্ছে"
        ],
        "severity": "Moderate",
        "reasoning": "লক্ষণগুলো ফাইটোফথোরা ইনফেস্টান্স (Phytophthora infestans) ছত্রাকজনিত লেট ব্লাইট রোগের সাথে সম্পূর্ণ মিলে যায়।",
        "recommendations": [
          "আক্রান্ত পাতাগুলো দ্রুত তুলে পুড়িয়ে ফেলুন।",
          "মেনকোজেব বা মেটালিক্সিল গ্রুপের ছত্রাকনাশক (যেমন: রিডোমিল গোল্ড) প্রতি লিটার পানিতে ২ গ্রাম মিশিয়ে স্প্রে করুন।",
          "গাছের গোড়ায় যেন পানি না জমে সেদিকে খেয়াল রাখুন।"
        ],
        "reliability": "High"
      };
      _isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('এআই বিশ্লেষণ রিপোর্ট', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image Section
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                  image: FileImage(File(widget.imagePath)),
                  fit: BoxFit.cover,
                ),
              ),
              child: _isAnalyzing
                  ? Container(
                      color: Colors.black.withOpacity(0.7),
                      child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                            strokeWidth: 4,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'AI বিশ্লেষণ করছে...',
                            style: GoogleFonts.hindSiliguri(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ছবির মান, গাছের ধরন ও রোগের লক্ষণ স্ক্যান করা হচ্ছে\nদয়া করে অপেক্ষা করুন।',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.hindSiliguri(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            if (!_isAnalyzing && _isError)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'বিশ্লেষণ ব্যর্থ হয়েছে',
                      style: GoogleFonts.hindSiliguri(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage ?? 'অজানা এরর। ইন্টারনেট কানেকশন চেক করুন।',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.hindSiliguri(fontSize: 14, color: Colors.red.shade900),
                      ),
                    ),
                  ],
                ),
              ),

            if (!_isAnalyzing && !_isError && _aiResult != null)
              _buildReportBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportBody() {
    final result = _aiResult!;
    
    final bool isQualityPoor = result['image_quality'] == 'Poor';
    final bool isPlantNotDetected = result['plant_detected'] == false;
    final String status = result['diagnosis_status'] ?? 'Unknown';

    if (isQualityPoor || isPlantNotDetected) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                isPlantNotDetected ? 'কোনো গাছ শনাক্ত করা যায়নি!' : 'ছবির কোয়ালিটি খুবই খারাপ!',
                textAlign: TextAlign.center,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                result['quality_reason'] ?? '',
                textAlign: TextAlign.center,
                style: GoogleFonts.hindSiliguri(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.camera_alt, color: Colors.black54),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        result['action_required'] ?? 'দয়া করে পর্যাপ্ত আলোতে গাছের পাতার একটি পরিষ্কার ছবি তুলুন।',
                        style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Info
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  icon: Icons.grass,
                  title: 'গাছের নাম',
                  value: result['plant_identified'] ?? 'অজানা গাছ',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoChip(
                  icon: Icons.analytics,
                  title: 'শনাক্তকরণ নির্ভুলতা',
                  value: '${result['plant_confidence'] ?? 0}%',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Disease Status Card
          if (status == 'Healthy')
            _buildStatusCard(
              title: 'আপনার গাছটি সম্পূর্ণ সুস্থ আছে!',
              icon: Icons.check_circle_outline,
              color: Colors.green,
              bgColor: Colors.green.shade50,
            )
          else if (status == 'Success' || status == 'Known')
            _buildDiseaseCard(result)
          else
            _buildStatusCard(
              title: 'রোগটি সঠিকভাবে শনাক্ত করা যায়নি।',
              subtitle: 'দয়া করে কৃষি বিশেষজ্ঞের পরামর্শ নিন অথবা আরও পরিষ্কার ছবি দিন।',
              icon: Icons.help_outline,
              color: Colors.orange.shade800,
              bgColor: Colors.orange.shade50,
            ),

          const SizedBox(height: 24),

          // Reasoning & Symptoms
          if (result['observed_symptoms'] != null && (result['observed_symptoms'] as List).isNotEmpty) ...[
            Text('পর্যবেক্ষণকৃত লক্ষণসমূহ:', style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...((result['observed_symptoms'] as List).map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 18, color: Colors.deepOrange)),
                  Expanded(child: Text(s.toString(), style: GoogleFonts.hindSiliguri(fontSize: 15))),
                ],
              ),
            )).toList()),
            const SizedBox(height: 16),
          ],

          if (result['reasoning'] != null && result['reasoning'].toString().isNotEmpty) ...[
             Text('বিশ্লেষণের কারণ:', style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold)),
             const SizedBox(height: 8),
             Container(
               width: double.infinity,
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
               child: Text(result['reasoning'], style: GoogleFonts.hindSiliguri(fontSize: 15, color: Colors.grey.shade800)),
             ),
             const SizedBox(height: 24),
          ],

          // Recommendations
          if (result['recommendations'] != null && (result['recommendations'] as List).isNotEmpty) ...[
            Text('প্রতিকার ও পরামর্শ:', style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                children: (result['recommendations'] as List).asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: Colors.blue.shade600, shape: BoxShape.circle),
                          child: Text('${entry.key + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(entry.value.toString(), style: GoogleFonts.hindSiliguri(fontSize: 15))),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Action Buttons
          if (status == 'Success' || status == 'Known')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.snackbar('Marketplace', 'কীটনাশক কেনার পেজে রিডাইরেক্ট করা হচ্ছে...');
                },
                icon: const Icon(Icons.shopping_cart),
                label: Text('ওষুধ কিনুন (Marketplace)', style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Get.snackbar('Expert', 'কৃষি বিশেষজ্ঞের সাথে কল কানেক্ট করা হচ্ছে...');
              },
              icon: const Icon(Icons.support_agent),
              label: Text('বিশেষজ্ঞের সাথে কথা বলুন', style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green.shade700,
                side: BorderSide(color: Colors.green.shade700),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(title, style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildStatusCard({required String title, String? subtitle, required IconData icon, required Color color, required Color bgColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: GoogleFonts.hindSiliguri(fontSize: 14, color: Colors.black87)),
          ]
        ],
      ),
    );
  }

  Widget _buildDiseaseCard(Map<String, dynamic> result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade50, Colors.orange.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'রোগ শনাক্ত হয়েছে',
              style: GoogleFonts.hindSiliguri(color: Colors.red.shade800, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            result['disease_name'] ?? 'অজানা রোগ',
            textAlign: TextAlign.center,
            style: GoogleFonts.hindSiliguri(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red.shade900),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMiniChip('তীব্রতা: ${result['severity'] ?? 'N/A'}', Colors.orange),
              const SizedBox(width: 8),
              _buildMiniChip('নিশ্চয়তা: ${result['disease_confidence'] ?? 0}%', Colors.blue),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(text, style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
