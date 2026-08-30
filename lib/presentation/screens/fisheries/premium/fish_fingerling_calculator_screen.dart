import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/presentation/widgets/premium_feature_gatekeeper.dart';

class FishFingerlingCalculatorScreen extends StatefulWidget {
  const FishFingerlingCalculatorScreen({super.key});

  @override
  State<FishFingerlingCalculatorScreen> createState() => _FishFingerlingCalculatorScreenState();
}

class _FishFingerlingCalculatorScreenState extends State<FishFingerlingCalculatorScreen> {
  final _decimalController = TextEditingController(text: '৫০');
  final _depthController = TextEditingController(text: '৫');
  String _farmingSystem = 'মিশ্র কার্প চাষ (রুই, কাতলা, মৃগেল)';

  // Results
  int _totalFingerlings = 0;
  double _expectedYieldKg = 0.0;
  double _expectedRevenue = 0.0;
  List<Map<String, dynamic>> _speciesBreakdown = [];

  @override
  void initState() {
    super.initState();
    _calculateStockingDensity();
  }

  void _calculateStockingDensity() {
    final double decimals = double.tryParse(_decimalController.text) ?? 50.0;
    final double depth = double.tryParse(_depthController.text) ?? 5.0;

    int totalCount = 0;
    double yieldKg = 0.0;
    double revenue = 0.0;
    List<Map<String, dynamic>> breakdown = [];

    if (_farmingSystem.contains('কার্প')) {
      // Semi-intensive polyculture carp: ~ 80 - 100 fingerlings per decimal (4-6 inch)
      final int rui = (decimals * 35).round();
      final int katla = (decimals * 15).round();
      final int mrigal = (decimals * 20).round();
      final int grasscarp = (decimals * 10).round();
      final int silvercarp = (decimals * 10).round();

      totalCount = rui + katla + mrigal + grasscarp + silvercarp;
      yieldKg = decimals * 45; // ~ 45 kg per decimal in 8-10 months
      revenue = yieldKg * 280; // Avg ৳280/kg

      breakdown = [
        {'name': 'রুই পোনা (৪-৬ ইঞ্চি)', 'count': rui, 'ratio': '৩৫%', 'harvestWeight': '১.২ কেজি'},
        {'name': 'কাতলা পোনা (৫-৭ ইঞ্চি)', 'count': katla, 'ratio': '১৫%', 'harvestWeight': '২.০ কেজি'},
        {'name': 'মৃগেল পোনা (৪-৫ ইঞ্চি)', 'count': mrigal, 'ratio': '২০%', 'harvestWeight': '১.০ কেজি'},
        {'name': 'গ্রাসকার্প পোনা', 'count': grasscarp, 'ratio': '১০%', 'harvestWeight': '১.৫ কেজি'},
        {'name': 'সিলভারকার্প/ব্রিগেড', 'count': silvercarp, 'ratio': '১০%', 'harvestWeight': '১.২ কেজি'},
      ];
    } else if (_farmingSystem.contains('পাবদা')) {
      // Intensive Pabda/Gulsha: ~ 400 - 500 pcs per decimal
      final int pabda = (decimals * 350).round();
      final int gulsha = (decimals * 100).round();
      final int rui = (decimals * 5).round(); // Carps as biological cleaner

      totalCount = pabda + gulsha + rui;
      yieldKg = decimals * 30; // ~ 30 kg per decimal
      revenue = yieldKg * 420; // Avg ৳420/kg

      breakdown = [
        {'name': 'পাবদা পোনা (২-৩ ইঞ্চি)', 'count': pabda, 'ratio': '৭৫%', 'harvestWeight': '৬০-৮০ গ্রাম'},
        {'name': 'গুলশা পোনা', 'count': gulsha, 'ratio': '২৩%', 'harvestWeight': '৪০-৫০ গ্রাম'},
        {'name': 'রুই ক্লিনার', 'count': rui, 'ratio': '২%', 'harvestWeight': '১.৫ কেজি'},
      ];
    } else {
      // Monoculture Tilapia / Pangas: ~ 250 pcs per decimal
      final int tilapia = (decimals * 250).round();
      totalCount = tilapia;
      yieldKg = decimals * 80;
      revenue = yieldKg * 180;

      breakdown = [
        {'name': 'মনোসেক্স তেলাপিয়া পোনা', 'count': tilapia, 'ratio': '১০০%', 'harvestWeight': '৪০০-৫০০ গ্রাম'},
      ];
    }

    setState(() {
      _totalFingerlings = totalCount;
      _expectedYieldKg = yieldKg;
      _expectedRevenue = revenue;
      _speciesBreakdown = breakdown;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color deepTeal = Color(0xFF004D40);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'হ্যাচারি পোনা মজুদ ডেনসিটি ক্যালকুলেটর 🐟',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        backgroundColor: deepTeal,
        elevation: 0,
        centerTitle: true,
      ),
      body: PremiumFeatureGatekeeper(
        featureName: 'হ্যাচারি পোনা মজুদ ও ফলন ক্যালকুলেটর',
        description: 'পুকুরের আয়তন ও গভীরতা অনুযায়ী রুই, কাতলা, মৃগেল, পাবদা বা তেলাপিয়ার শতক প্রতি পোনার সুনির্দিষ্ট বৈজ্ঞানিক সংখ্যা বের করুন।',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Inputs Card
              Card(
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('পুকুরের পরিমাপ ও চাষ পদ্ধতি', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _decimalController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'আয়তন (শতাংশ)',
                                prefixIcon: Icon(Icons.aspect_ratio, color: deepTeal),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onChanged: (_) => _calculateStockingDensity(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _depthController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'গভীরতা (ফুট)',
                                prefixIcon: Icon(Icons.height, color: deepTeal),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onChanged: (_) => _calculateStockingDensity(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _farmingSystem,
                        decoration: InputDecoration(
                          labelText: 'চাষ পদ্ধতি ও প্রজাতি',
                          prefixIcon: Icon(Icons.set_meal, color: deepTeal),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: [
                          'মিশ্র কার্প চাষ (রুই, কাতলা, মৃগেল)',
                          'নিবিড় পাবদা ও গুলশা চাষ',
                          'মনোসেক্স তেলাপিয়া গ্রো-আউট',
                        ].map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.hindSiliguri(fontSize: 13)))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _farmingSystem = val);
                            _calculateStockingDensity();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Hero Yield & Revenue Prediction
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF004D40), Color(0xFF00695C), Color(0xFF00796B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: deepTeal.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('মোট প্রয়োজনীয় পোনা', style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('${_decimalController.text} শতক পুকুর', style: GoogleFonts.hindSiliguri(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('$_totalFingerlings পিস', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32)),
                    const Divider(color: Colors.white24, height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('প্রাক্কলিত মোট ফলন', style: GoogleFonts.hindSiliguri(color: Colors.white60, fontSize: 11)),
                            Text('${_expectedYieldKg.toInt()} কেজি (${(_expectedYieldKg / 40).toStringAsFixed(1)} মণ)', style: GoogleFonts.poppins(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('প্রত্যাশিত মোট বিক্রয় আয়', style: GoogleFonts.hindSiliguri(color: Colors.white60, fontSize: 11)),
                            Text('৳ ${_expectedRevenue.toInt()}', style: GoogleFonts.poppins(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Species Ratio Breakdown
              Text('প্রজাতিভিত্তিক পোনা মজুদ বণ্টন তালিকা (Species Ratio)', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _speciesBreakdown.length,
                itemBuilder: (context, index) {
                  final sp = _speciesBreakdown[index];
                  return Card(
                    color: Theme.of(context).cardColor,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 1,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: deepTeal.withOpacity(0.12),
                        child: Text(sp['ratio'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: deepTeal)),
                      ),
                      title: Text(sp['name'], style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('টার্গেট হারভেস্ট সাইজ: ${sp['harvestWeight']}', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
                      trailing: Text('${sp['count']} পিস', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: deepTeal)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
