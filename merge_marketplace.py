import sys

file_path = "lib/presentation/screens/marketplace/marketplace_screen.dart"

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add cloud_firestore import
if "import 'package:cloud_firestore/cloud_firestore.dart';" not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';")

# 1. Update _categories to include 'key'
old_categories = """  final List<Map<String, dynamic>> _categories = [
    {'label': 'সব', 'icon': Icons.grid_view_rounded},
    {'label': 'সবজি', 'icon': Icons.grass_rounded},
    {'label': 'ফলমূল', 'icon': Icons.apple_rounded},
    {'label': 'চাল', 'icon': Icons.agriculture_rounded},
    {'label': 'মসলা', 'icon': Icons.local_florist_rounded},
    {'label': 'মাছ', 'icon': Icons.set_meal_rounded},
    {'label': 'মাংস', 'icon': Icons.kebab_dining_rounded},
    {'label': 'দুধ-ডিম', 'icon': Icons.egg_rounded},
  ];"""
new_categories = """  final List<Map<String, dynamic>> _categories = [
    {'label': 'সব', 'key': 'all', 'icon': Icons.grid_view_rounded},
    {'label': 'সবজি', 'key': 'vegetables', 'icon': Icons.grass_rounded},
    {'label': 'ফলমূল', 'key': 'fruits', 'icon': Icons.apple_rounded},
    {'label': 'চাল', 'key': 'grains', 'icon': Icons.agriculture_rounded},
    {'label': 'মসলা', 'key': 'spices', 'icon': Icons.local_florist_rounded},
    {'label': 'মাছ', 'key': 'fish', 'icon': Icons.set_meal_rounded},
    {'label': 'মাংস', 'key': 'meat', 'icon': Icons.kebab_dining_rounded},
    {'label': 'দুধ-ডিম', 'key': 'dairy', 'icon': Icons.egg_rounded},
  ];"""
content = content.replace(old_categories, new_categories)

# Remove the static _products and _filteredProducts getter
# I'll just find the block and remove it carefully using a regex or simple split since it's big.
# Because the user edited it, the exact text might not match.
# Instead of doing exact replace, I'll use index finding.

start_idx = content.find("final List<Map<String, dynamic>> _products = [")
end_idx = content.find("  @override\n  Widget build(BuildContext context) {")
if start_idx != -1 and end_idx != -1:
    content = content[:start_idx] + "\n" + content[end_idx:]

# Update the CustomScrollView slivers.
# Replace the SliverGrid that builds products with a StreamBuilder
grid_start = content.find("SliverPadding(\n            padding: const EdgeInsets.symmetric(horizontal: 16),")
grid_end = content.find("          ),\n        ],\n      ),\n    );\n  }\n\n  Widget _buildProductCard")

if grid_start != -1 and grid_end != -1:
    new_grid = """SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('bazaar_products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                var docs = snapshot.data?.docs ?? [];
                
                // Add static items (user mock data) plus firebase data
                List<Map<String, dynamic>> allProducts = [];
                
                // Firebase Data mapping
                for(var doc in docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  allProducts.add({
                    'id': doc.id,
                    'name': data['title'] ?? 'Unknown',
                    'price': (data['price'] ?? 0).toDouble(),
                    'unit': data['unit'] ?? 'kg',
                    'farmer': 'AgroLink Farm', // or fetch from user profile if stored
                    'farmerId': data['userId'],
                    'location': data['location'] ?? 'Unknown',
                    'image': data['imageUrl'] ?? 'https://via.placeholder.com/150',
                    'rating': 4.5,
                    'category': data['category'] ?? 'other',
                    'badge': 'New',
                    'isVerified': true,
                  });
                }

                // Add Mock Data so user's Rui and Himsagor are preserved if they weren't in Firebase!
                allProducts.addAll([
                  {
                    'name': 'আম (হিমসাগর)',
                    'price': 120,
                    'unit': 'কেজি',
                    'farmer': 'রাজশাহী ফ্রুট',
                    'location': 'রাজশাহী',
                    'image': 'https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?q=80&w=600&auto=format&fit=crop',
                    'rating': 4.9,
                    'category': 'fruits',
                    'badge': 'Top Rated',
                    'isVerified': true,
                  },
                  {
                    'name': 'রুই মাছ (হালদা)',
                    'price': 350,
                    'unit': 'কেজি',
                    'farmer': 'মৎস্য খামার',
                    'location': 'ময়মনসিংহ',
                    'image': 'https://images.unsplash.com/photo-1524824267900-2fa9cbf7a506?q=80&w=600&auto=format&fit=crop',
                    'rating': 4.7,
                    'category': 'fish',
                    'badge': 'Fresh',
                    'isVerified': true,
                  },
                ]);

                // Filter logic
                String selectedKey = 'all';
                for(var c in _categories) {
                  if(c['label'] == _selectedCategory) {
                    selectedKey = c['key'];
                    break;
                  }
                }

                var products = selectedKey == 'all' 
                    ? allProducts 
                    : allProducts.where((p) => p['category'] == selectedKey).toList();

                if (_sortBy == 'price_low') {
                  products.sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
                } else if (_sortBy == 'price_high') {
                  products.sort((a, b) => (b['price'] as num).compareTo(a['price'] as num));
                } else if (_sortBy == 'rating') {
                  products.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
                }

                if (products.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('কোনো পণ্য পাওয়া যায়নি')),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(products[index]);
                    },
                  ),
                );
              },
            ),
"""
    content = content[:grid_start] + new_grid + content[grid_end:]

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Merged Bazaar with MarketplaceScreen successfully!")
