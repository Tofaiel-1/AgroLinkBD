import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Farmer Marketplace - Buy Agricultural Inputs
/// Seeds, fertilizers, tools, equipment
class FarmerMarketplace extends StatefulWidget {
  const FarmerMarketplace({super.key});

  @override
  State<FarmerMarketplace> createState() => _FarmerMarketplaceState();
}

class _FarmerMarketplaceState extends State<FarmerMarketplace> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';

  final List<Map<String, dynamic>> inputs = [
    {
      'name': 'উন্নত ধানের বীজ',
      'supplier': 'সবুজ কৃষি',
      'price': '৳ ৩,৫০০',
      'rating': 4.8,
      'reviews': 125,
      'image': '🌾',
    },
    {
      'name': 'জৈব সার',
      'supplier': 'প্রকৃতির আশীর্বাদ',
      'price': '৳ ৫,২০০',
      'rating': 4.6,
      'reviews': 89,
      'image': '🌱',
    },
    {
      'name': 'কীটনাশক স্প্রে',
      'supplier': 'নিরাপদ কৃষি',
      'price': '৳ ৮,০০০',
      'rating': 4.7,
      'reviews': 156,
      'image': '🧪',
    },
    {
      'name': 'ট্র্যাক্টর ভাড়া',
      'supplier': 'কৃষি যন্ত্র সেবা',
      'price': '৳ ২৫,০০০/দিন',
      'rating': 4.9,
      'reviews': 203,
      'image': '🚜',
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
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        title: Text(
          'কৃষি ইনপুট স্টোর',
          style: GoogleFonts.openSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'বীজ, সার, যন্ত্র খুঁজুন...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
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
                  _buildCategoryChip('বীজ', 'seeds'),
                  const SizedBox(width: 8),
                  _buildCategoryChip('সার', 'fertilizer'),
                  const SizedBox(width: 8),
                  _buildCategoryChip('কীটনাশক', 'pesticide'),
                  const SizedBox(width: 8),
                  _buildCategoryChip('যন্ত্র', 'equipment'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Products list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: inputs.length,
              itemBuilder: (context, index) {
                final input = inputs[index];
                return _buildInputCard(
                  name: input['name'],
                  supplier: input['supplier'],
                  price: input['price'],
                  rating: input['rating'],
                  reviews: input['reviews'],
                  image: input['image'],
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
      selectedColor: const Color(0xFF2E7D32).withOpacity(0.2),
      labelStyle: GoogleFonts.openSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFF666666),
      ),
      side: BorderSide(
        color:
            isSelected ? const Color(0xFF2E7D32) : Colors.grey.withOpacity(0.2),
      ),
    );
  }

  Widget _buildInputCard({
    required String name,
    required String supplier,
    required String price,
    required double rating,
    required int reviews,
    required String image,
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
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(image, style: const TextStyle(fontSize: 32)),
            ),
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
                  supplier,
                  style: GoogleFonts.openSans(
                    fontSize: 11,
                    color: const Color(0xFF999999),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_half,
                        size: 14, color: Color(0xFFF39C12)),
                    const SizedBox(width: 2),
                    Text(
                      '$rating ($reviews)',
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
                  color: const Color(0xFF2E7D32),
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
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'যোগ করুন',
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
