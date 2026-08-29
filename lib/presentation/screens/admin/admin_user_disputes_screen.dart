import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/providers/admin_provider.dart';
import 'package:agrolinkbd/core/services/user_rating_service.dart';

/// Super Admin User Disputes & Fraud Reports Management Screen
/// Displays and resolves all peer disputes, quality fraud, cancellations, and defaults
class AdminUserDisputesScreen extends StatefulWidget {
  const AdminUserDisputesScreen({super.key});

  @override
  State<AdminUserDisputesScreen> createState() => _AdminUserDisputesScreenState();
}

class _AdminUserDisputesScreenState extends State<AdminUserDisputesScreen> {
  String _selectedFilter = 'all'; // 'all', 'pending', 'action_taken', 'dismissed'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isLightMode = false;

  Color get _bgColor => _isLightMode ? const Color(0xFFF3F4F6) : const Color(0xFF0B0F19);
  Color get _textColor => _isLightMode ? const Color(0xFF1F2937) : Colors.white;
  Color get _cardColor => _isLightMode ? Colors.white.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.04);
  Color get _subTextColor => _isLightMode ? Colors.grey[700]! : Colors.white70;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Ambient glowing background orb
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withValues(alpha: _isLightMode ? 0.15 : 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -60,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF3B82F6).withValues(alpha: _isLightMode ? 0.15 : 0.08),
                ),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(color: Colors.transparent),
            ),

            // Content
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildDisputesStream(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: _textColor),
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ব্যবহারকারী অভিযোগ ও জরিমানা',
                        style: GoogleFonts.hindSiliguri(
                          color: _textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'User Disputes & Fraud Reports Management',
                        style: GoogleFonts.poppins(
                          color: _subTextColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  _isLightMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: _textColor,
                ),
                onPressed: () => setState(() => _isLightMode = !_isLightMode),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search bar
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            style: TextStyle(color: _textColor, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'অভিযোগকারী বা অভিযুক্তের নাম, ফোন বা কারণ খুঁজুন...',
              hintStyle: TextStyle(color: _subTextColor.withValues(alpha: 0.6), fontSize: 12),
              prefixIcon: Icon(Icons.search_rounded, color: _subTextColor),
              filled: true,
              fillColor: _cardColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _textColor.withValues(alpha: 0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _textColor.withValues(alpha: 0.1)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'সকল অভিযোগ (All)'),
                _buildFilterChip('pending', '⏳ বিচারাধীন (Pending)'),
                _buildFilterChip('action_taken', '⚖️ দণ্ডপ্রাপ্ত (Action Taken)'),
                _buildFilterChip('dismissed', '🚫 খারিজ (Dismissed)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final bool isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.hindSiliguri(
            color: isSelected ? Colors.white : _textColor,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedColor: Colors.redAccent,
        backgroundColor: _cardColor,
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected ? Colors.redAccent : _textColor.withValues(alpha: 0.15),
        ),
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedFilter = value);
          }
        },
      ),
    );
  }

  Widget _buildDisputesStream() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('user_reports')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'তথ্য লোড করতে ত্রুটি: ${snapshot.error}',
              style: TextStyle(color: _textColor),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        // Apply filters
        final filteredDocs = docs.where((doc) {
          final data = doc.data();
          final status = data['status'] ?? 'pending';
          if (_selectedFilter != 'all' && status != _selectedFilter) {
            return false;
          }

          if (_searchQuery.isNotEmpty) {
            final targetName = (data['targetUserName'] ?? '').toString().toLowerCase();
            final targetPhone = (data['targetUserPhone'] ?? '').toString().toLowerCase();
            final reporterName = (data['reporterName'] ?? '').toString().toLowerCase();
            final reporterPhone = (data['reporterPhone'] ?? '').toString().toLowerCase();
            final category = (data['category'] ?? '').toString().toLowerCase();
            final reason = (data['reason'] ?? '').toString().toLowerCase();

            return targetName.contains(_searchQuery) ||
                targetPhone.contains(_searchQuery) ||
                reporterName.contains(_searchQuery) ||
                reporterPhone.contains(_searchQuery) ||
                category.contains(_searchQuery) ||
                reason.contains(_searchQuery);
          }

          return true;
        }).toList();

        // Metrics counts
        final totalCount = docs.length;
        final pendingCount = docs.where((d) => (d.data()['status'] ?? 'pending') == 'pending').length;
        final actionTakenCount = docs.where((d) => d.data()['status'] == 'action_taken').length;
        final dismissedCount = docs.where((d) => d.data()['status'] == 'dismissed').length;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // KPI Cards row
            Row(
              children: [
                _buildKpiCard('মোট অভিযোগ', totalCount.toString(), Colors.blue, Icons.list_alt),
                const SizedBox(width: 8),
                _buildKpiCard('বিচারাধীন', pendingCount.toString(), Colors.orange, Icons.pending_actions),
                const SizedBox(width: 8),
                _buildKpiCard('দণ্ডপ্রাপ্ত', actionTakenCount.toString(), Colors.red, Icons.gavel),
                const SizedBox(width: 8),
                _buildKpiCard('খারিজ', dismissedCount.toString(), Colors.green, Icons.check_circle_outline),
              ],
            ),
            const SizedBox(height: 16),

            if (filteredDocs.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.verified_user_outlined, size: 56, color: _subTextColor.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    Text(
                      'কোনো অভিযোগ পাওয়া যায়নি',
                      style: GoogleFonts.hindSiliguri(
                        color: _textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'এই ফিল্টারে বর্তমানে কোনো রিপোর্ট বা অভিযোগ নেই।',
                      style: GoogleFonts.hindSiliguri(
                        color: _subTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...filteredDocs.map((doc) => _buildDisputeCard(doc.id, doc.data())),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard(String title, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              count,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.hindSiliguri(
                fontSize: 10,
                color: _subTextColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisputeCard(String reportId, Map<String, dynamic> data) {
    final String status = data['status'] ?? 'pending';
    final String category = data['category'] ?? 'General Dispute';
    final String reason = data['reason'] ?? 'No description provided';
    final String targetUserName = data['targetUserName'] ?? 'Unknown User';
    final String targetUserId = data['targetUserId'] ?? '';
    final String targetUserRole = data['targetUserRole'] ?? 'User';
    final String targetUserPhone = data['targetUserPhone'] ?? '';

    final String reporterName = data['reporterName'] ?? 'Anonymous';
    final String reporterRole = data['reporterRole'] ?? 'User';
    final String reporterPhone = data['reporterPhone'] ?? '';
    final String orderReference = data['orderReference'] ?? 'N/A';
    final int penaltyType = data['penaltyType'] ?? 1;

    final String createdAt = data['createdAt'] != null
        ? DateTime.tryParse(data['createdAt'].toString())?.toLocal().toString().split('.')[0] ?? ''
        : '';
    final String adminNotes = data['adminNotes'] ?? '';
    final String resolvedBy = data['resolvedBy'] ?? '';

    Color statusColor = Colors.orange;
    String statusLabel = 'বিচারাধীন (Pending)';
    if (status == 'action_taken') {
      statusColor = Colors.red;
      statusLabel = 'দণ্ড কার্যকর (Action Taken)';
    } else if (status == 'dismissed') {
      statusColor = Colors.grey;
      statusLabel = 'খারিজ (Dismissed)';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status == 'pending'
              ? Colors.orange.withValues(alpha: 0.4)
              : (status == 'action_taken' ? Colors.red.withValues(alpha: 0.3) : _textColor.withValues(alpha: 0.1)),
          width: status == 'pending' ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header: Category badge & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.report_gmailerrorred_rounded, size: 14, color: Colors.red),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            category,
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    statusLabel,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Accused & Reporter Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Accused Party
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_off_outlined, size: 14, color: Colors.red),
                            const SizedBox(width: 4),
                            Text(
                              'অভিযুক্ত (Accused)',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          targetUserName,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'রোল: $targetUserRole',
                          style: TextStyle(fontSize: 11, color: _subTextColor),
                        ),
                        if (targetUserPhone.isNotEmpty)
                          Text(
                            'ফোন/আইডি: $targetUserPhone',
                            style: GoogleFonts.poppins(fontSize: 10, color: _subTextColor),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Reporter Party
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 14, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text(
                              'অভিযোগকারী (Reporter)',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reporterName,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'রোল: $reporterRole',
                          style: TextStyle(fontSize: 11, color: _subTextColor),
                        ),
                        if (reporterPhone.isNotEmpty)
                          Text(
                            'ফোন: $reporterPhone',
                            style: GoogleFonts.poppins(fontSize: 10, color: _subTextColor),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (orderReference.isNotEmpty && orderReference != 'N/A')
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.receipt_long, size: 14, color: _subTextColor),
                    const SizedBox(width: 4),
                    Text(
                      'রেফারেন্স: $orderReference',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _subTextColor,
                      ),
                    ),
                  ],
                ),
              ),

            // Description statement
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _textColor.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'অভিযোগের বিবরণ:',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _subTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reason,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12,
                      color: _textColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Timestamp & Admin Notes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'দাখিল: $createdAt',
                  style: GoogleFonts.poppins(fontSize: 10, color: _subTextColor),
                ),
                if (resolvedBy.isNotEmpty)
                  Text(
                    'অ্যাডমিন: $resolvedBy',
                    style: GoogleFonts.hindSiliguri(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
              ],
            ),

            if (adminNotes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'অ্যাডমিন নোট: $adminNotes',
                style: GoogleFonts.hindSiliguri(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.purple.shade300),
              ),
            ],

            // Action Buttons for Super Admin (When status == 'pending')
            if (status == 'pending') ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      onPressed: () => _showApplyPenaltyModal(reportId, targetUserId, targetUserName, penaltyType, category),
                      icon: const Icon(Icons.gavel_rounded, size: 16),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'জরিমানা ও ট্রাস্ট স্কোর কর্তন',
                          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: () => _showDismissModal(reportId, targetUserName),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'খারিজ করুন',
                          style: GoogleFonts.hindSiliguri(fontSize: 12),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _subTextColor,
                        side: BorderSide(color: _subTextColor.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Super Admin Apply Penalty Dialog
  void _showApplyPenaltyModal(
    String reportId,
    String targetUserId,
    String targetUserName,
    int initialPenaltyType,
    String category,
  ) {
    int selectedPenaltyType = initialPenaltyType;
    final notesController = TextEditingController();

    final List<Map<String, dynamic>> penalties = [
      {
        'id': 1,
        'title': '🚫 ভুয়া ওজন / ভেজাল পণ্য (Quality Fraud)',
        'deduction': '-১৫ ট্রাস্ট পয়েন্ট (Fraud Penalty)',
      },
      {
        'id': 2,
        'title': '❌ অর্ডার কনফার্ম করে বাতিল / চুক্তিভঙ্গ',
        'deduction': '-৫ ট্রাস্ট পয়েন্ট (Cancellation Penalty)',
      },
      {
        'id': 3,
        'title': '💸 পেমেন্ট বকেয়া বা অর্থ আত্মসাৎ (Default)',
        'deduction': '-১০ ট্রাস্ট পয়েন্ট (Payment Default Penalty)',
      },
      {
        'id': 4,
        'title': '⏰ ট্রিপ ড্রপ বা ডেলিভারি নো-শো (Delivery Fail)',
        'deduction': '-৫ ট্রাস্ট পয়েন্ট (Late / No-Show Penalty)',
      },
      {
        'id': 5,
        'title': '⚠️ অসদাচরণ ও প্রতারণামূলক আচরণ (Misbehavior)',
        'deduction': '-১০ ট্রাস্ট পয়েন্ট (Misbehavior Penalty)',
      },
      {
        'id': 6,
        'title': '📑 অন্যান্য গুরুতর অনিয়ম',
        'deduction': '-১৫ ট্রাস্ট পয়েন্ট (General Penalty)',
      },
    ];

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: _isLightMode ? Colors.white : const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.gavel_rounded, color: Colors.red, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'দণ্ড ও ট্রাস্ট স্কোর কর্তন অনুমোদন',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'অভিযুক্ত ব্যবহারকারী: $targetUserName',
                      style: GoogleFonts.hindSiliguri(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'প্রযোজ্য জরিমানার ধরন নির্বাচন করুন:',
                      style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600, fontSize: 12, color: _subTextColor),
                    ),
                    const SizedBox(height: 6),
                    ...penalties.map((p) {
                      return RadioListTile<int>(
                        title: Text(
                          p['title'],
                          style: GoogleFonts.hindSiliguri(fontSize: 12, color: _textColor),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          p['deduction'],
                          style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        value: p['id'] as int,
                        groupValue: selectedPenaltyType,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        dense: true,
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedPenaltyType = val);
                        },
                      );
                    }),
                    const SizedBox(height: 10),
                    TextField(
                      controller: notesController,
                      style: TextStyle(color: _textColor, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'সুপার অ্যাডমিন মন্তব্য / সিদ্ধান্তের কারণ (বাধ্যতামূলক)',
                        labelStyle: TextStyle(color: _subTextColor, fontSize: 12),
                        hintText: 'প্রমাণ যাচাইয়ের ভিত্তিতে এই জরিমানা আরোপ করা হলো...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text('বাতিল', style: GoogleFonts.hindSiliguri(color: _subTextColor)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () async {
                  final notes = notesController.text.trim();
                  if (notes.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('অনুগ্রহ করে অ্যাডমিন মন্তব্য লিখুন!'), backgroundColor: Colors.orange),
                    );
                    return;
                  }

                  Navigator.pop(dialogCtx);
                  final adminProvider = Provider.of<AdminProvider>(context, listen: false);
                  final adminName = adminProvider.currentAdmin?.name ?? 'Super Admin';
                  final adminId = adminProvider.currentAdmin?.id ?? 'super_admin';

                  final success = await UserRatingService().resolveDisputeAndApplyPenalty(
                    reportId: reportId,
                    targetUserId: targetUserId,
                    penaltyType: selectedPenaltyType,
                    adminNotes: notes,
                    adminId: adminId,
                    adminName: adminName,
                  );

                  if (success) {
                    await adminProvider.logAdminAction(
                      'PENALTY_APPLIED',
                      'Applied penalty on user $targetUserName ($targetUserId) for dispute $reportId: $notes',
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ জরিমানা সফলভাবে কার্যকর ও ট্রাস্ট স্কোর কর্তন করা হয়েছে!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
                child: Text('জরিমানা কার্যকর করুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  // Super Admin Dismiss Report Dialog
  void _showDismissModal(String reportId, String targetUserName) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: _isLightMode ? Colors.white : const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'অভিযোগ খারিজ করুন',
          style: GoogleFonts.hindSiliguri(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _textColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$targetUserName-এর বিরুদ্ধে এই অভিযোগটি খারিজ করার কারণ লিখুন:',
              style: GoogleFonts.hindSiliguri(fontSize: 12, color: _subTextColor),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: notesController,
              style: TextStyle(color: _textColor, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'খারিজের কারণ / বিবরণ',
                labelStyle: TextStyle(color: _subTextColor, fontSize: 12),
                hintText: 'যেমন: পর্যাপ্ত প্রমাণের অভাব / ভুল বোঝাবুঝি নিষ্পত্তি...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('বাতিল', style: GoogleFonts.hindSiliguri(color: _subTextColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700], foregroundColor: Colors.white),
            onPressed: () async {
              final notes = notesController.text.trim();
              Navigator.pop(dialogCtx);
              final adminProvider = Provider.of<AdminProvider>(context, listen: false);
              final adminName = adminProvider.currentAdmin?.name ?? 'Super Admin';
              final adminId = adminProvider.currentAdmin?.id ?? 'super_admin';

              final success = await UserRatingService().dismissDispute(
                reportId: reportId,
                adminNotes: notes.isNotEmpty ? notes : 'Dismissed without penalty by Super Admin',
                adminId: adminId,
                adminName: adminName,
              );

              if (success) {
                await adminProvider.logAdminAction(
                  'DISPUTE_DISMISSED',
                  'Dismissed dispute report $reportId against user $targetUserName: $notes',
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('অভিযোগটি খারিজ করা হয়েছে।'),
                      backgroundColor: Colors.grey,
                    ),
                  );
                }
              }
            },
            child: Text('খারিজ নিশ্চিত করুন', style: GoogleFonts.hindSiliguri()),
          ),
        ],
      ),
    );
  }
}
