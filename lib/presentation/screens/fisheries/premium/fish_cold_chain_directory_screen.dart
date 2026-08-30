import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/presentation/widgets/premium_feature_gatekeeper.dart';

class FishColdChainDirectoryScreen extends StatelessWidget {
  const FishColdChainDirectoryScreen({super.key});

  final List<Map<String, dynamic>> _coldChainHubs = const [
    {
      'name': 'পদ্মা আইস মিলস ও কোল্ড স্টোরেজ',
      'location': 'মাওয়া ঘাট, মুন্সিগঞ্জ',
      'type': 'বরফকল ও ডিপ ফ্রিজিং',
      'capacity': 'দৈনিক ৫০ টন বরফ ব্লক ও ক্রাশড আইস',
      'phone': '01719887766',
      'verified': true,
      'price': '৳১২০ / ব্লক (৪০ কেজি)',
    },
    {
      'name': 'কর্ণফুলী সি-ফুড প্রিজারভেশন লিমিটেড',
      'location': 'নতুন ফিশারি ঘাট, চট্টগ্রাম',
      'type': 'এক্সপোর্ট কোল্ড চেইন হাব (-১৮°C)',
      'capacity': '২০০ টন হিমায়িত স্টোরেজ ক্যাপাসিটি',
      'phone': '01811443322',
      'verified': true,
      'price': '৳১.৫০ / কেজি / দিন',
    },
    {
      'name': 'যমুনা আইস প্ল্যান্ট ও ইনসুলেটেড লজিস্টিকস',
      'location': 'সিরাজগঞ্জ মহাসড়ক রোড',
      'type': 'ক্রাশড আইস ও আইস ভ্যান সার্ভিস',
      'capacity': 'অক্সিজেন ও আইস ভ্যান সহ ৩০ টন আইস',
      'phone': '01912554433',
      'verified': true,
      'price': '৳১০০ / বস্তা ক্রাশড বরফ',
    },
  ];

  @override
  Widget build(BuildContext context) {
    const Color coldBlue = Color(0xFF0277BD);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'কোল্ড চেইন ও বরফকল ডিরেক্টরি ❄️',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        backgroundColor: coldBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: PremiumFeatureGatekeeper(
        featureName: 'কোল্ড চেইন ও বরফকল বুকিং ডিরেক্টরি',
        description: 'দেশের প্রধান মাছের মোকাম সংলগ্ন অনুমোদিত বরফকল, কোল্ড স্টোরেজ ও হিমায়িত ভ্যান অপারেটরদের ডিরেক্ট নম্বর আনলক করুন।',
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _coldChainHubs.length,
          itemBuilder: (context, index) {
            final hub = _coldChainHubs[index];
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
                        Expanded(
                          child: Text(
                            hub['name'],
                            style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.blue)),
                          child: Text(hub['type'], style: GoogleFonts.hindSiliguri(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('📍 অবস্থান: ${hub['location']}', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900 : Colors.cyan.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.ac_unit, size: 18, color: coldBlue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'ক্যাপাসিটি: ${hub['capacity']} • রেট: ${hub['price']}',
                              style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.cyan.shade200 : coldBlue),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(hub['phone'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                        ElevatedButton.icon(
                          onPressed: () {
                            Get.snackbar(
                              'কল দেওয়া হচ্ছে 📞',
                              '${hub['name']} (${hub['phone']}) এর সাথে যোগাযোগ করা হচ্ছে...',
                              backgroundColor: coldBlue,
                              colorText: Colors.white,
                            );
                          },
                          icon: const Icon(Icons.call, size: 16, color: Colors.white),
                          label: Text('বরফ বুকিং কল', style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: coldBlue,
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
