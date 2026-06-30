import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/presentation/screens/sokol_card/card_preview_screen.dart' as agrolinkbd;

class ProfileTabScreen extends StatelessWidget {
  const ProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: isMobile ? 200 : 240,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF2E7D32),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      radius: isMobile ? 45 : 55,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: CircleAvatar(
                        radius: isMobile ? 42 : 52,
                        backgroundColor: const Color(0xFFE8F5E9),
                        child: Icon(
                          Icons.person,
                          size: isMobile ? 40 : 50,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Name
                    Text(
                      user?.name ?? 'ব্যবহারকারী',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // Phone
                    Text(
                      user?.phone ?? 'ফোন নম্বর',
                      style: GoogleFonts.roboto(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: isMobile ? 12 : 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Body Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                // Premium Status
                if (user?.isPremium == true)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 24,
                      vertical: 12,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF9800).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'প্রিমিয়াম সদস্য',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'বিশেষ সুবিধা এবং অফার পান',
                                  style: GoogleFonts.roboto(
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Quick Stats
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: 12,
                  ),
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      _buildStatCard('অর্ডার', '০', const Color(0xFF2E7D32)),
                      _buildStatCard('পছন্দ', '০', const Color(0xFF1976D2)),
                      _buildStatCard('রিভিউ', '০', const Color(0xFFFF9800)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Menu Items
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 0 : 24,
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.edit,
                        title: 'প্রোফাইল সম্পাদনা',
                        subtitle: 'আপনার তথ্য পরিবর্তন করুন',
                        onTap: () {
                          Get.snackbar(
                            'প্রোফাইল সম্পাদনা',
                            'প্রোফাইল সম্পাদনা শুরু হচ্ছে...',
                            backgroundColor: const Color(0xFF2E7D32),
                            colorText: Colors.white,
                          );
                        },
                        isMobile: isMobile,
                      ),
                      _buildMenuItem(
                        icon: Icons.qr_code,
                        title: 'আমার কার্ড',
                        subtitle: 'ডিজিটাল স্মার্ট কার্ড',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const agrolinkbd.CardPreviewScreen(),
                            ),
                          );
                        },
                        isMobile: isMobile,
                      ),
                      _buildMenuItem(
                        icon: Icons.history,
                        title: 'লেনদেন ইতিহাস',
                        subtitle: 'আপনার সমস্ত লেনদেন দেখুন',
                        onTap: () {
                          Get.snackbar(
                            'লেনদেন ইতিহাস',
                            'লেনদেন ইতিহাস লোড হচ্ছে...',
                            backgroundColor: const Color(0xFF2E7D32),
                            colorText: Colors.white,
                          );
                        },
                        isMobile: isMobile,
                      ),
                      _buildMenuItem(
                        icon: Icons.favorite,
                        title: 'পছন্দের তালিকা',
                        subtitle: 'আপনার সংরক্ষিত পণ্য',
                        onTap: () {
                          Get.snackbar(
                            'পছন্দের তালিকা',
                            'পছন্দের তালিকা লোড হচ্ছে...',
                            backgroundColor: const Color(0xFF2E7D32),
                            colorText: Colors.white,
                          );
                        },
                        isMobile: isMobile,
                      ),
                      _buildMenuItem(
                        icon: Icons.star,
                        title: 'প্রিমিয়াম আপগ্রেড',
                        subtitle: 'প্রিমিয়াম সদস্য হন',
                        onTap: () {
                          Get.snackbar(
                            'প্রিমিয়াম আপগ্রেড',
                            'প্রিমিয়াম সুবিধা সম্পর্কে জানতে হবে',
                            backgroundColor: const Color(0xFF2E7D32),
                            colorText: Colors.white,
                          );
                        },
                        isMobile: isMobile,
                      ),
                      _buildMenuItem(
                        icon: Icons.settings,
                        title: 'সেটিংস',
                        subtitle: 'অ্যাপ পছন্দ কাস্টমাইজ করুন',
                        onTap: () {
                          Get.snackbar(
                            'সেটিংস',
                            'সেটিংস খুলছে...',
                            backgroundColor: const Color(0xFF2E7D32),
                            colorText: Colors.white,
                          );
                        },
                        isMobile: isMobile,
                      ),
                      _buildMenuItem(
                        icon: Icons.help,
                        title: 'সাহায্য ও সহায়তা',
                        subtitle: 'প্রশ্নের উত্তর খুঁজুন',
                        onTap: () {
                          Get.snackbar(
                            'সাহায্য',
                            'সাহায্য বিষয়বস্তু লোড হচ্ছে...',
                            backgroundColor: const Color(0xFF2E7D32),
                            colorText: Colors.white,
                          );
                        },
                        isMobile: isMobile,
                      ),
                      _buildMenuItem(
                        icon: Icons.logout,
                        title: 'লগ আউট',
                        subtitle: 'আপনার অ্যাকাউন্ট থেকে বেরিয়ে যান',
                        onTap: () async {
                          Get.dialog(
                            AlertDialog(
                              title: Text(
                                'নিশ্চিত করুন',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              content: Text(
                                'আপনি কি নিশ্চিত যে আপনি লগ আউট করতে চান?',
                                style: GoogleFonts.roboto(),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: Text(
                                    'বাতিল করুন',
                                    style: GoogleFonts.poppins(),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await userProvider.signOut();
                                    Get.back();
                                  },
                                  child: Text(
                                    'লগ আউট',
                                    style: GoogleFonts.poppins(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        isMobile: isMobile,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 0,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2E7D32),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 14 : 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.roboto(
                      fontSize: isMobile ? 11 : 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
