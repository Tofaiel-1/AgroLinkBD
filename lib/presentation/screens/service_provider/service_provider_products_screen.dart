import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/providers/service_provider_providers.dart';
import 'package:agrolinkbd/core/models/service_provider_models.dart';

import 'package:agrolinkbd/presentation/screens/service_provider/add_service_product_screen.dart';

/// Product Catalog Screen for Service Provider
/// Compact Grid/List with optimal screen usage and tight spacing
class ServiceProviderProductsScreen extends ConsumerStatefulWidget {
  const ServiceProviderProductsScreen({super.key});

  @override
  ConsumerState<ServiceProviderProductsScreen> createState() => _ServiceProviderProductsScreenState();
}

class _ServiceProviderProductsScreenState extends ConsumerState<ServiceProviderProductsScreen> {
  String _searchQuery = '';
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final isBn = LanguageProvider.isBn(context);
    final allProducts = ref.watch(serviceProductProvider);
    final categoryFilter = ref.watch(serviceProductCategoryFilterProvider);

    final filteredProducts = allProducts.where((p) {
      final matchesCategory = categoryFilter == null || p.category == categoryFilter;
      final q = _searchQuery.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          (p.nameEN?.toLowerCase().contains(q) ?? false) ||
          (p.brand?.toLowerCase().contains(q) ?? false);
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B32B2),
        elevation: 0,
        titleSpacing: 0,
        title: Text(
          isBn ? 'আমার পণ্য ক্যাটালগ' : 'My Product Catalogs',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Compact Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            child: SizedBox(
              height: 38,
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: GoogleFonts.poppins(fontSize: 12.5),
                decoration: InputDecoration(
                  hintText: isBn ? 'পণ্য বা ব্র্যান্ড খুঁজুন...' : 'Search product or brand...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 12),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 18),
                  filled: true,
                  fillColor: const Color(0xFFF1F3F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                ),
              ),
            ),
          ),

          // Compact Category Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip(isBn ? 'সব' : 'All', null, categoryFilter),
                  ...ServiceProductCategory.values.map(
                    (cat) => _buildFilterChip(isBn ? cat.bengaliName : cat.englishName, cat, categoryFilter),
                  ),
                ],
              ),
            ),
          ),

          // Compact Product Count Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isBn ? '${filteredProducts.length} টি পণ্য' : '${filteredProducts.length} Products',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                ),
                Text(
                  categoryFilter != null
                      ? (isBn ? categoryFilter.bengaliName : categoryFilter.englishName)
                      : (isBn ? 'সব ক্যাটাগরি' : 'All Categories'),
                  style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w600, color: const Color(0xFF2B32B2)),
                ),
              ],
            ),
          ),

          // Products Grid / List with efficient spacing
          Expanded(
            child: filteredProducts.isEmpty
                ? _buildEmptyState(isBn)
                : _isGridView
                    ? GridView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 2, 12, 70),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.83,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) => _buildProductGridCard(filteredProducts[index], isBn),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 2, 12, 70),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) => _buildProductListCard(filteredProducts[index], isBn),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const AddServiceProductScreen()),
        backgroundColor: const Color(0xFF2B32B2),
        elevation: 3,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        label: Text(
          isBn ? 'পণ্য যোগ করুন' : 'Add Product',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, ServiceProductCategory? category, ServiceProductCategory? activeFilter) {
    final isSelected = category == activeFilter;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 11,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        selected: isSelected,
        selectedColor: const Color(0xFF2B32B2),
        backgroundColor: Colors.grey.shade100,
        side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300),
        onSelected: (selected) {
          ref.read(serviceProductCategoryFilterProvider.notifier).state = selected ? category : null;
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isBn) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 54, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text(
              isBn ? 'এই ক্যাটাগরিতে কোনো পণ্য নেই' : 'No products in this category',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () => Get.to(() => const AddServiceProductScreen()),
              icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
              label: Text(
                isBn ? 'নতুন পণ্য যোগ করুন' : 'Add New Product',
                style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B32B2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGridCard(ServiceProduct product, bool isBn) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 0.8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 1.5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Product Image Container
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            child: SizedBox(
              height: 105,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (product.images.isNotEmpty)
                    Image.network(
                      product.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF2B32B2).withValues(alpha: 0.06),
                        child: Center(
                          child: Text(product.category.icon, style: const TextStyle(fontSize: 32)),
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2B32B2)),
                            ),
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      color: const Color(0xFF2B32B2).withValues(alpha: 0.06),
                      child: Center(
                        child: Text(product.category.icon, style: const TextStyle(fontSize: 32)),
                      ),
                    ),
                  // Discount badge
                  if (product.hasDiscount)
                    Positioned(
                      top: 5,
                      left: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${product.discountPercentage.toStringAsFixed(0)}%',
                          style: GoogleFonts.poppins(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  // Stock / Rent badge
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (product.isForRent)
                          Container(
                            margin: const EdgeInsets.only(bottom: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2B32B2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isBn ? 'ভাড়া' : 'Rent',
                              style: GoogleFonts.poppins(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        if (product.isLowStock || product.isOutOfStock)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: product.isOutOfStock ? Colors.red.shade700 : Colors.orange.shade800,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              product.isOutOfStock
                                  ? (isBn ? 'স্টক শেষ' : 'Out')
                                  : (isBn ? 'কম স্টক' : 'Low'),
                              style: GoogleFonts.poppins(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 2. Compact Details Area (Tight Stacking, No Dead Space)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Title
                Text(
                  product.getName(isBn),
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                    height: 1.15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                // Brand / Category
                Text(
                  product.brand ?? (isBn ? product.category.bengaliName : product.category.englishName),
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Price Row (directly beneath brand)
                Row(
                  children: [
                    Text(
                      '৳${product.effectivePrice.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2B32B2),
                      ),
                    ),
                    if (product.hasDiscount) ...[
                      const SizedBox(width: 4),
                      Text(
                        '৳${product.price.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 9.5,
                          color: Colors.grey.shade400,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                // Stock & Rating Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${isBn ? 'মজুদ: ' : 'Stock: '}${product.stockQuantity} ${product.getUnit(isBn)}',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, size: 12, color: Colors.amber.shade700),
                        Text(
                          ' ${product.rating}',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
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

  Widget _buildProductListCard(ServiceProduct product, bool isBn) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 0.8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 1.5)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 52,
                height: 52,
                child: product.images.isNotEmpty
                    ? Image.network(
                        product.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF2B32B2).withValues(alpha: 0.06),
                          child: Center(child: Text(product.category.icon, style: const TextStyle(fontSize: 24))),
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF2B32B2)),
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: const Color(0xFF2B32B2).withValues(alpha: 0.06),
                        child: Center(child: Text(product.category.icon, style: const TextStyle(fontSize: 24))),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.getName(isBn),
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, height: 1.15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${product.brand ?? ""} • ${isBn ? 'স্টক:' : 'Stock:'} ${product.stockQuantity} ${product.getUnit(isBn)}',
                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '৳${product.effectivePrice.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFF2B32B2)),
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 4),
                        Text(
                          '৳${product.price.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(fontSize: 9.5, color: Colors.grey.shade400, decoration: TextDecoration.lineThrough),
                        ),
                      ],
                      if (product.isForRent && product.rentPricePerDay != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2B32B2).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isBn
                                ? 'ভাড়া: ৳${product.rentPricePerDay?.toStringAsFixed(0)}/দিন'
                                : 'Rent: ৳${product.rentPricePerDay?.toStringAsFixed(0)}/day',
                            style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF2B32B2), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 0.78,
              child: Switch(
                value: product.isAvailable,
                activeThumbColor: const Color(0xFF2B32B2),
                onChanged: (val) {
                  ref.read(serviceProductProvider.notifier).toggleAvailability(product.id);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

