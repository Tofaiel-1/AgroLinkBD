import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';

class PromotionalBanner extends StatefulWidget {
  const PromotionalBanner({super.key});

  @override
  State<PromotionalBanner> createState() => _PromotionalBannerState();
}

class _PromotionalBannerState extends State<PromotionalBanner> {
  late PageController _pageController;

  List<BannerData> _getBanners(bool isBn) {
    return [
      BannerData(
        title: isBn ? 'সরাসরি কৃষকদের কাছ থেকে কিনুন' : 'Buy Directly from Farmers',
        subtitle: isBn ? 'সেরা দাম এবং সতেজ পণ্য' : 'Best prices & freshest harvest',
        icon: Icons.shopping_cart_checkout,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
        ),
      ),
      BannerData(
        title: isBn ? 'কৃষি যন্ত্রপাতি ভাড়া নিন' : 'Rent Agri Machinery',
        subtitle: isBn ? 'সাশ্রয়ী মূল্যে উন্নত যন্ত্রপাতি' : 'Modern equipment at affordable rates',
        icon: Icons.agriculture,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
        ),
      ),
      BannerData(
        title: isBn ? 'বিনিয়োগ করুন কৃষিতে' : 'Invest in Smart Agriculture',
        subtitle: isBn ? 'লাভজনক বিনিয়োগের সুযোগ' : 'High yield & secure farm growth',
        icon: Icons.trending_up,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6F00), Color(0xFFE65100)],
        ),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final bool isBn = LanguageProvider.isBn(context);
    final banners = _getBanners(isBn);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      child: Column(
        children: [
          SizedBox(
            height: isMobile ? 160 : 200,
            child: PageView.builder(
              controller: _pageController,
              itemCount: banners.length,
              itemBuilder: (context, index) {
                return _buildBannerCard(banners[index], isMobile, isBn);
              },
            ),
          ),
          const SizedBox(height: 12),
          SmoothPageIndicator(
            controller: _pageController,
            count: banners.length,
            effect: const WormEffect(
              dotColor: Colors.grey,
              activeDotColor: Color(0xFF2E7D32),
              dotHeight: 8,
              dotWidth: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCard(BannerData banner, bool isMobile, bool isBn) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        gradient: banner.gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decoration
          Positioned(
            right: -30,
            bottom: -20,
            child: Icon(
              banner.icon,
              size: isMobile ? 120 : 150,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  banner.title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Text(
                  banner.subtitle,
                  style: GoogleFonts.roboto(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isBn ? 'আরো জানুন' : 'Learn More',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.white, size: 10),
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
}

class BannerData {
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;

  BannerData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });
}
