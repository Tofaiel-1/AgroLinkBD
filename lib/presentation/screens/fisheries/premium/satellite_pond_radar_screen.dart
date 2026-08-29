import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/presentation/widgets/premium_feature_gatekeeper.dart';

class SatellitePondRadarScreen extends StatefulWidget {
  const SatellitePondRadarScreen({super.key});

  @override
  State<SatellitePondRadarScreen> createState() => _SatellitePondRadarScreenState();
}

class _SatellitePondRadarScreenState extends State<SatellitePondRadarScreen> {
  bool _sosAlertEnabled = true;
  bool _heavyRainAlarm = true;

  @override
  Widget build(BuildContext context) {
    const Color deepNavy = Color(0xFF0D47A1);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'স্যাটেলাইট শেওলা ও অতিবৃষ্টি রাডার 🛰️',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: deepNavy,
        elevation: 0,
        centerTitle: true,
      ),
      body: PremiumFeatureGatekeeper(
        featureName: 'পুকুরের স্যাটেলাইট বায়ো-অ্যালার্জি ও বন্যা রাডার',
        description: 'স্যাটেলাইট ইমেজিং দিয়ে শেওলার বিস্তার ও অতিবৃষ্টিতে পুকুর প্লাবনের লাইভ পূর্বাভাস পান।',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Satellite Visual Simulation Map
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=80'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.4), Colors.black.withOpacity(0.8)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.radar, color: Colors.white, size: 16),
                                const SizedBox(width: 6),
                                Text('Sentinel-2 লাইভ স্যাটেলাইট', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                            child: Text('রেজোলিউশন: ১০ মিটার', style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 11)),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('পুকুর-১ (সিংড়া, নাটোর)', style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text('ক্লোরোফিল-এ ইনডেক্স: স্বাভাবিক • অক্সিজেন সংকট ঝুঁকি: ২%', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.greenAccent)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Weather & Cloud Cover Telemetry
              Text('স্যাটেলাইট বায়ুমণ্ডলীয় টেলিমেট্রি', style: GoogleFonts.hindSiliguri(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTelemetryCard(
                      icon: Icons.cloud,
                      title: 'মেঘের ঘনত্ব',
                      value: '৭৫%',
                      status: 'সূর্যালোক কম',
                      color: Colors.amber.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTelemetryCard(
                      icon: Icons.water,
                      title: 'বৃষ্টিপাত সম্ভাবনা',
                      value: '৮০ মিলিমিটার',
                      status: 'অতিবৃষ্টি সতর্কতা ⚠️',
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTelemetryCard(
                      icon: Icons.grass,
                      title: 'শেওলা স্তর (Algae)',
                      value: '০.১২ mg/L',
                      status: 'নিরাপদ মাত্রা',
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTelemetryCard(
                      icon: Icons.air,
                      title: 'বায়ুচাপ ও দ্রবীভূত O₂',
                      value: '১০০২ hPa',
                      status: 'অক্সিজেন ড্রপ ঝুঁকি কম',
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // SMS Alert Switches
              Text('জরুরি এসএমএস ও সাইরেন অ্যালার্ট সেটিংস', style: GoogleFonts.hindSiliguri(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      activeColor: Colors.blue.shade700,
                      title: Text('পুকুরের পাড় প্লাবনের লাইভ সাইরেন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('অতিবৃষ্টিতে পুকুরের পাড় ভেসে যাওয়ার পূর্বাভাস পেলে তীব্র অ্যালার্ম বাজবে।', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600)),
                      value: _heavyRainAlarm,
                      onChanged: (v) => setState(() => _heavyRainAlarm = v),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      activeColor: Colors.blue.shade700,
                      title: Text('অক্সিজেন সংকটের তাৎক্ষণিক এসএমএস', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('ভোরে মেঘলা আবহাওয়ায় মাছ ভেসে ওঠার আগেই মোবাইলে ফ্রি এসএমএস পাঠানো হবে।', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600)),
                      value: _sosAlertEnabled,
                      onChanged: (v) => setState(() => _sosAlertEnabled = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTelemetryCard({
    required IconData icon,
    required String title,
    required String value,
    required String status,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600)),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(status, style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
