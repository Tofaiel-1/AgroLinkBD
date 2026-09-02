import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';

class TrendingProductsSection extends StatelessWidget {
  const TrendingProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final bool isBn = LanguageProvider.isBn(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isBn ? 'ট্রেন্ডিং পণ্য' : 'Trending Products',
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B5E20),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  isBn ? 'সব দেখুন' : 'See All',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildProductCard(isMobile, isBn),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(bool isMobile, bool isBn) {
    return Container(
      width: isMobile ? 140 : 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: double.infinity,
            height: isMobile ? 100 : 120,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Icon(
              Icons.agriculture,
              color: Color(0xFF2E7D32),
              size: 40,
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBn ? 'তাজা সবজি' : 'Fresh Veggies',
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  isBn ? 'সরাসরি খামার থেকে' : 'Direct from farm',
                  style: GoogleFonts.roboto(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isBn ? '৳ ৮৫' : '৳ 85',
                      style: GoogleFonts.poppins(
                        fontSize: isMobile ? 13 : 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
