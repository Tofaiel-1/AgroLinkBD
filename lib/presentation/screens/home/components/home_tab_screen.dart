import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import '../widgets/enhanced_app_bar.dart';
import '../widgets/greeting_section.dart';
import '../widgets/enhanced_quick_actions_grid.dart';
import '../widgets/promotional_banner.dart';
import '../widgets/trending_products_section.dart';
import '../widgets/featured_cards_section.dart';

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isMobile ? 70 : 80),
        child: const EnhancedAppBar(),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated greeting section
            GreetingSection(user: user),
            SizedBox(height: isMobile ? 20 : 24),

            // Promotional Banner
            const PromotionalBanner(),
            SizedBox(height: isMobile ? 20 : 28),

            // Quick actions grid
            const EnhancedQuickActionsGrid(),
            SizedBox(height: isMobile ? 20 : 28),

            // Trending Products Section
            const TrendingProductsSection(),
            SizedBox(height: isMobile ? 20 : 28),

            // Featured Cards Section
            const FeaturedCardsSection(),

            SizedBox(height: isMobile ? 24 : 32),
          ],
        ),
      ),
    );
  }
}
