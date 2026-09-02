import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:agrolinkbd/presentation/widgets/weather_card_widget.dart';
import 'package:agrolinkbd/presentation/screens/transport/upazila_transport_screen.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';

/// Emergency & Weather Services Screen (জরুরি সেবা ও আবহাওয়া কেন্দ্র)
class EmergencyWeatherServicesScreen extends StatelessWidget {
  const EmergencyWeatherServicesScreen({super.key});

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color alertRed = Color(0xFFD32F2F);

  Future<void> _makeCall(BuildContext context, String phoneNumber) async {
    final bool isBn = LanguageProvider.isBn(context);
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        Get.snackbar(
          isBn ? 'কল করা সম্ভব নয়' : 'Call Failed',
          isBn ? 'ফোন ডায়ালার চালু করতে সমস্যা হয়েছে: $phoneNumber' : 'Could not launch dialer for: $phoneNumber',
        );
      }
    } catch (e) {
      Get.snackbar(
        isBn ? 'কল নম্বর' : 'Helpline Number',
        isBn ? 'জরুরি হেল্পলাইন: $phoneNumber' : 'Emergency Hotline: $phoneNumber',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isBn = LanguageProvider.isBn(context);

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
          isBn ? 'জরুরি সেবা ও আবহাওয়া কেন্দ্র' : 'Emergency & Weather Center',
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
                          isBn ? 'জরুরি কৃষি ও দুর্যোগ সেবা' : 'Emergency Agri & Disaster Support',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          isBn
                              ? 'যেকোনো প্রাকৃতিক দুর্যোগ বা শস্য রক্ষায় দ্রুত সাহায্য নিন'
                              : 'Get rapid assistance during adverse weather & emergencies',
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
              isBn ? '🌤️ লাইভ আবহাওয়া ও পূর্বাভাস সিস্টেম' : '🌤️ Live Weather & Forecast System',
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
              isBn ? '📞 জরুরি হটলাইন নম্বরসমূহ' : '📞 Emergency Helpline Numbers',
              style: GoogleFonts.hindSiliguri(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 12),
            _buildHelplineCard(
              context: context,
              title: isBn ? 'কৃষি কল সেন্টার (সরকারি)' : 'Agri Call Center (Govt)',
              subtitle: isBn ? 'ফসল, সার ও পোকা দমনের বিনামূল্যে পরামর্শ' : 'Free advisory on crops, fertilizer & pest control',
              number: '16123',
              icon: Icons.phone_in_talk,
              color: Colors.green.shade700,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _buildHelplineCard(
              context: context,
              title: isBn ? 'দুর্যোগ পূর্বাভাস ও সহায়তায়' : 'Disaster Warning & Relief',
              subtitle: isBn ? 'বাংলাদেশ আবহাওয়া অধিদপ্তর জরুরি হেল্পলাইন' : 'BMD Early Warning Hotline',
              number: '1090',
              icon: Icons.thunderstorm_outlined,
              color: Colors.amber.shade900,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _buildHelplineCard(
              context: context,
              title: isBn ? 'জাতীয় জরুরি সেবা' : 'National Emergency Service',
              subtitle: isBn ? 'যেকোনো জরুরি পুলিশ, ফায়ার বা অ্যাম্বুলেন্স' : 'National Police, Fire Service, Ambulance',
              number: '999',
              icon: Icons.emergency,
              color: alertRed,
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // Quick Emergency Action Buttons Grid
            Text(
              isBn ? '🚀 দ্রুত জরুরি সেবাসমূহ' : '🚀 Quick Emergency Services',
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
                  title: isBn ? 'জরুরি শস্য পরিবহন' : 'Crop Transport',
                  subtitle: isBn ? 'দ্রুত ট্রাক বা পিকআপ খুঁজুন' : 'Find truck or pickup nearby',
                  icon: Icons.local_shipping,
                  color: Colors.blue.shade700,
                  isDark: isDark,
                  onTap: () => Get.to(() => const UpazilaTransportScreen()),
                ),
                _buildActionTile(
                  title: isBn ? 'কৃষি তথ্য কেন্দ্র' : 'Agri Info Hub',
                  subtitle: isBn ? 'মাটি ও ফসল জোন চেক করুন' : 'Check soil & crop zones',
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
    required BuildContext context,
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
            onPressed: () => _makeCall(context, number),
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
