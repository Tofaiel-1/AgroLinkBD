import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/agri_info_model.dart';

/// Crop Zone Screen
class CropZoneScreen extends StatelessWidget {
  final UpazilaCropData? data;
  const CropZoneScreen({super.key, this.data});

  static const Color primaryGreen = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    final d = data;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Get.back()),
        title: Text('ফসল জোন', style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: d == null
          ? Center(child: Text('তথ্য নেই', style: GoogleFonts.hindSiliguri(color: Colors.black87)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Zone header card
                _zoneHeader(d),
                const SizedBox(height: 16),
                // Climate & geography
                _sectionCard(
                  title: 'জলবায়ু ও ভৌগোলিক তথ্য',
                  icon: Icons.wb_sunny,
                  color: Colors.orange.shade600,
                  children: [
                    _infoRow('কৃষি পরিবেশ অঞ্চল', '${d.cropZoneBn} (${d.cropZone})'),
                    _infoRow('অক্ষাংশ / দ্রাঘিমাংশ', '${d.latitude.toStringAsFixed(2)}°N, ${d.longitude.toStringAsFixed(2)}°E'),
                    _infoRow('মাটির ধরন', d.soilProfile.typeBn),
                    _infoRow('পানি নিষ্কাশন', _drainageBn(d.soilProfile.drainage)),
                  ],
                ),
                const SizedBox(height: 12),
                // Season-wise crops
                _sectionCard(
                  title: 'মৌসুম ভিত্তিক ফসল',
                  icon: Icons.calendar_today,
                  color: primaryGreen,
                  children: [
                    _seasonRow('🌾 রবি (নভেম্বর–মার্চ)', d.suitableCrops.where((c) => c.season == 'rabi').map((c) => c.cropName).toList(), Colors.amber.shade700),
                    const Divider(),
                    _seasonRow('🌿 খরিফ-১ (মার্চ–জুন)', d.suitableCrops.where((c) => c.season == 'kharif1').map((c) => c.cropName).toList(), Colors.green.shade600),
                    const Divider(),
                    _seasonRow('🌧 খরিফ-২ (জুলাই–অক্টো.)', d.suitableCrops.where((c) => c.season == 'kharif2').map((c) => c.cropName).toList(), Colors.blue.shade600),
                  ],
                ),
                const SizedBox(height: 12),
                // Top crops table
                _sectionCard(
                  title: 'শীর্ষ উৎপাদনশীল ফসল',
                  icon: Icons.trending_up,
                  color: Colors.teal.shade600,
                  children: [
                    ...d.suitableCrops
                        .where((c) => c.suitability == 'high')
                        .map((c) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Container(width: 10, height: 10,
                                      decoration: const BoxDecoration(color: Color(0xFF2E7D32), shape: BoxShape.circle)),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(c.cropName, style: GoogleFonts.hindSiliguri(fontSize: 14))),
                                  Text('${c.yieldTonPerHa} টন/হেক্টর',
                                      style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _zoneHeader(UpazilaCropData d) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF1E88E5)]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(Icons.map, color: Colors.white, size: 40),
          const SizedBox(height: 12),
          Text(d.cropZoneBn, style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('কৃষি পরিবেশ অঞ্চল — ${d.cropZone}',
              style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statItem('বিভাগ', d.division, Colors.white),
              _statItem('জেলা', d.zilla, Colors.white),
              _statItem('উপজেলা', d.upazila, Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.hindSiliguri(color: color.withOpacity(0.7), fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.hindSiliguri(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _sectionCard({required String title, required IconData icon, required Color color, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Text(title, style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(label, style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade600)),
          const Spacer(),
          Text(value, style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _seasonRow(String season, List<String> crops, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(season, style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 6),
          crops.isEmpty
              ? Text('তথ্য নেই', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey))
              : Wrap(
                  spacing: 6, runSpacing: 4,
                  children: crops.map((c) => Chip(
                    label: Text(c, style: GoogleFonts.hindSiliguri(fontSize: 11, color: color)),
                    backgroundColor: color.withOpacity(0.1),
                    side: BorderSide(color: color.withOpacity(0.3)),
                    padding: const EdgeInsets.all(0),
                  )).toList(),
                ),
        ],
      ),
    );
  }

  String _drainageBn(String d) {
    return {'poor': 'দুর্বল', 'moderate': 'মাঝারি', 'good': 'ভালো'}[d] ?? d;
  }
}
