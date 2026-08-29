import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class ReturnTruckSharingScreen extends StatefulWidget {
  const ReturnTruckSharingScreen({super.key});

  @override
  State<ReturnTruckSharingScreen> createState() => _ReturnTruckSharingScreenState();
}

class _ReturnTruckSharingScreenState extends State<ReturnTruckSharingScreen> {
  final List<Map<String, dynamic>> _returnTrips = [
    {
      'id': 'RT-101',
      'driverName': 'মোঃ শফিকুল ইসলাম',
      'phone': '01712334455',
      'vehicle': 'মাঝারি ট্রাক (৫ টন)',
      'emptyCapacity': '৩.৫ টন খালি',
      'from': 'ঢাকা (কাওরান বাজার)',
      'to': 'বগুড়া (মহাস্থান)',
      'via': 'টাঙ্গাইল, সিরাজগঞ্জ হাইওয়ে',
      'departureTime': 'আজ রাত ৯:০০ টা',
      'discountPercent': '৪৫%',
      'regularFare': '৳ ৭,৫০০',
      'discountFare': '৳ ৪,১০০',
      'rating': 4.9,
      'isPro': true,
    },
    {
      'id': 'RT-102',
      'driverName': 'আলহাজ্ব আকরাম হোসেন',
      'phone': '01819887766',
      'vehicle': 'পিকআপ ভ্যান (১.৫ টন)',
      'emptyCapacity': 'সম্পূর্ণ খালি (১.৫ টন)',
      'from': 'চট্টগ্রাম (ফিশারি ঘাট)',
      'to': 'কুমিল্লা ও ফেনী',
      'via': 'ঢাকা-চট্টগ্রাম হাইওয়ে',
      'departureTime': 'কাল সকাল ৬:০০ টা',
      'discountPercent': '৫০%',
      'regularFare': '৳ ৫,০০০',
      'discountFare': '৳ ২,৫০০',
      'rating': 4.8,
      'isPro': true,
    },
    {
      'id': 'RT-103',
      'driverName': 'মোঃ জসিম উদ্দিন',
      'phone': '01911445566',
      'vehicle': 'লাইভ অক্সিজেন ফিশ ভ্যান',
      'emptyCapacity': '২ টন চেম্বার খালি',
      'from': 'ময়মনসিংহ',
      'to': 'নাটোর ও রাজশাহী',
      'via': 'টাঙ্গাইল, যমুনা সেতু রুট',
      'departureTime': 'আজ দুপুর ৩:৩০ টা',
      'discountPercent': '৪০%',
      'regularFare': '৳ ৮,০০০',
      'discountFare': '৳ ৪,৮০০',
      'rating': 5.0,
      'isPro': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryOrange = Color(0xFFF57C00);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'ফিরতি খালি গাড়ি শেয়ারিং (Backhaul) ⚡',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        backgroundColor: primaryOrange,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPostReturnTripDialog,
        backgroundColor: primaryOrange,
        icon: const Icon(Icons.add_road, color: Colors.white),
        label: Text('খালি ট্রিপ পোস্ট করুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE65100), Color(0xFFF57C00), Color(0xFFFF9800)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: primaryOrange.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, color: Colors.white, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '৫০% কম খরচে পণ্য পরিবহন 🚀',
                          style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          'শহরে মাল নামিয়ে খালি ফেরার পথে ড্রাইভাররা কম ভাড়ায় মাল নিয়ে যায়। আপনার পণ্য বুক করুন বা খালি গাড়ি পোস্ট করুন।',
                          style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.white.withOpacity(0.95)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('চলমান ফিরতি খালি গাড়ি সমূহ', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text('লাইভ ৩টি গাড়ি', style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _returnTrips.length,
              itemBuilder: (context, index) {
                final trip = _returnTrips[index];
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
                            Row(
                              children: [
                                Text(trip['driverName'], style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15)),
                                if (trip['isPro'] == true) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text('PRO ⭐', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.brown)),
                                  ),
                                ],
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange),
                              ),
                              child: Text('${trip['discountPercent']} ছাড়', style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Route
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.trip_origin, size: 16, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(trip['from'], style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600, fontSize: 13))),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 7),
                                child: Align(alignment: Alignment.centerLeft, child: Container(height: 14, width: 2, color: Colors.grey.shade400)),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(trip['to'], style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600, fontSize: 13))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('রুট: ${trip['via']} • ছাড়ার সময়: ${trip['departureTime']}', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
                        Text('গাড়ির ধরণ: ${trip['vehicle']} (${trip['emptyCapacity']})', style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blueGrey)),
                        const Divider(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('মূল ভাড়া: ${trip['regularFare']}', style: GoogleFonts.hindSiliguri(fontSize: 11, decoration: TextDecoration.lineThrough, color: Colors.grey)),
                                Text(trip['discountFare'], style: GoogleFonts.hindSiliguri(fontSize: 20, fontWeight: FontWeight.bold, color: primaryOrange)),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                Get.snackbar(
                                  'ড্রাইভারকে কল দেওয়া হচ্ছে 📞',
                                  '${trip['driverName']} (${trip['phone']}) এর সাথে যোগাযোগ করা হচ্ছে...',
                                  backgroundColor: primaryOrange,
                                  colorText: Colors.white,
                                );
                              },
                              icon: const Icon(Icons.call, size: 16, color: Colors.white),
                              label: Text('বুকিং কল', style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryOrange,
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
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  void _showPostReturnTripDialog() {
    final fromController = TextEditingController();
    final toController = TextEditingController();
    final capacityController = TextEditingController();
    final fareController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 16),
            Text('আপনার ফিরতি খালি গাড়ির ট্রিপ পোস্ট করুন 🚛', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 12),
            TextField(controller: fromController, decoration: const InputDecoration(labelText: 'কোথা থেকে ফিরছেন (উৎপত্তিস্থল)', prefixIcon: Icon(Icons.trip_origin))),
            const SizedBox(height: 10),
            TextField(controller: toController, decoration: const InputDecoration(labelText: 'কোথায় যাবেন (গন্তব্য)', prefixIcon: Icon(Icons.location_on))),
            const SizedBox(height: 10),
            TextField(controller: capacityController, decoration: const InputDecoration(labelText: 'খালি জায়গার পরিমাণ (যেমন: ২ টন)', prefixIcon: Icon(Icons.fitness_center))),
            const SizedBox(height: 10),
            TextField(controller: fareController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ডিসকাউন্টেড প্রস্তাবিত ভাড়া (৳)', prefixIcon: Icon(Icons.monetization_on))),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Get.snackbar('সফলভাবে পোস্ট হয়েছে! 🚀', 'আপনার ফিরতি খালি গাড়ির রুট কৃষকদের লোড বোর্ডে ব্রডকাস্ট করা হয়েছে।', backgroundColor: const Color(0xFF2E7D32), colorText: Colors.white);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF57C00), padding: const EdgeInsets.symmetric(vertical: 12)),
                child: Text('লাইভ পোস্ট প্রকাশ করুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
