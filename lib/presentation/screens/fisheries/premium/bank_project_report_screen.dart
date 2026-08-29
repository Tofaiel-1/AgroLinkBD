import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/presentation/widgets/premium_feature_gatekeeper.dart';

class BankProjectReportScreen extends StatefulWidget {
  const BankProjectReportScreen({super.key});

  @override
  State<BankProjectReportScreen> createState() => _BankProjectReportScreenState();
}

class _BankProjectReportScreenState extends State<BankProjectReportScreen> {
  String _selectedBank = 'বাংলাদেশ কৃষি ব্যাংক (BKB)';
  double _requestedLoanAmount = 500000.0;
  bool _isGenerating = false;

  final List<String> _bankList = [
    'বাংলাদেশ কৃষি ব্যাংক (BKB)',
    'সোনালী ব্যাংক পিএলসি',
    'ব্র্যাক ব্যাংক (SME কৃষি ঋণ)',
    'গ্রামীণ ব্যাংক / পিকেএসএফ পার্টনার',
    'ইসলামী ব্যাংক বাংলাদেশ (মুরাবাহা)',
  ];

  void _downloadReport() {
    setState(() => _isGenerating = true);
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isGenerating = false);
      Get.snackbar(
        'ডসিয়ার ডাউনলোড সম্পন্ন 📄',
        'আপনার খামারের ৩-বছরের পূর্ণাঙ্গ ফাইন্যান্সিয়াল ও ফিশারিজ প্রজেক্ট ফাইল পিডিএফ আকারে সেভ হয়েছে।',
        backgroundColor: const Color(0xFF1B5E20),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color forestGreen = Color(0xFF1B5E20);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = Provider.of<UserProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'ব্যাংক লোন ও প্রজেক্ট ডসিয়ার 📄',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: forestGreen,
        elevation: 0,
        centerTitle: true,
      ),
      body: PremiumFeatureGatekeeper(
        featureName: 'ব্যাংক লোন প্রজেক্ট ডসিয়ার জেনারেটর',
        description: 'কৃষি ও বাণিজ্যিক ব্যাংক থেকে স্বল্প সুদে লোন পেতে ১ ক্লিকে সার্টিফাইড প্রজেক্ট রিপোর্ট জেনারেট করুন।',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Intro
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
                      color: forestGreen.withOpacity(0.35),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance, size: 45, color: Colors.amberAccent),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ব্যাংক-সার্টিফাইড ফিশারিজ প্রজেক্ট প্রোফাইল',
                            style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'আপনার পুকুরের বিগত সাইকেল, এফসিআর রেশিও ও সম্ভাব্য আয়ের আন্তর্জাতিক মানের অডিট ফরম্যাট।',
                            style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text('ঋণ ও ব্যাংকের তথ্য', style: GoogleFonts.hindSiliguri(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              Text('আবেদনকৃত ব্যাংক বা আর্থিক প্রতিষ্ঠান', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedBank,
                    isExpanded: true,
                    items: _bankList.map((b) => DropdownMenuItem(value: b, child: Text(b, style: GoogleFonts.hindSiliguri()))).toList(),
                    onChanged: (v) => setState(() => _selectedBank = v!),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Text('প্রত্যাশিত লোনের পরিমাণ (টাকা)', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Slider(
                value: _requestedLoanAmount,
                min: 100000.0,
                max: 3000000.0,
                divisions: 29,
                activeColor: forestGreen,
                label: '৳${(_requestedLoanAmount / 100000).toStringAsFixed(1)} লক্ষ',
                onChanged: (v) => setState(() => _requestedLoanAmount = v),
              ),
              Center(
                child: Text(
                  '৳${_requestedLoanAmount.toStringAsFixed(0)} টাকা',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: forestGreen),
                ),
              ),

              const SizedBox(height: 24),
              Text('ডসিয়ারে অন্তর্ভুক্ত স্বয়ংক্রিয় অডিট চার্ট', style: GoogleFonts.hindSiliguri(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Summary Preview Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildReportItem('খামারি ও প্রোপাইটার', user?.name ?? 'মোঃ আব্দুল কুদ্দুস'),
                    _buildReportItem('খামারের মোট পরিধি', '১.৫ একর (৩টি পুকুর)'),
                    _buildReportItem('বর্তমান বায়োমাস সম্পদ মূল্য', '৳ ১২,৮০,০০০'),
                    _buildReportItem('এফসিআর পারফরম্যান্স স্কোর', '১.৪২ (আদর্শ মান)'),
                    _buildReportItem('বার্ষিক সম্ভাব্য নিট লাভ', '৳ ৭,৫০,০০০'),
                    _buildReportItem('ঋণ পরিশোধ সক্ষমতা (DSCR)', '২.৪ গুণ (খুবই নিরাপদ)'),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _downloadReport,
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                  label: _isGenerating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'পিডিএফ ডসিয়ার ডাউনলোড করুন 📥',
                          style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: forestGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade600)),
          Text(value, style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
