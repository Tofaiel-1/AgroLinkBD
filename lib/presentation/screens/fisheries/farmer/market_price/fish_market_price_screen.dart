import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';

class FishMarketPriceScreen extends StatefulWidget {
  const FishMarketPriceScreen({super.key});

  @override
  State<FishMarketPriceScreen> createState() => _FishMarketPriceScreenState();
}

class _FishMarketPriceScreenState extends State<FishMarketPriceScreen> {
  String _selectedDivisionKey = 'dhaka';

  final List<Map<String, String>> _divisions = [
    {'key': 'dhaka', 'nameBn': 'ঢাকা (যাত্রাবাড়ী ও কাওরান বাজার)', 'nameEn': 'Dhaka (Jatrabari & Karwan Bazar)'},
    {'key': 'mymensingh', 'nameBn': 'ময়মনসিংহ (ত্রিশাল ও তারাকান্দা)', 'nameEn': 'Mymensingh (Trishal & Tarakanda)'},
    {'key': 'rajshahi', 'nameBn': 'রাজশাহী ও নাটোর (চলনবিল)', 'nameEn': 'Rajshahi & Natore (Chalan Beel)'},
    {'key': 'khulna', 'nameBn': 'খুলনা ও সাতক্ষীরা (ঘের এলাকা)', 'nameEn': 'Khulna & Satkhira (Gher Zone)'},
    {'key': 'chittagong', 'nameBn': 'চট্টগ্রাম ও চাঁদপুর মোহনা', 'nameEn': 'Chattogram & Chandpur Estuary'},
    {'key': 'barishal', 'nameBn': 'বরিশাল ও পটুয়াখালী', 'nameEn': 'Barishal & Patuakhali'},
  ];

  final Map<String, List<Map<String, dynamic>>> _marketData = {
    'dhaka': [
      {'speciesBn': 'পদ্মার তাজা ইলিশ (১ কেজি+)', 'speciesEn': 'Fresh Padma Hilsa (1 kg+)', 'rate': '৳1450 - 1600', 'change': '+৳50', 'isUp': true, 'categoryBn': 'সামুদ্রিক', 'categoryEn': 'Marine'},
      {'speciesBn': 'দেশি রুই (১.৫ - ২ কেজি)', 'speciesEn': 'Local Rui (1.5 - 2 kg)', 'rate': '৳340 - 360', 'change': '+৳10', 'isUp': true, 'categoryBn': 'মিঠা পানি', 'categoryEn': 'Freshwater'},
      {'speciesBn': 'কাতলা (২.৫ কেজি+)', 'speciesEn': 'Katla (2.5 kg+)', 'rate': '৳380 - 420', 'change': '0%', 'isUp': true, 'categoryBn': 'মিঠা পানি', 'categoryEn': 'Freshwater'},
      {'speciesBn': 'গলদা চিংড়ি (বড় সাইজ)', 'speciesEn': 'Giant River Prawn (Large)', 'rate': '৳850 - 950', 'change': '+৳20', 'isUp': true, 'categoryBn': 'চিংড়ি', 'categoryEn': 'Prawn'},
      {'speciesBn': 'পাঙ্গাশ (বড় ২ কেজি+)', 'speciesEn': 'Pangasius (2 kg+)', 'rate': '৳170 - 190', 'change': '-৳5', 'isUp': false, 'categoryBn': 'মিঠা পানি', 'categoryEn': 'Freshwater'},
      {'speciesBn': 'তেলাপিয়া (বড় আকার)', 'speciesEn': 'Tilapia (Large)', 'rate': '৳200 - 220', 'change': '0%', 'isUp': true, 'categoryBn': 'মিঠা পানি', 'categoryEn': 'Freshwater'},
      {'speciesBn': 'দেশি জ্যান্ত শিং ও মাগুর', 'speciesEn': 'Live Shing & Magur Catfish', 'rate': '৳550 - 650', 'change': '+৳30', 'isUp': true, 'categoryBn': 'জীবন্ত', 'categoryEn': 'Live'},
      {'speciesBn': 'পাবদা ও গুলশা', 'speciesEn': 'Pabda & Gulsha', 'rate': '৳400 - 460', 'change': '+৳10', 'isUp': true, 'categoryBn': 'মিঠা পানি', 'categoryEn': 'Freshwater'},
    ],
    'mymensingh': [
      {'speciesBn': 'দেশি রুই (খামার রেট)', 'speciesEn': 'Farm Rui (Direct Rate)', 'rate': '৳280 - 310', 'change': '+৳5', 'isUp': true, 'categoryBn': 'মিঠা পানি', 'categoryEn': 'Freshwater'},
      {'speciesBn': 'পাঙ্গাশ (খামার পাইকারি)', 'speciesEn': 'Pangasius (Wholesale)', 'rate': '৳140 - 155', 'change': '-৳2', 'isUp': false, 'categoryBn': 'মিঠা পানি', 'categoryEn': 'Freshwater'},
      {'speciesBn': 'তেলাপিয়া মনোসেক্স', 'speciesEn': 'Monosex Tilapia', 'rate': '৳160 - 175', 'change': '0%', 'isUp': true, 'categoryBn': 'মিঠা পানি', 'categoryEn': 'Freshwater'},
      {'speciesBn': 'বায়োফ্লক শিং মাছ', 'speciesEn': 'Biofloc Shing Fish', 'rate': '৳420 - 460', 'change': '+৳15', 'isUp': true, 'categoryBn': 'জীবন্ত', 'categoryEn': 'Live'},
      {'speciesBn': 'পাবদা মাছ', 'speciesEn': 'Pabda Fish', 'rate': '৳350 - 380', 'change': '+৳10', 'isUp': true, 'categoryBn': 'মিঠা পানি', 'categoryEn': 'Freshwater'},
    ],
    'rajshahi': [
      {'speciesBn': 'দেশি রুই ও কাতলা', 'speciesEn': 'Local Rui & Katla', 'rate': '৳290 - 320', 'change': '+৳10', 'isUp': true, 'categoryBn': 'মিঠা পানি', 'categoryEn': 'Freshwater'},
      {'speciesBn': 'মৃগেল ও কার্প', 'speciesEn': 'Mrigal & Carp', 'rate': '৳240 - 260', 'change': '0%', 'isUp': true, 'categoryBn': 'মিঠা পানি', 'categoryEn': 'Freshwater'},
      {'speciesBn': 'দেশি বোয়াল ও চিতল', 'speciesEn': 'Local Boal & Chital', 'rate': '৳750 - 850', 'change': '+৳40', 'isUp': true, 'categoryBn': 'প্রাকৃতিক', 'categoryEn': 'Wild/River'},
    ],
    'khulna': [
      {'speciesBn': 'রপ্তানি গ্রেড বাগদা চিংড়ি', 'speciesEn': 'Export Grade Black Tiger Shrimp', 'rate': '৳850 - 920', 'change': '+৳30', 'isUp': true, 'categoryBn': 'চিংড়ি', 'categoryEn': 'Shrimp'},
      {'speciesBn': 'গলদা চিংড়ি (গ্রেড ১)', 'speciesEn': 'Galda Prawn (Grade 1)', 'rate': '৳780 - 850', 'change': '+৳20', 'isUp': true, 'categoryBn': 'চিংড়ি', 'categoryEn': 'Prawn'},
      {'speciesBn': 'ভেঁটকি ও কোরাল', 'speciesEn': 'Sea Bass (Koral)', 'rate': '৳650 - 720', 'change': '+৳15', 'isUp': true, 'categoryBn': 'সামুদ্রিক', 'categoryEn': 'Marine'},
      {'speciesBn': 'পারশে ও ভাঙন মাছ', 'speciesEn': 'Parshe & Bhangon', 'rate': '৳450 - 520', 'change': '0%', 'isUp': true, 'categoryBn': 'উপকূলীয়', 'categoryEn': 'Coastal'},
    ],
    'chittagong': [
      {'speciesBn': 'চাঁদপুরের রুপালি ইলিশ', 'speciesEn': 'Chandpur Silver Hilsa', 'rate': '৳1500 - 1700', 'change': '+৳60', 'isUp': true, 'categoryBn': 'সামুদ্রিক', 'categoryEn': 'Marine'},
      {'speciesBn': 'রূপচাঁদা মাছ (সাদা)', 'speciesEn': 'Silver Pomfret (Rupchanda)', 'rate': '৳950 - 1100', 'change': '+৳25', 'isUp': true, 'categoryBn': 'সামুদ্রিক', 'categoryEn': 'Marine'},
      {'speciesBn': 'সামুদ্রিক লইট্টা', 'speciesEn': 'Bombay Duck (Loitta)', 'rate': '৳180 - 220', 'change': '-৳10', 'isUp': false, 'categoryBn': 'সামুদ্রিক', 'categoryEn': 'Marine'},
    ],
    'barishal': [
      {'speciesBn': 'পদ্মা-মেঘনার ইলিশ', 'speciesEn': 'Padma-Meghna Hilsa', 'rate': '৳1350 - 1500', 'change': '+৳40', 'isUp': true, 'categoryBn': 'সামুদ্রিক', 'categoryEn': 'Marine'},
      {'speciesBn': 'নদীর আইড় ও রিঠা', 'speciesEn': 'River Air & Ritha', 'rate': '৳800 - 900', 'change': '+৳20', 'isUp': true, 'categoryBn': 'প্রাকৃতিক', 'categoryEn': 'Wild/River'},
      {'speciesBn': 'গলদা চিংড়ি', 'speciesEn': 'Galda Prawn', 'rate': '৳750 - 820', 'change': '+৳15', 'isUp': true, 'categoryBn': 'চিংড়ি', 'categoryEn': 'Prawn'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    const Color purpleColor = Color(0xFF7B1FA2);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isBn = LanguageProvider.isBn(context);
    final prices = _marketData[_selectedDivisionKey] ?? _marketData['dhaka']!;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          isBn ? 'লাইভ মাছের পাইকারি বাজার দর' : 'Live Wholesale Fish Market Rates',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: purpleColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Market Select Dropdown
            Text(
              isBn ? 'আড়ত ও মোকাম এলাকা নির্বাচন করুন' : 'Select Wholesale Depot / Market Area',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedDivisionKey,
                  isExpanded: true,
                  items: _divisions.map((div) {
                    final label = isBn ? div['nameBn']! : div['nameEn']!;
                    return DropdownMenuItem(
                      value: div['key']!,
                      child: Text(label, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDivisionKey = val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insights, color: Color(0xFF7B1FA2), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isBn
                          ? 'দৈনিক পাইকারি আড়ত থেকে হালনাগাদকৃত দর। জ্যান্ত মাছ ঢাকায় বিক্রিতে কেজি প্রতি ২০-৪০ টাকা বেশি পাওয়া যাচ্ছে।'
                          : 'Daily rates updated from verified wholesale depots. Live deliveries fetch ৳20-40 extra per kg in Dhaka.',
                      style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.purple.shade900),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Text(
              isBn ? 'আজকের বাজার দর তালিকা (প্রতি কেজি)' : 'Today\'s Market Price List (per kg)',
              style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...prices.map((item) {
              final isUp = item['isUp'] as bool;
              final changeColor = isUp ? Colors.green : Colors.red;
              final speciesName = isBn ? item['speciesBn'] : item['speciesEn'];
              final categoryName = isBn ? item['categoryBn'] : item['categoryEn'];

              return Card(
                color: Theme.of(context).cardColor,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.purple.shade50,
                            child: const Icon(Icons.set_meal, color: Color(0xFF7B1FA2)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                speciesName,
                                style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  categoryName,
                                  style: GoogleFonts.hindSiliguri(fontSize: 10, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item['rate'],
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF7B1FA2)),
                          ),
                          Row(
                            children: [
                              Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward, color: changeColor, size: 12),
                              const SizedBox(width: 2),
                              Text(
                                item['change'],
                                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: changeColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
