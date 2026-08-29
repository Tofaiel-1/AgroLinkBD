import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/models/fish_auction_model.dart';
import 'package:agrolinkbd/core/services/fish_auction_service.dart';

class FishBuyerBidScreen extends StatefulWidget {
  final String auctionId;

  const FishBuyerBidScreen({super.key, required this.auctionId});

  @override
  State<FishBuyerBidScreen> createState() => _FishBuyerBidScreenState();
}

class _FishBuyerBidScreenState extends State<FishBuyerBidScreen> {
  final _customBidController = TextEditingController();

  @override
  void dispose() {
    _customBidController.dispose();
    super.dispose();
  }

  void _submitBid(double amountPerKg) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    final auctionService = Get.isRegistered<FishAuctionService>()
        ? Get.find<FishAuctionService>()
        : Get.put(FishAuctionService());

    final success = auctionService.placeBid(
      auctionId: widget.auctionId,
      bidderId: user?.id ?? 'buyer_demo_${DateTime.now().millisecondsSinceEpoch}',
      bidderName: user?.name ?? 'মেসার্স ভাই ভাই মৎস্য আড়ত',
      bidderPhone: user?.phone ?? '01711000000',
      bidderOrganization: 'কাওরান বাজার পাইকারি আড়ত',
      bidAmountPerKg: amountPerKg,
    );

    if (success) {
      _customBidController.clear();
      Get.snackbar(
        'বিড সফল হয়েছে! 🎯',
        'আপনি প্রতি কেজি ৳${amountPerKg.toStringAsFixed(0)} দরে সর্বোচ্চ বিড করেছেন।',
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'বিড ব্যর্থ হয়েছে',
        'আপনার প্রস্তাবিত দর বর্তমান সর্বোচ্চ দর + ন্যূনতম বৃদ্ধির চেয়ে কম।',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    }
  }

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
          'লাইভ বিডিং রুম',
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
        final auction = auctionService.auctions.firstWhereOrNull((a) => a.id == widget.auctionId);
        if (auction == null) {
          return Center(child: Text('নিলাম পাওয়া যায়নি', style: GoogleFonts.hindSiliguri()));
        }

        final currentRate = auction.currentHighestBidPerKg ?? auction.startingPricePerKg;
        final minIncrement = auction.minBidIncrement;
        final nextMinBid = currentRate + minIncrement;
        final totalEstValue = currentRate * auction.estimatedTotalKg;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Header Banner
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.network(
                      auction.images.isNotEmpty
                          ? auction.images.first
                          : 'https://images.unsplash.com/photo-1534483509719-3feaee7c30da?w=600',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auction.lotTitle,
                            style: GoogleFonts.hindSiliguri(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'খামারি: ${auction.farmerName} • ${auction.farmLocation}',
                            style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Highest Bid Display Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.amber.shade600, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('বর্তমান সর্বোচ্চ দর', style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade600)),
                        Row(
                          children: [
                            const Icon(Icons.timer, color: Colors.red, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'বাকি: ${auction.remainingTime.inHours}ঘ ${auction.remainingTime.inMinutes % 60}মি',
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '৳${currentRate.toStringAsFixed(0)} /কেজি',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF006064),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'মোট ৳${totalEstValue.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            Text('${auction.estimatedTotalKg.toInt()} কেজির লট', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Interactive Bidding Section
              Text('আপনার দর প্রস্তাব করুন (Place Bid)', style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // Quick increment buttons
              Row(
                children: [
                  Expanded(
                    child: _buildQuickBidButton(
                      label: '+৳৫/কেজি',
                      rate: currentRate + 5.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickBidButton(
                      label: '+৳১০/কেজি',
                      rate: currentRate + 10.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickBidButton(
                      label: '+৳২০/কেজি',
                      rate: currentRate + 20.0,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Custom Bid Input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customBidController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: 'কাস্টম দর (ন্যূনতম ৳${nextMinBid.toStringAsFixed(0)})',
                        hintStyle: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade400),
                        prefixIcon: const Icon(Icons.edit, size: 18, color: Color(0xFF006064)),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      final amount = double.tryParse(_customBidController.text);
                      if (amount != null) {
                        _submitBid(amount);
                      } else {
                        Get.snackbar('ত্রুটি', 'সঠিক দর লিখুন');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: deepAqua,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('বিড দিন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Escrow Protection Info Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user, color: Colors.green, size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '১০০% নিরাপদ এসক্রো গ্যারান্টি',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                          Text(
                            'মাছ ডেলিভারি পেয়ে ওজন ও গুণমান সন্তোষজনক হলে কেবল তবেই খামারি পেমেন্ট পাবেন।',
                            style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.green.shade800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text('বিডিংয়ের ইতিহাস', style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              ...auction.bids.map((b) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: b.isWinning ? Colors.green.shade300 : (isDark ? Colors.white12 : Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(b.bidderName, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(
                        '৳${b.bidAmountPerKg.toStringAsFixed(0)} /কেজি',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: b.isWinning ? Colors.green.shade700 : null,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildQuickBidButton({required String label, required double rate}) {
    return ElevatedButton(
      onPressed: () => _submitBid(rate),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF006064),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
          Text('৳${rate.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
        ],
      ),
    );
  }
}
