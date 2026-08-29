import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FishMarketPriceScreen extends StatefulWidget {
  const FishMarketPriceScreen({super.key});

  @override
  State<FishMarketPriceScreen> createState() => _FishMarketPriceScreenState();
}

class _FishMarketPriceScreenState extends State<FishMarketPriceScreen> {
  String _selectedDivision = 'ঢাকা (যাত্রাবাড়ী ও কাওরান বাজার)';

  final List<String> _divisions = [
    'ঢাকা (যাত্রাবাড়ী ও কাওরান বাজার)',
    'ময়মনসিংহ (ত্রিশাল ও তারাকান্দা)',
    'রাজশাহী ও নাটোর (চলনবিল)',
    'খুলনা ও সাতক্ষীরা (ঘের এলাকা)',
    'চট্টগ্রাম ও চাঁদপুর মোহনা',
    'বরিশাল ও পটুয়াখালী',
  ];

  final Map<String, List<Map<String, dynamic>>> _marketData = {
    'ঢাকা (যাত্রাবাড়ী ও কাওরান বাজার)': [
      {'species': 'পদ্মার তাজা ইলিশ (১ কেজি+)', 'rate': '৳১৪৫০ - ১৬০০', 'change': '+৳৫০', 'isUp': true, 'category': 'সামুদ্রিক'},
      {'species': 'দেশি রুই (১.৫ - ২ কেজি)', 'rate': '৳৩৪০ - ৩৬০', 'change': '+৳১০', 'isUp': true, 'category': 'মিঠা পানি'},
      {'species': 'কাতলা (২.৫ কেজি+)', 'rate': '৳৩৮০ - ৪২০', 'change': '০%', 'isUp': true, 'category': 'মিঠা পানি'},
      {'species': 'গলদা চিংড়ি (বড় সাইজ)', 'rate': '৳৮৫০ - ৯৫০', 'change': '+৳২০', 'isUp': true, 'category': 'চিংড়ি'},
      {'species': 'পাঙ্গাশ (বড় ২ কেজি+)', 'rate': '৳১৭০ - ১৯০', 'change': '-৳৫', 'isUp': false, 'category': 'মিঠা পানি'},
      {'species': 'তেলাপিয়া (বড় আকার)', 'rate': '৳২০০ - ২২০', 'change': '০%', 'isUp': true, 'category': 'মিঠা পানি'},
      {'species': 'দেশি জ্যান্ত শিং ও মাগুর', 'rate': '৳৫৫০ - ৬৫০', 'change': '+৳৩০', 'isUp': true, 'category': 'জীবন্ত'},
      {'species': 'পাবদা ও গুলশা', 'rate': '৳৪০০ - ৪৬০', 'change': '+৳১০', 'isUp': true, 'category': 'মিঠা পানি'},
    ],
    'ময়মনসিংহ (ত্রিশাল ও তারাকান্দা)': [
      {'species': 'দেশি রুই (খামার রেট)', 'rate': '৳২৮০ - ৩১০', 'change': '+৳৫', 'isUp': true, 'category': 'মিঠা পানি'},
      {'species': 'পাঙ্গাশ (খামার পাইকারি)', 'rate': '৳১৪০ - ১৫৫', 'change': '-৳২', 'isUp': false, 'category': 'মিঠা পানি'},
      {'species': 'তেলাপিয়া মনোসেক্স', 'rate': '৳১৬০ - ১৭৫', 'change': '০%', 'isUp': true, 'category': 'মিঠা পানি'},
      {'species': 'বায়োফ্লক শিং মাছ', 'rate': '৳৪২০ - ৪৬০', 'change': '+৳১৫', 'isUp': true, 'category': 'জীবন্ত'},
      {'species': 'পাবদা মাছ', 'rate': '৳৩৫০ - ৩৮০', 'change': '+৳১০', 'isUp': true, 'category': 'মিঠা পানি'},
    ],
    'রাজশাহী ও নাটোর (চলনবিল)': [
      {'species': 'দেশি রুই ও কাতলা', 'rate': '৳২৯০ - ৩২০', 'change': '+৳১০', 'isUp': true, 'category': 'মিঠা পানি'},
      {'species': 'মৃগেল ও কার্প', 'rate': '৳২৪০ - ২৬০', 'change': '০%', 'isUp': true, 'category': 'মিঠা পানি'},
      {'species': 'দেশি বোয়াল ও চিতল', 'rate': '৳৭৫০ - ৮৫০', 'change': '+৳৪০', 'isUp': true, 'category': 'প্রাকৃতিক'},
    ],
    'খুলনা ও সাতক্ষীরা (ঘের এলাকা)': [
      {'species': 'রপ্তানি গ্রেড বাগদা চিংড়ি', 'rate': '৳৮৫০ - ৯২০', 'change': '+৳৩০', 'isUp': true, 'category': 'চিংড়ি'},
      {'species': 'গলদা চিংড়ি (গ্রেড ১)', 'rate': '৳৭৮০ - ৮৫০', 'change': '+৳২০', 'isUp': true, 'category': 'চিংড়ি'},
      {'species': 'ভেঁটকি ও কোরাল', 'rate': '৳৬৫০ - ৭২০', 'change': '+৳১৫', 'isUp': true, 'category': 'সামুদ্রিক'},
      {'species': 'পারশে ও ভাঙন মাছ', 'rate': '৳৪৫০ - ৫২০', 'change': '০%', 'isUp': true, 'category': 'উপকূলীয়'},
    ],
    'চট্টগ্রাম ও চাঁদপুর মোহনা': [
      {'species': 'চাঁদপুরের রুপালি ইলিশ', 'rate': '৳১৫০০ - ১৭০০', 'change': '+৳৬০', 'isUp': true, 'category': 'সামুদ্রিক'},
      {'species': 'রূপচাঁদা মাছ (সাদা)', 'rate': '৳৯৫০ - ১১০০', 'change': '+৳২৫', 'isUp': true, 'category': 'সামুদ্রিক'},
      {'species': 'সামুদ্রিক লইট্টা', 'rate': '৳১৮০ - ২২০', 'change': '-৳১০', 'isUp': false, 'category': 'সামুদ্রিক'},
    ],
    'বরিশাল ও পটুয়াখালী': [
      {'species': 'পদ্মা-মেঘনার ইলিশ', 'rate': '৳১৩৫০ - ১৫০০', 'change': '+৳৪০', 'isUp': true, 'category': 'সামুদ্রিক'},
      {'species': 'নদীর আইড় ও রিঠা', 'rate': '৳৮০০ - ৯০০', 'change': '+৳২০', 'isUp': true, 'category': 'প্রাকৃতিক'},
      {'species': 'গলদা চিংড়ি', 'rate': '৳৭৫০ - ৮২০', 'change': '+৳১৫', 'isUp': true, 'category': 'চিংড়ি'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    const Color purpleColor = Color(0xFF7B1FA2);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prices = _marketData[_selectedDivision] ?? _marketData['ঢাকা (যাত্রাবাড়ী ও কাওরান বাজার)']!;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'লাইভ মাছের পাইকারি বাজার দর',
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
            Text('আড়ত ও মোকাম এলাকা নির্বাচন করুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600, fontSize: 13)),
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
                  value: _selectedDivision,
                  isExpanded: true,
                  items: _divisions.map((div) {
                    return DropdownMenuItem(
                      value: div,
                      child: Text(div, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDivision = val);
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
                      'দৈনিক পাইকারি আড়ত থেকে হালনাগাদকৃত দর। জ্যান্ত মাছ ঢাকায় বিক্রিতে কেজি প্রতি ২০-৪০ টাকা বেশি পাওয়া যাচ্ছে।',
                      style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.purple.shade900),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Text(
              'আজকের বাজার দর তালিকা (প্রতি কেজি)',
              style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...prices.map((item) {
              final isUp = item['isUp'] as bool;
              final changeColor = isUp ? Colors.green : Colors.red;

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
                                item['species'],
                                style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item['category'],
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
