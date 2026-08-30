import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/presentation/screens/telemedicine/agri_telemedicine_screen.dart';
import 'package:agrolinkbd/presentation/screens/marketplace/buyer_rfq_board_screen.dart';
import 'package:agrolinkbd/presentation/screens/machinery/machinery_rental_screen.dart';
import 'package:agrolinkbd/presentation/screens/transport/upazila_transport_screen.dart';

class PremiumAgroServicesSection extends StatelessWidget {
  final bool isBn;
  final EdgeInsetsGeometry? padding;

  const PremiumAgroServicesSection({
    super.key,
    this.isBn = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.diamond_outlined, color: Colors.amber, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isBn ? 'প্রিমিয়াম কৃষি ও মৎস্য সেবা 💎' : 'Premium Agro Services 💎',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: isMobile ? 17 : 19,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'PRO SUITE',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Services Grid
          GridView.count(
            crossAxisCount: isMobile ? 2 : 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: isMobile ? 1.22 : 1.35,
            children: [
              _buildServiceTile(
                context: context,
                title: isBn ? 'কৃষি ও মৎস্য ডাক্তার 🩺' : 'Agri & Fish Doctor',
                subtitle: isBn ? 'লাইভ ভিডিও কল পরামর্শ' : 'Live Specialist Consult',
                badge: '৳৩০ টোকেন',
                badgeColor: Colors.purple,
                icon: Icons.video_camera_front_outlined,
                color: const Color(0xFF6A1B9A),
                onTap: () => Get.to(() => const AgriTelemedicineScreen()),
                isDark: isDark,
              ),
              _buildServiceTile(
                context: context,
                title: isBn ? 'পাইকারি চাহিদা বোর্ড 📋' : 'Bulk RFQ Board',
                subtitle: isBn ? 'পাইকারদের বড় টেন্ডার' : 'Wholesale Tenders',
                badge: 'বড় ডিল ⚡',
                badgeColor: Colors.red,
                icon: Icons.assignment_outlined,
                color: const Color(0xFFC62828),
                onTap: () => Get.to(() => const BuyerRfqBoardScreen()),
                isDark: isDark,
              ),
              _buildServiceTile(
                context: context,
                title: isBn ? 'মেশিনারি ও হার্ভেস্টার 🚜' : 'Machinery Rental',
                subtitle: isBn ? 'ট্রাক্টর ও কম্বাইন ভাড়া' : 'Harvester & Drone Rental',
                badge: 'এস্ক্রো সুরক্ষিত',
                badgeColor: Colors.amber.shade900,
                icon: Icons.agriculture_outlined,
                color: const Color(0xFFE65100),
                onTap: () => Get.to(() => const MachineryRentalScreen()),
                isDark: isDark,
              ),
              _buildServiceTile(
                context: context,
                title: isBn ? 'উপজেলা ট্রান্সপোর্ট 🚚' : 'Upazila Transport',
                subtitle: isBn ? 'পিকআপ ও ট্রাক বুকিং' : 'Live Truck GPS Booking',
                badge: '৫% প্ল্যাটফর্ম সেফটি',
                badgeColor: Colors.blue,
                icon: Icons.local_shipping_outlined,
                color: const Color(0xFF1565C0),
                onTap: () => Get.to(() => const UpazilaTransportScreen()),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 18),

          // B2B Sponsored Brand Deals Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade900.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified, color: Colors.amber, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'ACI & Lal Teer পার্টনার জোন',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'SPONSORED',
                              style: GoogleFonts.poppins(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'সার্টিফাইড হাইব্রিড বীজ ও ফিডে আকর্ষণীয় ছাড়',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 10,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
