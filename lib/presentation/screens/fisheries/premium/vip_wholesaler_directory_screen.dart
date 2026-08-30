import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/presentation/widgets/premium_feature_gatekeeper.dart';

class VipWholesalerDirectoryScreen extends StatefulWidget {
  const VipWholesalerDirectoryScreen({super.key});

  @override
  State<VipWholesalerDirectoryScreen> createState() => _VipWholesalerDirectoryScreenState();
}

class _VipWholesalerDirectoryScreenState extends State<VipWholesalerDirectoryScreen> {
  String _selectedDistrict = 'সকল মোকাম';

  final List<Map<String, dynamic>> _wholesalers = [
    {
      'name': 'মেসার্স রহিম ট্রেডার্স (কাওরান বাজার)',
      'contactPerson': 'আলহাজ্ব রহিম মিয়া',
      'phone': '01711223344',
      'location': 'কাওরান বাজার পাইকারি মৎস্য মার্কেট, ঢাকা',
      'specialty': 'রুই, কাতলা ও মৃগেল (দৈনিক ৩ টন ডিমান্ড)',
      'verified': true,
      'isExport': false,
    },
    {
      'name': 'বেঙ্গল সি-ফুড প্রসেসিং লিমিটেড',
      'contactPerson': 'ইঞ্জিনিয়ার তানভীর আহমেদ',
      'phone': '01819556677',
      'location': 'মংলা ইপিজেড, বাগেরহাট',
      'specialty': 'রপ্তানি গ্রেড বাগদা ও গলদা চিংড়ি',
      'verified': true,
      'isExport': true,
    },
    {
      'name': 'স্বপ্ন সুপারশপ সাপ্লাই চেইন হেডকোয়ার্টার',
      'contactPerson': 'মোঃ শরিফুল ইসলাম (প্রকিউরমেন্ট ম্যানেজার)',
      'phone': '01912998877',
      'location': 'তেজগাঁও ইন্ডাস্ট্রিয়াল এরিয়া, ঢাকা',
      'specialty': 'লাইভ অক্সিজেন দেশি মাছ ও প্রিমিয়াম ইলিশ',
      'verified': true,
      'isExport': false,
    },
    {
      'name': 'যাত্রাবাড়ী ভাই ভাই মৎস্য আড়ত',
      'contactPerson': 'হাজী শফিকুল ইসলাম',
      'phone': '01677334455',
      'location': 'যাত্রাবাড়ী আড়ত, ঢাকা',
      'specialty': 'পাবদা, গুলশা ও শিং মাছ (বাল্ক লট)',
      'verified': true,
      'isExport': false,
    },
    {
      'name': 'চট্টগ্রাম ফিশারি ঘাট এক্সপোর্টার্স গিল্ড',
      'contactPerson': 'ক্যাপ্টেন সালাউদ্দিন',
      'phone': '01715443322',
      'location': 'নতুন ফিশারি ঘাট, চট্টগ্রাম',
      'specialty': 'সামুদ্রিক রূপচান্দা, ইলিশ ও কাঁকড়া',
      'verified': true,
      'isExport': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    const Color deepPurple = Color(0xFF4A148C);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'ভিআইপি মোকাম আড়তদার ডিরেক্টরি 📞',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: deepPurple,
        elevation: 0,
        centerTitle: true,
      ),
      body: PremiumFeatureGatekeeper(
        featureName: 'ভিআইপি ডিরেক্ট আড়তদার ও বায়ার ডিরেক্টরি',
        description: 'দেশের শীর্ষ পাইকারি আড়তদার, এক্সপোর্টার ও সুপারশপ প্রকিউরমেন্ট ম্যানেজারদের ভেরিফাইড ডিরেক্ট নম্বর আনলক করুন।',
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _wholesalers.length,
          itemBuilder: (context, index) {
            final w = _wholesalers[index];

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
                            w['name'],
                            style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        if (w['verified'] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.verified, color: Colors.green, size: 14),
                                const SizedBox(width: 4),
                                Text('ভেরিফাইড', style: GoogleFonts.hindSiliguri(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ম্যানেজার: ${w['contactPerson']} • ${w['location']}',
                      style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900 : Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, size: 16, color: deepPurple),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'চাহিদা: ${w['specialty']}',
                              style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.purple.shade200 : deepPurple),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(w['phone'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Get.snackbar(
                                  'কল করা হচ্ছে 📞',
                                  '${w['name']} এর সাথে সরাসরি সংযোগ স্থাপন করা হচ্ছে: ${w['phone']}',
                                  backgroundColor: deepPurple,
                                  colorText: Colors.white,
                                );
                              },
                              icon: const Icon(Icons.call, size: 16, color: Colors.white),
                              label: Text('সরাসরি কল', style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: deepPurple,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
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
