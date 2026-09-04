import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/core/providers/cart_provider.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/utils/number_converter.dart';
import 'package:agrolinkbd/core/models/cart_model.dart';
import 'package:agrolinkbd/core/models/order_model.dart';
import 'package:agrolinkbd/core/services/order_service.dart';
import 'package:agrolinkbd/core/services/sslcommerz_service.dart';
import 'package:agrolinkbd/presentation/screens/buyer/fish_buyer_orders_screen.dart';

/// Shopping Cart Screen — Modern cart UI for buyer linked to CartProvider with full English & Bangla support
class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  final TextEditingController _specialInstructionsController = TextEditingController();

  @override
  void dispose() {
    _specialInstructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBn = LanguageProvider.isBn(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items;

    final double subtotal = cartProvider.totalPrice;
    final double shipping = cartItems.isEmpty ? 0.0 : 150.0;
    final double total = subtotal + shipping;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: cartItems.isEmpty
            ? _buildEmptyCart(isDark, isBn)
            : Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (Navigator.canPop(context))
                              Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: Icon(
                                    Icons.arrow_back,
                                    size: 22,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            Text(
                              isBn ? 'কার্ট 🛒' : 'Shopping Cart 🛒',
                              style: isBn
                                  ? GoogleFonts.hindSiliguri(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    )
                                  : GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isBn
                                    ? '${BanglaEnglishNumberHelper.format(cartItems.length, true)}টি আইটেম'
                                    : '${cartItems.length} items',
                                style: isBn
                                    ? GoogleFonts.hindSiliguri(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1976D2),
                                      )
                                    : GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1976D2),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.delete_sweep_outlined, color: Colors.red.shade400),
                              tooltip: isBn ? 'কার্ট খালি করুন' : 'Clear Cart',
                              onPressed: () => _showClearCartConfirmDialog(context, cartProvider, isBn),
                            ),
                          ],
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
                        return _buildCartItem(cartItems[index], cartProvider, isDark, isBn);
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
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Special Instructions
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white12 : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade200),
                          ),
                          child: TextField(
                            controller: _specialInstructionsController,
                            style: isBn
                                ? GoogleFonts.hindSiliguri(
                                    fontSize: 14,
                                    color: isDark ? Colors.white : Colors.black87,
                                  )
                                : GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                            decoration: InputDecoration(
                              hintText: isBn
                                  ? 'বিশেষ নির্দেশনা (যেমন: বরফ দিয়ে প্যাক করবেন)'
                                  : 'Special instructions (e.g., pack with ice)',
                              hintStyle: isBn
                                  ? GoogleFonts.hindSiliguri(
                                      color: isDark ? Colors.white54 : Colors.grey.shade400,
                                    )
                                  : GoogleFonts.poppins(
                                      color: isDark ? Colors.white54 : Colors.grey.shade400,
                                      fontSize: 12,
                                    ),
                              border: InputBorder.none,
                              icon: const Icon(Icons.info_outline, color: Color(0xFF1976D2), size: 20),
                            ),
                          ),
                        ),
                        _buildSummaryRow(
                          isBn ? 'মূল্য' : 'Subtotal',
                          '৳${BanglaEnglishNumberHelper.format(subtotal.toStringAsFixed(0), isBn)}',
                          isDark,
                          isBn,
                        ),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          isBn ? 'ডেলিভারি চার্জ' : 'Delivery Fee',
                          '৳${BanglaEnglishNumberHelper.format(shipping.toStringAsFixed(0), isBn)}',
                          isDark,
                          isBn,
                        ),
                        const SizedBox(height: 12),
                        Divider(
                          color: isDark ? Colors.white12 : Colors.grey.shade200,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isBn ? 'মোট' : 'Total',
                              style: isBn
                                  ? GoogleFonts.hindSiliguri(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    )
                                  : GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                            ),
                            Text(
                              '৳${BanglaEnglishNumberHelper.format(total.toStringAsFixed(0), isBn)}',
                              style: GoogleFonts.poppins(
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
                            onPressed: () => _handleCheckout(context, cartProvider, total, isBn),
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
                                const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  isBn ? 'চেকআউট করুন' : 'Proceed to Checkout',
                                  style: isBn
                                      ? GoogleFonts.hindSiliguri(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        )
                                      : GoogleFonts.poppins(
                                          fontSize: 15,
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

  Widget _buildEmptyCart(bool isDark, bool isBn) {
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
            isBn ? 'কার্ট খালি' : 'Your cart is empty',
            style: isBn
                ? GoogleFonts.hindSiliguri(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white54 : Colors.grey.shade500,
                  )
                : GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white54 : Colors.grey.shade500,
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            isBn ? 'বাজার থেকে পণ্য যোগ করুন' : 'Explore marketplace and add fresh fish',
            style: isBn
                ? GoogleFonts.hindSiliguri(
                    fontSize: 14,
                    color: isDark ? Colors.white38 : Colors.grey.shade400,
                  )
                : GoogleFonts.poppins(
                    fontSize: 13,
                    color: isDark ? Colors.white38 : Colors.grey.shade400,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, CartProvider cartProvider, bool isDark, bool isBn) {
    final bool allowFraction = !(item.unit == 'পিছ' || item.unit == 'ডজন' || item.itemType == CartItemType.transport);

    final List<dynamic> history = (item.metadata['history'] is List)
        ? (item.metadata['history'] as List)
        : [item.metadata['addedAt'] ?? DateTime.now().toIso8601String()];
    final String latestTimeStr = history.isNotEmpty ? history.last.toString() : '';
    final String formattedTime = _formatBanglaDateTime(latestTimeStr, isBn);

    return Dismissible(
      key: ValueKey('${item.id}_${item.title}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              isBn ? 'মুছে ফেলুন' : 'Remove',
              style: isBn
                  ? GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold)
                  : GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.delete_outline, color: Colors.white),
          ],
        ),
      ),
      onDismissed: (_) {
        cartProvider.removeFromCart(item.id);
        Get.snackbar(
          isBn ? 'সরানো হয়েছে' : 'Removed',
          isBn ? '${item.title} কার্ট থেকে সরানো হয়েছে' : '${item.title} removed from cart',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          duration: const Duration(seconds: 2),
        );
      },
      child: Container(
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
                    color: Colors.black.withValues(alpha: 0.03),
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
                    style: isBn
                        ? GoogleFonts.hindSiliguri(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                          )
                        : GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.sellerName,
                    style: isBn
                        ? GoogleFonts.hindSiliguri(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.grey.shade500,
                          )
                        : GoogleFonts.poppins(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.grey.shade500,
                          ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => _showAddHistoryDialog(context, item, isDark, isBn),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1976D2).withValues(alpha: 0.2) : const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF1976D2).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time, size: 12, color: Color(0xFF1976D2)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              isBn
                                  ? 'যোগ: $formattedTime${history.length > 1 ? ' (${BanglaEnglishNumberHelper.format(history.length, true)} বার)' : ''}'
                                  : 'Added: $formattedTime${history.length > 1 ? ' (${history.length} times)' : ''}',
                              style: isBn
                                  ? GoogleFonts.hindSiliguri(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1976D2),
                                    )
                                  : GoogleFonts.poppins(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1976D2),
                                    ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.info_outline, size: 12, color: Color(0xFF1976D2)),
                        ],
                      ),
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
                          '${BanglaEnglishNumberHelper.format(item.quantity.toStringAsFixed(allowFraction ? 1 : 0), isBn)} ${item.unit}',
                          style: isBn
                              ? GoogleFonts.hindSiliguri(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: isDark ? Colors.white : Colors.black87,
                                )
                              : GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
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
                  '৳${BanglaEnglishNumberHelper.format(item.totalPrice.toStringAsFixed(0), isBn)}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: const Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '৳${BanglaEnglishNumberHelper.format(item.price.toStringAsFixed(0), isBn)}/${item.unit}',
                  style: isBn
                      ? GoogleFonts.hindSiliguri(
                          fontSize: 10,
                          color: isDark ? Colors.white38 : Colors.grey.shade400,
                        )
                      : GoogleFonts.poppins(
                          fontSize: 10,
                          color: isDark ? Colors.white38 : Colors.grey.shade400,
                        ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    cartProvider.removeFromCart(item.id);
                    Get.snackbar(
                      isBn ? 'সরানো হয়েছে' : 'Removed',
                      isBn ? '${item.title} কার্ট থেকে সরানো হয়েছে' : '${item.title} removed from cart',
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
        child: Icon(icon, size: 16, color: isDark ? Colors.white70 : Colors.grey.shade700),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark, bool isBn) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBn
              ? GoogleFonts.hindSiliguri(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                )
              : GoogleFonts.poppins(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }

  Future<void> _handleCheckout(
    BuildContext context,
    CartProvider cartProvider,
    double total,
    bool isBn,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar(
        isBn ? 'অনুরোধ বাতিল' : 'Authentication Required',
        isBn ? 'দয়া করে আগে লগইন করুন' : 'Please log in first to continue checkout',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    final success = await SSLCommerzService.initiatePayment(
      context: context,
      amount: total,
      productName: cartProvider.items.map((e) => e.title).join(', '),
      customerName: user.displayName ?? 'Buyer User',
      customerEmail: user.email ?? 'buyer@example.com',
      customerPhone: '01700000000',
      customerAddress: 'Dhaka, Bangladesh',
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
          transportStatus: isBn ? 'অর্ডার গৃহিত হয়েছে' : 'Order Placed',
          paymentStatus: 'paid',
          createdAt: DateTime.now(),
          estimatedDeliveryDate: DateTime.now().add(const Duration(days: 3)),
          specialInstructions: _specialInstructionsController.text.trim().isEmpty
              ? null
              : _specialInstructionsController.text.trim(),
        );
        await OrderService().createOrder(newOrder);
      }

      cartProvider.clearCart();
      Get.snackbar(
        isBn ? 'সফল ✓' : 'Success ✓',
        isBn ? 'আপনার পেমেন্ট ও অর্ডার সফলভাবে সম্পন্ন হয়েছে!' : 'Payment and orders placed successfully!',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );

      // Navigate to My Orders
      Get.to(() => const FishBuyerOrdersScreen());
    } else {
      Get.snackbar(
        isBn ? 'পেমেন্ট ব্যর্থ' : 'Payment Failed',
        isBn ? 'পেমেন্ট সম্পন্ন করা যায়নি। অনুগ্রহ করে আবার চেষ্টা করুন।' : 'Payment could not be completed. Please try again.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  String _formatBanglaDateTime(String? isoStr, bool isBn) {
    if (isoStr == null || isoStr.isEmpty) {
      return isBn ? 'সময় পাওয়া যায়নি' : 'Time unavailable';
    }
    try {
      final dt = DateTime.parse(isoStr).toLocal();
      if (!isBn) {
        final monthsEn = [
          '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        int hour = dt.hour;
        final period = hour < 12 ? 'AM' : 'PM';
        if (hour == 0) hour = 12;
        if (hour > 12) hour -= 12;
        final minStr = dt.minute.toString().padLeft(2, '0');
        return '${dt.day} ${monthsEn[dt.month]} ${dt.year}, $hour:$minStr $period';
      }

      final List<String> months = [
        '', 'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
        'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
      ];
      final String month = months[dt.month];

      int hour = dt.hour;
      final String period = hour < 12 ? 'সকাল' : (hour < 16 ? 'দুপুর' : (hour < 18 ? 'বিকাল' : 'রাত'));
      if (hour == 0) hour = 12;
      if (hour > 12) hour -= 12;

      final dayBn = BanglaEnglishNumberHelper.toBanglaDigits('${dt.day}');
      final yearBn = BanglaEnglishNumberHelper.toBanglaDigits('${dt.year}');
      final hourBn = BanglaEnglishNumberHelper.toBanglaDigits('$hour');
      final minuteBn = BanglaEnglishNumberHelper.toBanglaDigits(dt.minute.toString().padLeft(2, '0'));

      return '$dayBn $month $yearBn, $period $hourBn:$minuteBn';
    } catch (e) {
      return isBn ? 'সাম্প্রতিক' : 'Recent';
    }
  }

  void _showAddHistoryDialog(BuildContext context, CartItem item, bool isDark, bool isBn) {
    final List<dynamic> history = (item.metadata['history'] is List)
        ? (item.metadata['history'] as List)
        : [item.metadata['addedAt'] ?? DateTime.now().toIso8601String()];

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.history, color: Color(0xFF1976D2), size: 24),
                  const SizedBox(width: 8),
                  Text(
                    isBn ? 'কার্টে যোগ করার ইতিহাস 🕒' : 'Cart Addition History 🕒',
                    style: isBn
                        ? GoogleFonts.hindSiliguri(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          )
                        : GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${isBn ? 'আইটেম' : 'Item'}: ${item.title} (${item.sellerName})',
                style: isBn
                    ? GoogleFonts.hindSiliguri(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                      )
                    : GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                      ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: history.length,
                  itemBuilder: (context, idx) {
                    final String timeStr = history[idx].toString();
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: const Color(0xFF1976D2).withValues(alpha: 0.15),
                        child: Text(
                          BanglaEnglishNumberHelper.format(idx + 1, isBn),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1976D2),
                          ),
                        ),
                      ),
                      title: Text(
                        _formatBanglaDateTime(timeStr, isBn),
                        style: isBn
                            ? GoogleFonts.hindSiliguri(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              )
                            : GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                      ),
                      subtitle: Text(
                        idx == 0
                            ? (isBn ? 'প্রথমবার কার্টে যোগ করা হয়েছে' : 'First added to cart')
                            : (isBn ? 'পরিমাণ পরিবর্তন করা হয়েছে' : 'Quantity updated'),
                        style: isBn
                            ? GoogleFonts.hindSiliguri(
                                fontSize: 12,
                                color: isDark ? Colors.white38 : Colors.grey.shade500,
                              )
                            : GoogleFonts.poppins(
                                fontSize: 11,
                                color: isDark ? Colors.white38 : Colors.grey.shade500,
                              ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isBn ? 'ঠিক আছে' : 'OK',
                    style: isBn
                        ? GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold)
                        : GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showClearCartConfirmDialog(BuildContext context, CartProvider cartProvider, bool isBn) {
    Get.defaultDialog(
      title: isBn ? 'কার্ট খালি করুন' : 'Clear Shopping Cart',
      titleStyle: isBn
          ? GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 18)
          : GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          isBn
              ? 'আপনি কি নিশ্চিত যে কার্টের সব আইটেম মুছে ফেলতে চান?'
              : 'Are you sure you want to remove all items from your cart?',
          style: isBn ? GoogleFonts.hindSiliguri(fontSize: 14) : GoogleFonts.poppins(fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ),
      textConfirm: isBn ? 'হ্যাঁ, খালি করুন' : 'Yes, Clear',
      textCancel: isBn ? 'না' : 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade600,
      onConfirm: () {
        cartProvider.clearCart();
        Get.back();
        Get.snackbar(
          isBn ? 'কার্ট খালি হয়েছে' : 'Cart Cleared',
          isBn ? 'আপনার কার্টের সব আইটেম সরানো হয়েছে' : 'All items have been removed from your cart',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      },
    );
  }
}
