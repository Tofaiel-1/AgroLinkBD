import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class BuyerRfqBoardScreen extends StatefulWidget {
  const BuyerRfqBoardScreen({super.key});

  @override
  State<BuyerRfqBoardScreen> createState() => _BuyerRfqBoardScreenState();
}

class _BuyerRfqBoardScreenState extends State<BuyerRfqBoardScreen> {
  final List<Map<String, dynamic>> _rfqList = [
    {
      'id': 'RFQ-8901',
      'buyerName': 'আগোরা সুপারস্টোর সোর্সিং উইং 🏢',
      'isVerifiedBuyer': true,
      'cropName': 'দেশি গোল আলু (Grade A)',
      'targetQuantity': '২০ টন (২০,০০০ কেজি)',
      'targetPricePerKg': 24.0,
      'totalBudget': '৳ ৪,৮০,০০০',
      'location': 'বগুড়া / জয়পুরহাট কালেকশন জোন',
      'deliveryDeadline': '৭ দিন বাকি',
      'totalBids': 6,
      'lowestBid': 23.5,
      'description': 'রপ্তানিযোগ্য মান, শুকনা ও পরিষ্কার হতে হবে। প্যাকেজিং প্লাস্টিক ক্রাফট ব্যাগে গ্রহণযোগ্য।',
    },
    {
      'id': 'RFQ-8902',
      'buyerName': 'মেসার্স ভাই ভাই মৎস্য আড়ত (কাওরান বাজার) 🐟',
      'isVerifiedBuyer': true,
      'cropName': 'জ্যান্ত রুই ও কাতল (১.৫ - ২.৫ কেজি সাইজ)',
      'targetQuantity': '৫ টন (৫,০০০ কেজি)',
      'targetPricePerKg': 260.0,
      'totalBudget': '৳ ১৩,০০,০০০',
      'location': 'ময়মনসিংহ / ত্রিশাল জোন',
      'deliveryDeadline': '৩ দিন বাকি',
      'totalBids': 11,
      'lowestBid': 255.0,
      'description': 'অক্সিজেন ড্রামে সরাসরি কাওরান বাজার ভোর ৫টার মধ্যে পৌঁছাতে হবে। লাইভ ডেলিভারি।',
    },
    {
      'id': 'RFQ-8903',
      'buyerName': 'স্বপ্ন সুপারশপ এগ্রো হাব 🛒',
      'isVerifiedBuyer': true,
      'cropName': 'হাইব্রিড পাকা টমেটো ও শসা',
      'targetQuantity': '৩ টন (৩,০০০ কেজি)',
      'targetPricePerKg': 40.0,
      'totalBudget': '৳ ১,২০,০০০',
      'location': 'যশোর / মেহেরপুর জোন',
      'deliveryDeadline': '২ দিন বাকি',
      'totalBids': 8,
      'lowestBid': 38.0,
      'description': 'সমান সাইজের লাল পাকা টমেটো। কোনো দাগ বা পচা থাকা যাবে না।',
    },
  ];

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'পাইকারি চাহিদা ও টেন্ডার বোর্ড (RFQ) 📋',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateRfqDialog,
        backgroundColor: const Color(0xFFE65100),
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: Text(
          'চাহিদা পোস্ট করুন',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Header Info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(bottom: BorderSide(color: Colors.blue.shade200)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: Color(0xFF1976D2), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '💡 পাইকারদের সরাসরি ক্রয়ের চাহিদা। খামারি হিসেবে প্রতিযোগিতামূলক দরে বিড করে বড় ডিল নিশ্চিত করুন।',
                    style: GoogleFonts.hindSiliguri(fontSize: 12, color: const Color(0xFF0D47A1), height: 1.3),
                  ),
                ),
              ],
            ),
          ),

          // RFQ List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _rfqList.length,
              itemBuilder: (context, index) {
                final rfq = _rfqList[index];
                return _buildRfqCard(rfq, primaryGreen);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRfqCard(Map<String, dynamic> rfq, Color primaryGreen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.green.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: ID + Time left
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  rfq['id'],
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: primaryGreen),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 14, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    rfq['deliveryDeadline'],
                    style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Crop & Quantity
          Text(
            rfq['cropName'],
            style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'চাহিদা: ${rfq['targetQuantity']}',
                style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1976D2)),
              ),
              const SizedBox(width: 8),
              Text('•', style: TextStyle(color: Colors.grey.shade400)),
              const SizedBox(width: 8),
              Text(
                'বাজেট: ${rfq['totalBudget']}',
                style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Buyer & Location
          Row(
            children: [
              const Icon(Icons.store, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${rfq['buyerName']}',
                  style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade800, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  rfq['location'],
                  style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            rfq['description'],
            style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade700, height: 1.3),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Current Bids & Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${rfq['totalBids']} জন বিড করেছেন',
                    style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  Text(
                    'টার্গেট দর: ৳ ${rfq['targetPricePerKg']} / কেজি',
                    style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showBidDialog(rfq),
                icon: const Icon(Icons.gavel, color: Colors.white, size: 16),
                label: Text(
                  'বিড জমা দিন ⚡',
                  style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBidDialog(Map<String, dynamic> rfq) {
    final priceController = TextEditingController(text: '${rfq['lowestBid']}');
    final qtyController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'আপনার দর ও লট প্রস্তাব করুন',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('পণ্য: ${rfq['cropName']}', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'আপনার অফার দর (প্রতি কেজি ৳)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.price_change, color: Colors.green),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'সরবরাহযোগ্য পরিমাণ (কেজি)',
                hintText: 'যেমন: ৫০০০',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.scale, color: Colors.green),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '🔒 সফল ডিল হলে ১.৫% এস্ক্রো ম্যাচিং ফি কর্তন করা হবে।',
              style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('বাতিল', style: GoogleFonts.hindSiliguri()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Get.snackbar(
                '🎉 বিড সফলভাবে জমা হয়েছে!',
                'ক্রেতা আপনার দর পছন্দ করলে সরাসরি এস্ক্রো বুকিং করবেন।',
                backgroundColor: const Color(0xFF2E7D32),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
            child: Text('বিড নিশ্চিত করুন', style: GoogleFonts.hindSiliguri(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateRfqDialog() {
    Get.snackbar(
      'পাইকারি চাহিদা ফর্ম',
      'পাইকার হিসেবে নতুন চাহিদা পোস্ট করার জন্য আপনার ভিআইপি অ্যাকাউন্ট সক্রিয় আছে।',
      backgroundColor: const Color(0xFF1976D2),
      colorText: Colors.white,
    );
  }
}
