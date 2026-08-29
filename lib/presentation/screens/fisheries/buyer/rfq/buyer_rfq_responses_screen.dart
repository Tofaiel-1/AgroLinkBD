import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/models/fish_rfq_model.dart';
import 'package:agrolinkbd/core/services/fish_auction_service.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/buyer/rfq/post_fish_rfq_screen.dart';

class BuyerRfqResponsesScreen extends StatelessWidget {
  const BuyerRfqResponsesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color deepAqua = Color(0xFF006064);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final auctionService = Get.isRegistered<FishAuctionService>()
        ? Get.find<FishAuctionService>()
        : Get.put(FishAuctionService());

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'আমার চাহিদাপত্র ও দর প্রস্তাব',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: deepAqua,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: () => Get.to(() => const PostFishRfqScreen()),
            tooltip: 'নতুন চাহিদাপত্র',
          ),
        ],
      ),
      body: Obx(() {
        final rfqs = auctionService.rfqs;

        if (rfqs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.speaker_notes_off, size: 70, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text('কোনো চাহিদাপত্র পোস্ট করা হয়নি', style: GoogleFonts.hindSiliguri(fontSize: 16, color: Colors.grey.shade600)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => const PostFishRfqScreen()),
                  icon: const Icon(Icons.add),
                  label: Text('চাহিদাপত্র পোস্ট করুন', style: GoogleFonts.hindSiliguri()),
                  style: ElevatedButton.styleFrom(backgroundColor: deepAqua),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rfqs.length,
          itemBuilder: (context, index) {
            final rfq = rfqs[index];

            return Card(
              color: Theme.of(context).cardColor,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: ExpansionTile(
                initiallyExpanded: rfq.quotes.isNotEmpty,
                title: Text(
                  '${rfq.fishSpecies} (${rfq.requiredQuantityKg.toInt()} কেজি)',
                  style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  'টার্গেট বাজেট: ৳${rfq.targetBudgetPerKg.toStringAsFixed(0)}/কেজি • প্রস্তাব পেয়েছে: ${rfq.quotes.length}টি',
                  style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('খামারিদের পাঠানো কোটেশনসমূহ:', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 10),
                        if (rfq.quotes.isEmpty)
                          Text('এখনও কোনো খামারি কোটেশন পাঠায়নি।', style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey))
                        else
                          ...rfq.quotes.map((q) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(q.farmerName, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text('৳${q.offeredPricePerKg.toStringAsFixed(0)} /কেজি', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.green.shade700, fontSize: 15)),
                                    ],
                                  ),
                                  Text('খামার: ${q.farmLocation} • গড় সাইজ: ${q.avgWeightGram.toInt()} গ্রাম', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600)),
                                  if (q.message.isNotEmpty)
                                    Text('বার্তা: "${q.message}"', style: GoogleFonts.hindSiliguri(fontSize: 11, fontStyle: FontStyle.italic)),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Get.snackbar(
                                            'অর্ডার নিশ্চিত ও এসক্রো প্রস্তুত 🤝',
                                            '${q.farmerName} এর দর গ্রহণ করা হয়েছে। অগ্রিম এসক্রো পেমেন্টে রিডাইরেক্ট করা হচ্ছে।',
                                            backgroundColor: Colors.green.shade700,
                                            colorText: Colors.white,
                                          );
                                        },
                                        icon: const Icon(Icons.handshake, size: 16, color: Colors.white),
                                        label: Text('দর গ্রহণ করুন (Accept)', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white)),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const PostFishRfqScreen()),
        backgroundColor: deepAqua,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('নতুন চাহিদাপত্র', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
