import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/marketplace/ssl_payment_mock_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const CheckoutScreen({super.key, required this.product});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final isBn = LanguageProvider.isBn(context);
    const Color oceanBlue = Color(0xFF0288D1);
    final double subtotal = widget.product['price'] * _quantity;
    const double deliveryFee = 150.0;
    final double total = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          isBn ? 'চেকআউট' : 'Checkout',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: oceanBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isBn ? 'অর্ডারের বিবরণ' : 'Order Details',
              style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(widget.product['imageIcon'], size: 40, color: oceanBlue),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product['name'],
                            style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '৳${widget.product['price'].toStringAsFixed(0)} ${isBn ? "/ ইউনিট" : "/ unit"}',
                            style: GoogleFonts.poppins(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isBn ? 'পরিমাণ নির্ধারণ করুন' : 'Select Quantity',
              style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (_quantity > 1) setState(() => _quantity--);
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 40,
                  color: oceanBlue,
                ),
                const SizedBox(width: 20),
                Text(
                  '$_quantity',
                  style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 20),
                IconButton(
                  onPressed: () {
                    setState(() => _quantity++);
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 40,
                  color: oceanBlue,
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              isBn ? 'পেমেন্ট বিবরণী' : 'Payment Summary',
              style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isBn ? 'সাবটোটাল' : 'Subtotal', style: GoogleFonts.hindSiliguri(fontSize: 16)),
                      Text('৳${subtotal.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isBn ? 'ডেলিভারি ফি' : 'Delivery Fee', style: GoogleFonts.hindSiliguri(fontSize: 16)),
                      Text('৳${deliveryFee.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 16)),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isBn ? 'সর্বমোট' : 'Total', style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        '৳${total.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: oceanBlue),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => SSLPaymentMockScreen(
                    totalAmount: total,
                    productName: widget.product['name'],
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: oceanBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isBn ? 'পেমেন্ট করুন (SSL Commerz)' : 'Pay Now (SSL Commerz)',
                  style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

