import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/presentation/widgets/premium_feature_gatekeeper.dart';

class ServiceProviderLeadEngineScreen extends StatelessWidget {
  const ServiceProviderLeadEngineScreen({super.key});

  final List<Map<String, dynamic>> _leads = const [
    {
      'id': 'LEAD-9912',
      'title': '১০০ শতক পুকুরে এয়ারেটর ও সৌর বিদ্যুৎ স্থাপন',
      'farmer': 'হাজী শফিকুল ইসলাম (বগুড়া)',
      'budget': '৳ ১,২০,০০০',
      'time': '১০ মিনিট আগে',
      'category': 'টেকনিক্যাল ও ইকুইপমেন্ট',
      'isUrgent': true,
    },
    {
      'id': 'LEAD-9913',
      'title': '৫০,০০০ পিস মনোসেক্স তেলাপিয়া পোনা সরবরাহ',
      'farmer': 'মেসার্স মাদার ফিশারিজ (ময়মনসিংহ)',
      'budget': '৳ ৭৫,০০০',
      'time': '২৫ মিনিট আগে',
      'category': 'হ্যাচারি পোনা সাপ্লাই',
      'isUrgent': false,
    },
    {
      'id': 'LEAD-9914',
      'title': 'পুকুরের তলদেশের গ্যাস ও অ্যামোনিয়া ট্রিটমেন্ট কনসালটেন্সি',
      'farmer': 'মোঃ আলমগীর হোসেন (নাটোর)',
      'budget': '৳ ৫,০০০',
      'time': '১ ঘণ্টা আগে',
      'category': 'ল্যাব টেস্ট ও ডক্টর ভিজিট',
      'isUrgent': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    const Color deepIndigo = Color(0xFF283593);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'ভিআইপি ভেরিফাইড লিড ইঞ্জিন 🚀',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        backgroundColor: deepIndigo,
        elevation: 0,
        centerTitle: true,
      ),
      body: PremiumFeatureGatekeeper(
        featureName: 'ভিআইপি লিড ইঞ্জিন ও ইনস্ট্যান্ট জব বিডিং',
        description: 'খামারি ও বড় প্রকল্পের নতুন কাজের চাহিদাপত্রে সাধারণ সেবাদাতাদের চেয়ে ৩ গুণ দ্রুত বিড করুন ও নিশ্চিত কাজ পান।',
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _leads.length,
          itemBuilder: (context, index) {
            final lead = _leads[index];
            return Card(
              color: Theme.of(context).cardColor,
              margin: const EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(6)),
                          child: Text(lead['category'], style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.bold, color: deepIndigo)),
                        ),
                        if (lead['isUrgent'] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.red)),
                            child: Text('জরুরি ⚡', style: GoogleFonts.hindSiliguri(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red.shade900)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(lead['title'], style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('পোস্টকারী: ${lead['farmer']} • ${lead['time']}', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600)),
                    const Divider(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('বাজেট / সম্ভাব্য চুক্তি', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
                            Text(lead['budget'], style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: deepIndigo)),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Get.snackbar(
                              'কোটেশন পাঠানো হয়েছে! 📨',
                              '${lead['title']} এর জন্য আপনার প্রফেশনাল বিড খামারির কাছে সরাসরি পাঠানো হয়েছে।',
                              backgroundColor: deepIndigo,
                              colorText: Colors.white,
                            );
                          },
                          icon: const Icon(Icons.bolt, size: 16, color: Colors.white),
                          label: Text('তাৎক্ষণিক বিড', style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: deepIndigo,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
