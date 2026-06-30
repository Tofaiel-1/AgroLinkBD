import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/models/order_model.dart';
import 'package:agrolinkbd/core/models/cart_model.dart';
import 'package:agrolinkbd/core/providers/cart_provider.dart';
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
  double _quantity = 1.0;
  late TextEditingController _quantityController;
  bool _allowFraction = true;

  @override
  void initState() {
    super.initState();
    final cat = widget.product['category'] ?? '';
    final unit = widget.product['unit'] ?? '';
    if (cat == 'meat' || cat == 'fish' || unit == 'পিছ' || unit == 'ডজন') {
      _allowFraction = false;
    }
    _quantityController = TextEditingController(text: _allowFraction ? '1.0' : '1');
    _quantityController.addListener(() {
      final val = double.tryParse(_quantityController.text);
      if (val != null && val > 0) {
        setState(() {
          _quantity = val;
        });
      }
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

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
                      onPressed: () {
                        double step = _allowFraction ? 0.5 : 1.0;
                        if (_quantity > step) {
                          _quantityController.text = (_quantity - step).toStringAsFixed(_allowFraction ? 1 : 0);
                        }
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: _quantityController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.numberWithOptions(decimal: _allowFraction),
                        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600, fontSize: 16),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        double step = _allowFraction ? 0.5 : 1.0;
                        _quantityController.text = (_quantity + step).toStringAsFixed(_allowFraction ? 1 : 0);
                      },
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
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF1976D2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      final cartProvider = Provider.of<CartProvider>(context, listen: false);
                      cartProvider.addToCart(CartItem(
                        id: widget.product['id']?.toString() ?? widget.product['name']?.toString() ?? DateTime.now().toString(),
                        title: widget.product['name'] ?? 'Product',
                        price: price,
                        unit: widget.product['unit'] ?? 'কেজি',
                        quantity: _quantity,
                        imageUrl: imageUrl,
                        itemType: CartItemType.product,
                        sellerId: widget.product['farmerId'] ?? widget.product['userId'] ?? 'unknown_farmer',
                        sellerName: widget.product['farmer'] ?? widget.product['seller'] ?? 'AgroLink Farm',
                        sellerRole: 'farmer',
                      ));
                      Navigator.pop(context);
                      Get.snackbar(
                        'কার্টে যোগ করা হয়েছে',
                        '${widget.product['name']} কার্টে যোগ করা হয়েছে।',
                        backgroundColor: Colors.green.shade100,
                        colorText: Colors.green.shade900,
                      );
                    },
                    child: Text(
                      'কার্টে যোগ করুন',
                      style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: const Color(0xFF1976D2), fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
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
                      'অর্ডার করুন',
                      style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
