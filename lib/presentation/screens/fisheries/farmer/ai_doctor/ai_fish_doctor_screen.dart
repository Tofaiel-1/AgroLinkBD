import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AIFishDoctorScreen extends StatefulWidget {
  const AIFishDoctorScreen({super.key});

  @override
  State<AIFishDoctorScreen> createState() => _AIFishDoctorScreenState();
}

class _AIFishDoctorScreenState extends State<AIFishDoctorScreen> with SingleTickerProviderStateMixin {
  File? _imageFile;
  bool _isScanning = false;
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'ক্যামেরা চালু করতে সমস্যা হয়েছে');
    }
  }

  void _startScan() {
    if (_imageFile == null) return;
    
    setState(() {
      _isScanning = true;
    });

    // Simulate AI processing delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() {
    Get.defaultDialog(
      title: 'স্ক্যানিং ফলাফল',
      titleStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.teal.shade700),
      content: Column(
        children: [
          const Icon(Icons.warning_amber_rounded, size: 50, color: Colors.orange),
          const SizedBox(height: 10),
          Text(
            'সম্ভাব্য রোগ: লেজ ও পাখনা পচা',
            style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'পরামর্শ: পুকুরের পানি পরিবর্তন করুন এবং প্রতি শতকে ৫০০ গ্রাম চুন ও ২৫০ গ্রাম লবণ প্রয়োগ করুন।',
            textAlign: TextAlign.center,
            style: GoogleFonts.hindSiliguri(fontSize: 14),
          ),
        ],
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade700),
        onPressed: () => Get.back(),
        child: Text('ঠিক আছে', style: GoogleFonts.hindSiliguri(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'এআই মাছের ডাক্তার',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal.shade700,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'মাছের আক্রান্ত অংশের ছবি তুলুন বা গ্যালারি থেকে আপলোড করুন',
              textAlign: TextAlign.center,
              style: GoogleFonts.hindSiliguri(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Center(
                child: _imageFile == null
                    ? _buildPlaceholder()
                    : _buildImagePreview(),
              ),
            ),
            const SizedBox(height: 30),
            if (_imageFile == null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOptionButton(
                    icon: Icons.camera_alt,
                    label: 'ক্যামেরা',
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  _buildOptionButton(
                    icon: Icons.photo_library,
                    label: 'গ্যালারি',
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _isScanning ? null : () {
                          setState(() {
                            _imageFile = null;
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: Text('নতুন ছবি', style: GoogleFonts.hindSiliguri()),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.teal.shade700,
                          side: BorderSide(color: Colors.teal.shade700),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isScanning ? null : _startScan,
                        icon: _isScanning
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.search),
                        label: Text(
                          _isScanning ? 'স্ক্যান করা হচ্ছে...' : 'স্ক্যান করুন',
                          style: GoogleFonts.hindSiliguri(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade700,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal.shade200, width: 2, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo, size: 80, color: Colors.teal.shade200),
          const SizedBox(height: 16),
          Text(
            'এখানে ছবি যুক্ত করুন',
            style: GoogleFonts.hindSiliguri(
              color: Colors.teal.shade400,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 350,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              _imageFile!,
              fit: BoxFit.cover,
            ),
            if (_isScanning)
              AnimatedBuilder(
                animation: _scanController,
                builder: (context, child) {
                  return Positioned(
                    top: _scanController.value * 350,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.greenAccent.withOpacity(0.8),
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            if (_isScanning)
              Container(
                color: Colors.teal.withOpacity(0.2),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.teal.shade700),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.hindSiliguri(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
