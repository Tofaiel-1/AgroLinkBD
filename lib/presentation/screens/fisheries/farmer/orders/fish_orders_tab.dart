import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/services/fish_auction_service.dart';
import 'package:agrolinkbd/core/models/fish_auction_model.dart';
import 'package:agrolinkbd/core/models/fish_harvest_contract_model.dart';

class FishOrdersTab extends StatelessWidget {
  const FishOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    const Color deepAqua = Color(0xFF006064);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final auctionService = Get.isRegistered<FishAuctionService>()
        ? Get.find<FishAuctionService>()
        : Get.put(FishAuctionService());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text(
            'মৎস্য বিক্রয় ও অর্ডার বুকিং',
            style: GoogleFonts.hindSiliguri(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: deepAqua,
          elevation: 0,
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: Colors.amberAccent,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: 'নিলামের বিক্রয় অর্ডার', icon: Icon(Icons.gavel, size: 18)),
              Tab(text: 'আগাম চুক্তি বুকিং', icon: Icon(Icons.assignment_turned_in, size: 18)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: Auction Sales
            Obx(() {
              final auctions = auctionService.auctions;
              if (auctions.isEmpty) {
                return Center(
                  child: Text('কোনো সক্রিয় নিলাম বা বিক্রয় অর্ডার নেই', style: GoogleFonts.hindSiliguri()),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: auctions.length,
                itemBuilder: (context, index) {
                  final a = auctions[index];
                  final isAwarded = a.status == FishAuctionStatus.awarded;

                  return Card(
                    color: Theme.of(context).cardColor,
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isAwarded ? Colors.green.shade50 : Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isAwarded ? 'বিক্রি চূড়ান্ত (এসক্রো লকড)' : 'লাইভ ডাক চলছে (${a.bids.length}টি বিড)',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isAwarded ? Colors.green.shade800 : Colors.blue.shade800,
                                  ),
                                ),
                              ),
                              Text(
                                a.id,
                                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            a.lotTitle,
                            style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'পরিমাণ: ${a.estimatedTotalKg.toInt()} কেজি | গড়: ${a.avgWeightGram.toInt()} গ্রাম',
                                style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade700),
                              ),
                              Text(
                                '৳${a.currentTotalEstimatedValue.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'সর্বোচ্চ বিডার: ${a.highestBidderName ?? "অপেক্ষারত"}',
                                style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Get.toNamed('/live-auction/${a.id}') ??
                                      Get.to(() => const SizedBox());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: deepAqua,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                                child: Text('বিবরণ দেখুন', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),

            // TAB 2: Pre-Harvest Contracts
            Obx(() {
              final contracts = auctionService.contracts;
              if (contracts.isEmpty) {
                return Center(
                  child: Text('কোনো আগাম চুক্তি রেকর্ড পাওয়া যায়নি', style: GoogleFonts.hindSiliguri()),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: contracts.length,
                itemBuilder: (context, index) {
                  final c = contracts[index];
                  final isBooked = c.status == FishContractStatus.depositPaid;

                  return Card(
                    color: Theme.of(context).cardColor,
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isBooked ? Colors.green.shade50 : Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isBooked ? 'অগ্রিম ক্যাশ এসক্রোতে প্রাপ্ত' : 'বায়ারের অপেক্ষায় উন্মুক্ত',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isBooked ? Colors.green.shade800 : Colors.amber.shade900,
                                  ),
                                ),
                              ),
                              Text('হারভেস্ট: ${c.daysUntilHarvest} দিন বাকি', style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.bold, color: deepAqua)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text('${c.pondName} - ${c.fishSpecies}', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('ফলন: ${c.estimatedYieldKg.toInt()} কেজি @ ৳${c.agreedPricePerKg.toStringAsFixed(0)}', style: GoogleFonts.hindSiliguri(fontSize: 13)),
                              Text('মোট: ৳${c.estimatedTotalValue.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.green.shade700, fontSize: 15)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
