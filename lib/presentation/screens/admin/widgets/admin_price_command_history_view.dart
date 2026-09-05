import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:agrolinkbd/core/services/admin_price_command_service.dart';

class AdminPriceCommandHistoryView extends StatefulWidget {
  const AdminPriceCommandHistoryView({super.key});

  @override
  State<AdminPriceCommandHistoryView> createState() =>
      _AdminPriceCommandHistoryViewState();
}

class _AdminPriceCommandHistoryViewState
    extends State<AdminPriceCommandHistoryView> {
  final AdminPriceCommandService _commandService = AdminPriceCommandService();
  String _selectedFilter = 'all'; // 'all', 'decrease', 'increase', 'sync', 'rollback'
  bool _isRollingBack = false;

  String _formatTimestamp(dynamic ts) {
    if (ts == null) return 'এইমাত্র';
    if (ts is Timestamp) {
      final dt = ts.toDate();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    }
    return ts.toString();
  }

  Future<void> _showRollbackConfirmDialog(
      BuildContext context, Map<String, dynamic> log) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logId = log['id'] as String;
    final reason = log['reason'] as String? ?? 'মূল্য সমন্বয়';
    final delta = (log['deltaValue'] as num?)?.toDouble() ?? 0.0;
    final unit = log['unit'] == 'percent' ? '%' : '৳';
    final action = log['action'] as String? ?? '';
    final prodCount = log['affectedProducts'] ?? 0;
    final fishCount = log['affectedFishLots'] ?? 0;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history_rounded, color: Colors.amber, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'রোলব্যাক নিশ্চিতকরণ',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'আপনি কি নিশ্চিত যে এই কমান্ডের সকল পরিবর্তন পূর্বাবস্থায় ফিরিয়ে নিতে চান?',
              style: GoogleFonts.hindSiliguri(
                fontSize: 14,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'অ্যাকশন: ${action == "decrease" ? "বাজার ধস (-$delta$unit)" : "কৃষক সুরক্ষা (+$delta$unit)"}',
                    style: GoogleFonts.hindSiliguri(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? Colors.white : const Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'প্রভাবিত: $prodCount টি কৃষি পণ্য • $fishCount টি মাছের লট',
                    style: GoogleFonts.hindSiliguri(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'কারণ: $reason',
                    style: GoogleFonts.hindSiliguri(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'বাতিল',
              style: GoogleFonts.hindSiliguri(
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.undo_rounded, size: 16, color: Colors.white),
            label: Text(
              'হ্যাঁ, রোলব্যাক করুন',
              style: GoogleFonts.hindSiliguri(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isRollingBack = true);
      final result = await _commandService.rollbackCommand(logId);
      if (mounted) {
        setState(() => _isRollingBack = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message,
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
            ),
            backgroundColor: result.success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Column(
      children: [
        // ─── Filter Chips ───────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'সকল কমান্ড', Icons.dashboard_customize_rounded, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('decrease', '📉 মূল্য হ্রাস', Icons.trending_down_rounded, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('increase', '📈 মূল্য বৃদ্ধি', Icons.trending_up_rounded, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('sync', '🔄 বেঞ্চমার্ক সিঙ্ক', Icons.sync_rounded, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('rollback', '↩️ রোলব্যাক লগ', Icons.undo_rounded, isDark),
              ],
            ),
          ),
        ),

        // ─── Command History List ───────────────────────────────
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _commandService.streamCommandHistory(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1976D2)),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 42),
                        const SizedBox(height: 10),
                        Text(
                          'হিস্টোরি লোড করতে সমস্যা হয়েছে: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.hindSiliguri(color: const Color(0xFFEF4444)),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final allLogs = snapshot.data ?? [];
              final filteredLogs = allLogs.where((log) {
                if (_selectedFilter == 'all') return true;
                final actionType = log['actionType'] as String? ?? '';
                final action = log['action'] as String? ?? '';
                if (_selectedFilter == 'rollback') return actionType == 'rollback';
                if (_selectedFilter == 'decrease') return action == 'decrease';
                if (_selectedFilter == 'increase') return action == 'increase';
                if (_selectedFilter == 'sync') return action == 'syncBenchmark';
                return true;
              }).toList();

              if (filteredLogs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.receipt_long_rounded,
                              size: 40, color: Color(0xFF1976D2)),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'কোনো কমান্ড হিস্টোরি পাওয়া যায়নি',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'সুপার এডমিন প্যানেল থেকে কমান্ড প্রয়োগ করলে এখানে অডিট হিস্টোরি প্রদর্শিত হবে।',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
                itemCount: filteredLogs.length,
                itemBuilder: (context, index) {
                  final log = filteredLogs[index];
                  return _buildLogCard(context, log, isDark, cardBg, textPrimary, textSecondary, borderColor);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String key, String label, IconData icon, bool isDark) {
    final isSelected = _selectedFilter == key;
    return FilterChip(
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = key),
      avatar: Icon(icon, size: 14, color: isSelected ? Colors.white : const Color(0xFF1976D2)),
      label: Text(
        label,
        style: GoogleFonts.hindSiliguri(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A)),
        ),
      ),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      selectedColor: const Color(0xFF1976D2),
      checkmarkColor: Colors.white,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: isSelected ? const Color(0xFF1976D2) : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1))),
      ),
    );
  }

  Widget _buildLogCard(
    BuildContext context,
    Map<String, dynamic> log,
    bool isDark,
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
  ) {
    final isRollbackAction = log['actionType'] == 'rollback';
    final isRolledBack = log['isRolledBack'] == true;
    final action = log['action'] as String? ?? '';
    final delta = (log['deltaValue'] as num?)?.toDouble() ?? 0.0;
    final unit = log['unit'] == 'percent' ? '%' : '৳';
    final reason = log['reason'] as String? ?? 'কোনো কারণ উল্লেখ নেই';
    final adminEmail = log['adminEmail'] as String? ?? 'Super Admin';
    final timestamp = _formatTimestamp(log['timestamp']);
    final productsCount = log['affectedProducts'] ?? log['restoredProducts'] ?? 0;
    final fishLotsCount = log['affectedFishLots'] ?? log['restoredFishLots'] ?? 0;
    final targetDistrict = log['targetDistrict'] as String? ?? 'all';
    final targetDivision = log['targetDivision'] as String? ?? 'all';
    final duration = log['duration'] as String? ?? 'permanent';

    Color badgeColor = const Color(0xFF1976D2);
    String actionLabel = 'মূল্য সমন্বয়';
    IconData actionIcon = Icons.tune_rounded;

    if (isRollbackAction) {
      badgeColor = const Color(0xFFD97706);
      actionLabel = 'রোলব্যাক সম্পন্ন';
      actionIcon = Icons.undo_rounded;
    } else if (action == 'decrease') {
      badgeColor = const Color(0xFFEF4444);
      actionLabel = 'বাজার ধস হ্রাস (-$delta$unit)';
      actionIcon = Icons.trending_down_rounded;
    } else if (action == 'increase') {
      badgeColor = const Color(0xFF10B981);
      actionLabel = 'কৃষক সুরক্ষা বৃদ্ধি (+$delta$unit)';
      actionIcon = Icons.trending_up_rounded;
    } else if (action == 'syncBenchmark') {
      badgeColor = const Color(0xFF0284C7);
      actionLabel = 'বাজার বেঞ্চমার্কে সিঙ্ক';
      actionIcon = Icons.sync_rounded;
    } else if (action == 'reset') {
      badgeColor = const Color(0xFF6B7280);
      actionLabel = 'কৃষকের আসল মূল্যে রিসেট';
      actionIcon = Icons.restart_alt_rounded;
    }

    String geoLabel = 'সারা বাংলাদেশ';
    if (targetDistrict != 'all') {
      geoLabel = 'জেলা: $targetDistrict';
    } else if (targetDivision != 'all') {
      geoLabel = 'বিভাগ: $targetDivision';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Badge & Timestamp
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(actionIcon, size: 14, color: badgeColor),
                      const SizedBox(width: 5),
                      Text(
                        actionLabel,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  timestamp,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 11,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Middle Stats Row: Geo, Scope & Duration
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildInfoPill(Icons.location_on_outlined, geoLabel, isDark),
                _buildInfoPill(Icons.inventory_2_outlined, '$productsCount টি কৃষি পণ্য', isDark),
                _buildInfoPill(Icons.water_drop_outlined, '$fishLotsCount টি মাছের লট', isDark),
                if (duration != 'permanent')
                  _buildInfoPill(Icons.timer_outlined, 'মেয়াদ: $duration', isDark),
              ],
            ),
            const SizedBox(height: 10),

            // Reason Text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor.withValues(alpha: 0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notes_rounded, size: 13, color: textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'কমান্ডের কারণ ও অডিট বিবরণ:',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    reason,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Footer Row: Admin user & Rollback Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 14, color: textSecondary),
                    const SizedBox(width: 5),
                    Text(
                      adminEmail,
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 11.5,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),

                if (!isRollbackAction)
                  isRolledBack
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '✓ পূর্বাবস্থায় ফিরিয়ে নেওয়া হয়েছে',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: _isRollingBack
                              ? null
                              : () => _showRollbackConfirmDialog(context, log),
                          icon: const Icon(Icons.undo_rounded, size: 14, color: Colors.white),
                          label: Text(
                            'রোলব্যাক করুন',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD97706),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155).withValues(alpha: 0.6) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.hindSiliguri(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
