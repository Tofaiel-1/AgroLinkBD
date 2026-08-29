import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/models/fish_auction_model.dart';
import 'package:agrolinkbd/core/services/fish_auction_service.dart';

class LiveFishAuctionScreen extends StatelessWidget {
  final String auctionId;

  const LiveFishAuctionScreen({super.key, required this.auctionId});

  @override
  Widget build(BuildContext context) {
    const Color deepAqua = Color(0xFF006064);
    const Color oceanBlue = Color(0xFF0288D1);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final auctionService = Get.isRegistered<FishAuctionService>()
        ? Get.find<FishAuctionService>()
        : Get.put(FishAuctionService());

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'লাইভ মাছ নিলাম কন্ট্রোল রুম',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: deepAqua,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        final auction = auctionService.auctions.firstWhereOrNull((a) => a.id == auctionId);
        if (auction == null) {
          return Center(
            child: Text('নিলামটি পাওয়া যায়নি', style: GoogleFonts.hindSiliguri(fontSize: 16)),
          );
        }

        final currentRate = auction.currentHighestBidPerKg ?? auction.startingPricePerKg;
        final totalEstValue = currentRate * auction.estimatedTotalKg;
        final highestBidder = auction.bids.isNotEmpty ? auction.bids.first : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Status Header Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF006064), Color(0xFF00838F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.fiber_manual_record, color: Colors.white, size: 10),
                              const SizedBox(width: 4),
                              Text(
                                'LIVE ডাক চলছে',
                                style: GoogleFonts.hindSiliguri(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.timer, color: Colors.amberAccent, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'বাকি: ${auction.remainingTime.inHours}ঘণ্টা ${auction.remainingTime.inMinutes % 60}মিনিট',
                              style: GoogleFonts.hindSiliguri(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      auction.lotTitle,
                      style: GoogleFonts.hindSiliguri(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildHeaderStat('মোট পরিমাণ', '${auction.estimatedTotalKg.toInt()} কেজি'),
                        _buildHeaderStat('গড় ওজন', '${auction.avgWeightGram.toInt()} গ্রাম'),
                        _buildHeaderStat('অবস্থা', auction.condition == FishCondition.liveInWater ? 'জ্যান্ত মাছ 🐟' : 'বরফ তাজা 🧊'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Highest Bid Display Card (Ultra Premium)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.shade600, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'সর্বোচ্চ লাইভ প্রস্তাব (Highest Bid)',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Text(
                            'মোট বিড: ${auction.bids.length}টি',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '৳${currentRate.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF006064),
                              ),
                            ),
                            Text(
                              'প্রতি কেজি দর',
                              style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '৳${totalEstValue.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            Text(
                              'লটের মোট সম্ভাব্য মূল্য',
                              style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    if (highestBidder != null) ...[
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(0xFF006064),
                            child: Icon(Icons.storefront, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  highestBidder.bidderName,
                                  style: GoogleFonts.hindSiliguri(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  highestBidder.bidderOrganization ?? 'নিবন্ধিত পাইকার',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              _showAcceptDealDialog(context, auction, highestBidder);
                            },
                            icon: const Icon(Icons.handshake, size: 18, color: Colors.white),
                            label: Text(
                              'দর কবুল করুন',
                              style: GoogleFonts.hindSiliguri(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        'এখনও কোনো বিড পড়েনি। প্রারম্ভিক দর ৳${auction.startingPricePerKg.toStringAsFixed(0)}/কেজি',
                        style: GoogleFonts.hindSiliguri(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'সমস্ত বিডিংয়ের ইতিহাস (Live Bids)',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              if (auction.bids.isEmpty)
                Container(
                  padding: const EdgeInsets.all(30),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(Icons.hourglass_empty, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'পাইকাররা ডাক দেখার পর বিড করা শুরু করবে',
                        style: GoogleFonts.hindSiliguri(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: auction.bids.length,
                  itemBuilder: (context, index) {
                    final bid = auction.bids[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: index == 0 ? Colors.green.shade300 : (isDark ? Colors.white12 : Colors.grey.shade200),
                          width: index == 0 ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: index == 0 ? Colors.green.shade100 : Colors.grey.shade200,
                                child: Text(
                                  '#${index + 1}',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: index == 0 ? Colors.green.shade800 : Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bid.bidderName,
                                    style: GoogleFonts.hindSiliguri(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${bid.timestamp.hour}:${bid.timestamp.minute.toString().padLeft(2, '0')}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '৳${bid.bidAmountPerKg.toStringAsFixed(0)} /কেজি',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: index == 0 ? Colors.green.shade700 : (isDark ? Colors.white : Colors.black87),
                                ),
                              ),
                              Text(
                                'মোট ৳${bid.totalBidAmount.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.hindSiliguri(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  void _showAcceptDealDialog(BuildContext context, FishAuctionModel auction, FishBid bid) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'দর চূড়ান্ত করবেন?',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ক্রেতা: ${bid.bidderName}',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
            ),
            Text('দর: ৳${bid.bidAmountPerKg.toStringAsFixed(0)} /কেজি', style: GoogleFonts.hindSiliguri()),
            Text('লটের মোট মূল্য: ৳${bid.totalBidAmount.toStringAsFixed(0)}', style: GoogleFonts.hindSiliguri()),
            const SizedBox(height: 10),
            Text(
              'কবুল করলে নিলামটি বন্ধ হয়ে যাবে এবং ক্রেতার এসক্রো পেমেন্ট লক হবে।',
              style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('বাতিল', style: GoogleFonts.hindSiliguri(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              auction.status = FishAuctionStatus.awarded;
              Get.snackbar(
                'অভিনন্দন! ডিল সম্পন্ন 🎉',
                'আপনার মাছের লটটি সফলভাবে বিক্রি চূড়ান্ত হয়েছে। পেমেন্ট এসক্রোতে সুরক্ষিত।',
                backgroundColor: Colors.green.shade700,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600),
            child: Text('হ্যাঁ, দর চূড়ান্ত করুন', style: GoogleFonts.hindSiliguri(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
