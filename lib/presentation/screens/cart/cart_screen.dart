import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:agrolinkbd/core/providers/cart_provider.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/utils/number_converter.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final isBn = LanguageProvider.isBn(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isBn ? 'শপিং কার্ট 🛒' : 'Shopping Cart 🛒'),
        elevation: 0,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          if (cartProvider.itemCount == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isBn ? 'আপনার কার্ট খালি' : 'Your cart is empty',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isBn ? 'পণ্য যুক্ত করে কেনাকাটা শুরু করুন' : 'Add products to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.shopping_bag),
                    label: Text(isBn ? 'কেনাকাটা চালিয়ে যান' : 'Continue Shopping'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Cart Items
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  itemCount: cartProvider.itemCount,
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    return _buildCartItemCard(context, item, cartProvider);
                  },
                ),

                // Summary Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
                    border: Border(
                      top: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.grey.shade300),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item Count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isBn
                                ? 'সাবটোটাল (${BanglaEnglishNumberHelper.toBanglaDigits(cartProvider.itemCount)}টি পণ্য)'
                                : 'Subtotal (${cartProvider.itemCount} items)',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            isBn
                                ? '৳${BanglaEnglishNumberHelper.toBanglaDigits(cartProvider.totalPrice.toStringAsFixed(0))}'
                                : '৳${cartProvider.totalPrice.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Delivery Fee
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isBn ? 'ডেলিভারি চার্জ' : 'Delivery Fee',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            isBn ? '৳৫০ - ৳১০০' : '৳50 - ৳100',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Divider
                      Divider(color: isDark ? const Color(0xFF334155) : Colors.grey.shade400),
                      const SizedBox(height: 12),

                      // Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isBn ? 'মোট সর্বমোট' : 'Total',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            isBn
                                ? '৳${BanglaEnglishNumberHelper.toBanglaDigits((cartProvider.totalPrice + 75).toStringAsFixed(0))}'
                                : '৳${(cartProvider.totalPrice + 75).toStringAsFixed(0)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2E7D32),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Checkout Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CheckoutScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isBn ? 'চেকআউট ও পেমেন্ট করুন 🚀' : 'Proceed to Checkout 🚀',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Continue Shopping Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(isBn ? 'আরও কেনাকাটা করুন' : 'Continue Shopping'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCartItemCard(
      BuildContext context, var item, CartProvider cartProvider) {
    final isBn = LanguageProvider.isBn(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                width: 80,
                height: 80,
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  isBn
                      ? '৳${BanglaEnglishNumberHelper.toBanglaDigits(item.price.toStringAsFixed(0))}/${item.unit}'
                      : '৳${item.price.toStringAsFixed(0)}/${item.unit}',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                ),
                const SizedBox(height: 8),

                // Quantity Controls & Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity Buttons
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark ? const Color(0xFF475569) : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              cartProvider.updateQuantity(
                                item.productId,
                                item.quantity - 1,
                              );
                            },
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: Icon(
                                Icons.remove,
                                size: 14,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          Container(
                            width: 30,
                            alignment: Alignment.center,
                            child: Text(
                              isBn
                                  ? BanglaEnglishNumberHelper.toBanglaDigits(item.quantity)
                                  : '${item.quantity}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              cartProvider.updateQuantity(
                                item.productId,
                                item.quantity + 1,
                              );
                            },
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: Icon(
                                Icons.add,
                                size: 14,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Total Price & Delete
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isBn
                              ? '৳${BanglaEnglishNumberHelper.toBanglaDigits(item.totalPrice.toStringAsFixed(0))}'
                              : '৳${item.totalPrice.toStringAsFixed(0)}',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2E7D32),
                                  ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () {
                            cartProvider.removeFromCart(item.productId);
                          },
                          child: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.red.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
