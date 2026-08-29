import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/models/fish_auction_model.dart';
import 'package:agrolinkbd/core/services/fish_auction_service.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/buyer/auction/fish_buyer_bid_screen.dart';

class FishBuyerAuctionListScreen extends StatefulWidget {
  const FishBuyerAuctionListScreen({super.key});

  @override
  State<FishBuyerAuctionListScreen> createState() => _FishBuyerAuctionListScreenState();
}

class _FishBuyerAuctionListScreenState extends State<FishBuyerAuctionListScreen> {
  String _filterSpecies = 'সব';
  String _filterCondition = 'সব';

  final List<String> _speciesList = ['সব', 'দেশি রুই', 'কাতলা', 'বাগদা চিংড়ি', 'গলদা চিংড়ি', 'পাঙ্গাশ', 'শিং ও মাগুর', 'তেলাপিয়া'];

  @override
  Widget build(BuildContext context) {
    const Color oceanBlue = Color(0xFF0288D1);
    const Color deepAqua = Color(0xFF006064);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final auctionService = Get.isRegistered<FishAuctionService>()
        ? Get.find<FishAuctionService>()
        : Get.put(FishAuctionService());

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'মাছের লাইভ পাইকারি নিলাম ঘর',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: deepAqua,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Chips Scroll
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: Theme.of(context).cardColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _speciesList.map((species) {
                  final isSelected = _filterSpecies == species;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        species,
                        style: GoogleFonts.hindSiliguri(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: deepAqua,
                      backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      onSelected: (selected) {
                        if (selected) setState(() => _filterSpecies = species);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Auctions List
          Expanded(
            child: Obx(() {
              var list = auctionService.auctions.where((a) => a.status == FishAuctionStatus.live).toList();
              if (_filterSpecies != 'সব') {
                list = list.where((a) => a.fishSpecies.contains(_filterSpecies)).toList();
              }

              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.gavel, size: 70, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'এই ক্যাটাগরিতে এখন কোনো লাইভ ডাক নেই',
                        style: GoogleFonts.hindSiliguri(fontSize: 16, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final auction = list[index];
                  final currentRate = auction.currentHighestBidPerKg ?? auction.startingPricePerKg;
                  final totalValue = currentRate * auction.estimatedTotalKg;

                  return Card(
                    color: Theme.of(context).cardColor,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                    child: InkWell(
                      onTap: () => Get.to(() => FishBuyerBidScreen(auctionId: auction.id)),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header: Condition Tag + Countdown
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: auction.condition == FishCondition.liveInWater
                                        ? Colors.cyan.shade50
                                        : Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: auction.condition == FishCondition.liveInWater
                                          ? Colors.cyan.shade700
                                          : Colors.blue.shade700,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        auction.condition == FishCondition.liveInWater
                                            ? Icons.water
                                            : Icons.ac_unit,
                                        size: 14,
                                        color: auction.condition == FishCondition.liveInWater
                                            ? Colors.cyan.shade800
                                            : Colors.blue.shade800,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        auction.condition == FishCondition.liveInWater
                                            ? 'জ্যান্ত মাছ (Live Tank)'
                                            : 'বরফ ঢাকা তাজা',
                                        style: GoogleFonts.hindSiliguri(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: auction.condition == FishCondition.liveInWater
                                              ? Colors.cyan.shade900
                                              : Colors.blue.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.timer, size: 14, color: Colors.red),
                                      const SizedBox(width: 4),
                                      Text(
                                        'বাকি ${auction.remainingTime.inHours}ঘ ${auction.remainingTime.inMinutes % 60}মি',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),
                            Text(
                              auction.lotTitle,
                              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'খামার: ${auction.farmLocation} • বিক্রেতা: ${auction.farmerName}',
                              style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
                            ),

                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildAuctionMetric('মোট ওজন', '${auction.estimatedTotalKg.toInt()} কেজি'),
                                _buildAuctionMetric('গড় সাইজ', '${auction.avgWeightGram.toInt()} গ্রাম'),
                                _buildAuctionMetric('বর্তমান দর', '৳${currentRate.toStringAsFixed(0)}/কেজি', isHighlight: true),
                              ],
                            ),

                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('মোট আনুমানিক বিল', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
                                    Text('৳${totalValue.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => Get.to(() => FishBuyerBidScreen(auctionId: auction.id)),
                                  icon: const Icon(Icons.touch_app, size: 16, color: Colors.white),
                                  label: Text(
                                    'ডাক দিন (Bid Now)',
                                    style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: deepAqua,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAuctionMetric(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isHighlight ? const Color(0xFF006064) : null,
          ),
        ),
      ],
    );
  }
}
