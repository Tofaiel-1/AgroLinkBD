import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/admin_provider.dart';

class AdminAnnouncementScreen extends StatefulWidget {
  const AdminAnnouncementScreen({super.key});

  @override
  State<AdminAnnouncementScreen> createState() => _AdminAnnouncementScreenState();
}

class _AdminAnnouncementScreenState extends State<AdminAnnouncementScreen> {
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  
  String _selectedAudience = 'All Users';
  String _selectedPriority = 'Normal';
  
  bool _isSending = false;
  bool _isResettingBalances = false; // For dev tools

  final List<String> _audienceOptions = ['All Users', 'Farmers Only', 'Buyers Only', 'Drivers Only'];
  final List<String> _priorityOptions = ['Low', 'Normal', 'High'];

  Future<void> _sendAnnouncement() async {
    if (_titleController.text.trim().isEmpty || _detailsController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Title and Details cannot be empty.', backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return;
    }

    setState(() => _isSending = true);

    try {
      final id = const Uuid().v4();
      await FirebaseFirestore.instance.collection('announcements').doc(id).set({
        'id': id,
        'title': _titleController.text.trim(),
        'details': _detailsController.text.trim(),
        'audience': _selectedAudience,
        'priority': _selectedPriority,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      _titleController.clear();
      _detailsController.clear();
      setState(() {
        _selectedAudience = 'All Users';
        _selectedPriority = 'Normal';
      });

      if (mounted) {
        await Provider.of<AdminProvider>(context, listen: false).logAdminAction(
          'ANNOUNCEMENT_SENT',
          'Sent $_selectedPriority priority announcement to $_selectedAudience',
        );
      }

      Get.snackbar('Success', 'Announcement sent successfully to $_selectedAudience!', backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send announcement: $e', backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
    } finally {
      setState(() => _isSending = false);
    }
  }

  // Temporary Dev Tool to Reset All Wallets to 0
  Future<void> _resetAllWallets() async {
    setState(() => _isResettingBalances = true);
    try {
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      
      WriteBatch batch = FirebaseFirestore.instance.batch();
      int count = 0;
      
      for (var doc in usersSnapshot.docs) {
        batch.update(doc.reference, {
          'walletBalance': 0.0,
          'pendingBalance': 0.0,
        });
        count++;
        
        // Firestore batches can only have up to 500 operations. If more than 400, commit and create new batch
        if (count % 400 == 0) {
          await batch.commit();
          batch = FirebaseFirestore.instance.batch();
        }
      }
      
      await batch.commit();
      
      if (mounted) {
        await Provider.of<AdminProvider>(context, listen: false).logAdminAction(
          'WALLETS_RESET',
          'Developer Tool: Reset wallet balances to 0 for $count users',
        );
      }

      Get.snackbar('Success', 'Successfully reset balances to ৳0.0 for $count users!', backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to reset balances: $e', backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
    } finally {
      setState(() => _isResettingBalances = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19), // Deep Neon Dark
      body: SafeArea(
        child: Stack(
          children: [
            // Ambient glowing orbs
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFF59E0B).withOpacity(0.15)),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -50,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF8B5CF6).withOpacity(0.1)),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(color: Colors.transparent),
            ),
            
            // Content
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildGlassContainer(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Compose Announcement', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Text('Send targeted alerts and notifications to users.', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                                  const SizedBox(height: 30),
                                  
                                  _buildTextField(label: 'Title', controller: _titleController, icon: Icons.title_rounded),
                                  const SizedBox(height: 20),
                                  _buildTextField(label: 'Detailed Message', controller: _detailsController, icon: Icons.description_rounded, maxLines: 5),
                                  const SizedBox(height: 20),
                                  
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildDropdown(
                                          label: 'Target Audience',
                                          value: _selectedAudience,
                                          items: _audienceOptions,
                                          onChanged: (val) => setState(() => _selectedAudience = val!),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildDropdown(
                                          label: 'Priority Level',
                                          value: _selectedPriority,
                                          items: _priorityOptions,
                                          onChanged: (val) => setState(() => _selectedPriority = val!),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 40),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 55,
                                    child: ElevatedButton(
                                      onPressed: _isSending ? null : _sendAnnouncement,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFF59E0B),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: 10,
                                        shadowColor: const Color(0xFFF59E0B).withOpacity(0.5),
                                      ),
                                      child: _isSending 
                                          ? const CircularProgressIndicator(color: Colors.white)
                                          : const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.campaign_rounded),
                                                SizedBox(width: 10),
                                                Text('Publish Announcement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                            
                            // DEV TOOLS SECTION
                            _buildGlassContainer(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                                      const SizedBox(width: 10),
                                      const Text('Developer / Maintenance Tools', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text('Warning: These actions are destructive and will alter live database records.', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton.icon(
                                      onPressed: _isResettingBalances ? null : () {
                                        Get.defaultDialog(
                                          title: 'Are you sure?',
                                          middleText: 'This will wipe out the wallet and pending balances of EVERY user in the database.',
                                          backgroundColor: const Color(0xFF1F2937),
                                          titleStyle: const TextStyle(color: Colors.white),
                                          middleTextStyle: const TextStyle(color: Colors.white70),
                                          textConfirm: 'Yes, Reset All',
                                          textCancel: 'Cancel',
                                          confirmTextColor: Colors.white,
                                          buttonColor: Colors.redAccent,
                                          onConfirm: () {
                                            Get.back();
                                            _resetAllWallets();
                                          }
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent.withOpacity(0.15),
                                        foregroundColor: Colors.redAccent,
                                        side: const BorderSide(color: Colors.redAccent),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      icon: _isResettingBalances ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.redAccent, strokeWidth: 2)) : const Icon(Icons.delete_sweep_rounded),
                                      label: const Text('Reset All User Wallet Balances to 0'),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 20),
          const Text('Global Announcements', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, required IconData icon, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
          prefixIcon: maxLines == 1 ? Icon(icon, color: Colors.white.withOpacity(0.5)) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDropdown({required String label, required String value, required List<String> items, required void Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF1F2937),
          style: const TextStyle(color: Colors.white),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withOpacity(0.5)),
          items: items.map((String item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
