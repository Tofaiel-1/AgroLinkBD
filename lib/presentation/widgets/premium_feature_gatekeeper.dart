import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/presentation/screens/subscription/vip_subscription_paywall_screen.dart';

class PremiumFeatureGatekeeper extends StatelessWidget {
  final Widget child;
  final String featureName;
  final String description;

  const PremiumFeatureGatekeeper({
    super.key,
    required this.child,
    required this.featureName,
    this.description = 'এই ফিচারটি এগ্রোলিংক ভিআইপি পাস গ্রাহকদের জন্য সংরক্ষিত।',
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isPremium = userProvider.isPremium;

    if (isPremium) {
      return child;
    }

    return Stack(
      children: [
        // Blurring the underlying child
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: AbsorbPointer(child: child),
        ),

        // Paywall Lock Overlay
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.45),
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFFFB300), width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFB300)),
                      ),
                      child: const Icon(Icons.workspace_premium, color: Color(0xFFE65100), size: 40),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'প্রিমিয়াম ভিআইপি ফিচার 👑',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFE65100),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      featureName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.to(() => VipSubscriptionPaywallScreen(highlightFeature: featureName));
                        },
                        icon: const Icon(Icons.lock_open, color: Colors.white, size: 18),
                        label: Text(
                          'আনলক করতে ভিআইপি পাস নিন 🚀',
                          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE65100),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
