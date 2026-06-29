import os

target_dir = "lib/presentation/widgets"
os.makedirs(target_dir, exist_ok=True)
target_file = os.path.join(target_dir, "quick_buy_bottom_sheet.dart")

widget_code = """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/models/order_model.dart';
import 'package:agrolinkbd/core/services/order_service.dart';
import 'package:agrolinkbd/core/services/sslcommerz_service.dart';
import 'package:agrolinkbd/presentation/screens/buyer/buyer_orders_screen.dart';

class QuickBuyBottomSheet extends StatefulWidget {
  final Map<String, dynamic> product;

  const QuickBuyBottomSheet({Key? key, required this.product}) : super(key: key);

  @override
  State<QuickBuyBottomSheet> createState() => _QuickBuyBottomSheetState();
}

class _QuickBuyBottomSheetState extends State<QuickBuyBottomSheet> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    // Parse price dynamically
    double price = 0.0;
    if (widget.product['price'] != null) {
      if (widget.product['price'] is String) {
        price = double.tryParse(widget.product['price'].toString()) ?? 0.0;
      } else {
        price = (widget.product['price'] as num).toDouble();
      }
    }
    
    final totalAmount = price * _quantity;
    
    // Parse image
    String imageUrl = widget.product['image'] ?? widget.product['imageUrl'] ?? 'https://via.placeholder.com/150';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'অর্ডার কনফার্ম করুন',
            style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product['name'] ?? 'Product',
                      style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    Text(
                      '৳$price / ${widget.product['unit'] ?? 'কেজি'}',
                      style: GoogleFonts.hindSiliguri(color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'পরিমাণ:',
                style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      '$_quantity',
                      style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _quantity++),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'মোট মূল্য:',
                style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              Text(
                '৳$totalAmount',
                style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final success = await SSLCommerzService.initiatePayment(
                  context: context,
                  amount: totalAmount,
                  productName: widget.product['name'] ?? 'Product',
                  customerName: "Buyer User",
                  customerEmail: "buyer@example.com",
                  customerPhone: "01700000000",
                  customerAddress: "Dhaka, Bangladesh",
                );

                if (success) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    final newOrder = OrderModel(
                      id: '',
                      buyerId: user.uid,
                      farmerId: widget.product['farmerId'] ?? widget.product['userId'] ?? 'unknown_farmer',
                      farmerName: widget.product['farmer'] ?? widget.product['seller'] ?? 'AgroLink Farm',
                      productName: widget.product['name'] ?? 'Product',
                      productImageUrl: imageUrl,
                      quantity: _quantity,
                      totalAmount: totalAmount,
                      status: 'pending',
                      statusStep: 1,
                      transportStatus: 'অর্ডার গৃহিত হয়েছে',
                      paymentStatus: 'paid',
                      createdAt: DateTime.now(),
                      estimatedDeliveryDate: DateTime.now().add(const Duration(days: 3)),
                    );

                    final orderId = await OrderService().createOrder(newOrder);
                    if (orderId != null) {
                      Navigator.pop(context); // close bottom sheet
                      Get.off(() => const BuyerOrdersScreen());
                    }
                  }
                }
              },
              child: Text(
                'পেমেন্ট করুন (SSLCommerz)',
                style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
"""

with open(target_file, 'w', encoding='utf-8') as f:
    f.write(widget_code)

print("Created quick_buy_bottom_sheet.dart")
