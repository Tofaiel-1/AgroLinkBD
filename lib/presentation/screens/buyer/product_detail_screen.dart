import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/services/sslcommerz_service.dart';
import 'package:agrolinkbd/core/models/order_model.dart';
import 'package:agrolinkbd/core/services/order_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/presentation/screens/buyer/buyer_orders_screen.dart';

/// Product Detail Screen - View product details and place order
class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('পণ্য বিবরণ'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.blue.withOpacity(0.1),
              child: widget.product['image'] != null
                  ? Image.network(
                      widget.product['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.shopping_basket,
                        color: Colors.blue,
                        size: 80,
                      ),
                    )
                  : const Icon(
                      Icons.shopping_basket,
                      color: Colors.blue,
                      size: 80,
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Price
                  Text(
                    widget.product['name'] ?? 'Product',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '৳ ${widget.product['price']}/${widget.product['unit'] ?? 'কেজি'}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 18, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.product['rating'] ?? 0.0}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Farmer Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product['farmer'] ?? 'Unknown Farmer',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.product['location'] ?? 'Unknown Location',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Get.snackbar(
                                'অনুসরণ করুন', 'ফার্মার অনুসরণ করা হয়েছে');
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('অনুসরণ'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'বিবরণ',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'সম্পূর্ণ জৈব পদ্ধতিতে চাষ করা তাজা টমেটো। কোন রাসায়নিক সার বা কীটনাশক ব্যবহার করা হয়নি। সরাসরি খামার থেকে আপনার দোকানে।',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Availability
                  Text(
                    'উপলব্ধতা: ১০০ কেজি',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quantity Selector
                  Row(
                    children: [
                      Text(
                        'পরিমাণ:',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                              icon: const Icon(Icons.remove),
                              iconSize: 16,
                            ),
                            Text(
                              '$_quantity',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(() => _quantity++),
                              icon: const Icon(Icons.add),
                              iconSize: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.blue),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            Get.snackbar(
                              'কার্টে যোগ করা হয়েছে',
                              '$_quantity কেজি টমেটো যোগ করা হয়েছে',
                            );
                          },
                          child: Text(
                            'কার্টে যোগ করুন',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            final success = await SSLCommerzService.initiatePayment(
                              context: context,
                              amount: (widget.product['price'] as num).toDouble() * _quantity,
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
                                  farmerId: widget.product['farmerId'] ?? 'unknown_farmer',
                                  farmerName: widget.product['farmer'] ?? 'AgroLink Farm',
                                  productName: widget.product['name'] ?? 'Unknown Product',
                                  productImageUrl: widget.product['image'] ?? '',
                                  quantity: _quantity,
                                  totalAmount: (widget.product['price'] as num).toDouble() * _quantity,
                                  status: 'pending',
                                  statusStep: 1,
                                  transportStatus: 'অর্ডার গৃহীত হয়েছে',
                                  paymentStatus: 'paid',
                                  createdAt: DateTime.now(),
                                  estimatedDeliveryDate: DateTime.now().add(const Duration(days: 3)),
                                );
                                
                                final orderId = await OrderService().createOrder(newOrder);
                                if (orderId != null) {
                                  Get.off(() => const BuyerOrdersScreen());
                                }
                              }
                            }
                          },
                          child: Text(
                            'অর্ডার করুন',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
  }
}
