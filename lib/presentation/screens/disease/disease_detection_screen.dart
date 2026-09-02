import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'disease_result_screen.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  final ImagePicker _picker = ImagePicker();
  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
      );

      await _controller!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isBn = LanguageProvider.isBn(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isBn ? 'রোগ নির্ণয় 🌿' : 'Disease Detection 🌿',
          style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Preview or Placeholder
          if (_isCameraInitialized && _controller != null)
            Center(child: CameraPreview(_controller!))
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 100,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isBn ? 'ক্যামেরা লোড হচ্ছে...' : 'Loading camera...',
                    style: GoogleFonts.hindSiliguri(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

          // Overlay Frame
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          // Instructions
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isBn ? 'পাতার স্পষ্ট ছবি নিন' : 'Take a Clear Leaf Photo',
                textAlign: TextAlign.center,
                style: GoogleFonts.hindSiliguri(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Bottom Instructions
          Positioned(
            bottom: 150,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isBn ? 'আক্রান্ত পাতাকে ফ্রেমের মধ্যে রাখুন' : 'Keep infected leaf inside the frame',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.hindSiliguri(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Capture Button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  if (_controller != null && _isCameraInitialized) {
                    try {
                      final XFile image = await _controller!.takePicture();
                      Get.to(() => DiseaseResultScreen(imagePath: image.path));
                    } catch (e) {
                      debugPrint('Error taking picture: $e');
                    }
                  }
                },
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.green, width: 4),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 32,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ),
          ),

          // Gallery Button
          Positioned(
            bottom: 20,
            left: 30,
            child: IconButton(
              icon: const Icon(Icons.photo_library,
                  color: Colors.white, size: 32),
              onPressed: () async {
                try {
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    Get.to(() => DiseaseResultScreen(imagePath: image.path));
                  }
                } catch (e) {
                  debugPrint('Error picking from gallery: $e');
                }
              },
            ),
          ),

          // Flash Button
          Positioned(
            bottom: 20,
            right: 30,
            child: IconButton(
              icon: Icon(
                _flashMode == FlashMode.off ? Icons.flash_off : Icons.flash_on,
                color: Colors.white,
                size: 32,
              ),
              onPressed: () async {
                if (_controller != null && _isCameraInitialized) {
                  setState(() {
                    _flashMode = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
                  });
                  await _controller!.setFlashMode(_flashMode);
                }
              },
            ),
          ),
        ],
      ),
    );
  }


}
