import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/buyer/fish_buyer_live_auction_screen.dart';
import 'package:agrolinkbd/presentation/screens/subscription/vip_subscription_paywall_screen.dart';

class AuctionScreen extends StatelessWidget {
  const AuctionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isBn = LanguageProvider.isBn(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5132),
        elevation: 0,
        title: Text(
          isBn ? 'লাইভ ডিজিটাল নিলাম ও পাইকারি ডাক' : 'Live Digital Auctions & Bidding',
          style: GoogleFonts.hindSiliguri(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            tooltip: isBn ? 'ভিআইপি পাস' : 'VIP Pass',
            icon: const Icon(Icons.workspace_premium_rounded, color: Colors.amberAccent),
            onPressed: () => Get.to(() => const VipSubscriptionPaywallScreen()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // VIP Banner
          GestureDetector(
            onTap: () => Get.to(() => const VipSubscriptionPaywallScreen()),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD97706), Color(0xFFF59E0B), Color(0xFFB45309)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD97706).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn ? '👑 ভিআইপি ট্রেডার্স পাস' : '👑 VIP Traders Pass',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          isBn
                              ? 'লাইভ পাইকারি নিলামে সরাসরি ডাক তুলুন ও ০% কমিশনে কিনুন'
                              : 'Place direct bids in live auctions with 0% platform fee',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 11.5,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Active Auction Rooms Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isBn ? 'চলমান লাইভ নিলাম রুম' : 'Active Live Auction Rooms',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isBn ? '🔴 লাইভ চলছে' : '🔴 LIVE NOW',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Live Fish Auction Card
          _buildAuctionRoomCard(
            context,
            title: isBn ? 'তাজা দেশি মাছের লাইভ নিলাম ও বাল্ক লট' : 'Fresh Live Fish Auction & Bulk Lots',
            subtitle: isBn ? 'পদ্মা ও মেঘনা নদীর তাজা ইলিশ, রুই ও কাতলা লট' : 'Padma & Meghna live Ilish, Rui, Katla lots',
            badge: isBn ? 'ফিশারিজ স্পেশাল' : 'Fisheries Special',
            activeBids: isBn ? '২৪ জন ডাকছেন' : '24 Bidding',
            icon: Icons.set_meal_rounded,
            iconColor: Colors.blue,
            isDark: isDark,
            cardBg: cardBg,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            onTap: () => Get.to(() => const FishBuyerLiveAuctionScreen()),
          ),

          const SizedBox(height: 12),

          // Live Grain & Agro Bulk Auction Card
          _buildAuctionRoomCard(
            context,
            title: isBn ? 'দিনাজপুর মিনিকেট ও সুগন্ধি চালের মেগা লট' : 'Dinajpur Miniket & Aromatic Rice Mega Lot',
            subtitle: isBn ? 'সরাসরি হাসকিং মিল ও সমবায় থেকে ৫০ টন লট' : 'Direct from husking mills & co-op: 50 Ton lot',
            badge: isBn ? 'শস্য নিলাম' : 'Grain Auction',
            activeBids: isBn ? '১৮ জন ডাকছেন' : '18 Bidding',
            icon: Icons.agriculture_rounded,
            iconColor: Colors.amber.shade800,
            isDark: isDark,
            cardBg: cardBg,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            onTap: () => Get.to(() => const FishBuyerLiveAuctionScreen()),
          ),

          const SizedBox(height: 12),

          // Live Fruits & Organic Mango Auction Card
          _buildAuctionRoomCard(
            context,
            title: isBn ? 'রাজশাহী ও চাঁপাইনবাবগঞ্জ আম বাগান প্রি-হার্ভেস্ট লট' : 'Rajshahi & Chapai Mango Pre-Harvest Lot',
            subtitle: isBn ? 'হিমসাগর, ল্যাংড়া ও আম্রপালি বাগানের সম্পূর্ণ লট' : 'Himsagar, Langra whole orchard harvest lot',
            badge: isBn ? 'ফলমূল নিলাম' : 'Fruit Auction',
            activeBids: isBn ? '১২ জন ডাকছেন' : '12 Bidding',
            icon: Icons.apple_rounded,
            iconColor: Colors.red,
            isDark: isDark,
            cardBg: cardBg,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            onTap: () => Get.to(() => const FishBuyerLiveAuctionScreen()),
          ),

          const SizedBox(height: 20),

          // How Live Auction Works
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBn ? '🎯 ডিজিটাল নিলাম কীভাবে কাজ করে?' : '🎯 How Digital Auction Works?',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                _buildProcessStep(
                  '১',
                  isBn ? 'লাইভ ডাক তুলুন' : 'Place Live Bids',
                  isBn ? 'রিয়েল-টাইমে অন্য পাইকারি ক্রেতাদের সাথে ডাক বাড়িয়ে সেরা দর দিন' : 'Compete with wholesale buyers in real-time',
                  textPrimary,
                  textSecondary,
                ),
                const SizedBox(height: 8),
                _buildProcessStep(
                  '২',
                  isBn ? 'এস্ক্রো সুরক্ষিত পেমেন্ট' : 'Escrow Secured Payment',
                  isBn ? 'সর্বোচ্চ দরদাতা হলে SSLCommerz দিয়ে এস্ক্রো লক করুন' : 'Lock payment via SSLCommerz upon winning',
                  textPrimary,
                  textSecondary,
                ),
                const SizedBox(height: 8),
                _buildProcessStep(
                  '৩',
                  isBn ? 'কোল্ড চেইন ডেলিভারি ও ওটিপি ভেরিফিকেশন' : 'Cold Chain & OTP Delivery',
                  isBn ? 'মাল বুঝে পেয়ে ৪ ডিজিটের ওটিপি দিলে কৃষকের কাছে টাকা পৌঁছাবে' : 'Verify physical goods & share 4-digit OTP to release funds',
                  textPrimary,
                  textSecondary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const FishBuyerLiveAuctionScreen()),
        backgroundColor: const Color(0xFF0F5132),
        icon: const Icon(Icons.gavel_rounded, color: Colors.white),
        label: Text(
          isBn ? 'নিলামে ডাক দিন' : 'Enter Live Bidding',
          style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildAuctionRoomCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String badge,
    required String activeBids,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badge,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.people_outline_rounded, size: 12, color: Colors.green),
                          const SizedBox(width: 3),
                          Text(
                            activeBids,
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 11,
                      color: textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessStep(
    String stepNum,
    String title,
    String description,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFF0F5132),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNum,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 11,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
