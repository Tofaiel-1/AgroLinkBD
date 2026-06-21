import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _selectedCategory = 'সব';
  String _sortBy = 'popular';

  final List<Map<String, dynamic>> _categories = [
    {'label': 'সব', 'emoji': '🛒'},
    {'label': 'সবজি', 'emoji': '🥬'},
    {'label': 'ফলমূল', 'emoji': '🍎'},
    {'label': 'চাল', 'emoji': '🌾'},
    {'label': 'মসলা', 'emoji': '🌶️'},
    {'label': 'মাছ', 'emoji': '🐟'},
    {'label': 'মাংস', 'emoji': '🥩'},
    {'label': 'দুধ-ডিম', 'emoji': '🥚'},
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'তাজা টমেটো',
      'price': 40,
      'unit': 'কেজি',
      'farmer': 'করিম ফার্ম',
      'location': 'বগুড়া',
      'emoji': '🍅',
      'color': Colors.red,
      'rating': 4.8,
      'category': 'সবজি',
    },
    {
      'name': 'দেশি পেঁয়াজ',
      'price': 70,
      'unit': 'কেজি',
      'farmer': 'রহিম এগ্রো',
      'location': 'পাবনা',
      'emoji': '🧅',
      'color': Colors.purple,
      'rating': 4.5,
      'category': 'সবজি',
    },
    {
      'name': 'মিনিকেট চাল',
      'price': 65,
      'unit': 'কেজি',
      'farmer': 'কৃষক সমবায়',
      'location': 'দিনাজপুর',
      'emoji': '🌾',
      'color': Colors.amber,
      'rating': 4.9,
      'category': 'চাল',
    },
    {
      'name': 'আলু',
      'price': 25,
      'unit': 'কেজি',
      'farmer': 'রংপুর ফার্ম',
      'location': 'রংপুর',
      'emoji': '🥔',
      'color': Colors.brown,
      'rating': 4.3,
      'category': 'সবজি',
    },
    {
      'name': 'আম (হিমসাগর)',
      'price': 120,
      'unit': 'কেজি',
      'farmer': 'রাজশাহী ফ্রুট',
      'location': 'রাজশাহী',
      'emoji': '🥭',
      'color': Colors.orange,
      'rating': 4.9,
      'category': 'ফলমূল',
    },
    {
      'name': 'হলুদ গুঁড়া',
      'price': 250,
      'unit': 'কেজি',
      'farmer': 'মসলা ঘর',
      'location': 'মানিকগঞ্জ',
      'emoji': '🟡',
      'color': Colors.yellow,
      'rating': 4.6,
      'category': 'মসলা',
    },
    {
      'name': 'রুই মাছ',
      'price': 350,
      'unit': 'কেজি',
      'farmer': 'মৎস্য খামার',
      'location': 'ময়মনসিংহ',
      'emoji': '🐟',
      'color': Colors.blue,
      'rating': 4.7,
      'category': 'মাছ',
    },
    {
      'name': 'দেশি মুরগি',
      'price': 550,
      'unit': 'কেজি',
      'farmer': 'গ্রামীণ পোল্ট্রি',
      'location': 'গাজীপুর',
      'emoji': '🐔',
      'color': Colors.deepOrange,
      'rating': 4.4,
      'category': 'মাংস',
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    var products = _selectedCategory == 'সব'
        ? _products
        : _products.where((p) => p['category'] == _selectedCategory).toList();

    if (_sortBy == 'price_low') {
      products.sort((a, b) => (a['price'] as int).compareTo(b['price'] as int));
    } else if (_sortBy == 'price_high') {
      products.sort((a, b) => (b['price'] as int).compareTo(a['price'] as int));
    } else if (_sortBy == 'rating') {
      products.sort(
          (a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
    }

    return products;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar + Search
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
              child: Column(
                children: [
                  // Title row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'কৃষি বাজার 🛒',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.sort,
                          color: isDark ? Colors.white70 : Colors.grey.shade700,
                        ),
                        onSelected: (value) => setState(() => _sortBy = value),
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'popular', child: Text('জনপ্রিয়')),
                          const PopupMenuItem(value: 'price_low', child: Text('দাম: কম → বেশি')),
                          const PopupMenuItem(value: 'price_high', child: Text('দাম: বেশি → কম')),
                          const PopupMenuItem(value: 'rating', child: Text('সেরা রেটিং')),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'পণ্য খুঁজুন...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        icon: Icon(Icons.search,
                            color: isDark ? Colors.white38 : Colors.grey.shade400),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Category chips
            SizedBox(
              height: 52,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat['label'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat['label']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1976D2)
                            : isDark
                                ? const Color(0xFF2A2A2A)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1976D2)
                              : isDark
                                  ? Colors.white12
                                  : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(cat['emoji'], style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            cat['label'],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : isDark
                                      ? Colors.white70
                                      : Colors.grey.shade700,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Results count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    '${_filteredProducts.length}টি পণ্য পাওয়া গেছে',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            // Product Grid
            Expanded(
              child: _filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64,
                              color: isDark ? Colors.white24 : Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'কোনো পণ্য পাওয়া যায়নি',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white54 : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return _buildGridProductCard(product, isDark);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridProductCard(Map<String, dynamic> product, bool isDark) {
    return GestureDetector(
      onTap: () {
        Get.snackbar(
          product['name'],
          '${product['farmer']} — ${product['location']}',
          backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
          colorText: isDark ? Colors.white : Colors.black87,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image area
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (product['color'] as Color).withOpacity(0.08),
                      (product['color'] as Color).withOpacity(0.15),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        product['emoji'],
                        style: const TextStyle(fontSize: 52),
                      ),
                    ),
                    // Rating badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black54 : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 12, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              '${product['rating']}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Product info
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${product['farmer']} • ${product['location']}',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white54 : Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '৳${product['price']}/${product['unit']}',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showAddToCartBottomSheet(context, product, isDark);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1976D2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add_shopping_cart,
                                color: Colors.white, size: 16),
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
      ),
    );
  }

  void _showAddToCartBottomSheet(BuildContext context, Map<String, dynamic> product, bool isDark) {
    int quantity = 1;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        product['emoji'],
                        style: const TextStyle(fontSize: 40),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '৳${product['price']} / ${product['unit']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'পরিমাণ নির্বাচন করুন',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (quantity > 1) {
                            setModalState(() => quantity--);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white12 : Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.remove, color: isDark ? Colors.white : Colors.black),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          '$quantity',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setModalState(() => quantity++);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976D2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'মোট মূল্য:',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      Text(
                        '৳${product['price'] * quantity}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Get.snackbar(
                          'কার্টে যোগ হয়েছে ✓',
                          '$quantity ${product['unit']} ${product['name']} কার্টে যোগ করা হয়েছে',
                          backgroundColor: Colors.green.shade100,
                          colorText: Colors.green.shade900,
                          duration: const Duration(seconds: 2),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'কার্টে যোগ করুন',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
