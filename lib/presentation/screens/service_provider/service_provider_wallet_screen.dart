import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

/// Service Provider Wallet Screen - Manage balance and payments
class ServiceProviderWalletScreen extends StatefulWidget {
  const ServiceProviderWalletScreen({super.key});

  @override
  State<ServiceProviderWalletScreen> createState() =>
      _ServiceProviderWalletScreenState();
}

class _ServiceProviderWalletScreenState
    extends State<ServiceProviderWalletScreen> {
  final List<Map<String, dynamic>> transactions = [
    {
      'type': 'ক্রেডিট',
      'description': 'সেবা সরবরাহ - কীটনাশক স্প্রে',
      'amount': '৳ ৫০০',
      'date': '১৮ এপ্রিল ২০২৬',
      'icon': Icons.add_circle,
      'color': Colors.green,
    },
    {
      'type': 'ডেবিট',
      'description': 'প্ল্যাটফর্ম কমিশন',
      'amount': '৳ ৫০',
      'date': '১৮ এপ্রিল ২০২৬',
      'icon': Icons.remove_circle,
      'color': Colors.red,
    },
    {
      'type': 'ক্রেডিট',
      'description': 'মাটি পরীক্ষা সেবা',
      'amount': '৳ ১,০০০',
      'date': '১৭ এপ্রিল ২০২৬',
      'icon': Icons.add_circle,
      'color': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ওয়ালেট'),
        backgroundColor: const Color(0xFF7B1FA2),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Balance Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF7B1FA2),
                    Color(0xFF4A148C),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'মোট ব্যালেন্স',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '৳ ৮,৭৫০',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF7B1FA2),
                          ),
                          onPressed: () {
                            Get.snackbar('আমানত', 'অ্যাকাউন্টে অর্থ যোগ করুন');
                          },
                          child: const Text('আমানত'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Get.snackbar('উত্তোলন', 'অর্থ উত্তোলন করুন');
                          },
                          child: const Text('উত্তোলন'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Transactions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'লেনদেনের ইতিহাস',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (transaction['color'] as Color)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            transaction['icon'] as IconData,
                            color: transaction['color'] as Color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                transaction['description'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                transaction['date'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          transaction['amount'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: transaction['color'] as Color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
