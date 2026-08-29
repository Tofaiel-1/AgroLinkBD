import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/presentation/screens/wallet/withdraw_money_screen.dart';

/// Farmer Wallet Screen - Manage balance, escrow holdings, and withdrawal
class FarmerWalletScreen extends StatefulWidget {
  const FarmerWalletScreen({super.key});

  @override
  State<FarmerWalletScreen> createState() => _FarmerWalletScreenState();
}

class _FarmerWalletScreenState extends State<FarmerWalletScreen> {
  final List<Map<String, dynamic>> transactions = [
    {
      'type': 'ক্রেডিট',
      'title': 'ফসল বিক্রয়মূল্য প্রাপ্তি (৯৭% নেট)',
      'description': 'অর্ডার #BATCH-BD-9041 সফল ডেলিভারি',
      'amount': '+ ৳ ৪৮,৫০০',
      'date': 'আজ, দুপুর ২:১৫',
      'icon': Icons.add_circle,
      'color': Colors.green,
      'isEscrow': false,
    },
    {
      'type': 'এস্ক্রো হোল্ড',
      'title': 'চলমান অর্ডার এস্ক্রো লকড 🔒',
      'description': 'অর্ডার #BATCH-BD-3312 ড্রাইভার ট্রানজিটে আছে',
      'amount': '৳ ১৯,৪০০',
      'date': 'আজ, সকাল ১১:০০',
      'icon': Icons.lock_clock,
      'color': Colors.orange,
      'isEscrow': true,
    },
    {
      'type': 'ডেবিট',
      'title': 'বিকাশ ক্যাশআউট',
      'description': 'TxnID: 9X8102BA92',
      'amount': '- ৳ ১০,০০০',
      'date': '১৭ এপ্রিল ২০২৬',
      'icon': Icons.arrow_outward_rounded,
      'color': Colors.red,
      'isEscrow': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'এগ্রো ওয়ালেট ও এস্ক্রো',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Dual Balance Card (Available + Escrow Pending)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2E7D32),
                    Color(0xFF1B5E20),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade900.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'উত্তোলনযোগ্য ব্যালেন্স (Available)',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '১০০% সুরক্ষিত',
                          style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '৳ ১২,৫০০.০০',
                    style: GoogleFonts.poppins(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Escrow Holding Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lock_outline, color: Colors.amber, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'এস্ক্রোতে আটক (পেন্ডিং ডেলিভারি):',
                              style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.white),
                            ),
                          ],
                        ),
                        Text(
                          '৳ ১৯,৪০০.০০',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2E7D32),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            final uid = FirebaseAuth.instance.currentUser?.uid ?? 'farmer_user';
                            Get.to(() => WithdrawMoneyScreen(userId: uid, currentBalance: 12500.0));
                          },
                          icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
                          label: Text(
                            'বিকাশ/নগদ ক্যাশআউট',
                            style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // How Escrow Works Info Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF1976D2), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '💡 এগ্রোলিংক এস্ক্রো কীভাবে কাজ করে?\nক্রেতা অর্ডার করার সাথে সাথে টাকা এস্ক্রোতে জমা থাকে। আপনার পণ্য ড্রাইভারের কাছে পৌঁছানোর পর ক্রেতা ওটিপি দিলে ৯৭% নেট টাকা সরাসরি আপনার উত্তোলনযোগ্য ব্যালেন্সে যোগ হয়ে যায়।',
                      style: GoogleFonts.hindSiliguri(fontSize: 12, color: const Color(0xFF0D47A1), height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Transactions Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'সাম্প্রতিক লেনদেন',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'সব দেখুন',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 13,
                      color: const Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Transactions List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (transaction['color'] as Color).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          transaction['icon'] as IconData,
                          color: transaction['color'] as Color,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        transaction['title'] as String,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${transaction['description']}\n${transaction['date']}',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      trailing: Text(
                        transaction['amount'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: transaction['color'] as Color,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
