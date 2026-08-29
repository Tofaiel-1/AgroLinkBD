import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/presentation/widgets/premium_feature_gatekeeper.dart';

class FishPricePredictionScreen extends StatefulWidget {
  const FishPricePredictionScreen({super.key});

  @override
  State<FishPricePredictionScreen> createState() => _FishPricePredictionScreenState();
}

class _FishPricePredictionScreenState extends State<FishPricePredictionScreen> {
  String _selectedSpecies = 'দেশি রুই (১.৫ - ২ কেজি)';
  String _selectedMokam = 'কাওরান বাজার, ঢাকা';

  final List<String> _speciesList = [
    'দেশি রুই (১.৫ - ২ কেজি)',
    'কাতলা মাছ (৩+ কেজি)',
    'বাগদা চিংড়ি (রপ্তানি গ্রেড)',
    'গলদা চিংড়ি (বড় সাইজ)',
    'পাবদা ও গুলশা',
    'পাঙ্গাশ ও তেলাপিয়া',
  ];

  final List<String> _mokamList = [
    'কাওরান বাজার, ঢাকা',
    'যাত্রাবাড়ী আড়ত, ঢাকা',
    'ময়মনসিংহ ফিশ হাব',
    'সাতক্ষীরা চিংড়ি মোকাম',
    'ফিশারি ঘাট, চট্টগ্রাম',
  ];

  final List<Map<String, dynamic>> _predictions = [
    {'day': 'আজ (বর্তমান)', 'price': 340.0, 'trend': 'স্থিতিশীল', 'diff': '০%'},
    {'day': '২ দিন পর', 'price': 345.0, 'trend': 'উর্ধ্বমুখী', 'diff': '+১.৫%'},
    {'day': '৪ দিন পর', 'price': 355.0, 'trend': 'উর্ধ্বমুখী', 'diff': '+৪.৪%'},
    {'day': '৭ দিন পর (বৃহস্পতিবার)', 'price': 370.0, 'trend': 'সর্বোচ্চ পিক 🔥', 'diff': '+৮.৮%'},
    {'day': '১০ দিন পর', 'price': 360.0, 'trend': 'নিম্নমুখী', 'diff': '+৫.৮%'},
    {'day': '১৪ দিন পর', 'price': 348.0, 'trend': 'স্বাভাবিক', 'diff': '+২.৩%'},
  ];

  @override
  Widget build(BuildContext context) {
    const Color deepAqua = Color(0xFF006064);
    const Color deepAmber = Color(0xFFE65100);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          '১৪-দিনের এআই প্রাইজ প্রেডিকশন 📈',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: deepAqua,
        elevation: 0,
        centerTitle: true,
      ),
      body: PremiumFeatureGatekeeper(
        featureName: '১৪-দিনের এআই পাইকারি দর পূর্বাভাস',
        description: 'দেশের প্রধান মোকামগুলোর ভবিষ্যৎ মাছের দাম জেনে সর্বোচ্চ লাভে হারভেস্ট করুন।',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI Decision Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF004D40), Color(0xFF00695C), Color(0xFF00796B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF004D40).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'এআই ট্রেডিং ও হারভেস্ট এডভাইজার',
                          style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '💡 পরামর্শ: আগামী বৃহস্পতিবার কাওরান বাজারে রুই মাছের পাইকারি দাম কেজি প্রতি ৩০ টাকা বৃদ্ধির সম্ভাবনা রয়েছে (+৮.৮%)। আপনার ১,০০০ কেজি লট এখনই বিক্রি না করে ৭ দিন পর হারভেস্ট করলে অতিরিক্ত ৳৩০,০০০ নিট লাভ হবে!',
                      style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.white.withOpacity(0.95), height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Filter Controls
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSpecies,
                          isExpanded: true,
                          items: _speciesList.map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.hindSiliguri(fontSize: 12)))).toList(),
                          onChanged: (v) => setState(() => _selectedSpecies = v!),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedMokam,
                          isExpanded: true,
                          items: _mokamList.map((m) => DropdownMenuItem(value: m, child: Text(m, style: GoogleFonts.hindSiliguri(fontSize: 12)))).toList(),
                          onChanged: (v) => setState(() => _selectedMokam = v!),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Text('আগামী ১৪ দিনের পাইকারি পূর্বাভাস সূচক', style: GoogleFonts.hindSiliguri(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Price Trend List
              ..._predictions.map((p) {
                final isPeak = p['trend'].toString().contains('পিক');
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isPeak ? Colors.amber.shade50 : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isPeak ? Colors.amber.shade700 : (isDark ? Colors.white12 : Colors.grey.shade200),
                      width: isPeak ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(p['day'] as String, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14)),
                              if (isPeak) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: deepAmber, borderRadius: BorderRadius.circular(6)),
                                  child: Text('সেরা সময়', style: GoogleFonts.hindSiliguri(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                          Text('ট্রেন্ড: ${p['trend']}', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('৳${(p['price'] as double).toStringAsFixed(0)} /কেজি', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                          Text(p['diff'] as String, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: p['diff'].toString().startsWith('+') ? Colors.green : Colors.red)),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),

              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'পূর্বাভাসটি বিগত ৫ বছরের বাজার ট্রেন্ড, আবহাওয়া পরিবর্তন, এবং মোকামের সাপ্তাহিক ডিমান্ড ডেটার ওপর ভিত্তি করে এআই ইঞ্জিন দ্বারা প্রস্তুত।',
                        style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.blue.shade900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
