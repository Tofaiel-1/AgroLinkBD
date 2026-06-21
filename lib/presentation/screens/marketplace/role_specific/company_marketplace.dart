import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Company Marketplace - Bulk Ordering
/// Browse farmers, create bulk orders, view pricing
class CompanyMarketplace extends StatefulWidget {
  const CompanyMarketplace({super.key});

  @override
  State<CompanyMarketplace> createState() => _CompanyMarketplaceState();
}

class _CompanyMarketplaceState extends State<CompanyMarketplace> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';

  final List<Map<String, dynamic>> farmers = [
    {
      'name': 'রহিম ফার্ম',
      'location': 'নারায়ণগঞ্জ',
      'products': 'ধান, গম, সবজি',
      'capacity': '৫০ টন/মাস',
      'rating': 4.8,
      'reviews': 145,
      'icon': '🌾',
    },
    {
      'name': 'সবুজ কৃষি সহযোগিতা',
      'location': 'টাঙ্গাইল',
      'products': 'আলু, পেঁয়াজ, রসুন',
      'capacity': '৩০ টন/মাস',
      'rating': 4.6,
      'reviews': 98,
      'icon': '🥔',
    },
    {
      'name': 'করিম সবজি বাগান',
      'location': 'ঢাকা',
      'products': 'শাক, সবজি (সারা বছর)',
      'capacity': '২০ টন/মাস',
      'rating': 4.9,
      'reviews': 176,
      'icon': '🥬',
    },
    {
      'name': 'ফারিয়াল ফিশ ফার্ম',
      'location': 'খুলনা',
      'products': 'দেশীয় মাছ',
      'capacity': '১০ টন/মাস',
      'rating': 4.7,
      'reviews': 112,
      'icon': '🐟',
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
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        title: Text(
          'কৃষক সংযোগ',
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
                hintText: 'কৃষক বা পণ্য খুঁজুন...',
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
                  _buildCategoryChip('শস্য', 'grains'),
                  const SizedBox(width: 8),
                  _buildCategoryChip('সবজি', 'vegetables'),
                  const SizedBox(width: 8),
                  _buildCategoryChip('মাছ', 'fish'),
                  const SizedBox(width: 8),
                  _buildCategoryChip('দুধ', 'dairy'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Farmers list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: farmers.length,
              itemBuilder: (context, index) {
                final farmer = farmers[index];
                return _buildFarmerCard(
                  name: farmer['name'],
                  location: farmer['location'],
                  products: farmer['products'],
                  capacity: farmer['capacity'],
                  rating: farmer['rating'],
                  reviews: farmer['reviews'],
                  icon: farmer['icon'],
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
      selectedColor: const Color(0xFF0D47A1).withOpacity(0.2),
      labelStyle: GoogleFonts.openSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isSelected ? const Color(0xFF0D47A1) : const Color(0xFF666666),
      ),
      side: BorderSide(
        color:
            isSelected ? const Color(0xFF0D47A1) : Colors.grey.withOpacity(0.2),
      ),
    );
  }

  Widget _buildFarmerCard({
    required String name,
    required String location,
    required String products,
    required String capacity,
    required double rating,
    required int reviews,
    required String icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: const Color(0xFF0D47A1).withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D47A1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 28)),
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 12, color: Color(0xFF0D47A1)),
                        const SizedBox(width: 2),
                        Text(
                          location,
                          style: GoogleFonts.openSans(
                            fontSize: 11,
                            color: const Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 12, color: Color(0xFFF39C12)),
                        const SizedBox(width: 2),
                        Text(
                          '$rating ($reviews রিভিউ)',
                          style: GoogleFonts.openSans(
                            fontSize: 10,
                            color: const Color(0xFFF39C12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0D47A1).withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'পণ্য: $products',
                  style: GoogleFonts.openSans(
                    fontSize: 11,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ক্ষমতা: $capacity',
                  style: GoogleFonts.openSans(
                    fontSize: 11,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // View details
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFF0D47A1),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'বিবরণ দেখুন',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.openSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0D47A1),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Create bulk order
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D47A1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'অর্ডার তৈরি করুন',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.openSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
    );
  }
}
