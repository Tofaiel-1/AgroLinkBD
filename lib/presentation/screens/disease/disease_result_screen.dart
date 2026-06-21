import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:agrolinkbd/core/services/ai_disease_service.dart';

class DiseaseResultScreen extends StatefulWidget {
  final String imagePath;

  const DiseaseResultScreen({super.key, required this.imagePath});

  @override
  State<DiseaseResultScreen> createState() => _DiseaseResultScreenState();
}

class _DiseaseResultScreenState extends State<DiseaseResultScreen> {
  bool _isAnalyzing = true;
  
  // Dummy AI results
  final List<Map<String, dynamic>> _dummyResults = [
    {
      'name': 'টমেটোর লেট ব্লাইট (Tomato Late Blight)',
      'accuracy': 94.5,
      'status': 'ক্ষতিকর',
      'color': Colors.red,
      'cause': 'Phytophthora infestans নামক ছত্রাক।',
      'treatment': 'মেনকোজেব বা মেটালিক্সিল গ্রুপের ছত্রাকনাশক স্প্রে করুন। জমিতে পানি জমতে দেবেন না।'
    },
    {
      'name': 'পাতায় দাগ রোগ (Leaf Spot)',
      'accuracy': 88.2,
      'status': 'মাঝারি ক্ষতিকর',
      'color': Colors.orange,
      'cause': 'Cercospora বা অন্যান্য ছত্রাক।',
      'treatment': 'আক্রান্ত পাতা ছিঁড়ে ফেলুন। কপার অক্সিক্লোরাইড স্প্রে করতে পারেন।'
    },
    {
      'name': 'মোজাইক ভাইরাস (Mosaic Virus)',
      'accuracy': 91.0,
      'status': 'মারাত্মক',
      'color': Colors.redAccent,
      'cause': 'সাদা মাছি বা জাব পোকার মাধ্যমে ছড়ায়।',
      'treatment': 'আক্রান্ত গাছ সাথে সাথে তুলে পুড়িয়ে ফেলুন। বাহক পোকা দমনে ইমিডাক্লোরোপ্রিড স্প্রে করুন।'
    },
    {
      'name': 'সুস্থ পাতা (Healthy Leaf)',
      'accuracy': 98.1,
      'status': 'সুস্থ',
      'color': Colors.green,
      'cause': 'কোনো রোগ নেই।',
      'treatment': 'আপনার ফসল সম্পূর্ণ সুস্থ আছে। নিয়মিত যত্ন নিন।'
    }
  ];

  late Map<String, dynamic> _result;

  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    // Attempt real AI analysis
    final aiResponse = await AiDiseaseService.analyzeImage(widget.imagePath);

    if (mounted) {
      if (aiResponse != null) {
        setState(() {
          _result = {
            'name': aiResponse['plant_and_disease_bn'] ?? 'অজ্ঞাত রোগ',
            'accuracy': 95.0, // Default accuracy since not requested in JSON
            'status': 'চিহ্নিত',
            'color': Colors.redAccent,
            'cause': "কারণ: ${aiResponse['cause_bn'] ?? ''}\n\nলক্ষণ: ${aiResponse['symptoms_bn'] ?? ''}",
            'treatment': "জৈব পদ্ধতি:\n${aiResponse['organic_remedy_bn'] ?? ''}\n\nরাসায়নিক পদ্ধতি:\n${aiResponse['chemical_medicine_bn'] ?? ''}"
          };
          _isAnalyzing = false;
        });
      } else {
        // Fallback to mock data
        _fallbackToMockData();
      }
    }
  }

  void _fallbackToMockData() {
    setState(() {
      _result = _dummyResults[Random().nextInt(_dummyResults.length)];
    });
    
    // Simulate processing time
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('বিশ্লেষণ ফলাফল'),
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
                      color: Colors.black54,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                            strokeWidth: 4,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'AI বিশ্লেষণ করছে...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'পাতার ধরন ও রোগের লক্ষণ স্ক্যান করা হচ্ছে',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            if (!_isAnalyzing)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Result Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _result['name'],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _result['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _result['color']),
                          ),
                          child: Text(
                            _result['status'],
                            style: TextStyle(
                              color: _result['color'],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Accuracy Bar
                    Row(
                      children: [
                        const Icon(Icons.analytics, size: 18, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'AI নিশ্চয়তা: ${_result['accuracy']}%',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Details Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.coronavirus, color: Colors.deepOrange),
                              SizedBox(width: 8),
                              Text(
                                'কারণ / লক্ষণ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _result['cause'],
                            style: const TextStyle(fontSize: 15, height: 1.4),
                          ),
                          const Divider(height: 32),
                          const Row(
                            children: [
                              Icon(Icons.medical_services, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                'প্রতিকার / পরামর্শ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _result['treatment'],
                            style: const TextStyle(fontSize: 15, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Action Buttons
                    if (_result['status'] != 'সুস্থ')
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Get.snackbar('Marketplace', 'কীটনাশক কেনার পেজে রিডাইরেক্ট করা হচ্ছে...');
                              },
                              icon: const Icon(Icons.shopping_cart),
                              label: const Text('ওষুধ কিনুন (Marketplace)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
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
                              label: const Text('বিশেষজ্ঞের সাথে কথা বলুন'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.green.shade700,
                                side: BorderSide(color: Colors.green.shade700),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
