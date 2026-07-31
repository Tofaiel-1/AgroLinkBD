import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/order_model.dart';

class FishOrderTrackingScreen extends StatelessWidget {
  final OrderModel order;

  const FishOrderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Custom steps for fish orders
    final steps = ['মাছ সংগ্রহ', 'বরফজাতকরণ', 'পরিবহনে', 'ডেলিভারি সম্পন্ন'];
    final stepDetails = [
      'খামার থেকে তাজা মাছ সংগ্রহ করা হচ্ছে।',
      'মাছ তাজা রাখতে পর্যাপ্ত বরফ দিয়ে প্যাক করা হচ্ছে।',
      'আপনার ঠিকানায় পাঠানোর জন্য কোল্ড চেইন পরিবহনে রয়েছে।',
      'পণ্যটি সফলভাবে আপনার ঠিকানায় হস্তান্তর করা হয়েছে।'
    ];
    final stepIcons = [Icons.water, Icons.ac_unit, Icons.local_shipping, Icons.done_all];
    
    final statusStep = order.statusStep;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF0F8FF), // Light blue theme
      appBar: AppBar(
        backgroundColor: const Color(0xFF0277BD),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'মাছের অর্ডার ট্র্যাকিং',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Map Placeholder
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.blue.shade100,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.5,
                      child: Image.network(
                        'https://maps.googleapis.com/maps/api/staticmap?center=Dhaka,Bangladesh&zoom=12&size=600x300&maptype=roadmap&key=API_KEY',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.map, size: 64, color: Colors.blueGrey),
                        ),
                      ),
                    ),
                  ),
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, size: 48, color: Colors.red),
                        SizedBox(height: 8),
                        Text(
                          'লাইভ ম্যাপ ট্র্যাকিং (শীঘ্রই আসছে)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'অর্ডার #${order.id.substring(0, 8).toUpperCase()}',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.set_meal, color: Color(0xFF0277BD), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${order.productName} (${order.quantity})',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 14,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (order.specialInstructions != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.lightBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info, size: 16, color: Colors.lightBlue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'বিশেষ নির্দেশনা: ${order.specialInstructions}',
                                    style: GoogleFonts.hindSiliguri(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.lightBlue.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  Text(
                    'ট্র্যাকিং স্ট্যাটাস',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Custom Timeline
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      children: List.generate(steps.length, (index) {
                        final isActive = index < statusStep;
                        final isCurrent = index == statusStep - 1;
                        final isLast = index == steps.length - 1;
                        
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isActive ? const Color(0xFF0277BD) : Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                    border: isCurrent ? Border.all(color: Colors.lightBlue.shade200, width: 4) : null,
                                  ),
                                  child: Icon(
                                    stepIcons[index],
                                    color: isActive ? Colors.white : Colors.grey.shade500,
                                    size: 16,
                                  ),
                                ),
                                if (!isLast)
                                  Container(
                                    width: 3,
                                    height: 40,
                                    color: index < statusStep - 1 ? const Color(0xFF0277BD) : Colors.grey.shade300,
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    steps[index],
                                    style: GoogleFonts.hindSiliguri(
                                      fontSize: 16,
                                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                      color: isActive ? (isDark ? Colors.white : Colors.black87) : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    stepDetails[index],
                                    style: GoogleFonts.hindSiliguri(
                                      fontSize: 12,
                                      color: isActive ? (isDark ? Colors.white70 : Colors.grey.shade700) : Colors.grey.shade400,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
