import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';

class BuyerRfqBoardScreen extends StatefulWidget {
  const BuyerRfqBoardScreen({super.key});

  @override
  State<BuyerRfqBoardScreen> createState() => _BuyerRfqBoardScreenState();
}

class _BuyerRfqBoardScreenState extends State<BuyerRfqBoardScreen> {
  final List<Map<String, dynamic>> _rfqList = [
    {
      'id': 'RFQ-8901',
      'buyerNameBn': 'আগোরা সুপারস্টোর সোর্সিং উইং 🏢',
      'buyerNameEn': 'Agora Superstore Sourcing Wing 🏢',
      'isVerifiedBuyer': true,
      'cropNameBn': 'দেশি গোল আলু (Grade A)',
      'cropNameEn': 'Local Round Potato (Grade A)',
      'targetQuantityBn': '২০ টন (২০,০০০ কেজি)',
      'targetQuantityEn': '20 Tons (20,000 kg)',
      'targetPricePerKg': 24.0,
      'totalBudgetBn': '৳ ৪,৮০,০০০',
      'totalBudgetEn': '৳ 4,80,000',
      'locationBn': 'বগুড়া / জয়পুরহাট কালেকশন জোন',
      'locationEn': 'Bogura / Joypurhat Collection Zone',
      'deliveryDeadlineBn': '৭ দিন বাকি',
      'deliveryDeadlineEn': '7 days left',
      'totalBids': 6,
      'lowestBid': 23.5,
      'descriptionBn': 'রপ্তানিযোগ্য মান, শুকনা ও পরিষ্কার হতে হবে। প্যাকেজিং প্লাস্টিক ক্রাফট ব্যাগে গ্রহণযোগ্য।',
      'descriptionEn': 'Export grade quality, clean and dry. Packaging in mesh craft bags required.',
    },
    {
      'id': 'RFQ-8902',
      'buyerNameBn': 'মেসার্স ভাই ভাই মৎস্য আড়ত (কাওরান বাজার) 🐟',
      'buyerNameEn': 'Bhai Bhai Fish Wholesale Depot (Karwan Bazar) 🐟',
      'isVerifiedBuyer': true,
      'cropNameBn': 'জ্যান্ত রুই ও কাতল (১.৫ - ২.৫ কেজি সাইজ)',
      'cropNameEn': 'Live Rui & Katla (1.5 - 2.5 kg size)',
      'targetQuantityBn': '৫ টন (৫,০০০ কেজি)',
      'targetQuantityEn': '5 Tons (5,000 kg)',
      'targetPricePerKg': 260.0,
      'totalBudgetBn': '৳ ১৩,০০,০০০',
      'totalBudgetEn': '৳ 1,300,000',
      'locationBn': 'ময়মনসিংহ / ত্রিশাল জোন',
      'locationEn': 'Mymensingh / Trishal Zone',
      'deliveryDeadlineBn': '৩ দিন বাকি',
      'deliveryDeadlineEn': '3 days left',
      'totalBids': 11,
      'lowestBid': 255.0,
      'descriptionBn': 'অক্সিজেন ড্রামে সরাসরি কাওরান বাজার ভোর ৫টার মধ্যে পৌঁছাতে হবে। লাইভ ডেলিভারি।',
      'descriptionEn': 'Live delivery in oxygen drums directly to Karwan Bazar before 5 AM.',
    },
    {
      'id': 'RFQ-8903',
      'buyerNameBn': 'স্বপ্ন সুপারশপ এগ্রো হাব 🛒',
      'buyerNameEn': 'Shwapno Supershop Agro Hub 🛒',
      'isVerifiedBuyer': true,
      'cropNameBn': 'হাইব্রিড পাকা টমেটো ও শসা',
      'cropNameEn': 'Hybrid Ripe Tomatoes & Cucumber',
      'targetQuantityBn': '৩ টন (৩,০০০ কেজি)',
      'targetQuantityEn': '3 Tons (3,000 kg)',
      'targetPricePerKg': 40.0,
      'totalBudgetBn': '৳ ১,২০,০০০',
      'totalBudgetEn': '৳ 1,20,000',
      'locationBn': 'যশোর / মেহেরপুর জোন',
      'locationEn': 'Jashore / Meherpur Zone',
      'deliveryDeadlineBn': '২ দিন বাকি',
      'deliveryDeadlineEn': '2 days left',
      'totalBids': 8,
      'lowestBid': 38.0,
      'descriptionBn': 'সমান সাইজের লাল পাকা টমেটো। কোনো দাগ বা পচা থাকা যাবে না।',
      'descriptionEn': 'Uniform size red ripe tomatoes. No blemishes or rotten pieces.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2E7D32);
    final bool isBn = LanguageProvider.isBn(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          isBn ? 'পাইকারি চাহিদা ও টেন্ডার বোর্ড (RFQ) 📋' : 'Wholesale RFQ & Tender Board 📋',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateRfqDialog(isBn),
        backgroundColor: const Color(0xFFE65100),
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: Text(
          isBn ? 'চাহিদা পোস্ট করুন' : 'Post RFQ',
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
                    isBn 
                        ? '💡 পাইকারদের সরাসরি ক্রয়ের চাহিদা। খামারি হিসেবে প্রতিযোগিতামূলক দরে বিড করে বড় ডিল নিশ্চিত করুন।'
                        : '💡 Direct buying demands from verified bulk buyers. Place competitive bids to win large orders.',
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
                return _buildRfqCard(rfq, primaryGreen, isBn);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRfqCard(Map<String, dynamic> rfq, Color primaryGreen, bool isBn) {
    final buyerName = isBn ? rfq['buyerNameBn'] : rfq['buyerNameEn'];
    final cropName = isBn ? rfq['cropNameBn'] : rfq['cropNameEn'];
    final targetQuantity = isBn ? rfq['targetQuantityBn'] : rfq['targetQuantityEn'];
    final totalBudget = isBn ? rfq['totalBudgetBn'] : rfq['totalBudgetEn'];
    final location = isBn ? rfq['locationBn'] : rfq['locationEn'];
    final deliveryDeadline = isBn ? rfq['deliveryDeadlineBn'] : rfq['deliveryDeadlineEn'];
    final description = isBn ? rfq['descriptionBn'] : rfq['descriptionEn'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                    deliveryDeadline,
                    style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Crop & Quantity
          Text(
            cropName,
            style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${isBn ? 'চাহিদা' : 'Demand'}: $targetQuantity',
                style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1976D2)),
              ),
              const SizedBox(width: 8),
              Text('•', style: TextStyle(color: Colors.grey.shade400)),
              const SizedBox(width: 8),
              Text(
                '${isBn ? 'বাজেট' : 'Budget'}: $totalBudget',
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
                  buyerName,
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
                  location,
                  style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
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
                    isBn ? '${rfq['totalBids']} জন বিড করেছেন' : '${rfq['totalBids']} bids submitted',
                    style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  Text(
                    isBn 
                        ? 'টার্গেট দর: ৳ ${rfq['targetPricePerKg']} / কেজি'
                        : 'Target Price: ৳ ${rfq['targetPricePerKg']} / kg',
                    style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showBidDialog(rfq, isBn),
                icon: const Icon(Icons.gavel, color: Colors.white, size: 16),
                label: Text(
                  isBn ? 'বিড জমা দিন ⚡' : 'Place Bid ⚡',
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

  void _showBidDialog(Map<String, dynamic> rfq, bool isBn) {
    final priceController = TextEditingController(text: '${rfq['lowestBid']}');
    final qtyController = TextEditingController();
    final cropName = isBn ? rfq['cropNameBn'] : rfq['cropNameEn'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          isBn ? 'আপনার দর ও লট প্রস্তাব করুন' : 'Submit Your Bid & Lot',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${isBn ? 'পণ্য' : 'Crop'}: $cropName',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: isBn ? 'আপনার অফার দর (প্রতি কেজি ৳)' : 'Your Offer Price (per kg ৳)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.price_change, color: Colors.green),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: isBn ? 'সরবরাহযোগ্য পরিমাণ (কেজি)' : 'Supply Quantity (kg)',
                hintText: isBn ? 'যেমন: ৫০০০' : 'e.g. 5000',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.scale, color: Colors.green),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isBn
                  ? '🔒 সফল ডিল হলে ১.৫% এস্ক্রো ম্যাচিং ফি কর্তন করা হবে।'
                  : '🔒 A 1.5% escrow matching fee applies upon deal closing.',
              style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isBn ? 'বাতিল' : 'Cancel', style: GoogleFonts.hindSiliguri()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Get.snackbar(
                isBn ? '🎉 বিড সফলভাবে জমা হয়েছে!' : '🎉 Bid Placed Successfully!',
                isBn 
                    ? 'ক্রেতা আপনার দর পছন্দ করলে সরাসরি এস্ক্রো বুকিং করবেন।'
                    : 'The buyer will initiate an escrow contract if your offer is accepted.',
                backgroundColor: const Color(0xFF2E7D32),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
            child: Text(isBn ? 'বিড নিশ্চিত করুন' : 'Confirm Bid', style: GoogleFonts.hindSiliguri(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateRfqDialog(bool isBn) {
    Get.snackbar(
      isBn ? 'পাইকারি চাহিদা ফর্ম' : 'Wholesale RFQ Form',
      isBn 
          ? 'পাইকার হিসেবে নতুন চাহিদা পোস্ট করার জন্য আপনার ভিআইপি অ্যাকাউন্ট সক্রিয় আছে।'
          : 'Your wholesale account is active to post new buy tenders.',
      backgroundColor: const Color(0xFF1976D2),
      colorText: Colors.white,
    );
  }
}
