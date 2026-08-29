import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agrolinkbd/core/models/market_price_model.dart';
import 'package:agrolinkbd/presentation/widgets/quick_buy_bottom_sheet.dart';

class CommodityOrderBookScreen extends StatefulWidget {
  const CommodityOrderBookScreen({super.key});

  @override
  State<CommodityOrderBookScreen> createState() => _CommodityOrderBookScreenState();
}

class _CommodityOrderBookScreenState extends State<CommodityOrderBookScreen> {
  late MarketPriceModel commodity;

  @override
  void initState() {
    super.initState();
    commodity = Get.arguments as MarketPriceModel;
  }

  @override
  Widget build(BuildContext context) {
    bool isTrendUp = commodity.trend == PriceTrend.up;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        title: Text(
          commodity.productName,
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Base Price Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agrolink Base Price',
                      style: GoogleFonts.hindSiliguri(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    Text(
                      '৳${commodity.currentPrice} / ${commodity.unit}',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B5E20),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isTrendUp ? Colors.red.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isTrendUp ? Colors.red.shade200 : Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isTrendUp ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                        color: isTrendUp ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isTrendUp ? 'উচ্চমূল্য (Surge)' : 'স্বাভাবিক',
                        style: GoogleFonts.hindSiliguri(
                          color: isTrendUp ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Order Book Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.list_alt, color: Color(0xFF1B5E20)),
                const SizedBox(width: 8),
                Text(
                  'কৃষকদের তালিকা (Order Book)',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Order Book List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('status', isEqualTo: 'ProductStatus.available')
                  // Simple check for commodity name
                  // Note: Firestore doesn't support 'LIKE', so this requires exact title match or fetching all and filtering locally.
                  // For the sake of this prototype, we'll fetch all and filter in memory.
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final docs = snapshot.data?.docs ?? [];
                
                // Filter locally because Firestore lacks string 'contains' queries
                List<Map<String, dynamic>> orderBook = [];
                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = data['title']?.toString() ?? '';
                  if (title.contains(commodity.productName) || commodity.productName.contains(title)) {
                    data['id'] = doc.id;
                    orderBook.add(data);
                  }
                }

                // Sort by price (Lowest to Highest)
                orderBook.sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));

                if (orderBook.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'বর্তমানে কোনো কৃষক এই পণ্য বিক্রি করছেন না',
                          style: GoogleFonts.hindSiliguri(color: Colors.grey.shade600, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: orderBook.length,
                  itemBuilder: (context, index) {
                    final item = orderBook[index];
                    final price = (item['price'] as num).toDouble();
                    final diff = price - commodity.currentPrice;
                    final isCheaper = diff <= 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                        border: Border(left: BorderSide(color: isCheaper ? Colors.green : Colors.red, width: 4)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFF1B5E20).withOpacity(0.1),
                              child: const Icon(Icons.person, color: Color(0xFF1B5E20)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['sellerName'] ?? 'অজানা কৃষক',
                                    style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    '${item['quantity']} ${item['unit']} Available • ${item['location'] ?? item['district'] ?? ''}',
                                    style: GoogleFonts.hindSiliguri(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '৳$price / ${item['unit']}',
                                  style: GoogleFonts.hindSiliguri(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isCheaper ? Colors.green.shade700 : Colors.red.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ElevatedButton(
                                  onPressed: () {
                                    // Adapt product map for QuickBuyBottomSheet
                                    Map<String, dynamic> adaptedProduct = {
                                      'id': item['id'],
                                      'name': item['title'],
                                      'price': price,
                                      'unit': item['unit'],
                                      'farmer': item['sellerName'],
                                      'farmerId': item['sellerId'],
                                      'location': item['location'] ?? item['district'] ?? 'বাংলাদেশ',
                                      'image': (item['images'] != null && item['images'].isNotEmpty) ? item['images'][0] : 'https://via.placeholder.com/150',
                                      'rating': 4.5, // placeholder
                                      'category': item['category'],
                                      'isVerified': true,
                                    };
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => QuickBuyBottomSheet(product: adaptedProduct),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1B5E20),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                    minimumSize: const Size(0, 32),
                                  ),
                                  child: Text('Buy Now', style: GoogleFonts.hindSiliguri(fontSize: 12)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
