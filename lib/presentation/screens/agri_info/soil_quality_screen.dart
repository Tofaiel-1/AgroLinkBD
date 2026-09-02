import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/agri_info_model.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';

/// Soil Quality Screen
class SoilQualityScreen extends StatelessWidget {
  final UpazilaCropData? data;
  const SoilQualityScreen({super.key, this.data});

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color earthyBrown = Color(0xFF6D4C41);

  @override
  Widget build(BuildContext context) {
    final d = data;
    final bool isBn = LanguageProvider.isBn(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: earthyBrown,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Get.back()),
        title: Text(
          isBn ? 'মাটির গুণাগুণ' : 'Soil Quality',
          style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: d == null
          ? Center(child: Text(isBn ? 'তথ্য নেই' : 'No Data Available', style: GoogleFonts.hindSiliguri(color: Colors.black87)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Soil health score card
                _buildHealthCard(d.soilProfile, isBn),
                const SizedBox(height: 16),
                // Soil properties
                _buildPropertiesCard(d.soilProfile, isBn),
                const SizedBox(height: 12),
                // pH chart
                _buildPhCard(d.soilProfile, isBn),
                const SizedBox(height: 12),
                // Recommendations
                _buildRecommendationsCard(d.soilProfile, isBn),
              ],
            ),
    );
  }

  Widget _buildHealthCard(SoilProfile soil, bool isBn) {
    final score = _getSoilScore(soil);
    final color = _getScoreColor(score);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [earthyBrown, Colors.brown.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.landscape, color: Colors.white, size: 36),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn ? soil.typeBn : soil.type,
                      style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      soil.description,
                      style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
              // Health score circle
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: Center(
                  child: Text('$score',
                      style: GoogleFonts.poppins(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isBn ? 'মাটির স্বাস্থ্য স্কোর' : 'Soil Health Score',
                style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 12),
              ),
              Text(
                '${_getHealthLabel(score, isBn)} ($score/100)',
                style: GoogleFonts.hindSiliguri(color: color, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesCard(SoilProfile soil, bool isBn) {
    final organic = {'low': isBn ? '১-২%' : '1-2%', 'medium': isBn ? '২-৩%' : '2-3%', 'high': isBn ? '৩%+' : '3%+'}[soil.organicMatter] ?? soil.organicMatter;
    final orgIcon = soil.organicMatter == 'high' ? Icons.thumb_up : soil.organicMatter == 'medium' ? Icons.thumbs_up_down : Icons.thumb_down;
    final orgColor = soil.organicMatter == 'high' ? primaryGreen : soil.organicMatter == 'medium' ? Colors.orange.shade600 : Colors.red.shade400;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.info_outline, color: Color(0xFF6D4C41)),
              const SizedBox(width: 8),
              Text(
                isBn ? 'মাটির বৈশিষ্ট্য' : 'Soil Properties',
                style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ]),
            const Divider(height: 20),
            _propRow(isBn ? 'মাটির ধরন' : 'Soil Type', isBn ? soil.typeBn : soil.type, Icons.category, earthyBrown),
            _propRow(isBn ? 'জৈব পদার্থ' : 'Organic Matter', organic, orgIcon, orgColor),
            _propRow(isBn ? 'পানি নিষ্কাশন' : 'Water Drainage', _drainageText(soil.drainage, isBn), Icons.water, Colors.blue.shade500),
            _propRow(isBn ? 'মাটির pH পরিসীমা' : 'pH Range', '${soil.phMin} – ${soil.phMax}', Icons.science, Colors.purple.shade500),
          ],
        ),
      ),
    );
  }

  Widget _buildPhCard(SoilProfile soil, bool isBn) {
    final phMid = (soil.phMin + soil.phMax) / 2;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.science, color: Colors.purple),
              const SizedBox(width: 8),
              Text(
                isBn ? 'pH মাত্রা বিশ্লেষণ' : 'pH Level Analysis',
                style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ]),
            const SizedBox(height: 16),
            // pH scale bar
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 24,
                    child: Row(
                      children: [
                        Expanded(flex: 35, child: Container(color: Colors.red.shade300)),
                        Expanded(flex: 15, child: Container(color: Colors.orange.shade300)),
                        Expanded(flex: 20, child: Container(color: Colors.green.shade400)),
                        Expanded(flex: 15, child: Container(color: Colors.blue.shade300)),
                        Expanded(flex: 15, child: Container(color: Colors.purple.shade300)),
                      ],
                    ),
                  ),
                ),
                // Indicator
                Positioned(
                  left: ((phMid / 14) * (MediaQuery.of(Get.context!).size.width - 60)).clamp(0.0, double.infinity),
                  child: const Icon(Icons.arrow_drop_down, color: Colors.black, size: 30),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: (isBn 
                      ? ['অম্ল (0)', 'নিরপেক্ষ (7)', 'ক্ষারীয় (14)']
                      : ['Acidic (0)', 'Neutral (7)', 'Alkaline (14)'])
                  .map((l) => Text(l, style: GoogleFonts.hindSiliguri(fontSize: 10, color: Colors.grey)))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getPhColor(phMid).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: _getPhColor(phMid), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getPhAdvice(phMid, isBn),
                      style: GoogleFonts.hindSiliguri(fontSize: 13, color: _getPhColor(phMid)),
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

  Widget _buildRecommendationsCard(SoilProfile soil, bool isBn) {
    final recs = _getRecommendations(soil, isBn);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.tips_and_updates, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                isBn ? 'মাটি উন্নয়নের পরামর্শ' : 'Soil Improvement Guidelines',
                style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ]),
            const Divider(height: 20),
            ...recs.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24, height: 24,
                    decoration: const BoxDecoration(color: Color(0xFF2E7D32), shape: BoxShape.circle),
                    child: Center(child: Text('${e.key + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(e.value, style: GoogleFonts.hindSiliguri(fontSize: 13, height: 1.4))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _propRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Text(label, style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade600)),
          const Spacer(),
          Text(value, style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  int _getSoilScore(SoilProfile soil) {
    int s = 50;
    if (soil.organicMatter == 'high') s += 25;
    else if (soil.organicMatter == 'medium') s += 15;
    if (soil.drainage == 'good') s += 15;
    else if (soil.drainage == 'moderate') s += 8;
    if (soil.phMin >= 5.5 && soil.phMax <= 7.5) s += 10;
    return s.clamp(0, 100);
  }

  Color _getScoreColor(int s) {
    if (s >= 80) return Colors.green;
    if (s >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getHealthLabel(int s, bool isBn) {
    if (isBn) {
      if (s >= 80) return 'অত্যন্ত ভালো';
      if (s >= 65) return 'ভালো';
      if (s >= 50) return 'মাঝারি';
      return 'উন্নয়নযোগ্য';
    } else {
      if (s >= 80) return 'Excellent';
      if (s >= 65) return 'Good';
      if (s >= 50) return 'Fair';
      return 'Needs Improvement';
    }
  }

  Color _getPhColor(double ph) {
    if (ph < 5.5) return Colors.red.shade600;
    if (ph < 6.0) return Colors.orange.shade600;
    if (ph <= 7.5) return Colors.green.shade600;
    return Colors.blue.shade600;
  }

  String _getPhAdvice(double ph, bool isBn) {
    if (isBn) {
      if (ph < 5.5) return 'অত্যন্ত অম্লীয়। চুন (ডোলোমাইট) প্রয়োগ করে pH বাড়ান।';
      if (ph < 6.0) return 'কিছুটা অম্লীয়। কৃষি চুন ব্যবহার করুন।';
      if (ph <= 7.5) return 'সর্বোত্তম pH। অধিকাংশ ফসলের জন্য আদর্শ।';
      return 'ক্ষারীয় মাটি। জৈব সার ও গন্ধক প্রয়োগ করুন।';
    } else {
      if (ph < 5.5) return 'Highly acidic. Apply agricultural lime (dolomite) to increase pH.';
      if (ph < 6.0) return 'Slightly acidic. Apply light agricultural lime.';
      if (ph <= 7.5) return 'Optimal pH. Ideal condition for most agricultural crops.';
      return 'Alkaline soil. Apply organic compost and sulphur to balance pH.';
    }
  }

  String _drainageText(String d, bool isBn) {
    if (isBn) {
      return {'poor': 'দুর্বল', 'moderate': 'মাঝারি', 'good': 'ভালো'}[d] ?? d;
    } else {
      return {'poor': 'Poor', 'moderate': 'Moderate', 'good': 'Good'}[d] ?? d;
    }
  }

  List<String> _getRecommendations(SoilProfile soil, bool isBn) {
    final recs = <String>[];
    if (isBn) {
      if (soil.organicMatter == 'low') recs.add('জৈব পদার্থ বাড়ান। কম্পোস্ট, সবুজ সার বা ভার্মি কম্পোস্ট ব্যবহার করুন।');
      if (soil.drainage == 'poor') recs.add('মাটির পানি নিষ্কাশন উন্নত করুন। নালা খনন এবং উঁচু বেড পদ্ধতিতে চাষ করুন।');
      if (soil.phMin < 5.5) recs.add('মাটির pH কম। প্রতি বিঘায় ১০-১৫ কেজি চুন প্রয়োগ করুন।');
      if (soil.phMin > 7.5) recs.add('মাটি ক্ষারীয়। জৈব পদার্থ ও গন্ধক দিয়ে pH কমান।');
      recs.add('নিয়মিত মাটি পরীক্ষা করুন (প্রতি ৩ বছরে একবার)।');
      recs.add('ফসল পরিক্রমা মেনে চলুন। একই ফসল বারবার চাষ করবেন না।');
    } else {
      if (soil.organicMatter == 'low') recs.add('Increase organic matter using compost, green manure or vermicompost.');
      if (soil.drainage == 'poor') recs.add('Improve water drainage by digging trenches and raised bed farming.');
      if (soil.phMin < 5.5) recs.add('Low soil pH. Apply 10-15 kg agricultural lime per bigha.');
      if (soil.phMin > 7.5) recs.add('Alkaline soil. Lower pH using organic matter and gypsum/sulphur.');
      recs.add('Test soil regularly (once every 3 years).');
      recs.add('Follow crop rotation. Avoid cultivating the same crop repeatedly.');
    }
    return recs;
  }
}
