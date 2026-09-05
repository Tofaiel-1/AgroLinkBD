import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/presentation/widgets/quick_buy_bottom_sheet.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/utils/number_converter.dart';
import 'package:agrolinkbd/core/utils/masked_identity_helper.dart';

/// Buyer Marketplace - Browse and Buy Products
/// Browse farmers' products, compare prices, add to cart
class BuyerMarketplace extends StatefulWidget {
  final String? initialCategory;
  const BuyerMarketplace({super.key, this.initialCategory});

  @override
  State<BuyerMarketplace> createState() => _BuyerMarketplaceState();
}

class _BuyerMarketplaceState extends State<BuyerMarketplace> {
  final TextEditingController _searchController = TextEditingController();
  late String _selectedCategory;
  String _sortBy = 'latest';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _categories = [
    {'bn': 'সকল পণ্য', 'en': 'All', 'key': 'all'},
    {'bn': 'শাকসবজি', 'en': 'Vegetables', 'key': 'vegetables'},
    {'bn': 'ফলমূল', 'en': 'Fruits', 'key': 'fruits'},
    {'bn': 'চাল ও শস্য', 'en': 'Grains', 'key': 'grains'},
    {'bn': 'মসলা', 'en': 'Spices', 'key': 'spices'},
    {'bn': 'তাজা মাছ', 'en': 'Fresh Fish', 'key': 'fish'},
    {'bn': 'মাংস ও ডিম', 'en': 'Meat & Eggs', 'key': 'meat'},
  ];

  final List<Map<String, dynamic>> products = [
    {
      'id': 'mango_101',
      'nameBn': 'তাজা আম (হিমসাগর)',
      'nameEn': 'Fresh Mango (Himsagar)',
      'farmerBn': 'রহিম ফ্রুট গার্ডেন',
      'farmerEn': 'Rahim Fruit Garden',
      'farmerId': 'farmer_rahim_01',
      'price': 80.0,
      'unitBn': 'কেজি',
      'unitEn': 'kg',
      'rating': 4.8,
      'quantityBn': '১০ কেজি',
      'quantityEn': '10 kg',
      'image': 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=400&q=80',
      'badgeBn': 'প্রিমিয়াম',
      'badgeEn': 'Premium',
      'category': 'fruits',
    },
    {
      'id': 'spinach_102',
      'nameBn': 'অর্গানিক পালং শাক',
      'nameEn': 'Organic Spinach',
      'farmerBn': 'সবুজ পল্লী এগ্রো',
      'farmerEn': 'Sabuj Polli Agro',
      'farmerId': 'farmer_green_02',
      'price': 45.0,
      'unitBn': 'আঁটি',
      'unitEn': 'bundle',
      'rating': 4.6,
      'quantityBn': '১ আঁটি',
      'quantityEn': '1 bundle',
      'image': 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400&q=80',
      'badgeBn': 'জৈব সার',
      'badgeEn': 'Organic',
      'category': 'vegetables',
    },
    {
      'id': 'rice_103',
      'nameBn': 'মিনিকেট চাল (নতুন ধান)',
      'nameEn': 'Miniket Premium Rice',
      'farmerBn': 'দিনাজপুর গ্রেইন রাইস মিল',
      'farmerEn': 'Dinajpur Grain Rice Mill',
      'farmerId': 'farmer_rice_03',
      'price': 72.0,
      'unitBn': 'কেজি',
      'unitEn': 'kg',
      'rating': 4.9,
      'quantityBn': '৫০ কেজি বস্তা',
      'quantityEn': '50 kg sack',
      'image': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&q=80',
      'badgeBn': 'সেরা মান',
      'badgeEn': 'Top Quality',
      'category': 'grains',
    },
    {
      'id': 'spices_104',
      'nameBn': 'খাঁটি হলুদ গুঁড়া ও কাঁচা মরিচ',
      'nameEn': 'Pure Turmeric & Green Chili',
      'farmerBn': 'নাটোর স্পাইস হাব',
      'farmerEn': 'Natore Spice Hub',
      'farmerId': 'farmer_spice_04',
      'price': 220.0,
      'unitBn': 'কেজি',
      'unitEn': 'kg',
      'rating': 4.7,
      'quantityBn': '১ কেজি',
      'quantityEn': '1 kg',
      'image': 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=400&q=80',
      'badgeBn': 'কেমিক্যালমুক্ত',
      'badgeEn': 'Pure',
      'category': 'spices',
    },
    {
      'id': 'fish_105',
      'nameBn': 'পদ্মার তাজা রুই ও কাতলা',
      'nameEn': 'Fresh Padma Rui & Katla',
      'farmerBn': 'পদ্মা রিভার ফিশারিজ',
      'farmerEn': 'Padma River Fisheries',
      'farmerId': 'farmer_fish_05',
      'price': 420.0,
      'unitBn': 'কেজি',
      'unitEn': 'kg',
      'rating': 4.9,
      'quantityBn': '৫ কেজি',
      'quantityEn': '5 kg',
      'image': 'https://images.unsplash.com/photo-1534043464124-3be32fe00099?w=400&q=80',
      'badgeBn': 'লাইভ ফিশ',
      'badgeEn': 'Live Fish',
      'category': 'fish',
    },
    {
      'id': 'chicken_106',
      'nameBn': 'দেশি মুরগি ও তাজা ডিম',
      'nameEn': 'Country Chicken & Farm Eggs',
      'farmerBn': 'করিম অর্গানিক পোল্ট্রি',
      'farmerEn': 'Karim Organic Poultry',
      'farmerId': 'farmer_karim_06',
      'price': 580.0,
      'unitBn': 'জোড়া',
      'unitEn': 'pair',
      'rating': 4.8,
      'quantityBn': '১ জোড়া',
      'quantityEn': '1 pair',
      'image': 'https://images.unsplash.com/photo-1548550023-2bdb3c5beed7?w=400&q=80',
      'badgeBn': '১০০% দেশি',
      'badgeEn': 'Country Bred',
      'category': 'meat',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'all';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openQuickBuy(Map<String, dynamic> product, bool isBn) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: QuickBuyBottomSheet(product: {
          'id': product['id'] ?? 'product_item',
          'name': isBn ? product['nameBn'] : product['nameEn'],
          'price': product['price'] ?? 100.0,
          'unit': isBn ? product['unitBn'] : product['unitEn'],
          'farmer': isBn ? product['farmerBn'] : product['farmerEn'],
          'farmerId': product['farmerId'] ?? 'farmer_id',
          'location': isBn ? 'এগ্রোলিংক সার্টিফাইড হাব' : 'AgroLink Certified Hub',
          'image': product['image'],
          'qualityGrade': isBn ? 'Grade A+ (সুপার প্রিমিয়াম)' : 'Grade A+ (Super Premium)',
          'batchCode': MaskedIdentityHelper.generateBatchCode(),
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBn = LanguageProvider.isBn(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    var filteredProducts = _selectedCategory == 'all'
        ? List<Map<String, dynamic>>.from(products)
        : products.where((p) => p['category'] == _selectedCategory).toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filteredProducts = filteredProducts.where((p) {
        final nameBn = (p['nameBn'] ?? '').toString().toLowerCase();
        final nameEn = (p['nameEn'] ?? '').toString().toLowerCase();
        final farmerBn = (p['farmerBn'] ?? '').toString().toLowerCase();
        final farmerEn = (p['farmerEn'] ?? '').toString().toLowerCase();
        return nameBn.contains(q) || nameEn.contains(q) || farmerBn.contains(q) || farmerEn.contains(q);
      }).toList();
    }

    if (_sortBy == 'price_low') {
      filteredProducts.sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
    } else if (_sortBy == 'price_high') {
      filteredProducts.sort((a, b) => (b['price'] as num).compareTo(a['price'] as num));
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        title: Text(
          isBn ? 'কৃষি মার্কেটপ্লেস' : 'Agri Marketplace',
          style: GoogleFonts.hindSiliguri(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                style: GoogleFonts.hindSiliguri(color: textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: isBn ? 'কী খুঁজছেন? (যেমন: আম, চাল, মাছ)...' : 'Search products...',
                  hintStyle: GoogleFonts.hindSiliguri(color: textSecondary, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF1976D2), size: 22),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: textSecondary, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // 6 Categories Horizontal List
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final key = cat['key'] as String;
                final isSelected = _selectedCategory == key;
                final label = isBn ? cat['bn'] : cat['en'];

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      label,
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : textPrimary,
                      ),
                    ),
                    selected: isSelected,
                    backgroundColor: cardBg,
                    selectedColor: const Color(0xFF1976D2),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF1976D2) : borderColor,
                    ),
                    onSelected: (selected) {
                      setState(() => _selectedCategory = key);
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // Sort & Filter Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isBn
                      ? '${BanglaEnglishNumberHelper.toBanglaDigits(filteredProducts.length)} টি পণ্য পাওয়া গেছে'
                      : '${filteredProducts.length} items found',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
                DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  dropdownColor: cardBg,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 12,
                    color: const Color(0xFF1976D2),
                    fontWeight: FontWeight.bold,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'latest',
                      child: Text(isBn ? 'সর্বশেষ' : 'Latest'),
                    ),
                    DropdownMenuItem(
                      value: 'price_low',
                      child: Text(isBn ? 'দাম: কম → বেশি' : 'Price: Low → High'),
                    ),
                    DropdownMenuItem(
                      value: 'price_high',
                      child: Text(isBn ? 'দাম: বেশি → কম' : 'Price: High → Low'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _sortBy = value ?? 'latest');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Products List
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 56, color: textSecondary.withOpacity(0.5)),
                        const SizedBox(height: 10),
                        Text(
                          isBn ? 'কোনো পণ্য পাওয়া যায়নি' : 'No products found',
                          style: GoogleFonts.hindSiliguri(
                            color: textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _buildProductCard(
                        product: product,
                        isBn: isBn,
                        isDark: isDark,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard({
    required Map<String, dynamic> product,
    required bool isBn,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final String name = isBn ? product['nameBn'] : product['nameEn'];
    final String farmer = isBn ? product['farmerBn'] : product['farmerEn'];
    final String quantity = isBn ? product['quantityBn'] : product['quantityEn'];
    final String unit = isBn ? product['unitBn'] : product['unitEn'];
    final String badge = isBn ? product['badgeBn'] : product['badgeEn'];
    final double price = (product['price'] as num).toDouble();
    final double rating = (product['rating'] as num).toDouble();
    final String imageUrl = product['image'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image with Badge
          Stack(
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1976D2),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  farmer,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 11,
                    color: textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      quantity,
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 11,
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 2),
                    Text(
                      isBn ? BanglaEnglishNumberHelper.toBanglaDigits(rating.toStringAsFixed(1)) : rating.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Price and Order Now CTA Button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '৳${isBn ? BanglaEnglishNumberHelper.toBanglaDigits(price.toStringAsFixed(0)) : price.toStringAsFixed(0)} / $unit',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF15803D),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _openQuickBuy(product, isBn),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.flash_on_rounded, color: Colors.amberAccent, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        isBn ? 'কিনুন' : 'Buy',
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
