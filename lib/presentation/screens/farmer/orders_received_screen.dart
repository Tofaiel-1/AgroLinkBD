import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/utils/masked_identity_helper.dart';

/// Orders Received Screen - Farmers view buyer orders with masked identity and Escrow safety
class OrdersReceivedScreen extends StatefulWidget {
  const OrdersReceivedScreen({super.key});

  @override
  State<OrdersReceivedScreen> createState() => _OrdersReceivedScreenState();
}

class _OrdersReceivedScreenState extends State<OrdersReceivedScreen> {
  final List<Map<String, dynamic>> orders = [
    {
      'id': '#ORD-4091',
      'batchCode': 'BATCH-BD-9041',
      'buyer': MaskedIdentityHelper.getMaskedBuyerName(userId: 'buyer_01', district: 'ঢাকা কাওরান বাজার'),
      'product': 'দেশি গোল আলু (Grade A)',
      'quantity': '৫০ মণ (২,০০০ কেজি)',
      'totalPrice': '৳ ৫০,০০০',
      'netPayout': '৳ ৪৮,৫০০ (৯৭% নেট পেআউট)',
      'platformCommission': '৳ ১,৫০০ (৩% প্ল্যাটফর্ম ফি)',
      'status': 'এস্ক্রো সুরক্ষিত 🔒',
      'statusColor': Colors.green,
      'date': 'আজ, দুপুর ১:৩০',
      'transportStatus': 'উপজেলা হাব কালেকশন পেন্ডিং',
    },
    {
      'id': '#ORD-4092',
      'batchCode': 'BATCH-BD-3312',
      'buyer': MaskedIdentityHelper.getMaskedBuyerName(userId: 'buyer_02', district: 'চট্টগ্রাম খাতুনগঞ্জ'),
      'product': 'লাল পাকা টমেটো (Grade A)',
      'quantity': '২০ ক্যারেট (৫০০ কেজি)',
      'totalPrice': '৳ ২০,০০০',
      'netPayout': '৳ ১৯,৪০০ (৯৭% নেট পেআউট)',
      'platformCommission': '৳ ৬০০ (৩% প্ল্যাটফর্ম ফি)',
      'status': 'ড্রাইভার লোডিংয়ে আছে 🚚',
      'statusColor': Colors.blue,
      'date': 'গতকাল',
      'transportStatus': 'ড্রাইভার পিকআপ সম্পন্ন',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'প্রাপ্ত অর্ডার ও এস্ক্রো',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order['id'],
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                          Text(
                            'ব্যাচ: ${order['batchCode']}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: (order['statusColor'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: (order['statusColor'] as Color).withOpacity(0.3)),
                        ),
                        child: Text(
                          order['status'],
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 11,
                            color: order['statusColor'] as Color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Buyer Masked Zone
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF1976D2)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'গন্তব্য: ${order['buyer']}',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Product & Quantity
                  Text(
                    '${order['product']} • ${order['quantity']}',
                    style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),

                  // Escrow Financial Breakdown Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'মোট বিক্রয়মূল্য:',
                              style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade700),
                            ),
                            Text(
                              order['totalPrice'],
                              style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'প্ল্যাটফর্ম সার্ভিস চার্জ (৩%):',
                              style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade700),
                            ),
                            Text(
                              order['platformCommission'],
                              style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.red.shade700, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const Divider(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'আপনার ওয়ালেটে নেট জমা:',
                              style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
                            ),
                            Text(
                              order['netPayout'],
                              style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '🔒 ক্রেতার টাকা এস্ক্রোতে নিশ্চিত জমা রয়েছে। হাব-এ ড্রপ বা গাড়িতে লোড হলে ডেলিভারি ওটিপি কনফার্মেশনের সাথে সাথে ওয়ালেটে টাকা পেয়ে যাবেন।',
                    style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
