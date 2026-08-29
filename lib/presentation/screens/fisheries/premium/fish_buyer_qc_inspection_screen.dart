import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/presentation/widgets/premium_feature_gatekeeper.dart';

class FishBuyerQcInspectionScreen extends StatefulWidget {
  const FishBuyerQcInspectionScreen({super.key});

  @override
  State<FishBuyerQcInspectionScreen> createState() => _FishBuyerQcInspectionScreenState();
}

class _FishBuyerQcInspectionScreenState extends State<FishBuyerQcInspectionScreen> {
  String _fishSpecies = 'রুই ও কাতলা (গ্রেড-A)';
  String _lotCode = 'LOT-FISH-2024-998';
  double _lotWeightKg = 2500.0;
  bool _formalinNegative = true;
  bool _gillColorBrightRed = true;
  bool _eyesClear = true;
  bool _iceRatioAdequate = true; // 1:1 ice to fish
  String _overallGrade = 'Grade A+ (এক্সপোর্ট ও সুপারশপ স্ট্যান্ডার্ড)';

  @override
  Widget build(BuildContext context) {
    const Color deepNavy = Color(0xFF0D47A1);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'মাছের কিউসি ও কোয়ালিটি সার্টিফিকেট 🎖️',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        backgroundColor: deepNavy,
        elevation: 0,
        centerTitle: true,
      ),
      body: PremiumFeatureGatekeeper(
        featureName: 'ডিজিটাল মাছের কিউসি কোয়ালিটি সার্টিফিকেট',
        description: 'পাইকারি লটের সতেজতা গ্রেডিং, ফরমালিন মুক্ত পরীক্ষণ ও সুপারশপ/এক্সপোর্ট স্ট্যান্ডার্ড ডিজিটাল সার্টিফিকেট তৈরি করুন।',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Certificate Badge Banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: deepNavy.withOpacity(0.35),
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
                        Row(
                          children: [
                            const Icon(Icons.verified_user, color: Colors.amberAccent, size: 26),
                            const SizedBox(width: 8),
                            Text('ডিজিটাল কোয়ালিটি পাসপোর্ট', style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                          child: Text(_lotCode, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('লট সাইজ: ${_lotWeightKg.toInt()} কেজি (${(_lotWeightKg / 40).toStringAsFixed(1)} মণ) • $_fishSpecies', style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.green.shade800, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amberAccent, size: 16),
                          const SizedBox(width: 6),
                          Text(_overallGrade, style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // QC Checklist
              Text('লট ইন্সপেকশন মানদণ্ড (QC Checklist)', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),

              Card(
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 1,
                child: Column(
                  children: [
                    CheckboxListTile(
                      activeColor: Colors.green,
                      title: Text('ফরমালিন ও রাসায়নিক মুক্ত (Negative)', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('ডিজিটাল কিট পরীক্ষণ সম্পন্ন', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
                      value: _formalinNegative,
                      onChanged: (v) => setState(() => _formalinNegative = v ?? true),
                    ),
                    const Divider(height: 1),
                    CheckboxListTile(
                      activeColor: Colors.green,
                      title: Text('ফুলকার সতেজ উজ্জ্বল লাল রং (Bright Red Gills)', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('প্রাকৃতিক গন্ধ ও অটুট টেক্সচার', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
                      value: _gillColorBrightRed,
                      onChanged: (v) => setState(() => _gillColorBrightRed = v ?? true),
                    ),
                    const Divider(height: 1),
                    CheckboxListTile(
                      activeColor: Colors.green,
                      title: Text('চোখ স্বচ্ছ ও ফোলাভাব মুক্ত (Clear Eyes)', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('সতেজতার গ্রেড-১ সূচক', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
                      value: _eyesClear,
                      onChanged: (v) => setState(() => _eyesClear = v ?? true),
                    ),
                    const Divider(height: 1),
                    CheckboxListTile(
                      activeColor: Colors.green,
                      title: Text('সঠিক বরফ অনুপাত (১:১ Ice Packaging)', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('পরিবহন তাপমাত্রা ৪° সেলসিয়াসের নিচে সংরক্ষিত', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
                      value: _iceRatioAdequate,
                      onChanged: (v) => setState(() => _iceRatioAdequate = v ?? true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Certificate Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                      'সার্টিফিকেট জেনারেট হয়েছে! 📄',
                      'লট #$_lotCode এর ভেরিফাইড কিউসি সার্টিফিকেট পিডিএফ রেডি। সুপারশপ/আড়তে শেয়ার করুন।',
                      backgroundColor: deepNavy,
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                  label: Text('ডিজিটাল কিউসি সার্টিফিকেট ডাউনলোড (PDF)', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: deepNavy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
