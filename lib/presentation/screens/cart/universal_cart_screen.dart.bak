import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/models/cart_model.dart';
import 'universal_checkout_screen.dart';

class UniversalCartScreen extends StatefulWidget {
  const UniversalCartScreen({super.key});

  @override
  State<UniversalCartScreen> createState() => _UniversalCartScreenState();
}

class _UniversalCartScreenState extends State<UniversalCartScreen> {
  // Mock data representing a universal cart
  final List<CartItem> cartItems = [
    // Bought from Farmer (Vegetables)
    CartItem(
      id: 'p1',
      title: 'তাজা টমেটো',
      price: 40,
      unit: 'কেজি',
      quantity: 50,
      imageUrl: '🍅', // Using emoji for placeholder
      itemType: CartItemType.product,
      sellerId: 'f1',
      sellerName: 'করিম ফার্ম',
      sellerRole: 'farmer',
    ),
    // Bought from Company (Pesticide)
    CartItem(
      id: 's1',
      title: 'ইউরিয়া সার',
      price: 1200,
      unit: 'বস্তা',
      quantity: 2,
      imageUrl: '🌾',
      itemType: CartItemType.supply,
      sellerId: 'c1',
      sellerName: 'বিসিআইসি ডিলার',
      sellerRole: 'company',
    ),
    // Hired Service (Tractor)
    CartItem(
      id: 'm1',
      title: 'ট্রাক্টর ভাড়া',
      price: 1500,
      unit: 'ঘণ্টা',
      quantity: 3,
      imageUrl: '🚜',
      itemType: CartItemType.machinery,
      sellerId: 'sp1',
      sellerName: 'রহিম মেকানিক্স',
      sellerRole: 'serviceProvider',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Group items by seller
    final Map<String, List<CartItem>> groupedItems = {};
    for (var item in cartItems) {
      if (!groupedItems.containsKey(item.sellerName)) {
        groupedItems[item.sellerName] = [];
      }
      groupedItems[item.sellerName]!.add(item);
    }

    final subtotal = cartItems.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('কার্ট 🛒'),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0.5,
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart(isDark)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: groupedItems.length,
                    itemBuilder: (context, index) {
                      final sellerName = groupedItems.keys.elementAt(index);
                      final items = groupedItems[sellerName]!;
                      return _buildSellerGroup(sellerName, items, isDark);
                    },
                  ),
                ),
                _buildCheckoutFooter(subtotal, isDark),
              ],
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
            'আপনার কার্ট খালি',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white54 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerGroup(String sellerName, List<CartItem> items, bool isDark) {
    final primaryColor = isDark ? Colors.green.shade700 : const Color(0xFF2E7D32);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seller Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.storefront, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  sellerName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: primaryColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    items.first.sellerRole.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Items
          ...items.map((item) => _buildCartItem(item, isDark)).toList(),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji/Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(item.imageUrl, style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '৳${item.price} / ${item.unit}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                // Qty controls
                Row(
                  children: [
                    _buildQtyButton(Icons.remove, isDark, () {
                      if (item.quantity > 1) {
                        setState(() => item.quantity--);
                      }
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    _buildQtyButton(Icons.add, isDark, () {
                      setState(() => item.quantity++);
                    }),
                  ],
                ),
              ],
            ),
          ),
          // Price & Action
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '৳${item.totalPrice}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  setState(() => cartItems.remove(item));
                },
                child: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 22),
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
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark ? Colors.white12 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: isDark ? Colors.white70 : Colors.grey.shade700),
      ),
    );
  }

  Widget _buildCheckoutFooter(double subtotal, bool isDark) {
    return Container(
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
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'মোট মূল্য (ডেলিভারি ছাড়া)',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                ),
                Text(
                  '৳$subtotal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => UniversalCheckoutScreen(cartItems: cartItems, subtotal: subtotal));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'চেকআউট করুন',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
