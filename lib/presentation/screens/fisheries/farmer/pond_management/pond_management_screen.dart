import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/controllers/pond_controller.dart';
import 'package:agrolinkbd/core/models/pond_model.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/pond_management/add_pond_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/pond_management/pond_detail_screen.dart';

class PondManagementScreen extends StatefulWidget {
  const PondManagementScreen({super.key});

  @override
  State<PondManagementScreen> createState() => _PondManagementScreenState();
}

class _PondManagementScreenState extends State<PondManagementScreen> {
  late final PondController _pondController;

  @override
  void initState() {
    super.initState();
    // Initialize or find the controller
    _pondController = Get.isRegistered<PondController>()
        ? Get.find<PondController>()
        : Get.put(PondController());
  }

  @override
  Widget build(BuildContext context) {
    const Color oceanBlue = Color(0xFF0288D1);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'পুকুর ব্যবস্থাপনা',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: oceanBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (_pondController.ponds.isEmpty) {
          return _buildEmptyState();
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _pondController.ponds.length,
          itemBuilder: (context, index) {
            return _buildPondCard(_pondController.ponds[index]);
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => const AddPondScreen());
        },
        backgroundColor: oceanBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'নতুন পুকুর',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pool, size: 100, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'আপনার কোনো পুকুর নেই',
            style: GoogleFonts.hindSiliguri(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'নতুন পুকুর যোগ করতে নিচের বাটনে ক্লিক করুন',
            style: GoogleFonts.hindSiliguri(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPondCard(PondModel pond) {
    final bool isWarning = pond.status == 'সতর্কতা';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            Get.to(() => PondDetailScreen(pond: pond));
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        pond.name,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isWarning ? Colors.red.shade50 : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isWarning ? Colors.red.shade200 : Colors.green.shade200,
                        ),
                      ),
                      child: Text(
                        pond.status,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isWarning ? Colors.red.shade700 : Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 8),
                Text(
                  'মাছ: ${pond.fishSpecies}',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.straighten, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'আয়তন: ${pond.area}',
                      style: GoogleFonts.hindSiliguri(color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'চাষের দিন: ${pond.daysSinceStocked}',
                      style: GoogleFonts.hindSiliguri(color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol(context, 'মোট খরচ', '৳${pond.totalCost.toStringAsFixed(0)}', Icons.monetization_on),
                    Container(width: 1, height: 30, color: Colors.grey.shade300),
                    _buildStatCol(context, 'pH', pond.ph.toString(), Icons.science),
                    Container(width: 1, height: 30, color: Colors.grey.shade300),
                    _buildStatCol(context, 'অ্যামোনিয়া', pond.ammonia.toString(), Icons.warning_amber),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCol(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.hindSiliguri(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}
