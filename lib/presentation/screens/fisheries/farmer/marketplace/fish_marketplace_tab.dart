import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/models/marketplace_item_model.dart';
import 'package:agrolinkbd/core/controllers/marketplace_controller.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/marketplace/checkout_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/marketplace/sell_fish_screen.dart';
import 'package:agrolinkbd/core/utils/responsive_helper.dart';

class FishMarketplaceTab extends StatefulWidget {
  const FishMarketplaceTab({super.key});

  @override
  State<FishMarketplaceTab> createState() => _FishMarketplaceTabState();
}

class _FishMarketplaceTabState extends State<FishMarketplaceTab> {
  final MarketplaceController _marketplaceController = Get.put(MarketplaceController());

  @override
  Widget build(BuildContext context) {
    const Color oceanBlue = Color(0xFF0288D1);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'মৎস্য বাজার',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: oceanBlue,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business, color: Colors.white),
            onPressed: () => Get.to(() => const SellFishScreen()),
            tooltip: 'মাছ বিক্রি করুন',
          ),
        ],
      ),
      body: Obx(() {
        if (_marketplaceController.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.storefront, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('বাজারে এখন কোনো মাছ নেই', style: GoogleFonts.hindSiliguri(fontSize: 18, color: Colors.grey.shade600)),
              ],
            ),
          );
        }

        final items = _marketplaceController.items;
        final isDesktop = ResponsiveHelper.isDesktop(context) || ResponsiveHelper.isTablet(context);

        Widget buildItemCard(MarketplaceItemModel product) {
          return Card(
            color: Theme.of(context).cardColor,
            margin: isDesktop ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: oceanBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.set_meal, size: 40, color: oceanBlue),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${product.quantityKg} কেজি',
                            style: GoogleFonts.hindSiliguri(fontSize: 10, color: Colors.orange.shade800),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.fishType,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        Text(
                          product.farmerName,
                          style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        Text(
                          'গড় ওজন: ${product.avgWeightGram} গ্রাম',
                          style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '৳${product.pricePerKg.toStringAsFixed(0)} /কেজি',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final checkoutProduct = {
                                  'id': product.id,
                                  'name': product.fishType,
                                  'type': '${product.quantityKg} কেজি',
                                  'price': product.pricePerKg, 
                                  'imageIcon': Icons.set_meal,
                                  'vendor': product.farmerName,
                                };
                                Get.to(() => CheckoutScreen(product: checkoutProduct));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: oceanBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text('অর্ডার করুন', style: GoogleFonts.hindSiliguri()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (isDesktop) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveHelper.getGridColumns(context),
              childAspectRatio: 2.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) => buildItemCard(items[index]),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) => buildItemCard(items[index]),
        );
      }),
    );
  }
}
