import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Buyer Marketplace - Browse and Buy Products
/// Browse farmers' products, compare prices, add to cart
class BuyerMarketplace extends StatefulWidget {
  const BuyerMarketplace({super.key});

  @override
  State<BuyerMarketplace> createState() => _BuyerMarketplaceState();
}

class _BuyerMarketplaceState extends State<BuyerMarketplace> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _sortBy = 'latest';

  final List<Map<String, dynamic>> products = [
    {
      'name': 'তাজা আম',
      'farmer': 'রহিম ফার্ম',
      'price': '৳ ৮০/কেজি',
      'rating': 4.8,
      'quantity': '১০ কেজি',
      'image': '🥭',
      'badge': 'নতুন',
    },
    {
      'name': 'জৈব পালক শাক',
      'farmer': 'সবুজ বাগান',
      'price': '৳ ৪৫/বান্ডেল',
      'rating': 4.6,
      'quantity': '১ বান্ডেল',
      'image': '🥬',
      'badge': 'জৈব',
    },
    {
      'name': 'স্থানীয় মুরগি',
      'farmer': 'করিম ফার্ম',
      'price': '৳ ৩০০/টি',
      'rating': 4.9,
      'quantity': '১টি',
      'image': '🐔',
      'badge': 'জনপ্রিয়',
    },
    {
      'name': 'তাজা দুধ',
      'farmer': 'দেশীয় দুগ্ধ',
      'price': '৳ ৬০/লিটার',
      'rating': 4.7,
      'quantity': '১ লিটার',
      'image': '🥛',
      'badge': 'প্রতিদিন',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        title: Text(
          'কৃষি বাজার',
          style: GoogleFonts.openSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search and Filter bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'পণ্য খুঁজুন...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: const Icon(
                    Icons.filter_list,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ],
            ),
          ),

          // Categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip('সব', 'all'),
                  const SizedBox(width: 8),
                  _buildCategoryChip('ফল', 'fruits'),
                  const SizedBox(width: 8),
                  _buildCategoryChip('সবজি', 'vegetables'),
                  const SizedBox(width: 8),
                  _buildCategoryChip('দুধ', 'dairy'),
                  const SizedBox(width: 8),
                  _buildCategoryChip('মাংস', 'meat'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Sort options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${products.length} পণ্য পাওয়া গেছে',
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    color: const Color(0xFF999999),
                  ),
                ),
                DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  items: [
                    DropdownMenuItem(
                      value: 'latest',
                      child: Text(
                        'সর্বশেষ',
                        style: GoogleFonts.openSans(fontSize: 12),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'price_low',
                      child: Text(
                        'কম দাম',
                        style: GoogleFonts.openSans(fontSize: 12),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'rating',
                      child: Text(
                        'রেটিং',
                        style: GoogleFonts.openSans(fontSize: 12),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Products list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductCard(
                  name: product['name'],
                  farmer: product['farmer'],
                  price: product['price'],
                  rating: product['rating'],
                  quantity: product['quantity'],
                  image: product['image'],
                  badge: product['badge'],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String value) {
    bool isSelected = _selectedCategory == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _selectedCategory = value;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF1976D2).withOpacity(0.2),
      labelStyle: GoogleFonts.openSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isSelected ? const Color(0xFF1976D2) : const Color(0xFF666666),
      ),
      side: BorderSide(
        color:
            isSelected ? const Color(0xFF1976D2) : Colors.grey.withOpacity(0.2),
      ),
    );
  }

  Widget _buildProductCard({
    required String name,
    required String farmer,
    required String price,
    required double rating,
    required String quantity,
    required String image,
    required String badge,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(image, style: const TextStyle(fontSize: 32)),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1976D2),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomLeft: Radius.circular(6),
                    ),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.openSans(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.openSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  farmer,
                  style: GoogleFonts.openSans(
                    fontSize: 11,
                    color: const Color(0xFF999999),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quantity,
                  style: GoogleFonts.openSans(
                    fontSize: 10,
                    color: const Color(0xFFBBBBBB),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFFF39C12)),
                    const SizedBox(width: 2),
                    Text(
                      '$rating',
                      style: GoogleFonts.openSans(
                        fontSize: 11,
                        color: const Color(0xFFF39C12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1976D2),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  // Add to cart
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'কার্টে যোগ করুন',
                    style: GoogleFonts.openSans(
                      fontSize: 11,
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
    );
  }
}
