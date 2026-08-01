import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:agrolinkbd/presentation/widgets/weather_card_widget.dart';
import 'package:agrolinkbd/presentation/screens/transport/upazila_transport_screen.dart';

/// Emergency & Weather Services Screen (জরুরি সেবা ও আবহাওয়া কেন্দ্র)
class EmergencyWeatherServicesScreen extends StatelessWidget {
  const EmergencyWeatherServicesScreen({super.key});

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color alertRed = Color(0xFFD32F2F);

  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        Get.snackbar('কল করা সম্ভব নয়', 'ফোন ডায়ালার চালু করতে সমস্যা হয়েছে: $phoneNumber');
      }
    } catch (e) {
      Get.snackbar('কল নম্বর', 'জরুরি হেল্পলাইন: $phoneNumber');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: alertRed,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'জরুরি সেবা ও আবহাওয়া কেন্দ্র',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency Header Alert Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [alertRed, Colors.red.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: alertRed.withValues(alpha: 0.3),
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
                    child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'জরুরি কৃষি ও দুর্যোগ সেবা',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'যেকোনো প্রাকৃতিক দুর্যোগ বা শস্য রক্ষায় দ্রুত সাহায্য নিন',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Live Weather System Component
            Text(
              '🌤️ লাইভ আবহাওয়া ও পূর্বাভাস সিস্টেম',
              style: GoogleFonts.hindSiliguri(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 10),
            const WeatherCardWidget(),
            const SizedBox(height: 24),

            // Emergency Helplines Section
            Text(
              '📞 জরুরি হটলাইন নম্বরসমূহ',
              style: GoogleFonts.hindSiliguri(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 12),
            _buildHelplineCard(
              title: 'কৃষি কল সেন্টার (সরকারি)',
              subtitle: 'ফসল, সার ও পোকা দমনের বিনামূল্যে পরামর্শ',
              number: '16123',
              icon: Icons.phone_in_talk,
              color: Colors.green.shade700,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _buildHelplineCard(
              title: 'দুর্যোগ পূর্বাভাস ও সহায়তায়',
              subtitle: 'বাংলাদেশ আবহাওয়া অধিদপ্তর জরুরি হেল্পলাইন',
              number: '1090',
              icon: Icons.thunderstorm_outlined,
              color: Colors.amber.shade900,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _buildHelplineCard(
              title: 'জাতীয় জরুরি সেবা',
              subtitle: 'যেকোনো জরুরি পুলিশ, ফায়ার বা অ্যাম্বুলেন্স',
              number: '999',
              icon: Icons.emergency,
              color: alertRed,
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // Quick Emergency Action Buttons Grid
            Text(
              '🚀 দ্রুত জরুরি সেবাসমূহ',
              style: GoogleFonts.hindSiliguri(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _buildActionTile(
                  title: 'জরুরি শস্য পরিবহন',
                  subtitle: 'দ্রুত ট্রাক বা পিকআপ খুঁজুন',
                  icon: Icons.local_shipping,
                  color: Colors.blue.shade700,
                  isDark: isDark,
                  onTap: () => Get.to(() => const UpazilaTransportScreen()),
                ),
                _buildActionTile(
                  title: 'কৃষি তথ্য কেন্দ্র',
                  subtitle: 'মাটি ও ফসল জোন চেক করুন',
                  icon: Icons.eco,
                  color: primaryGreen,
                  isDark: isDark,
                  onTap: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHelplineCard({
    required String title,
    required String subtitle,
    required String number,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 11,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _makeCall(number),
            icon: const Icon(Icons.call, size: 16, color: Colors.white),
            label: Text(
              number,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.hindSiliguri(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.hindSiliguri(
                fontSize: 10,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
