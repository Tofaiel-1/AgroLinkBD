import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/providers/service_provider_providers.dart';
import 'package:agrolinkbd/core/models/service_provider_models.dart';

/// Product Catalog Screen for Service Provider
/// Grid/List of all products with category filters, search, and inline actions
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
    final allProducts = ref.watch(serviceProductProvider);
    final categoryFilter = ref.watch(serviceProductCategoryFilterProvider);

    final filteredProducts = allProducts.where((p) {
      final matchesCategory = categoryFilter == null || p.category == categoryFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.brand?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4527A0),
        title: Text('আমার পণ্য', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded, color: Colors.white),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'পণ্য খুঁজুন...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Category Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('সব', null, categoryFilter),
                  ...ServiceProductCategory.values.map(
                    (cat) => _buildFilterChip(cat.bengaliName, cat, categoryFilter),
                  ),
                ],
              ),
            ),
          ),

          // Product Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredProducts.length} টি পণ্য',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
                ),
                Text(
                  categoryFilter != null ? categoryFilter.bengaliName : 'সব ক্যাটাগরি',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF4527A0)),
                ),
              ],
            ),
          ),

          // Products Grid/List
          Expanded(
            child: filteredProducts.isEmpty
                ? _buildEmptyState()
                : _isGridView
                    ? GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) => _buildProductGridCard(filteredProducts[index]),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) => _buildProductListCard(filteredProducts[index]),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.snackbar(
            'পণ্য যুক্ত করুন',
            'নতুন পণ্য যুক্ত করার ফর্ম শীঘ্রই আসছে!',
            backgroundColor: const Color(0xFF4527A0),
            colorText: Colors.white,
          );
        },
        backgroundColor: const Color(0xFF4527A0),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('পণ্য যোগ করুন', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildFilterChip(String label, ServiceProductCategory? category, ServiceProductCategory? activeFilter) {
    final isSelected = category == activeFilter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 12,
          ),
        ),
        selected: isSelected,
        selectedColor: const Color(0xFF4527A0),
        backgroundColor: Colors.grey.shade100,
        side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300),
        onSelected: (selected) {
          ref.read(serviceProductCategoryFilterProvider.notifier).state = selected ? category : null;
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('এই ক্যাটাগরিতে কোনো পণ্য নেই', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildProductGridCard(ServiceProduct product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF4527A0).withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Stack(
              children: [
                Center(child: Text(product.category.icon, style: const TextStyle(fontSize: 40))),
                // Discount badge
                if (product.hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-${product.discountPercentage.toStringAsFixed(0)}%',
                        style: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                // Stock indicator
                if (product.isLowStock || product.isOutOfStock)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: product.isOutOfStock ? Colors.red : Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.isOutOfStock ? 'স্টক শেষ' : 'কম',
                        style: GoogleFonts.poppins(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (product.hasDiscount)
                            Text(
                              '৳${product.price.toStringAsFixed(0)} ',
                              style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey, decoration: TextDecoration.lineThrough),
                            ),
                          Text(
                            '৳${product.effectivePrice.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'স্টক: ${product.stockQuantity}',
                            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500),
                          ),
                          Row(
                            children: [
                              Icon(Icons.star, size: 12, color: Colors.amber.shade600),
                              Text(' ${product.rating}', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600)),
                            ],
                          ),
                        ],
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

  Widget _buildProductListCard(ServiceProduct product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF4527A0).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text(product.category.icon, style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${product.brand ?? ""} • স্টক: ${product.stockQuantity} ${product.unit}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('৳${product.effectivePrice.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text('৳${product.price.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Switch(
                  value: product.isAvailable,
                  activeColor: const Color(0xFF4527A0),
                  onChanged: (val) {
                    ref.read(serviceProductProvider.notifier).toggleAvailability(product.id);
                  },
                ),
                Text(product.isAvailable ? 'সক্রিয়' : 'নিষ্ক্রিয়', style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
