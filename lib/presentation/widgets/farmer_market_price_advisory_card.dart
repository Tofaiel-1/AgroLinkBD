import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/services/market_price_advisory_service.dart';

/// Farmer Market Price Advisory & Command Card
/// Reads Super Admin commands and benchmark rates from Firebase,
/// and suggests price decrease/increase to Agri & Fish Farmers with 1-tap price sync.
class FarmerMarketPriceAdvisoryCard extends StatefulWidget {
  final String farmerId;
  final bool isFishFarmer;
  final EdgeInsetsGeometry? margin;

  const FarmerMarketPriceAdvisoryCard({
    super.key,
    required this.farmerId,
    this.isFishFarmer = false,
    this.margin,
  });

  @override
  State<FarmerMarketPriceAdvisoryCard> createState() => _FarmerMarketPriceAdvisoryCardState();
}

class _FarmerMarketPriceAdvisoryCardState extends State<FarmerMarketPriceAdvisoryCard> {
  final MarketPriceAdvisoryService _advisoryService = MarketPriceAdvisoryService();
  final Set<String> _updatingItemIds = {};

  Future<void> _handleApplyPrice(PriceSuggestion suggestion, bool isBn) async {
    final itemId = suggestion.itemId;
    setState(() => _updatingItemIds.add(itemId));

    final success = await _advisoryService.applySuggestedPrice(
      itemId: itemId,
      newPrice: suggestion.recommendedPrice,
      isFishLot: suggestion.isFishLot,
    );

    if (mounted) {
      setState(() => _updatingItemIds.remove(itemId));
      if (success) {
        Get.snackbar(
          isBn ? 'দর সফলভাবে সমন্বিত!' : 'Price Updated!',
          isBn
              ? '${suggestion.itemName}-এর দাম ৳${suggestion.recommendedPrice.toStringAsFixed(0)}/${suggestion.unit} করা হয়েছে।'
              : 'Price for ${suggestion.itemName} updated to ৳${suggestion.recommendedPrice.toStringAsFixed(0)}/${suggestion.unit}.',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
        );
      } else {
        Get.snackbar(
          isBn ? 'আপডেট ব্যর্থ' : 'Update Failed',
          isBn ? 'মূল্য সমন্বয়ে সমস্যা হয়েছে। পুনরায় চেষ্টা করুন।' : 'Failed to update price. Please try again.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBn = LanguageProvider.isBn(context);

    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
              : [const Color(0xFFF0FDF4), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF10B981).withValues(alpha: 0.3) : const Color(0xFF10B981).withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.08 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Super Admin Active Command Header Banner
          _buildAdminCommandBanner(isDark, isBn),

          // 2. Farmer's Items Live Recommendation Section
          StreamBuilder<List<PriceSuggestion>>(
            stream: widget.isFishFarmer
                ? _advisoryService.streamFishFarmerLotSuggestions(widget.farmerId)
                : _advisoryService.streamFarmerAgriSuggestions(widget.farmerId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981)),
                    ),
                  ),
                );
              }

              final allSuggestions = snapshot.data ?? [];
              final actionableSuggestions = allSuggestions
                  .where((s) => s.type == PriceSuggestionType.decrease || s.type == PriceSuggestionType.increase)
                  .toList();

              if (allSuggestions.isEmpty) {
                return _buildEmptyState(isDark, isBn);
              }

              if (actionableSuggestions.isEmpty) {
                return _buildAllOptimalState(allSuggestions.length, isDark, isBn);
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Pill Row
                    Row(
                      children: [
                        Text(
                          isBn ? 'প্রয়োজনীয় মূল্য সমন্বয়' : 'Price Adjustments Needed',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade700),
                          ),
                          child: Text(
                            '${actionableSuggestions.length} ${isBn ? "টি পণ্য" : "items"}',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.amberAccent : Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // List of actionable suggestions
                    ...actionableSuggestions.map((suggestion) => _buildSuggestionTile(suggestion, isDark, isBn)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCommandBanner(bool isDark, bool isBn) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _advisoryService.streamLatestAdminCommand(),
      builder: (context, snapshot) {
        final command = snapshot.data;
        final action = command?['action'] as String? ?? 'syncBenchmark';
        final isDecrease = action == 'decrease';
        final isIncrease = action == 'increase';
        final delta = (command?['deltaValue'] as num?)?.toDouble() ?? 10.0;
        final unit = command?['unit'] == 'fixedBdt' ? '৳' : '%';

        Color accentColor = const Color(0xFF10B981);
        IconData icon = Icons.verified_rounded;
        String headline = isBn ? 'কেন্দ্রীয় বাজার বেঞ্চমার্ক রেট সক্রিয়' : 'Central Market Benchmark Active';
        String subtitle = isBn
            ? 'সুপার এডমিন কর্তৃক বাজার তদারকি চালু রয়েছে। বর্তমান গড় হারের সাথে মিলিয়ে পণ্য বিক্রির পরামর্শ।'
            : 'Super admin market supervision is active. Recommended to align prices with current rates.';

        if (isDecrease) {
          accentColor = const Color(0xFFEF4444);
          icon = Icons.trending_down_rounded;
          headline = isBn
              ? '📉 বাজার ধস সতর্কতা: -$delta$unit ছাড়ের পরামর্শ'
              : '📉 Market Drop Notice: -$delta$unit Clearance Advisory';
          subtitle = isBn
              ? 'বাজারে অতি-সরবরাহ বা পাইকারি দর কমে যাওয়ায় দ্রুত বিক্রি করতে দাম কমানোর পরামর্শ জারি রয়েছে।'
              : 'Due to market glut, super admin advises lowering prices to sell before spoilage.';
        } else if (isIncrease) {
          accentColor = const Color(0xFF10B981);
          icon = Icons.trending_up_rounded;
          headline = isBn
              ? '📈 কৃষক সুরক্ষা নোটিশ: +$delta$unit মূল্য বৃদ্ধির সুযোগ'
              : '📈 Farmer Protection Alert: +$delta$unit Price Opportunity';
          subtitle = isBn
              ? 'বাজারদর বৃদ্ধি পেয়েছে। কম দামে বিক্রি না করে ন্যায্যমূল্য নিশ্চিত করতে দর বৃদ্ধির সুপারিশ।'
              : 'Market wholesale prices have rallied. Raise your listing price to secure fair profit.';
        }

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
            border: Border(bottom: BorderSide(color: accentColor.withValues(alpha: 0.25))),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      style: GoogleFonts.hindSiliguri(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 11,
                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuggestionTile(PriceSuggestion suggestion, bool isDark, bool isBn) {
    final isDecrease = suggestion.type == PriceSuggestionType.decrease;
    final badgeColor = isDecrease ? const Color(0xFFEF4444) : const Color(0xFF10B981);
    final isUpdating = _updatingItemIds.contains(suggestion.itemId);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: badgeColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Product Name & Lot Type
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      suggestion.isFishLot ? Icons.set_meal_rounded : Icons.eco_rounded,
                      size: 16,
                      color: badgeColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        suggestion.itemName,
                        style: GoogleFonts.hindSiliguri(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Recommendation Tag Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  isBn ? suggestion.headlineBn : suggestion.headlineEn,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Price Comparison Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn ? 'আপনার মূল্য' : 'Your Price',
                      style: GoogleFonts.hindSiliguri(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      '৳${suggestion.currentPrice.toStringAsFixed(0)}/${suggestion.unit}',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.arrow_forward_rounded, size: 16, color: badgeColor),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isBn ? 'বাজার বেঞ্চমার্ক রেট' : 'Market Benchmark',
                      style: GoogleFonts.hindSiliguri(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      '৳${suggestion.benchmarkPrice.toStringAsFixed(0)}/${suggestion.unit}',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Reason text
          Text(
            isBn ? suggestion.reasonBn : suggestion.reasonEn,
            style: GoogleFonts.hindSiliguri(
              fontSize: 11.5,
              color: isDark ? Colors.white60 : Colors.grey.shade700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),

          // 1-Tap Apply Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isUpdating ? null : () => _handleApplyPrice(suggestion, isBn),
              icon: isUpdating
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(
                      isDecrease ? Icons.price_check_rounded : Icons.trending_up_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
              label: Text(
                isBn
                    ? 'প্রস্তাবিত দর ৳${suggestion.recommendedPrice.toStringAsFixed(0)}/${suggestion.unit} করুন'
                    : 'Apply Recommended ৳${suggestion.recommendedPrice.toStringAsFixed(0)}/${suggestion.unit}',
                style: GoogleFonts.hindSiliguri(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: badgeColor,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllOptimalState(int totalItems, bool isDark, bool isBn) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBn ? 'সকল পণ্যের মূল্য উপযুক্ত রয়েছে' : 'All Prices Perfectly Aligned',
                  style: GoogleFonts.hindSiliguri(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  isBn
                      ? 'আপনার $totalItemsটি বিজ্ঞাপিত পণ্যের দর বর্তমান কেন্দ্রীয় বাজারদরের সাথে মানানসই।'
                      : 'All $totalItems of your listed products align well with current benchmark prices.',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, bool isBn) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.storefront_outlined, color: Colors.grey.shade400, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isBn
                  ? 'আপনার কোনো পণ্য বা লট তালিকাভুক্ত নেই। নতুন পণ্য যুক্ত করলে বাজারদর অনুযায়ী স্বয়ংক্রিয় পরামর্শ পাবেন।'
                  : 'No active listings found. Add crops or fish lots to receive real-time price suggestions.',
              style: GoogleFonts.hindSiliguri(
                fontSize: 11.5,
                color: isDark ? Colors.white60 : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
