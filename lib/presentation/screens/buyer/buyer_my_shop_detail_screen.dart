import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/buyer_inventory_model.dart';
import 'package:intl/intl.dart';

class BuyerMyShopDetailScreen extends StatelessWidget {
  final BuyerInventoryModel item;

  const BuyerMyShopDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        title: Text(
          'ইনভেন্টরি বিবরণ',
          style: GoogleFonts.hindSiliguri(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image Header
            Container(
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: item.image != null && item.image!.isNotEmpty
                      ? NetworkImage(item.image!)
                      : const NetworkImage('https://via.placeholder.com/400'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                alignment: Alignment.bottomLeft,
                child: Text(
                  item.productName,
                  style: GoogleFonts.hindSiliguri(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Status & Quantity Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('মজুদ পরিমাণ', '${item.quantity} ${item.unit}', Icons.inventory_2),
                        _buildStatItem('স্ট্যাটাস', item.status, Icons.info_outline),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Financial Details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'আর্থিক বিবরণী',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const Divider(height: 24),
                        _buildDetailRow('ক্রয় মূল্য (প্রতি ${item.unit})', '৳${item.purchasePrice}'),
                        const SizedBox(height: 12),
                        _buildDetailRow('বর্তমান বাজার মূল্য (প্রতি ${item.unit})', '৳${item.currentMarketPrice}', isHighlight: true),
                        const Divider(height: 24),
                        _buildDetailRow('মোট ক্রয় মূল্য', '৳${(item.purchasePrice * item.quantity).toStringAsFixed(2)}'),
                        const SizedBox(height: 12),
                        _buildDetailRow('মোট আনুমানিক মূল্য', '৳${item.estimatedValue.toStringAsFixed(2)}', isHighlight: true),
                        const Divider(height: 24),
                        _buildGainLossRow(item.estimatedGain),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Other Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'অন্যান্য তথ্য',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const Divider(height: 24),
                        _buildDetailRow('ক্রয়ের তারিখ', DateFormat('dd MMM yyyy, hh:mm a').format(item.purchaseDate)),
                        const SizedBox(height: 12),
                        _buildDetailRow('সরবরাহকারী', item.supplierName ?? 'অজানা'),
                        const SizedBox(height: 12),
                        _buildDetailRow('অবস্থান', item.location),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                  // Read Only Disclaimer
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'এটি আপনার কেনা পণ্যের ডিজিটাল রেকর্ড। আপনি এই পণ্য মার্কেটপ্লেসে বিক্রয় করতে পারবেন না।',
                            style: GoogleFonts.hindSiliguri(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF1B5E20), size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.hindSiliguri(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.hindSiliguri(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isHighlight ? const Color(0xFF1B5E20) : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildGainLossRow(double gain) {
    final isPositive = gain >= 0;
    final color = isPositive ? Colors.teal.shade700 : Colors.red.shade700;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'সম্ভাব্য লাভ/ক্ষতি',
          style: GoogleFonts.hindSiliguri(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(
              '${isPositive ? '+' : ''}৳${gain.toStringAsFixed(2)}',
              style: GoogleFonts.hindSiliguri(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
