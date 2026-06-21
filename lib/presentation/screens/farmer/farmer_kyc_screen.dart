import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

/// Farmer KYC Screen - Upload verification documents
class FarmerKycScreen extends StatefulWidget {
  const FarmerKycScreen({super.key});

  @override
  State<FarmerKycScreen> createState() => _FarmerKycScreenState();
}

class _FarmerKycScreenState extends State<FarmerKycScreen> {
  bool _nidUploaded = false;
  bool _landDocUploaded = false;
  bool _bankDetailsUploaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC যাচাইকরণ'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                border: Border.all(color: Colors.amber),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.amber, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'আপনার KYC যাচাইকরণ প্রক্রিয়াধীন। সমস্ত ডকুমেন্ট সাবমিট করুন।',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Documents
            Text(
              'প্রয়োজনীয় ডকুমেন্ট',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // NID
            _buildDocumentCard(
              icon: Icons.badge,
              title: 'জাতীয় পরিচয়পত্র (NID)',
              subtitle: 'উভয় পাশের ছবি আপলোড করুন',
              isUploaded: _nidUploaded,
              onTap: () {
                setState(() => _nidUploaded = !_nidUploaded);
                Get.snackbar('NID', 'ছবি আপলোড হয়েছে');
              },
            ),
            const SizedBox(height: 12),

            // Land Document
            _buildDocumentCard(
              icon: Icons.description,
              title: 'জমির কাগজপত্র',
              subtitle: 'মালিকানা প্রমাণ পত্র বা ইজারা চুক্তি',
              isUploaded: _landDocUploaded,
              onTap: () {
                setState(() => _landDocUploaded = !_landDocUploaded);
                Get.snackbar('জমির কাগজ', 'ডকুমেন্ট আপলোড হয়েছে');
              },
            ),
            const SizedBox(height: 12),

            // Bank Details
            _buildDocumentCard(
              icon: Icons.account_balance,
              title: 'ব্যাংক অ্যাকাউন্ট বিবরণ',
              subtitle: 'চেক বই বা ব্যাংক স্টেটমেন্ট',
              isUploaded: _bankDetailsUploaded,
              onTap: () {
                setState(() => _bankDetailsUploaded = !_bankDetailsUploaded);
                Get.snackbar('ব্যাংক বিবরণ', 'ডকুমেন্ট আপলোড হয়েছে');
              },
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _nidUploaded && _landDocUploaded && _bankDetailsUploaded
                          ? const Color(0xFF2E7D32)
                          : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed:
                    _nidUploaded && _landDocUploaded && _bankDetailsUploaded
                        ? () {
                            Get.snackbar(
                              'সাফল্য',
                              'KYC যাচাইকরণের জন্য জমা দেওয়া হয়েছে',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          }
                        : null,
                child: Text(
                  'জমা দিন',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isUploaded,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUploaded ? Colors.green.withOpacity(0.05) : Colors.white,
        border: Border.all(
          color: isUploaded ? Colors.green : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isUploaded
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isUploaded ? Colors.green : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isUploaded ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                isUploaded ? Icons.check : Icons.upload,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
