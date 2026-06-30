import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/core/providers/cart_provider.dart';
import 'package:agrolinkbd/core/models/cart_model.dart';
import 'package:agrolinkbd/core/models/order_model.dart';
import 'package:agrolinkbd/core/services/order_service.dart';
import 'package:agrolinkbd/core/services/sslcommerz_service.dart';
import 'package:agrolinkbd/presentation/screens/buyer/buyer_orders_screen.dart';

/// Shopping Cart Screen — Modern cart UI for buyer linked to CartProvider
class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items;

    final double subtotal = cartProvider.totalPrice;
    final double shipping = cartItems.isEmpty ? 0.0 : 150.0;
    final double total = subtotal + shipping;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: cartItems.isEmpty
            ? _buildEmptyCart(isDark)
            : Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'কার্ট 🛒',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976D2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${cartItems.length}টি আইটেম',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1976D2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Cart items list
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        return _buildCartItem(cartItems[index], cartProvider, isDark);
                      },
                    ),
                  ),

                  // Summary & Checkout
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow('মূল্য', '৳${subtotal.toStringAsFixed(0)}', isDark),
                        const SizedBox(height: 8),
                        _buildSummaryRow('ডেলিভারি চার্জ', '৳${shipping.toStringAsFixed(0)}', isDark),
                        const SizedBox(height: 12),
                        Divider(
                          color: isDark ? Colors.white12 : Colors.grey.shade200,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'মোট',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              '৳${total.toStringAsFixed(0)}',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1976D2),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () => _handleCheckout(context, cartProvider, total),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1976D2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.shopping_bag_outlined,
                                    color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  'চেকআউট করুন',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyCart(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'কার্ট খালি',
            style: GoogleFonts.hindSiliguri(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white54 : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'বাজার থেকে পণ্য যোগ করুন',
            style: GoogleFonts.hindSiliguri(
              fontSize: 14,
              color: isDark ? Colors.white38 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, CartProvider cartProvider, bool isDark) {
    final bool allowFraction = !(item.unit == 'পিছ' || item.unit == 'ডজন' || item.itemType == CartItemType.transport);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade100,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 56,
              height: 56,
              color: Colors.grey.shade100,
              child: item.imageUrl.isNotEmpty && item.imageUrl.startsWith('http')
                  ? Image.network(
                      item.imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_basket, color: Colors.grey),
                    )
                  : const Icon(Icons.shopping_basket, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 14),
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.hindSiliguri(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.sellerName,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 8),
                // Quantity controls
                Row(
                  children: [
                    _buildQtyButton(Icons.remove, isDark, () {
                      double step = allowFraction ? 0.5 : 1.0;
                      if (item.quantity > step) {
                        cartProvider.updateQuantity(item.id, item.quantity - step);
                      } else {
                        cartProvider.removeFromCart(item.id);
                      }
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity.toStringAsFixed(allowFraction ? 1 : 0)} ${item.unit}',
                        style: GoogleFonts.hindSiliguri(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    _buildQtyButton(Icons.add, isDark, () {
                      double step = allowFraction ? 0.5 : 1.0;
                      cartProvider.updateQuantity(item.id, item.quantity + step);
                    }),
                  ],
                ),
              ],
            ),
          ),
          // Price + Delete
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '৳${item.totalPrice.toStringAsFixed(0)}',
                style: GoogleFonts.hindSiliguri(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: const Color(0xFF1976D2),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '৳${item.price.toStringAsFixed(0)}/${item.unit}',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 10,
                  color: isDark ? Colors.white38 : Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  cartProvider.removeFromCart(item.id);
                  Get.snackbar(
                    'সরানো হয়েছে',
                    '${item.title} কার্ট থেকে সরানো হয়েছে',
                    backgroundColor: Colors.red.shade100,
                    colorText: Colors.red.shade900,
                    duration: const Duration(seconds: 2),
                  );
                },
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red.shade400,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? Colors.white12 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16,
            color: isDark ? Colors.white70 : Colors.grey.shade700),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: 14,
            color: isDark ? Colors.white54 : Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.hindSiliguri(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }

  Future<void> _handleCheckout(BuildContext context, CartProvider cartProvider, double total) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar(
        'অনুরোধ বাতিল',
        'দয়া করে আগে লগইন করুন',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    final success = await SSLCommerzService.initiatePayment(
      context: context,
      amount: total,
      productName: cartProvider.items.map((e) => e.title).join(', '),
      customerName: user.displayName ?? "Buyer User",
      customerEmail: user.email ?? "buyer@example.com",
      customerPhone: "01700000000",
      customerAddress: "Dhaka, Bangladesh",
    );

    if (success) {
      // Loop through cart items and create order for each
      for (final item in cartProvider.items) {
        final newOrder = OrderModel(
          id: '',
          buyerId: user.uid,
          farmerId: item.sellerId,
          farmerName: item.sellerName,
          productName: item.title,
          productImageUrl: item.imageUrl,
          quantity: item.quantity,
          totalAmount: item.totalPrice,
          status: 'pending',
          statusStep: 1,
          transportStatus: 'অর্ডার গৃহিত হয়েছে',
          paymentStatus: 'paid',
          createdAt: DateTime.now(),
          estimatedDeliveryDate: DateTime.now().add(const Duration(days: 3)),
        );
        await OrderService().createOrder(newOrder);
      }

      cartProvider.clearCart();
      Get.snackbar(
        'সফল ✓',
        'আপনার পেমেন্ট ও অর্ডার সফলভাবে সম্পন্ন হয়েছে!',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );

      // Navigate to My Orders
      Get.off(() => const BuyerOrdersScreen());
    } else {
      Get.snackbar(
        'পেমেন্ট ব্যর্থ',
        'পেমেন্ট সম্পন্ন করা যায়নি। অনুগ্রহ করে আবার চেষ্টা করুন।',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }
}
