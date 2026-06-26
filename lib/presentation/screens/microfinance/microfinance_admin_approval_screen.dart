import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const _kBg      = Color(0xFF0D1B3E);
const _kGlass   = Color(0x0DFFFFFF);
const _kBorder  = Color(0x1AFFFFFF);
const _kGreen   = Color(0xFF10B981);
const _kBlue    = Color(0xFF3B82F6);
const _kAmber   = Color(0xFFF59E0B);
const _kRed     = Color(0xFFEF4444);
const _kPurple  = Color(0xFF8B5CF6);
const _kGold    = Color(0xFFD97706);
const _kText    = Colors.white;
const _kSubtext = Color(0xFFAEB8CC);

// ─────────────────────────────────────────────
// Mock data models
// ─────────────────────────────────────────────
class _Application {
  final String id;
  final String name;
  final String loanType;
  final String amount;
  final String appliedDate;
  final int creditScore;
  final String status;
  final String nid;
  final String email;
  final String phone;
  final Map<String, dynamic> docs;
  final String initials;
  final Color avatarColor;

  const _Application({
    required this.id,
    required this.name,
    required this.loanType,
    required this.amount,
    required this.appliedDate,
    required this.creditScore,
    required this.status,
    required this.nid,
    required this.email,
    required this.phone,
    required this.docs,
    required this.initials,
    required this.avatarColor,
  });

  factory _Application.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name'] ?? 'Unknown User';
    
    String inits = 'U';
    if (name.isNotEmpty) {
      final parts = name.split(' ');
      if (parts.length > 1) {
        inits = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        inits = name.substring(0, name.length < 2 ? name.length : 2).toUpperCase();
      }
    }
    
    final colors = [_kGreen, _kBlue, _kAmber, _kPurple, _kGold];
    final color = colors[doc.id.hashCode.abs() % colors.length];

    DateTime appliedDate = DateTime.now();
    if (data['createdAt'] != null) {
      appliedDate = (data['createdAt'] as Timestamp).toDate();
    }
    String formattedDate = '${appliedDate.day}/${appliedDate.month}/${appliedDate.year}';

    return _Application(
      id: doc.id,
      name: name,
      loanType: data['loanType'] ?? 'Unknown Loan',
      amount: data['amount'] ?? 'TBD',
      appliedDate: formattedDate,
      creditScore: data['creditScore'] ?? 700,
      status: data['status'] ?? 'pending',
      nid: data['nid'] ?? 'N/A',
      email: data['email'] ?? 'N/A',
      phone: data['phone'] ?? 'N/A',
      docs: data['documents'] ?? {},
      initials: inits,
      avatarColor: color,
    );
  }
}

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────
class MicrofinanceAdminApprovalScreen extends StatefulWidget {
  const MicrofinanceAdminApprovalScreen({super.key});

  @override
  State<MicrofinanceAdminApprovalScreen> createState() =>
      _MicrofinanceAdminApprovalScreenState();
}

class _MicrofinanceAdminApprovalScreenState
    extends State<MicrofinanceAdminApprovalScreen>
    with SingleTickerProviderStateMixin {

  int _selectedIndex = 0;
  String _filterStatus = 'All';
  final Map<String, String> _localStatuses = {};

  late final AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  String _statusOf(_Application app) => app.status;

  List<_Application> _getFilteredApps(List<_Application> allApps) {
    if (_filterStatus == 'All') return allApps;
    if (_filterStatus == 'Verified') {
      return allApps.where((a) => a.status == 'admin_verified').toList();
    }
    if (_filterStatus == 'Pending') {
      return allApps.where((a) => a.status == 'pending').toList();
    }
    if (_filterStatus == 'Approved') {
      return allApps.where((a) => a.status == 'approved').toList();
    }
    return allApps;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          _buildOrbs(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildFilterTabs(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('microfinance_applications')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: _kGreen));
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: _kRed)));
                      }

                      final allApps = snapshot.data?.docs
                              .map((doc) => _Application.fromFirestore(doc))
                              .toList() ?? [];
                      
                      final filtered = _getFilteredApps(allApps);
                      
                      if (_selectedIndex >= filtered.length) {
                        _selectedIndex = 0;
                      }

                      return isMobile
                          ? _buildMobileLayout(filtered)
                          : _buildDesktopLayout(filtered);
                    },
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
        Positioned(top: -80, right: -80,
            child: _orb(260, _kPurple.withOpacity(0.10))),
        Positioned(bottom: -100, left: -60,
            child: _orb(300, _kGreen.withOpacity(0.08))),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Admin Approval Portal',
                          style: TextStyle(color: _kText, fontSize: 18,
                              fontWeight: FontWeight.w700, letterSpacing: -0.4)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _kGold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _kGold.withOpacity(0.4)),
                        ),
                        child: const Text('SUPER ADMIN',
                            style: TextStyle(color: _kGold, fontSize: 9,
                                fontWeight: FontWeight.w800, letterSpacing: 0.6)),
                      ),
                    ],
                  ),
                  const Text('Credit application review & approval',
                      style: TextStyle(color: _kSubtext, fontSize: 11)),
                ],
              ),
            ),
            _glassBtn(Icons.refresh_rounded),
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

  // ── Filter Tabs ───────────────────────────
  Widget _buildFilterTabs() {
    final filters = ['All', 'Verified', 'Pending', 'Approved'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: filters.map((f) {
          final active = _filterStatus == f;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _filterStatus = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active ? _kAmber.withOpacity(0.2) : _kGlass,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: active ? _kAmber.withOpacity(0.5) : _kBorder,
                  ),
                ),
                child: Text(f,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: active ? _kAmber : _kSubtext,
                      fontSize: 12,
                      fontWeight: active ? FontWeight.w700 : FontWeight.normal,
                    )),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Mobile: stacked list + detail sheet ──
  Widget _buildMobileLayout(List<_Application> apps) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: _buildApplicationList(apps),
        ),
        if (apps.isNotEmpty)
          Expanded(
            flex: 3,
            child: _buildDetailPanel(apps[_selectedIndex]),
          ),
      ],
    );
  }

  // ── Desktop: side-by-side ─────────────────
  Widget _buildDesktopLayout(List<_Application> apps) => Row(
        children: [
          SizedBox(width: 340, child: _buildApplicationList(apps)),
          Container(width: 1, color: _kBorder),
          Expanded(
            child: apps.isNotEmpty
                ? _buildDetailPanel(apps[_selectedIndex])
                : const Center(
                    child: Text('Select an application',
                        style: TextStyle(color: _kSubtext)),
                  ),
          ),
        ],
      );

  // ── Application list ──────────────────────
  Widget _buildApplicationList(List<_Application> apps) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: apps.length,
      itemBuilder: (ctx, i) {
        final app = apps[i];
        final selected = _selectedIndex == i;
        final status = _statusOf(app);
        return GestureDetector(
          onTap: () => setState(() => _selectedIndex = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected
                  ? _kBlue.withOpacity(0.12)
                  : _kGlass,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? _kBlue.withOpacity(0.4) : _kBorder,
              ),
              boxShadow: selected
                  ? [BoxShadow(color: _kBlue.withOpacity(0.1), blurRadius: 14)]
                  : null,
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: app.avatarColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: app.avatarColor.withOpacity(0.4)),
                  ),
                  child: Center(
                    child: Text(app.initials,
                        style: TextStyle(color: app.avatarColor,
                            fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.name,
                          style: const TextStyle(
                              color: _kText, fontSize: 13, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Text('${app.loanType} · ${app.amount}',
                          style: const TextStyle(color: _kSubtext, fontSize: 11),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _statusBadge(status),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'admin_verified':
        color = _kAmber; label = 'Verified'; break;
      case 'approved':
        color = _kGreen; label = 'Approved'; break;
      case 'rejected':
        color = _kRed; label = 'Rejected'; break;
      default:
        color = _kSubtext; label = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  // ── Detail panel ──────────────────────────
  Widget _buildDetailPanel(_Application app) {
    final status = _statusOf(app);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _kGlass,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _kBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        color: app.avatarColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: app.avatarColor.withOpacity(0.5), width: 2),
                      ),
                      child: Center(
                        child: Text(app.initials,
                            style: TextStyle(color: app.avatarColor,
                                fontWeight: FontWeight.w800, fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(app.name,
                              style: const TextStyle(color: _kText, fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(app.email,
                              style: const TextStyle(color: _kSubtext, fontSize: 12)),
                          Text(app.phone,
                              style: const TextStyle(color: _kSubtext, fontSize: 12)),
                          const SizedBox(height: 6),
                          _statusBadge(status),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Loan info row
          Row(
            children: [
              _infoCard('Loan Type', app.loanType, Icons.account_balance_rounded, _kBlue),
              const SizedBox(width: 10),
              _infoCard('Amount', app.amount, Icons.monetization_on_rounded, _kGreen),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _infoCard('Applied', app.appliedDate, Icons.calendar_today_rounded, _kAmber),
              const SizedBox(width: 10),
              _infoCard('NID', app.nid, Icons.badge_rounded, _kPurple),
            ],
          ),
          const SizedBox(height: 16),

          // Credit score gauge
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _kGlass,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _kBorder),
                ),
                child: Row(
                  children: [
                    _buildCreditScoreGauge(app.creditScore),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Credit Score',
                              style: TextStyle(color: _kSubtext, fontSize: 12)),
                          Text('${app.creditScore}',
                              style: TextStyle(
                                  color: _scoreColor(app.creditScore),
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800)),
                          Text(_scoreLabel(app.creditScore),
                              style: TextStyle(
                                  color: _scoreColor(app.creditScore),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          const Text('Based on payment history & credit utilisation',
                              style: TextStyle(color: _kSubtext, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Documents
          _buildDocList(app),
          const SizedBox(height: 16),

          // Action buttons
          if (status == 'admin_verified' || status == 'pending')
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    label: 'Reject',
                    icon: Icons.close_rounded,
                    color: _kRed,
                    onTap: () => _updateStatus(app, 'rejected'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _actionButton(
                    label: 'Final Approve',
                    icon: Icons.check_circle_rounded,
                    color: _kGreen,
                    glow: true,
                    onTap: () => _updateStatus(app, 'approved'),
                  ),
                ),
              ],
            )
          else if (status == 'approved')
            _resultBanner('Application has been approved!', _kGreen)
          else
            _resultBanner('Application has been rejected.', _kRed),
        ],
      ),
    );
  }

  Widget _infoCard(String label, String value, IconData icon, Color color) =>
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _kGlass,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _kBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: color, size: 14),
                      const SizedBox(width: 6),
                      Text(label,
                          style: const TextStyle(color: _kSubtext, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(value,
                      style: const TextStyle(color: _kText, fontSize: 12,
                          fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildCreditScoreGauge(int score) {
    final progress = (score - 300) / (850 - 300);
    return SizedBox(
      width: 80, height: 80,
      child: CustomPaint(
        painter: _ScoreArcPainter(progress: progress, color: _scoreColor(score)),
        child: Center(
          child: Text('${score}',
              style: TextStyle(color: _scoreColor(score),
                  fontSize: 16, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 750) return _kGreen;
    if (score >= 650) return _kAmber;
    return _kRed;
  }

  String _scoreLabel(int score) {
    if (score >= 750) return 'Excellent';
    if (score >= 700) return 'Good';
    if (score >= 650) return 'Fair';
    return 'Poor';
  }

  Widget _buildDocList(_Application app) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kGlass,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Uploaded Documents',
                    style: TextStyle(color: _kText, fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                if (app.docs.isEmpty)
                  const Text('No documents uploaded', style: TextStyle(color: _kSubtext, fontSize: 12))
                else
                  ...app.docs.entries.map((entry) {
                    final docId = entry.key.toUpperCase();
                    final docUrl = entry.value as String;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          // Show image dialog
                          showDialog(
                            context: context,
                            builder: (ctx) => Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: const EdgeInsets.all(16),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      docUrl,
                                      fit: BoxFit.contain,
                                      loadingBuilder: (ctx, child, progress) {
                                        if (progress == null) return child;
                                        return const Center(child: CircularProgressIndicator(color: _kGreen));
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                      onPressed: () => Navigator.pop(ctx),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 34, height: 34,
                              decoration: BoxDecoration(
                                color: _kGreen.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.image_rounded,
                                  color: _kGreen, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(docId,
                                  style: const TextStyle(color: _kBlue, fontSize: 13, decoration: TextDecoration.underline)),
                            ),
                            const Icon(Icons.check_circle_rounded,
                                color: _kGreen, size: 18),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      );

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool glow = false,
  }) {
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (_, __) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.5)),
            boxShadow: glow
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3 + 0.15 * _glowCtrl.value),
                      blurRadius: 16 + 8 * _glowCtrl.value,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(color: color,
                      fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultBanner(String message, Color color) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(
              color == _kGreen ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: color, size: 22,
            ),
            const SizedBox(width: 12),
            Text(message, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Future<void> _updateStatus(_Application app, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('microfinance_applications')
          .doc(app.id)
          .update({'status': newStatus});

      final msg = newStatus == 'approved'
          ? '✅ Application approved successfully!'
          : '❌ Application rejected.';
      final color = newStatus == 'approved' ? _kGreen : _kRed;
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: color),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e'), backgroundColor: _kRed),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────
// Credit score arc painter
// ─────────────────────────────────────────────
class _ScoreArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _ScoreArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const start = -math.pi * 0.85;
    const sweep = math.pi * 1.7;

    canvas.drawArc(rect.deflate(4), start, sweep, false,
        Paint()
          ..color = Colors.white.withOpacity(0.07)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round);

    canvas.drawArc(rect.deflate(4), start, sweep * progress.clamp(0.0, 1.0), false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant _ScoreArcPainter o) =>
      o.progress != progress || o.color != color;
}
