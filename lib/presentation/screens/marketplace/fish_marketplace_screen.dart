import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/presentation/screens/buyer/shopping_cart_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/core/models/order_model.dart';
import 'package:agrolinkbd/core/services/order_service.dart';
import 'package:agrolinkbd/core/services/sslcommerz_service.dart';
import 'package:agrolinkbd/presentation/screens/buyer/fish_buyer_orders_screen.dart';
import 'package:agrolinkbd/core/utils/responsive_helper.dart';
import 'package:agrolinkbd/core/providers/cart_provider.dart';
import 'package:agrolinkbd/core/models/cart_model.dart';

class FishMarketplaceScreen extends StatefulWidget {
  const FishMarketplaceScreen({super.key});

  @override
  State<FishMarketplaceScreen> createState() => _FishMarketplaceScreenState();
}

class _FishMarketplaceScreenState extends State<FishMarketplaceScreen> {
  String _selectedCategory = 'সব';
  String _sortBy = 'popular';
  int _currentBannerIndex = 0;

  final List<String> _banners = [
    'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=1000&auto=format&fit=crop&q=80', // Fresh fish market
    'https://images.unsplash.com/photo-1516815231560-8f41ec531527?w=1000&auto=format&fit=crop&q=80', // Fishing boats
  ];

  final List<Map<String, dynamic>> _categories = [
    {'label': 'সব', 'key': 'all', 'icon': Icons.set_meal},
    {'label': 'মিঠা পানির মাছ', 'key': 'sweet_water', 'icon': Icons.water},
    {'label': 'সামুদ্রিক মাছ', 'key': 'sea_water', 'icon': Icons.waves},
    {'label': 'জীবন্ত মাছ', 'key': 'live', 'icon': Icons.pool},
    {'label': 'বরফ ঢাকা', 'key': 'frozen', 'icon': Icons.ac_unit},
    {'label': 'শুটকি', 'key': 'dry', 'icon': Icons.sunny},
  ];

  final List<String> _fishImages = [
    'https://images.unsplash.com/photo-1534483509719-3feaee7c30da?w=600&auto=format&fit=crop&q=80', // Rui / Fresh fish
    'https://images.unsplash.com/photo-1510130387422-82ebdeffd616?w=600&auto=format&fit=crop&q=80', // Ilish / Silver fish
    'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=600&auto=format&fit=crop&q=80', // Prawn / Shrimp
    'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=600&auto=format&fit=crop&q=80', // Katla / Fish market
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ==========================================
          // APP BAR & SEARCH
          // ==========================================
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            floating: true,
            backgroundColor: const Color(0xFF0277BD), // Deep water blue
            elevation: 0,
            title: Text(
              'মৎস্য বাজার',
              style: GoogleFonts.hindSiliguri(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            actions: [
              Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                        onPressed: () {
                          Get.to(() => const ShoppingCartScreen());
                        },
                      ),
                      if (cartProvider.itemCount > 0)
                        Positioned(
                          right: 6,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              '${cartProvider.itemCount}',
                              style: GoogleFonts.poppins(
                                color: Colors.black87,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort, color: Colors.white),
                onSelected: (value) => setState(() => _sortBy = value),
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'popular', child: Text('জনপ্রিয়', style: GoogleFonts.hindSiliguri())),
                  PopupMenuItem(value: 'price_low', child: Text('দাম: কম → বেশি', style: GoogleFonts.hindSiliguri())),
                  PopupMenuItem(value: 'price_high', child: Text('দাম: বেশি → কম', style: GoogleFonts.hindSiliguri())),
                  PopupMenuItem(value: 'rating', child: Text('সেরা রেটিং', style: GoogleFonts.hindSiliguri())),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0277BD), Color(0xFF00ACC1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C3E50) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? Colors.white24 : Colors.transparent),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: TextField(
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'কী মাছ খুঁজছেন? (যেমন: রুই, ইলিশ)',
                          hintStyle: GoogleFonts.hindSiliguri(color: isDark ? Colors.grey.shade400 : Colors.grey.shade400, fontSize: 14),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF0277BD)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ==========================================
          // BANNER CAROUSEL
          // ==========================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: SizedBox(
                height: 160,
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: _banners.length,
                      onPageChanged: (index) => setState(() => _currentBannerIndex = index),
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: NetworkImage(_banners[index]),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              'তাজা মাছের সমাহার',
                              style: GoogleFonts.hindSiliguri(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _banners.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentBannerIndex == index ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentBannerIndex == index ? const Color(0xFF0277BD) : Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==========================================
          // CATEGORIES (Horizontal Scroll)
          // ==========================================
          SliverToBoxAdapter(
            child: SizedBox(
              height: 110,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat['label'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat['label']),
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: Column(
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? const Color(0xFF0277BD) 
                                  : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                              shape: BoxShape.circle,
                              border: Border.all(color: isDark && !isSelected ? Colors.white12 : Colors.transparent),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                )
                              ],
                            ),
                            child: Icon(
                              cat['icon'],
                              color: isSelected ? Colors.white : const Color(0xFF0277BD),
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cat['label'],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected 
                                  ? const Color(0xFF0277BD) 
                                  : (isDark ? Colors.grey.shade300 : Colors.black87),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ==========================================
          // PRODUCTS GRID (Mock Data)
          // ==========================================
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveHelper.getGridColumns(context),
                childAspectRatio: ResponsiveHelper.isDesktop(context) ? 0.85 : 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                    return _buildFishProductCard(
                      title: ['রুই মাছ (তাজা)', 'ইলিশ (১ কেজি+)', 'চিংড়ি', 'কাতলা'][index % 4],
                      price: ['350', '1200', '800', '400'][index % 4],
                      seller: 'করিম মৎস্য খামার',
                      location: 'চাঁদপুর',
                      imageUrl: _fishImages[index % 4],
                      isDark: isDark,
                    );
                },
                childCount: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFishProductCard({
    required String title,
    required String price,
    required String seller,
    required String location,
    required String imageUrl,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder -> Real Image
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: isDark ? const Color(0xFF0D47A1).withOpacity(0.3) : const Color(0xFFE1F5FE),
                      child: const Center(
                        child: Icon(Icons.set_meal, size: 48, color: Color(0xFF0277BD)),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'প্রিমিয়াম',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Details
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.hindSiliguri(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '৳ $price / কেজি',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: const Color(0xFF0277BD),
                    ),
                  ),
                  // Buttons: Add to cart & Buy Now
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: () => _addToCart(title, price, seller, location, imageUrl),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? const Color(0xFF1976D2).withOpacity(0.2) : const Color(0xFFE3F2FD),
                              foregroundColor: const Color(0xFF0277BD),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Icon(Icons.shopping_cart_outlined, size: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: () => _handleDirectPurchase(title, double.parse(price), seller, imageUrl),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0277BD),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              'এখুনি কিনুন',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 11,
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
          ),
        ],
      ),
    );
  }

  void _addToCart(String title, String priceStr, String seller, String location, String imageUrl) {
    final double price = double.tryParse(priceStr) ?? 0.0;
    final String id = 'fish_${title.hashCode}_${seller.hashCode}';
    final String nowIso = DateTime.now().toIso8601String();

    final item = CartItem(
      id: id,
      title: title,
      price: price,
      unit: 'কেজি',
      quantity: 1.0,
      imageUrl: imageUrl,
      itemType: CartItemType.product,
      sellerId: 'seller_${seller.hashCode}',
      sellerName: seller,
      sellerRole: 'fishFarmer',
      metadata: {
        'addedAt': nowIso,
        'location': location,
        'category': 'fish',
        'history': [nowIso],
      },
    );

    Provider.of<CartProvider>(context, listen: false).addToCart(item);

    Get.snackbar(
      'কার্টে যোগ করা হয়েছে 🛒',
      '$title (১ কেজি) আপনার কার্টে যোগ করা হয়েছে।',
      backgroundColor: const Color(0xFF0277BD),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      mainButton: TextButton(
        onPressed: () {
          Get.to(() => const ShoppingCartScreen());
        },
        child: Text(
          'কার্ট দেখুন',
          style: GoogleFonts.hindSiliguri(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Future<void> _handleDirectPurchase(String title, double price, String seller, String imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar(
        'ত্রুটি',
        'দয়া করে লগইন করুন',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    final success = await SSLCommerzService.initiatePayment(
      context: context,
      amount: price,
      productName: title,
      customerName: user.displayName ?? "Fish Buyer",
      customerEmail: user.email ?? "buyer@example.com",
      customerPhone: "01700000000",
      customerAddress: "Dhaka, Bangladesh",
    );

    if (success) {
      final orderId = 'ORD_${DateTime.now().millisecondsSinceEpoch}';
      final newOrder = OrderModel(
        id: orderId,
        buyerId: user.uid,
        farmerId: 'FARMER_123',
        farmerName: seller,
        productName: title,
        productImageUrl: imageUrl,
        quantity: 1.0,
        totalAmount: price,
        status: 'Processing',
        statusStep: 2,
        transportStatus: 'অর্ডার গৃহীত হয়েছে',
        paymentStatus: 'Paid via SSLCommerz',
        createdAt: DateTime.now(),
      );
      
      final orderService = OrderService();
      await orderService.createOrder(newOrder);
      Get.to(() => const FishBuyerOrdersScreen());
    }
  }
}
