import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

/// Ultra-Premium Visionary Farmer Marketplace
/// "Bento Box" Spatial Grid System
class FarmerMarketplace extends StatefulWidget {
  const FarmerMarketplace({super.key});

  @override
  State<FarmerMarketplace> createState() => _FarmerMarketplaceState();
}

class _FarmerMarketplaceState extends State<FarmerMarketplace> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';

  // Colors
  final Color bottleGreen = const Color(0xFF006A4E);
  final Color harvestYellow = const Color(0xFFF2A900);
  final Color cleanWhite = const Color(0xFFFFFFFF);
  final Color bgColor = const Color(0xFFF5F7FA);

  final List<Map<String, dynamic>> inputs = [
    {
      'name': 'উন্নত ধানের বীজ',
      'supplier': 'সবুজ কৃষি',
      'price': '৳ ৩,৫০০',
      'rating': 4.8,
      'reviews': 125,
      'image': 'https://plus.unsplash.com/premium_photo-1661962383210-90c74fb936bb?w=400&q=80',
      'category': 'seeds',
    },
    {
      'name': 'জৈব সার',
      'supplier': 'প্রকৃতির আশীর্বাদ',
      'price': '৳ ৫,২০০',
      'rating': 4.6,
      'reviews': 89,
      'image': 'https://images.unsplash.com/photo-1592997572594-34afe4facfb5?w=400&q=80',
      'category': 'fertilizer',
    },
    {
      'name': 'কীটনাশক স্প্রে',
      'supplier': 'নিরাপদ কৃষি',
      'price': '৳ ৮,০০০',
      'rating': 4.7,
      'reviews': 156,
      'image': 'https://images.unsplash.com/photo-1586773860383-55abbfa112e4?w=400&q=80',
      'category': 'pesticide',
    },
    {
      'name': 'মিনি ট্রাক্টর',
      'supplier': 'কৃষি যন্ত্র সেবা',
      'price': '৳ ২৫,০০০',
      'rating': 4.9,
      'reviews': 203,
      'image': 'https://images.unsplash.com/photo-1589923188900-85dae523342b?w=400&q=80',
      'category': 'equipment',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredInputs = _selectedCategory == 'all'
        ? inputs
        : inputs.where((i) => i['category'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'কৃষি ইনপুট মার্কেটপ্লেস',
          style: GoogleFonts.hindSiliguri(
            fontWeight: FontWeight.bold,
            color: bottleGreen,
          ),
        ),
        backgroundColor: cleanWhite,
        elevation: 0,
        iconTheme: IconThemeData(color: bottleGreen),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              bgColor,
              const Color(0xFFE8F5E9),
            ],
          ),
        ),
        child: Column(
          children: [
            // Search Bar (Premium Style)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.hindSiliguri(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'বীজ, সার, যন্ত্র খুঁজুন...',
                    hintStyle: GoogleFonts.hindSiliguri(color: Colors.grey.shade500),
                    prefixIcon: Icon(Icons.search, color: bottleGreen),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: harvestYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.tune, color: harvestYellow),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),

            // Categories (Premium Chips)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildPremiumCategoryChip('সব', 'all', Icons.grid_view),
                  const SizedBox(width: 12),
                  _buildPremiumCategoryChip('বীজ', 'seeds', Icons.grass),
                  const SizedBox(width: 12),
                  _buildPremiumCategoryChip('সার', 'fertilizer', Icons.science),
                  const SizedBox(width: 12),
                  _buildPremiumCategoryChip('কীটনাশক', 'pesticide', Icons.pest_control),
                  const SizedBox(width: 12),
                  _buildPremiumCategoryChip('যন্ত্র', 'equipment', Icons.agriculture),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Products Bento Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: filteredInputs.length,
                itemBuilder: (context, index) {
                  final input = filteredInputs[index];
                  return _buildBentoProductCard(input);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCategoryChip(String label, String value, IconData icon) {
    bool isSelected = _selectedCategory == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? bottleGreen : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: bottleGreen.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : bottleGreen.withOpacity(0.7),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.hindSiliguri(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoProductCard(Map<String, dynamic> input) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      input['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: bottleGreen.withOpacity(0.1),
                        child: Icon(Icons.image_not_supported, color: bottleGreen),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${input['rating']}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Product Details
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            input['name'],
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            input['supplier'],
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              input['price'],
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: bottleGreen,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.snackbar(
                                'কার্টে যোগ করা হয়েছে',
                                '${input['name']} আপনার কার্টে সফলভাবে যোগ হয়েছে।',
                                backgroundColor: bottleGreen,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                                margin: const EdgeInsets.all(16),
                                icon: const Icon(Icons.check_circle, color: Colors.white),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: harvestYellow,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: harvestYellow.withOpacity(0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 20),
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
      ),
    );
  }
}
