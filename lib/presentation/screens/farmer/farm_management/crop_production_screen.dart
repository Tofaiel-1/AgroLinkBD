import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/phase2_models/farm_models.dart';
import 'package:agrolinkbd/core/services/phase2_services/farm_service.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/presentation/screens/farmer/farm_management/add_edit_crop_screen.dart';

class CropProductionScreen extends StatefulWidget {
  const CropProductionScreen({Key? key}) : super(key: key);

  @override
  State<CropProductionScreen> createState() => _CropProductionScreenState();
}

class _CropProductionScreenState extends State<CropProductionScreen> {
  final FarmService _farmService = FarmService();

  void _confirmDelete(BuildContext context, String plantingId, bool isBn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isBn ? 'ফসল ট্র্যাকিং মুছুন' : 'Delete Crop'),
        content: Text(isBn ? 'আপনি কি নিশ্চিতভাবে এই ফসলের ট্র্যাকিং মুছে ফেলতে চান?' : 'Are you sure you want to remove this crop from tracking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isBn ? 'বাতিল' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _farmService.deleteCropPlanting(plantingId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isBn ? 'ফসল সফলভাবে মুছে ফেলা হয়েছে' : 'Crop deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isBn ? 'মুছুন' : 'Delete', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isBn = LanguageProvider.isBn(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8BC34A),
        elevation: 0,
        title: Text(
          isBn ? 'ফসল উৎপাদন ও পর্যায়' : 'Crop Production & Growth',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            tooltip: isBn ? 'নতুন ফসল ট্র্যাক করুন' : 'Track New Crop',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddEditCropScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<CropPlanting>>(
        stream: _farmService.getCropPlantingsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF8BC34A)));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }

          final crops = snapshot.data ?? [];
          final healthyCount = crops.where((c) => c.status != 'ready_to_harvest' && c.status != 'harvested').length;
          final needsAttnCount = crops.where((c) => c.status == 'ready_to_harvest').length;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF8BC34A),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBn ? 'সক্রিয় ফসলের সামগ্রিক অবস্থা' : 'Active Crops Summary',
                        style: GoogleFonts.hindSiliguri(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryStat(isBn ? 'মোট ফসল' : 'Total Crops', crops.length.toString()),
                          _buildSummaryStat(isBn ? 'ক্রমবর্ধমান' : 'Growing', healthyCount.toString()),
                          _buildSummaryStat(isBn ? 'কর্তন প্রস্তুত' : 'Ready', needsAttnCount.toString()),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              if (crops.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.grass, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          isBn ? 'এখনও কোনো ফসল ট্র্যাক করা হয়নি' : 'No crops tracked yet',
                          style: GoogleFonts.hindSiliguri(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isBn ? 'উপরে + বাটনে ক্লিক করে ফসল যোগ করুন' : 'Click the + icon above to start tracking.',
                          style: GoogleFonts.hindSiliguri(fontSize: 14, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(20.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildCropCard(context, crops[index], isBn);
                      },
                      childCount: crops.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.hindSiliguri(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCropCard(BuildContext context, CropPlanting crop, bool isBn) {
    // Calculate progress roughly based on dates
    final totalDays = crop.expectedHarvestDate.difference(crop.plantedDate).inDays;
    final daysPassed = DateTime.now().difference(crop.plantedDate).inDays;
    double progress = totalDays > 0 ? daysPassed / totalDays : 0.0;
    if (progress < 0) progress = 0;
    if (progress > 1) progress = 1;

    Color healthColor = Colors.green;
    String healthText = isBn ? 'ভালো' : 'Good';
    if (crop.status == 'ready_to_harvest') {
      healthColor = Colors.orange;
      healthText = isBn ? 'কর্তন প্রস্তুত' : 'Harvest Now';
    } else if (crop.status == 'harvested') {
      healthColor = Colors.blue;
      healthText = isBn ? 'সম্পন্ন' : 'Harvested';
      progress = 1.0;
    }

    String stageText = crop.status;
    if (crop.status == 'planted') stageText = isBn ? 'রোপিত (Planted)' : 'Planted';
    if (crop.status == 'growing') stageText = isBn ? 'বর্ধমান (Growing)' : 'Growing';
    if (crop.status == 'flowering') stageText = isBn ? 'ফুল পর্যায় (Flowering)' : 'Flowering';
    if (crop.status == 'ready_to_harvest') stageText = isBn ? 'ফসল কাটার সময়' : 'Ready to Harvest';
    if (crop.status == 'harvested') stageText = isBn ? 'ফসল তোলা শেষ' : 'Harvested';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCBD5E1).withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  crop.cropName,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: healthColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      healthText,
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: healthColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _confirmDelete(context, crop.id, isBn),
                    child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 8),
              Text(
                '${isBn ? "রোপনের তারিখ:" : "Planted:"} ${crop.plantedDate.toLocal().toString().split(' ')[0]}',
                style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.event_available, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 8),
              Text(
                '${isBn ? "কর্তনের সম্ভাব্য তারিখ:" : "Est. Harvest:"} ${crop.expectedHarvestDate.toLocal().toString().split(' ')[0]}',
                style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '${isBn ? "বর্তমান পর্যায়:" : "Stage:"} $stageText',
            style: GoogleFonts.hindSiliguri(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8BC34A)),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(progress * 100).toInt()}% ${isBn ? "পরিপক্ক" : "to Harvest"}',
              style: GoogleFonts.hindSiliguri(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

