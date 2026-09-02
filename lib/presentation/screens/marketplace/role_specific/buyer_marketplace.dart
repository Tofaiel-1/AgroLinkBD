import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/presentation/widgets/quick_buy_bottom_sheet.dart';

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
      'id': 'mango_101',
      'name': 'তাজা আম (হিমসাগর)',
      'farmer': 'রহিম ফার্ম',
      'farmerId': 'farmer_rahim_01',
      'price': '৳ ৮০/কেজি',
      'rawPrice': 80.0,
      'unit': 'কেজি',
      'rating': 4.8,
      'quantity': '১০ কেজি',
      'image': 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=400&q=80',
      'badge': 'নতুন',
      'category': 'fruits',
    },
    {
      'id': 'spinach_102',
      'name': 'জৈব পালং শাক',
      'farmer': 'সবুজ বাগান',
      'farmerId': 'farmer_green_02',
      'price': '৳ ৪৫/বান্ডেল',
      'rawPrice': 45.0,
      'unit': 'বান্ডেল',
      'rating': 4.6,
      'quantity': '১ বান্ডেল',
      'image': 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400&q=80',
      'badge': 'জৈব',
      'category': 'vegetables',
    },
    {
      'id': 'chicken_103',
      'name': 'দেশি মুরগি',
      'farmer': 'করিম পোল্ট্রি ফার্ম',
      'farmerId': 'farmer_karim_03',
      'price': '৳ ৫৫০/টি',
      'rawPrice': 550.0,
      'unit': 'টি',
      'rating': 4.9,
      'quantity': '১টি',
      'image': 'https://images.unsplash.com/photo-1548550023-2bdb3c5beed7?w=400&q=80',
      'badge': 'জনপ্রিয়',
      'category': 'meat',
    },
    {
      'id': 'milk_104',
      'name': 'খাঁটি তরল দুধ',
      'farmer': 'দেশীয় দুগ্ধ খামার',
      'farmerId': 'farmer_dairy_04',
      'price': '৳ ৮০/লিটার',
      'rawPrice': 80.0,
      'unit': 'লিটার',
      'rating': 4.7,
      'quantity': '১ লিটার',
      'image': 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400&q=80',
      'badge': 'প্রতিদিন',
      'category': 'dairy',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openQuickBuy(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: QuickBuyBottomSheet(product: {
          'id': product['id'] ?? 'product_item',
          'name': product['name'] ?? 'কৃষি পণ্য',
          'price': product['rawPrice'] ?? 100.0,
          'unit': product['unit'] ?? 'কেজি',
          'farmer': product['farmer'] ?? 'কৃষক',
          'farmerId': product['farmerId'] ?? 'farmer_id',
          'image': product['image'],
          'qualityGrade': 'Premium A Grade',
        }),
      ),
    );
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
          style: GoogleFonts.hindSiliguri(
            fontSize: 20,
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
                    style: GoogleFonts.hindSiliguri(),
                    decoration: InputDecoration(
                      hintText: 'পণ্য খুঁজুন...',
                      hintStyle: GoogleFonts.hindSiliguri(color: Colors.grey.shade400),
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
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),

          // Categories Horizontal List
          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChip('সকল পণ্য', 'all'),
                _buildCategoryChip('শাক-সবজি', 'vegetables'),
                _buildCategoryChip('ফলমূল', 'fruits'),
                _buildCategoryChip('দুগ্ধজাত', 'dairy'),
                _buildCategoryChip('মাংস ও হাঁস-মুরগি', 'meat'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Sort & Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'পণ্য তালিকা (${products.length}টি পণ্য)',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 13,
                    color: const Color(0xFF1976D2),
                    fontWeight: FontWeight.bold,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'latest',
                      child: Text('সর্বশেষ'),
                    ),
                    DropdownMenuItem(
                      value: 'price_low',
                      child: Text('দাম: কম থেকে বেশি'),
                    ),
                    DropdownMenuItem(
                      value: 'price_high',
                      child: Text('দাম: বেশি থেকে কম'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _sortBy = value ?? 'latest');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Products List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return GestureDetector(
                  onTap: () => _openQuickBuy(product),
                  child: _buildProductCard(
                    id: product['id'] as String,
                    name: product['name'] as String,
                    farmer: product['farmer'] as String,
                    price: product['price'] as String,
                    rating: product['rating'] as double,
                    quantity: product['quantity'] as String,
                    imageUrl: product['image'] as String,
                    badge: product['badge'] as String,
                    productMap: product,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String value) {
    final isSelected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
        selected: isSelected,
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF1976D2),
        side: BorderSide(
          color: isSelected ? const Color(0xFF1976D2) : Colors.grey.shade300,
        ),
        onSelected: (selected) {
          setState(() => _selectedCategory = value);
        },
      ),
    );
  }

  Widget _buildProductCard({
    required String id,
    required String name,
    required String farmer,
    required String price,
    required double rating,
    required String quantity,
    required String imageUrl,
    required String badge,
    required Map<String, dynamic> productMap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
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
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  farmer,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 12,
                    color: const Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quantity,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 11,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFFF39C12)),
                    const SizedBox(width: 2),
                    Text(
                      '$rating',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
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
                style: GoogleFonts.hindSiliguri(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1976D2),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _openQuickBuy(productMap),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.flash_on, color: Colors.amberAccent, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'কিনুন',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 12,
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
        ],
      ),
    );
  }
}
