import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/models/fish_harvest_contract_model.dart';
import 'package:agrolinkbd/core/services/fish_auction_service.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/contracts/create_harvest_contract_screen.dart';

class FarmerContractsScreen extends StatelessWidget {
  const FarmerContractsScreen({super.key});

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
          'আগাম মাছ বিক্রয় চুক্তি সমূহ',
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
            onPressed: () => Get.to(() => const CreateHarvestContractScreen()),
            tooltip: 'নতুন আগাম চুক্তি',
          ),
        ],
      ),
      body: Obx(() {
        final contracts = auctionService.contracts;

        if (contracts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('কোনো আগাম চুক্তি নেই', style: GoogleFonts.hindSiliguri(fontSize: 18, color: Colors.grey.shade600)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => const CreateHarvestContractScreen()),
                  icon: const Icon(Icons.add),
                  label: Text('নতুন চুক্তি পোস্ট করুন', style: GoogleFonts.hindSiliguri()),
                  style: ElevatedButton.styleFrom(backgroundColor: deepAqua),
                ),
              ],
            ),
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
                            color: isBooked ? Colors.green.shade50 : Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isBooked ? Colors.green.shade300 : Colors.amber.shade400),
                          ),
                          child: Text(
                            isBooked ? 'বুকড (অগ্রিম এসক্রোতে জমা)' : 'উন্মুক্ত (বায়ার খুঁজছে)',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isBooked ? Colors.green.shade800 : Colors.amber.shade900,
                            ),
                          ),
                        ),
                        Text(
                          'হারভেস্ট: ${contract.daysUntilHarvest} দিন বাকি',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: deepAqua,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${contract.pondName} - ${contract.fishSpecies}',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildContractMetric('প্রত্যাশিত ফলন', '${contract.estimatedYieldKg.toInt()} কেজি'),
                        _buildContractMetric('চুক্তির দর', '৳${contract.agreedPricePerKg.toStringAsFixed(0)}/কেজি'),
                        _buildContractMetric('মোট মূল্য', '৳${contract.estimatedTotalValue.toStringAsFixed(0)}'),
                      ],
                    ),
                    const Divider(height: 20),
                    if (isBooked) ...[
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'ক্রেতা: ${contract.buyerName ?? "নিবন্ধিত বায়ার"} | অগ্রিম: ৳${contract.advancePaidAmount.toStringAsFixed(0)}',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'প্রত্যাশিত অগ্রিম: ৳${contract.requiredAdvanceAmount.toStringAsFixed(0)} (${contract.advancePercentage.toInt()}%)',
                            style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade600),
                          ),
                          Text(
                            'এসক্রো প্রোটেকশন',
                            style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const CreateHarvestContractScreen()),
        backgroundColor: deepAqua,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'নতুন চুক্তি',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildContractMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
        Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
