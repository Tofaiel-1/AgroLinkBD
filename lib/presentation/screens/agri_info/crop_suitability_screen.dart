import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/agri_info_model.dart';

/// Crop Suitability Screen — Google Maps + List View
class CropSuitabilityScreen extends StatefulWidget {
  final UpazilaCropData? data;
  const CropSuitabilityScreen({super.key, this.data});

  @override
  State<CropSuitabilityScreen> createState() => _CropSuitabilityScreenState();
}

class _CropSuitabilityScreenState extends State<CropSuitabilityScreen> {
  bool _showMap = false;
  String _filterSeason = 'all';

  static const Color primaryGreen = Color(0xFF2E7D32);

  static const Map<String, String> _seasonLabels = {
    'all': 'সব মৌসুম',
    'rabi': 'রবি',
    'kharif1': 'খরিফ-১',
    'kharif2': 'খরিফ-২',
  };

  static const Map<String, Color> _suitabilityColors = {
    'high': Color(0xFF2E7D32),
    'medium': Color(0xFFE65100),
    'low': Color(0xFFC62828),
  };

  static const Map<String, String> _suitabilityLabels = {
    'high': 'অত্যন্ত উপযুক্ত',
    'medium': 'মোটামুটি উপযুক্ত',
    'low': 'কম উপযুক্ত',
  };

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ফসল উপযোগিতা',
                style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            if (data != null)
              Text('${data.zilla} › ${data.upazila}',
                  style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 11)),
          ],
        ),
        actions: [
          // Map/List toggle
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _toggleBtn(Icons.list, !_showMap, () => setState(() => _showMap = false)),
                _toggleBtn(Icons.map, _showMap, () => setState(() => _showMap = true)),
              ],
            ),
          ),
        ],
      ),
      body: data == null
          ? _buildNoData()
          : Column(
              children: [
                // Season filter chips
                _buildSeasonFilter(),
                // Content
                Expanded(
                  child: _showMap
                      ? _buildMapView(data)
                      : _buildListView(data),
                ),
              ],
            ),
    );
  }

  Widget _toggleBtn(IconData icon, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildSeasonFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _seasonLabels.entries.map((e) {
            final active = _filterSeason == e.key;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(e.value, style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
                selected: active,
                onSelected: (_) => setState(() => _filterSeason = e.key),
                selectedColor: primaryGreen,
                labelStyle: TextStyle(color: active ? Colors.white : Colors.black87),
                checkmarkColor: Colors.white,
                backgroundColor: Colors.grey.shade100,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildListView(UpazilaCropData data) {
    final crops = data.suitableCrops.where((c) =>
        _filterSeason == 'all' || c.season == _filterSeason).toList();

    if (crops.isEmpty) {
      return Center(
        child: Text('এই মৌসুমে কোনো ফসলের তথ্য নেই',
            style: GoogleFonts.hindSiliguri(color: Colors.grey.shade600)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: crops.length,
      itemBuilder: (ctx, i) {
        final c = crops[i];
        final color = _suitabilityColors[c.suitability] ?? primaryGreen;
        final label = _suitabilityLabels[c.suitability] ?? '';
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Crop icon
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.grass, color: color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(c.cropName,
                              style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: color.withOpacity(0.3)),
                            ),
                            child: Text(label,
                                style: GoogleFonts.hindSiliguri(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _tag(Icons.calendar_month, c.seasonBn, Colors.blue.shade600),
                          const SizedBox(width: 12),
                          _tag(Icons.grain, c.variety, Colors.brown.shade400),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Yield bar
                      Row(
                        children: [
                          Text('উৎপাদন: ${c.yieldTonPerHa} টন/হেক্টর',
                              style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600)),
                          const Spacer(),
                          SizedBox(
                            width: 80,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (c.yieldTonPerHa / 50).clamp(0.0, 1.0),
                                backgroundColor: Colors.grey.shade200,
                                color: color,
                                minHeight: 6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapView(UpazilaCropData data) {
    // Show a styled placeholder with location info and crop markers
    // In production, replace with actual GoogleMap widget
    return Stack(
      children: [
        // Map background placeholder
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade100, Colors.green.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CustomPaint(painter: _MapPatternPainter()),
        ),
        // Center location marker
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF2E7D32), size: 32),
                    const SizedBox(height: 4),
                    Text(data.upazila,
                        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${data.division} · ${data.zilla}',
                        style: GoogleFonts.hindSiliguri(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Color(0xFF2E7D32), size: 30),
            ],
          ),
        ),
        // Floating crop legend
        Positioned(
          bottom: 16, left: 16, right: 16,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('এলাকার উপযুক্ত ফসল',
                    style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8, runSpacing: 6,
                  children: data.suitableCrops.map((c) {
                    final color = _suitabilityColors[c.suitability] ?? primaryGreen;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(c.cropName, style: GoogleFonts.hindSiliguri(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tag(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.hindSiliguri(fontSize: 12, color: color)),
      ],
    );
  }

  Widget _buildNoData() {
    return Center(
      child: Text('তথ্য পাওয়া যায়নি', style: GoogleFonts.hindSiliguri(fontSize: 16, color: Colors.grey)),
    );
  }
}

class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.shade200.withOpacity(0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw grid lines to simulate a map
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw some "field" areas
    final fieldPaint = Paint()..color = Colors.green.shade300.withOpacity(0.3);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.1, size.height * 0.1, size.width * 0.3, size.height * 0.25), const Radius.circular(8)), fieldPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, size.height * 0.15, size.width * 0.35, size.height * 0.3), const Radius.circular(8)), fieldPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.1, size.height * 0.55, size.width * 0.4, size.height * 0.25), const Radius.circular(8)), fieldPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}
