import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/core/services/sslcommerz_service.dart';
import 'package:agrolinkbd/core/models/cart_model.dart';
import 'package:agrolinkbd/core/providers/cart_provider.dart';

/// Inputs Store Screen - Farmers buy seeds, fertilizers, equipment
class InputsStoreScreen extends StatefulWidget {
  const InputsStoreScreen({super.key});

  @override
  State<InputsStoreScreen> createState() => _InputsStoreScreenState();
}

class _InputsStoreScreenState extends State<InputsStoreScreen> {
  final List<Map<String, dynamic>> items = [
    {
      'id': 1,
      'name': 'উচ্চ ফলনশীল টমেটো বীজ',
      'category': 'বীজ',
      'price': 550.0,
      'priceText': '৳ ৫৫০',
      'rating': '4.8',
      'reviews': '১২৫',
      'provider': 'গ্রীন ফার্ম সিড কোম্পানি',
      'image': 'https://images.unsplash.com/photo-1592997572594-34afe4facfb5?w=400&q=80',
    },
    {
      'id': 2,
      'name': 'জৈব সার (৫০ কেজি)',
      'category': 'সার',
      'price': 1200.0,
      'priceText': '৳ ১,২০০',
      'rating': '4.6',
      'reviews': '৮৯',
      'provider': 'ইকো এগ্রো প্রোডাক্টস',
      'image': 'https://images.unsplash.com/photo-1586773860383-55abbfa112e4?w=400&q=80',
    },
    {
      'id': 3,
      'name': 'স্প্রে পাম্প (২০ লিটার)',
      'category': 'সরঞ্জাম',
      'price': 2500.0,
      'priceText': '৳ ২,৫০০',
      'rating': '4.7',
      'reviews': '৬৫',
      'provider': 'এগ্রো সাপ্লাই কেন্দ্র',
      'image': 'https://images.unsplash.com/photo-1589923188900-85dae523342b?w=400&q=80',
    },
  ];

  Future<void> _buyNowWithSsl(Map<String, dynamic> item) async {
    final user = FirebaseAuth.instance.currentUser;
    final amount = (item['price'] as num).toDouble();

    final success = await SSLCommerzService.initiatePayment(
      context: context,
      amount: amount,
      productName: item['name'] as String,
      customerName: user?.displayName ?? 'Farmer User',
      customerEmail: user?.email ?? 'farmer@agrolinkbd.com',
      customerPhone: user?.phoneNumber ?? '01700000000',
      customerAddress: 'Bangladesh',
    );

    if (success) {
      Get.snackbar(
        'পেমেন্ট সফল! 🎉',
        '${item['name']} সফলভাবে অর্ডার সম্পন্ন হয়েছে। সরবরাহকারী দ্রুত ডেলিভারি করবে।',
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('কৃষি ইনপুট স্টোর', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Product image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.eco,
                      color: Colors.green,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Product details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] as String,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['provider'] as String,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${item['rating']} (${item['reviews']})',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              item['priceText'] as String,
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 34,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFF2E7D32)),
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                    final cartProvider = Provider.of<CartProvider>(context, listen: false);
                                    cartProvider.addToCart(CartItem(
                                      id: 'input_${item['id']}',
                                      title: item['name'] as String,
                                      price: (item['price'] as num).toDouble(),
                                      unit: 'পিস',
                                      quantity: 1,
                                      imageUrl: item['image'] ?? '',
                                      itemType: CartItemType.service,
                                      sellerId: 'input_supplier_${item['id']}',
                                      sellerName: item['provider'] as String,
                                      sellerRole: 'supplier',
                                    ));
                                    Get.snackbar(
                                      'কার্টে যোগ করা হয়েছে',
                                      '${item['name']} কার্টে যোগ করা হয়েছে',
                                      backgroundColor: Colors.green.shade50,
                                      colorText: Colors.green.shade900,
                                    );
                                  },
                                  child: Text(
                                    'কার্টে যোগ',
                                    style: GoogleFonts.hindSiliguri(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2E7D32),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 34,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2E7D32),
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () => _buyNowWithSsl(item),
                                  icon: const Icon(Icons.flash_on, size: 14, color: Colors.amberAccent),
                                  label: Text(
                                    'সরাসরি কিনুন',
                                    style: GoogleFonts.hindSiliguri(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
