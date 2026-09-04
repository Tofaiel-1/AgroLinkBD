import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/models/order_model.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/presentation/screens/transport/order_qr_delivery_screen.dart';

/// Fish Driver Deliveries Screen
/// Active trip tracking, Gher-to-Arat route progress, live oxygen telemetry and delivery completion.
class FishDriverDeliveriesScreen extends StatefulWidget {
  const FishDriverDeliveriesScreen({super.key});

  @override
  State<FishDriverDeliveriesScreen> createState() => _FishDriverDeliveriesScreenState();
}

class _FishDriverDeliveriesScreenState extends State<FishDriverDeliveriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBn = LanguageProvider.isBn(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0277BD),
        elevation: 0,
        title: Text(
          isBn ? 'মাছ ডেলিভারি ও লাইভ ট্র্যাকিং' : 'Fish Deliveries & Transit',
          style: GoogleFonts.hindSiliguri(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amberAccent,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(text: isBn ? 'চলমান ডেলিভারি (Active)' : 'Active Delivery'),
            Tab(text: isBn ? 'ডেলিভারি হিস্ট্রি (History)' : 'Past Deliveries'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveDeliveryTab(isDark, isBn),
          _buildPastDeliveriesTab(isDark, isBn),
        ],
      ),
    );
  }

  Widget _buildActiveDeliveryTab(bool isDark, bool isBn) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simulated Real-Time GPS Map View
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16252F) : const Color(0xFFE1F5FE),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF0288D1), width: 1.5),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.airport_shuttle, size: 54, color: Color(0xFF0277BD)),
                      const SizedBox(height: 8),
                      Text(
                        isBn ? 'ঢাকা-নাটোর মহাসড়ক (হাইওয়ে কিলোমিটার: ১২৮/২১০)' : 'Dhaka-Natore Highway (Km 128/210)',
                        style: GoogleFonts.hindSiliguri(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        isBn ? 'আনুমানিক পৌঁছানোর সময়: ১ ঘণ্টা ৪৫ মিনিট' : 'Estimated Arrival: 1h 45m',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isBn ? 'গতি: ৬০ কিমি/ঘণ্টা' : 'Speed: 60 km/h',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tank Telemetry Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F7FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00ACC1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniSensor(Icons.air, 'O2: 7.8 bar', isBn ? 'অক্সিজেন সক্রিয়' : 'O2 Flowing', Colors.green),
                _buildMiniSensor(Icons.thermostat, '23.5 °C', isBn ? 'পানি ঠান্ডা' : 'Cool Water', Colors.cyan.shade800),
                _buildMiniSensor(Icons.scale, '৮০০ কেজি', isBn ? 'জ্যান্ত রুই/কাতল' : 'Live Biomass', Colors.blue.shade800),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Trip Progress Stepper
          Text(
            isBn ? 'ট্রিপের ধাপ ও বর্তমান স্ট্যাটাস' : 'Trip Progress Stages',
            style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildStageStepper(isDark, isBn),
          const SizedBox(height: 20),

          // Contact Parties Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16252F) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildContactRow(
                  title: isBn ? 'খামারি: মোঃ আব্দুল কুদ্দুস' : 'Farmer: Md. Abdul Kuddus',
                  subtitle: isBn ? 'সিংড়া বাজার, চলনবিল, নাটোর' : 'Singra, Chalan Beel, Natore',
                  icon: Icons.person,
                  phone: '01711223344',
                ),
                const Divider(height: 16),
                _buildContactRow(
                  title: isBn ? 'আড়তদার ক্রেতা: ভাই ভাই মৎস্য আড়ত' : 'Buyer: Bhai Bhai Fish Arat',
                  subtitle: isBn ? 'যাত্রাবাড়ী মৎস্য পাইকারি আড়ত, ঢাকা' : 'Jatrabari Wholesale Fish Market',
                  icon: Icons.storefront,
                  phone: '01715998877',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Complete Delivery Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => Get.to(() => OrderQrDeliveryScreen(
                    order: OrderModel(
                      id: 'TR-FISH-401',
                      buyerId: 'buyer_01',
                      farmerId: 'farmer_01',
                      farmerName: 'মোঃ আব্দুল কুদ্দুস',
                      productName: 'জ্যান্ত রুই ও কাতলা মাছ',
                      productImageUrl: 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788505454/images_jzjue9.jpg',
                      quantity: 800.0,
                      totalAmount: 8500.0,
                      status: 'in_transit',
                      statusStep: 3,
                      deliveryOtp: '5821',
                      createdAt: DateTime.now(),
                    ),
                  )),
              icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
              label: Text(
                isBn ? 'আড়তে ডেলিভারি নিশ্চিত করুন (QR স্ক্যান)' : 'Confirm Delivery (Scan QR)',
                style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0277BD),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniSensor(IconData icon, String val, String sub, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(val, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: color)),
            Text(sub, style: GoogleFonts.hindSiliguri(fontSize: 10, color: Colors.black87)),
          ],
        ),
      ],
    );
  }

  Widget _buildStageStepper(bool isDark, bool isBn) {
    final stages = [
      {'title': isBn ? 'খামারে পৌঁছানো' : 'Reached Farm', 'done': true},
      {'title': isBn ? 'মাছ ওজন ও ড্রাম লোডিং' : 'Fish Loaded', 'done': true},
      {'title': isBn ? 'অক্সিজেন চালু ও সিল' : 'Oxygen Active', 'done': true},
      {'title': isBn ? 'মহাসড়কে ট্রানজিট' : 'On Highway', 'done': true},
      {'title': isBn ? 'আড়তে পৌঁছানো' : 'At Destination', 'done': false},
      {'title': isBn ? 'ডেলিভারি সম্পন্ন' : 'Delivered', 'done': false},
    ];

    return Column(
      children: stages.asMap().entries.map((entry) {
        final idx = entry.key;
        final item = entry.value;
        final isDone = item['done'] as bool;
        final isCurrent = idx == 3;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: isCurrent
                      ? Colors.amberAccent
                      : (isDone ? Colors.green : Colors.grey.shade400),
                  child: Icon(
                    isDone ? Icons.check : Icons.circle,
                    size: 14,
                    color: isCurrent ? Colors.black87 : Colors.white,
                  ),
                ),
                if (idx < stages.length - 1)
                  Container(
                    width: 2,
                    height: 28,
                    color: isDone ? Colors.green : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                item['title'] as String,
                style: GoogleFonts.hindSiliguri(
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                  color: isCurrent
                      ? const Color(0xFF0288D1)
                      : (isDone ? (isDark ? Colors.white : Colors.black87) : Colors.grey),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildContactRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required String phone,
  }) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFF0277BD).withOpacity(0.12),
          child: Icon(icon, color: const Color(0xFF0277BD), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(subtitle, style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.phone, color: Colors.green),
          onPressed: () {
            Get.snackbar('কল করা হচ্ছে', '$phone নম্বরে কল ডায়াল করা হচ্ছে...');
          },
        ),
      ],
    );
  }

  Widget _buildPastDeliveriesTab(bool isDark, bool isBn) {
    final pastTrips = [
      {
        'id': 'TR-FISH-389',
        'date': 'গতকাল, বিকাল ৫:৩০',
        'from': 'শ্যামনগর বাগদা ঘের, সাতক্ষীরা',
        'to': 'কাওরান বাজার মৎস্য আড়ত, ঢাকা',
        'fish': '৬০০ কেজি বরফযুক্ত বাগদা চিংড়ি',
        'fare': '৳ ১২,৫০০',
        'status': 'সম্পন্ন (Delivered)',
      },
      {
        'id': 'TR-FISH-382',
        'date': '২ দিন আগে, ভোর ৪:০০',
        'from': 'ত্রিশাল পাঙ্গাশ খামার, ময়মনসিংহ',
        'to': 'যাত্রাবাড়ী আড়ত, ঢাকা',
        'fish': '১.২ টন জ্যান্ত পাঙ্গাশ ও তেলাপিয়া',
        'fare': '৳ ৯,৮০০',
        'status': 'সম্পন্ন (Delivered)',
      },
      {
        'id': 'TR-FISH-375',
        'date': '৪ দিন আগে, রাত ১১:১৫',
        'from': 'হালদা হ্যাচারি জোন, চট্টগ্রাম',
        'to': 'কুমিল্লা মৎস্য বাজার',
        'fish': '৩৫০ কেজি কার্প জাতীয় মাছ',
        'fare': '৳ ৭,২০০',
        'status': 'সম্পন্ন (Delivered)',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pastTrips.length,
      itemBuilder: (context, index) {
        final item = pastTrips[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16252F) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['id']!,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF0277BD)),
                  ),
                  Text(
                    item['fare']!,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(item['date']!, style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey)),
              const Divider(height: 16),
              Text('উৎস: ${item['from']}', style: GoogleFonts.hindSiliguri(fontSize: 12)),
              Text('গন্তব্য: ${item['to']}', style: GoogleFonts.hindSiliguri(fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                'পণ্য: ${item['fish']}',
                style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF00695C)),
              ),
            ],
          ),
        );
      },
    );
  }
}
