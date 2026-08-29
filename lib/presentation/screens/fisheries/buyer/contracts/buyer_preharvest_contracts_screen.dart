import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/models/fish_harvest_contract_model.dart';
import 'package:agrolinkbd/core/services/fish_auction_service.dart';

class BuyerPreharvestContractsScreen extends StatelessWidget {
  const BuyerPreharvestContractsScreen({super.key});

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
          'আগাম খামার বুকিং (Pre-Harvest Futures)',
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
        final contracts = auctionService.contracts;

        if (contracts.isEmpty) {
          return Center(
            child: Text('কোনো আগাম ফলন অফার নেই', style: GoogleFonts.hindSiliguri(fontSize: 16)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: contracts.length,
          itemBuilder: (context, index) {
            final contract = contracts[index];
            final isBooked = contract.status == FishContractStatus.depositPaid;

            return Card(
              color: Theme.of(context).cardColor,
              margin: const EdgeInsets.only(bottom: 16),
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isBooked ? Colors.grey.shade100 : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isBooked ? Colors.grey : Colors.green.shade400),
                          ),
                          child: Text(
                            isBooked ? 'বুকিং সম্পন্ন' : 'বুকিংয়ের জন্য উন্মুক্ত',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isBooked ? Colors.grey.shade700 : Colors.green.shade800,
                            ),
                          ),
                        ),
                        Text(
                          'হারভেস্ট: ${contract.daysUntilHarvest} দিন পর',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: deepAqua,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${contract.pondName} - ${contract.fishSpecies}',
                      style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    Text(
                      'খামারি: ${contract.farmerName} • অবস্থান: ${contract.location}',
                      style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildContractMetric('প্রত্যাশিত ফলন', '${contract.estimatedYieldKg.toInt()} কেজি'),
                        _buildContractMetric('চুক্তিবদ্ধ দর', '৳${contract.agreedPricePerKg.toStringAsFixed(0)}/কেজি'),
                        _buildContractMetric('প্রয়োজনীয় অগ্রিম', '৳${contract.requiredAdvanceAmount.toStringAsFixed(0)} (${contract.advancePercentage.toInt()}%)'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.water_drop, color: Colors.blue, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'পানির স্বাস্থ্য: ${contract.waterQualityReport}',
                              style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.blue.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('লটের মোট সম্ভাব্য মূল্য', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
                            Text('৳${contract.estimatedTotalValue.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                          ],
                        ),
                        if (!isBooked)
                          ElevatedButton.icon(
                            onPressed: () {
                              _showBookingDialog(context, contract);
                            },
                            icon: const Icon(Icons.lock_clock, size: 16, color: Colors.white),
                            label: Text(
                              'অগ্রিম বুকিং দিন',
                              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: deepAqua,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                          )
                        else
                          Text('বুকড বাই: ${contract.buyerName ?? "নিবন্ধিত বায়ার"}', style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildContractMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
        Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showBookingDialog(BuildContext context, FishHarvestContractModel contract) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'আগাম বুকিং নিশ্চিত করবেন?',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('লট: ${contract.pondName} (${contract.fishSpecies})', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
            Text('ফলন: ${contract.estimatedYieldKg.toInt()} কেজি @ ৳${contract.agreedPricePerKg.toStringAsFixed(0)}/কেজি', style: GoogleFonts.hindSiliguri()),
            const SizedBox(height: 10),
            Text(
              'অগ্রিম এসক্রো ডিপোজিট: ৳${contract.requiredAdvanceAmount.toStringAsFixed(0)} (${contract.advancePercentage.toInt()}%)',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.green.shade800),
            ),
            const SizedBox(height: 8),
            Text(
              'ডিপোজিটকৃত অর্থ এগ্রোলিংক এসক্রোতে সুরক্ষিত থাকবে এবং হারভেস্টের দিন ডেলিভারি পাওয়ার পর রিলিজ হবে।',
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
              contract.buyerId = user?.id ?? 'buyer_demo';
              contract.buyerName = user?.name ?? 'মেসার্স ভাই ভাই মৎস্য আড়ত';
              contract.buyerPhone = user?.phone ?? '01711000000';
              contract.advancePaidAmount = contract.requiredAdvanceAmount;
              contract.status = FishContractStatus.depositPaid;

              Get.find<FishAuctionService>().contracts.refresh();

              Get.snackbar(
                'বুকিং সফল হয়েছে! 🔒',
                'আপনার অগ্রিম ডিপোজিট এসক্রোতে জমা হয়েছে। খামারি হারভেস্টের জন্য মাছ প্রস্তুত করবে।',
                backgroundColor: Colors.green.shade700,
                colorText: Colors.white,
                duration: const Duration(seconds: 4),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006064)),
            child: Text('অগ্রিম ডিপোজিট দিন', style: GoogleFonts.hindSiliguri(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
