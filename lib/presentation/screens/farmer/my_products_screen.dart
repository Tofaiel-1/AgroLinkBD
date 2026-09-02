import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/presentation/screens/bazaar/add_product_screen.dart';

/// My Products Screen - Farmers manage their listed products
class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  final List<Map<String, dynamic>> products = [
    {
      'id': 1,
      'nameBn': 'টাটকা টমেটো',
      'nameEn': 'Fresh Tomatoes',
      'quantity': 100,
      'price': 45,
      'categoryBn': 'সবজি',
      'categoryEn': 'Vegetables',
      'status': 'active',
      'orders': 12,
    },
    {
      'id': 2,
      'nameBn': 'জৈব পেঁয়াজ',
      'nameEn': 'Organic Onions',
      'quantity': 50,
      'price': 35,
      'categoryBn': 'সবজি',
      'categoryEn': 'Vegetables',
      'status': 'active',
      'orders': 8,
    },
    {
      'id': 3,
      'nameBn': 'মানসম্পন্ন আলু',
      'nameEn': 'Quality Potatoes',
      'quantity': 200,
      'price': 25,
      'categoryBn': 'সবজি',
      'categoryEn': 'Vegetables',
      'status': 'sold_out',
      'orders': 15,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bool isBn = LanguageProvider.isBn(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isBn ? 'আমার পণ্য ও দোকান' : 'My Shop & Products',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isBn ? 'কোন পণ্য নেই' : 'No products listed',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Get.to(() => const AddProductScreen()),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: Text(
                      isBn ? 'নতুন পণ্য যোগ করুন' : 'Add New Product',
                      style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final bool isActive = product['status'] == 'active';
                final String name = isBn ? product['nameBn'] : product['nameEn'];
                final String statusText = isActive 
                    ? (isBn ? 'সক্রিয়' : 'Active') 
                    : (isBn ? 'স্টক শেষ' : 'Sold Out');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: GoogleFonts.hindSiliguri(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${product['quantity']} ${isBn ? "কেজি" : "kg"} • ৳${product['price']}/${isBn ? "কেজি" : "kg"}',
                                    style: GoogleFonts.hindSiliguri(
                                      fontSize: 12.5,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                statusText,
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 11,
                                  color: isActive ? Colors.green.shade800 : Colors.orange.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${product['orders']} ${isBn ? "অর্ডার সম্পন্ন" : "Orders Completed"}',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 11.5,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Get.to(() => const AddProductScreen());
                                },
                                icon: const Icon(Icons.edit, size: 14, color: Color(0xFF2E7D32)),
                                label: Text(
                                  isBn ? 'সম্পাদনা' : 'Edit',
                                  style: GoogleFonts.hindSiliguri(
                                    color: const Color(0xFF2E7D32),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF2E7D32)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(isBn ? 'পণ্য মুছে ফেলা হয়েছে' : 'Product deleted'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.delete_outline, size: 14, color: Colors.red),
                                label: Text(
                                  isBn ? 'মুছুন' : 'Delete',
                                  style: GoogleFonts.hindSiliguri(color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E7D32),
        onPressed: () => Get.to(() => const AddProductScreen()),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
