import sys

file_path = "lib/presentation/screens/marketplace/marketplace_screen.dart"

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# I will replace from "// PRODUCT COUNT" down to the end of the PRODUCT GRID SliverPadding
start_marker = "// PRODUCT COUNT"
end_marker = "const SliverToBoxAdapter(child: SizedBox(height: 80)),"

start_idx = content.find(start_marker)
end_idx = content.find(end_marker)

if start_idx != -1 and end_idx != -1:
    new_code = """// PRODUCT GRID WITH FIREBASE
          SliverToBoxAdapter(
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
                
                List<Map<String, dynamic>> allProducts = [];
                
                for(var doc in docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  allProducts.add({
                    'id': doc.id,
                    'name': data['title'] ?? 'Unknown',
                    'price': (data['price'] ?? 0).toDouble(),
                    'unit': data['unit'] ?? 'kg',
                    'farmer': 'AgroLink Farm',
                    'farmerId': data['userId'],
                    'location': data['location'] ?? 'Unknown',
                    'image': data['imageUrl'] ?? 'https://via.placeholder.com/150',
                    'rating': 4.5,
                    'category': data['category'] ?? 'other',
                    'badge': 'New',
                    'isVerified': true,
                  });
                }

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
                  products.sort((a, b) => (b['rating'] as num).compareTo(a['rating'] as num));
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text(
                        '${products.length} টি পণ্য পাওয়া গেছে',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    if (products.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            children: [
                              Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text('কোনো পণ্য পাওয়া যায়নি', style: GoogleFonts.hindSiliguri(color: Colors.grey.shade600, fontSize: 16)),
                            ],
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.68,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            return _buildProductCard(products[index]);
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          
          """
    content = content[:start_idx] + new_code + content[end_idx:]
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Fixed marketplace_screen.dart")
else:
    print("Could not find markers")
