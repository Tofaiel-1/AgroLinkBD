import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/core/controllers/user_controller.dart';
import 'microfinance_repayment_screen.dart';

const _kBg      = Color(0xFF0D1B3E);
const _kGlass   = Color(0x0DFFFFFF);
const _kBorder  = Color(0x1AFFFFFF);
const _kGreen   = Color(0xFF10B981);
const _kBlue    = Color(0xFF3B82F6);
const _kAmber   = Color(0xFFF59E0B);
const _kText    = Colors.white;
const _kSubtext = Color(0xFFAEB8CC);

// ─────────────────────────────────────────────
// Document upload model
// ─────────────────────────────────────────────
class _DocItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<String> roles; // which roles need this doc
  bool uploaded;
  String? fileName;
  XFile? localFile;

  _DocItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.roles,
    this.uploaded = false,
    this.fileName,
    this.localFile,
  });
}

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────
class MicrofinanceKycScreen extends StatefulWidget {
  final String loanType;
  final String userRole;

  const MicrofinanceKycScreen({
    super.key,
    this.loanType = 'Farmer Crop Loan',
    this.userRole = 'farmer',
  });

  @override
  State<MicrofinanceKycScreen> createState() => _MicrofinanceKycScreenState();
}

class _MicrofinanceKycScreenState extends State<MicrofinanceKycScreen>
    with SingleTickerProviderStateMixin {

  late final AnimationController _progressCtrl;
  late final Animation<double> _progressAnim;

  late final List<_DocItem> _docs;

  int _currentStep = 1; // 1: Upload Docs, 2: Review, 3: Submit
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _docs = [
      _DocItem(
        id: 'nid',
        title: 'National ID Card (NID)',
        subtitle: 'Upload front & back clearly',
        icon: Icons.badge_rounded,
        color: _kGreen,
        roles: ['farmer', 'buyer', 'driver', 'company'],
      ),
      _DocItem(
        id: 'driving',
        title: 'Driving License',
        subtitle: 'Valid & non-expired',
        icon: Icons.drive_eta_rounded,
        color: _kAmber,
        roles: ['driver'],
      ),
      _DocItem(
        id: 'trade',
        title: 'Trade License',
        subtitle: 'Issued by City Corporation',
        icon: Icons.business_center_rounded,
        color: _kBlue,
        roles: ['buyer', 'company'],
      ),
      _DocItem(
        id: 'tin',
        title: 'TIN Certificate',
        subtitle: 'Tax Identification Number',
        icon: Icons.receipt_long_rounded,
        color: Color(0xFF8B5CF6),
        roles: ['company'],
      ),
      _DocItem(
        id: 'land',
        title: 'Land Ownership Proof',
        subtitle: 'Khatian or deed document',
        icon: Icons.landscape_rounded,
        color: _kGreen,
        roles: ['farmer'],
      ),
    ];

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _progressAnim = Tween<double>(begin: 0, end: _calcProgress())
        .animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOut));
    _progressCtrl.forward();
  }

  double _calcProgress() {
    final visible = _visibleDocs;
    if (visible.isEmpty) return 0;
    final uploaded = visible.where((d) => d.uploaded).length;
    return uploaded / visible.length;
  }

  List<_DocItem> get _visibleDocs =>
      _docs.where((d) => d.roles.contains(widget.userRole)).toList();

  Future<void> _toggleUpload(_DocItem doc) async {
    if (doc.uploaded) {
      setState(() {
        doc.uploaded = false;
        doc.fileName = null;
        doc.localFile = null;
      });
      _progressCtrl.animateTo(
        _calcProgress(),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        doc.localFile = image;
        doc.uploaded = true;
        doc.fileName = image.name;
      });
      _progressCtrl.animateTo(
        _calcProgress(),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  bool get _canSubmit => _visibleDocs.every((d) => d.uploaded);

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          _buildOrbs(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildProgressSection(),
                _buildStepIndicator(),
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(child: _buildLoanInfoBanner()),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                          child: Text(
                            'Required Documents',
                            style: const TextStyle(
                              color: _kText, fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => _buildDocWidget(_visibleDocs[i]),
                            childCount: _visibleDocs.length,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: _buildSubmitSection()),
                      const SliverToBoxAdapter(child: SizedBox(height: 40)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Orbs ──────────────────────────────────
  Widget _buildOrbs() => Stack(children: [
        Positioned(top: -60, right: -60,
            child: _orb(220, _kBlue.withOpacity(0.10))),
        Positioned(bottom: -100, left: -40,
            child: _orb(280, _kGreen.withOpacity(0.08))),
      ]);

  Widget _orb(double size, Color color) => Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  // ── Header ────────────────────────────────
  Widget _buildHeader() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: _glassBtn(Icons.arrow_back_ios_new_rounded),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('KYC Verification',
                      style: TextStyle(color: _kText, fontSize: 20,
                          fontWeight: FontWeight.w700, letterSpacing: -0.4)),
                  Text('Upload your documents securely',
                      style: TextStyle(color: _kSubtext, fontSize: 12)),
                ],
              ),
            ),
            _glassBtn(Icons.help_outline_rounded),
          ],
        ),
      );

  Widget _glassBtn(IconData icon) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: _kGlass,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder),
            ),
            child: Icon(icon, color: _kText, size: 20),
          ),
        ),
      );

  // ── Progress Bar ──────────────────────────
  Widget _buildProgressSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Application Progress',
                  style: TextStyle(color: _kSubtext, fontSize: 12)),
              AnimatedBuilder(
                animation: _progressAnim,
                builder: (_, __) => Text(
                  '${(_progressAnim.value * 100).round()}%',
                  style: const TextStyle(
                      color: _kGreen, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(height: 8, color: Colors.white.withOpacity(0.08)),
                AnimatedBuilder(
                  animation: _progressAnim,
                  builder: (_, __) => FractionallySizedBox(
                    widthFactor: _progressAnim.value,
                    child: Container(
                      height: 8,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_kGreen, Color(0xFF34D399)],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Step Indicator ────────────────────────
  Widget _buildStepIndicator() {
    final steps = ['Upload Docs', 'Review', 'Submit'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: steps.asMap().entries.map((e) {
          final i = e.key;
          final label = e.value;
          final active = _currentStep == i + 1;
          final done = _currentStep > i + 1;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done
                              ? _kGreen
                              : active
                                  ? _kGreen.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.05),
                          border: Border.all(
                            color: done || active ? _kGreen : _kBorder,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: done
                              ? const Icon(Icons.check, color: Colors.white, size: 16)
                              : Text('${i + 1}',
                                  style: TextStyle(
                                    color: active ? _kGreen : _kSubtext,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  )),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(label,
                          style: TextStyle(
                            color: active ? _kGreen : _kSubtext,
                            fontSize: 10,
                            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                          )),
                    ],
                  ),
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: done ? _kGreen : Colors.white.withOpacity(0.08),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Loan banner ───────────────────────────
  Widget _buildLoanInfoBanner() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kBlue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kBlue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: _kBlue, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.loanType,
                            style: const TextStyle(
                                color: _kText, fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        const Text('All documents are encrypted and stored securely.',
                            style: TextStyle(color: _kSubtext, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  // ── Document upload widget ────────────────
  Widget _buildDocWidget(_DocItem doc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: doc.uploaded
                  ? doc.color.withOpacity(0.08)
                  : _kGlass,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: doc.uploaded ? doc.color.withOpacity(0.5) : _kBorder,
                style: doc.uploaded ? BorderStyle.solid : BorderStyle.solid,
              ),
              boxShadow: doc.uploaded
                  ? [BoxShadow(color: doc.color.withOpacity(0.1), blurRadius: 16)]
                  : null,
            ),
            child: Row(
              children: [
                // Icon area
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: doc.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: doc.color.withOpacity(0.3)),
                  ),
                  child: Icon(doc.icon, color: doc.color, size: 24),
                ),
                const SizedBox(width: 14),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc.title,
                          style: const TextStyle(
                              color: _kText, fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      Text(doc.uploaded ? doc.fileName! : doc.subtitle,
                          style: TextStyle(
                              color: doc.uploaded ? doc.color : _kSubtext,
                              fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Upload / Done button
                GestureDetector(
                  onTap: () => _toggleUpload(doc),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: doc.uploaded
                          ? doc.color
                          : Colors.white.withOpacity(0.06),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: doc.uploaded ? doc.color : _kBorder,
                      ),
                      boxShadow: doc.uploaded
                          ? [BoxShadow(color: doc.color.withOpacity(0.4), blurRadius: 10)]
                          : null,
                    ),
                    child: Icon(
                      doc.uploaded
                          ? Icons.check_rounded
                          : Icons.upload_file_rounded,
                      color: doc.uploaded ? Colors.white : _kSubtext,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Submit section ────────────────────────
  Widget _buildSubmitSection() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_canSubmit) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _kAmber.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _kAmber.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: _kAmber, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          'Upload ${_visibleDocs.where((d) => !d.uploaded).length} more document(s) to continue.',
                          style: const TextStyle(color: _kAmber, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            if (_canSubmit)
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: _kGreen.withOpacity(0.4),
                  ),
                  icon: _isSubmitting 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send_rounded, size: 20),
                  label: Text(_isSubmitting ? 'Submitting...' : 'Submit Application',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                '🔒  256-bit SSL encrypted · Data never shared',
                style: TextStyle(color: _kSubtext, fontSize: 11),
              ),
            ),
          ],
        ),
      );

  Future<void> _submitApplication() async {
    setState(() => _isSubmitting = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      Map<String, String> uploadedUrls = {};
      
      // Upload files to Firebase Storage
      for (var doc in _visibleDocs) {
        if (doc.localFile != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('microfinance_docs/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_${doc.id}.jpg');
          
          final bytes = await File(doc.localFile!.path).readAsBytes();
          
          // Using putData instead of putFile to bypass Resumable Upload bugs
          // which sometimes cause 404 on Android when App Check is missing
          await ref.putData(
            bytes, 
            SettableMetadata(contentType: 'image/jpeg')
          );
          
          final url = await ref.getDownloadURL();
          uploadedUrls[doc.id] = url;
        }
      }

      // Save application to Firestore
      await FirebaseFirestore.instance.collection('microfinance_applications').add({
        'userId': user.uid,
        'name': userController.userName.isEmpty ? 'Unknown User' : userController.userName,
        'phone': userController.userPhone.isEmpty ? 'N/A' : userController.userPhone,
        'email': user.email ?? 'N/A',
        'userRole': widget.userRole,
        'loanType': widget.loanType,
        'documents': uploadedUrls,
        'status': 'pending', // Use 'pending' to match admin screen logic
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.off(() => const MicrofinanceRepaymentScreen());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Application submitted successfully!'),
          backgroundColor: _kGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
