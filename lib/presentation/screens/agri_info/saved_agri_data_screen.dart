import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/agri_info_model.dart';
import 'package:agrolinkbd/core/services/agri_info_service.dart';
import 'package:agrolinkbd/core/controllers/user_controller.dart';
import 'agri_info_hub_screen.dart';

/// Saved Agricultural Data Screen
class SavedAgriDataScreen extends StatefulWidget {
  const SavedAgriDataScreen({super.key});

  @override
  State<SavedAgriDataScreen> createState() => _SavedAgriDataScreenState();
}

class _SavedAgriDataScreenState extends State<SavedAgriDataScreen> {
  final AgriInfoService _service = AgriInfoService();
  List<SavedAgriData> _savedItems = [];
  bool _isLoading = true;
  late String _userId;

  static const Color primaryGreen = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    final uc = Get.isRegistered<UserController>() ? Get.find<UserController>() : Get.put(UserController());
    _userId = uc.userId.isNotEmpty ? uc.userId : 'demo_user';
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final items = await _service.getSavedData(_userId);
      setState(() { _savedItems = items; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _delete(String id) async {
    await _service.deleteData(id);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text('সংরক্ষিত তথ্য',
            style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : _savedItems.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _savedItems.length,
                    itemBuilder: (_, i) => _buildSavedCard(_savedItems[i]),
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('কোনো সংরক্ষিত তথ্য নেই',
              style: GoogleFonts.hindSiliguri(fontSize: 18, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('কৃষি তথ্য কেন্দ্র থেকে এলাকার তথ্য সংরক্ষণ করুন',
              textAlign: TextAlign.center,
              style: GoogleFonts.hindSiliguri(fontSize: 14, color: Colors.grey.shade500)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.off(() => const AgriInfoHubScreen()),
            icon: const Icon(Icons.add),
            label: Text('তথ্য যোগ করুন', style: GoogleFonts.hindSiliguri(color: Colors.black87)),
            style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedCard(SavedAgriData item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: primaryGreen.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.location_on, color: primaryGreen, size: 24),
        ),
        title: Text(item.upazila,
            style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${item.division} › ${item.zilla}',
                style: GoogleFonts.hindSiliguri(color: Colors.grey.shade600, fontSize: 12)),
            if (item.note != null && item.note!.isNotEmpty)
              Text(item.note!, style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.open_in_new, color: primaryGreen),
              onPressed: () {
                Get.to(() => const AgriInfoHubScreen());
              },
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
              onPressed: () => _confirmDelete(item.id),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String id) {
    Get.dialog(AlertDialog(
      title: Text('মুছে ফেলবেন?', style: GoogleFonts.hindSiliguri(color: Colors.black87)),
      content: Text('এই সংরক্ষিত তথ্যটি মুছে যাবে।', style: GoogleFonts.hindSiliguri(color: Colors.black87)),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('বাতিল', style: GoogleFonts.hindSiliguri(color: Colors.black87))),
        ElevatedButton(
          onPressed: () { Get.back(); _delete(id); },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text('মুছুন', style: GoogleFonts.hindSiliguri(color: Colors.white)),
        ),
      ],
    ));
  }
}
