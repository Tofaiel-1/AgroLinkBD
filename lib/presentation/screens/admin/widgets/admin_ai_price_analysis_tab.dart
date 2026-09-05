import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/services/admin_price_command_service.dart';
import 'package:agrolinkbd/core/services/ai_price_analysis_service.dart';
import 'package:agrolinkbd/presentation/screens/admin/widgets/admin_quick_price_command_sheet.dart';

// ─── Color Palette ────────────────────────────────────────────────────
const _kBrand = Color(0xFF2563EB);
const _kPurple = Color(0xFF7C3AED);
const _kCyan = Color(0xFF06B6D4);
const _kGreen = Color(0xFF10B981);
const _kAmber = Color(0xFFF59E0B);
const _kRed = Color(0xFFEF4444);
const _kOrange = Color(0xFFEA580C);

class AdminAiPriceAnalysisTab extends StatefulWidget {
  final VoidCallback? onCommandExecuted;

  const AdminAiPriceAnalysisTab({
    super.key,
    this.onCommandExecuted,
  });

  @override
  State<AdminAiPriceAnalysisTab> createState() =>
      _AdminAiPriceAnalysisTabState();
}

class _AdminAiPriceAnalysisTabState extends State<AdminAiPriceAnalysisTab>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  AiMarketAnalysisReport? _latestReport;
  String? _errorMessage;

  late AnimationController _pulseCtrl;
  late AnimationController _scanLineCtrl;
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _loadInitialOrCachedReport();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _scanLineCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitialOrCachedReport() async {
    setState(() => _isLoading = true);
    try {
      final report = await AiPriceAnalysisService.runMarketAnalysis();
      if (mounted) {
        setState(() {
          _latestReport = report;
          _isLoading = false;
        });
        _fadeCtrl.forward(from: 0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _triggerFreshScan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _latestReport = null;
    });
    _fadeCtrl.reset();
    try {
      final report = await AiPriceAnalysisService.runMarketAnalysis();
      if (mounted) {
        setState(() {
          _latestReport = report;
          _isLoading = false;
        });
        _fadeCtrl.forward();
        Get.snackbar(
          '✅ এআই স্ক্যান সম্পন্ন',
          'ফায়ারবেইস থেকে লাইভ ক্রয়-বিক্রয় ডাটা বিশ্লেষণ করা হয়েছে।',
          backgroundColor: const Color(0xFF065F46),
          colorText: Colors.white,
          icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'স্ক্যান ব্যর্থ হয়েছে: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _applyRecommendation(AiPriceRecommendationItem rec) {
    AdminQuickPriceCommandSheet.show(
      context,
      initialAction: rec.action,
      initialScope: rec.scope,
      initialDelta: rec.deltaPercent,
      initialCategory: rec.targetCategory,
      initialDivision: rec.targetDivision,
      initialDistrict: rec.targetDistrict,
      initialReason: rec.rationaleBn,
      onCommandExecuted: () {
        widget.onCommandExecuted?.call();
        _triggerFreshScan();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF070F1E) : const Color(0xFFF1F5F9),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroBanner(isDark),
            const SizedBox(height: 16),
            if (_latestReport != null) ...[
              _buildStabilityGauge(isDark),
              const SizedBox(height: 16),
              _buildKpiGrid(isDark),
              const SizedBox(height: 20),
            ],
            if (_isLoading) _buildScanAnimation(isDark),
            if (_errorMessage != null) _buildErrorCard(isDark),
            if (_latestReport != null) ...[
              _buildSectionHeader(
                icon: Icons.tips_and_updates_rounded,
                title: 'কার্যকরী এআই সুপারিশ',
                badge: '${_latestReport!.recommendations.length} টি সুপারিশ',
                badgeColor: _kPurple,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              if (_latestReport!.recommendations.isEmpty)
                _buildAllClearCard(isDark)
              else
                FadeTransition(
                  opacity: _fadeCtrl,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _latestReport!.recommendations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final rec = _latestReport!.recommendations[index];
                      return _buildProRecommendationCard(rec, isDark, index);
                    },
                  ),
                ),
              const SizedBox(height: 28),
              _buildSectionHeader(
                icon: Icons.timeline_rounded,
                title: 'বিশ্লেষণ ইতিহাস',
                badge: 'সর্বশেষ ৬টি',
                badgeColor: _kCyan,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildHistoryTimeline(isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1B3E), Color(0xFF1E3A8A), Color(0xFF312E81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kBrand.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, child) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: 0.15 + _pulseCtrl.value * 0.15,
                      ),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _kPurple.withValues(
                          alpha: 0.2 + _pulseCtrl.value * 0.3,
                        ),
                        blurRadius: 16 + _pulseCtrl.value * 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'এআই মার্কেট ইন্টেলিজেন্স',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Powered by Google Gemini · Firebase Live Data',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white54,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              _isLoading ? _buildScanningIndicator() : _buildScanButton(),
            ],
          ),
          if (_latestReport != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: FadeTransition(
                opacity: _fadeCtrl,
                child: Text(
                  _latestReport!.overviewBn,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildMetaBadge(
                  icon: Icons.memory_rounded,
                  label: _latestReport!.analysisEngine,
                  color: _kPurple,
                ),
                _buildMetaBadge(
                  icon: Icons.inventory_2_rounded,
                  label: '${_latestReport!.totalProductsAnalyzed} পণ্য',
                  color: _kCyan,
                ),
                _buildMetaBadge(
                  icon: Icons.water_rounded,
                  label: '${_latestReport!.totalFishLotsAnalyzed} লট',
                  color: _kGreen,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetaBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton() {
    return GestureDetector(
      onTap: _triggerFreshScan,
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (_, __) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _kPurple.withValues(alpha: 0.8 + _pulseCtrl.value * 0.2),
                _kBrand.withValues(alpha: 0.8 + _pulseCtrl.value * 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _kPurple.withValues(alpha: 0.3 + _pulseCtrl.value * 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.radar_rounded, color: Colors.white, size: 15),
              const SizedBox(width: 6),
              Text(
                'স্ক্যান',
                style: GoogleFonts.hindSiliguri(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanningIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _kCyan,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'স্ক্যানিং...',
            style: GoogleFonts.inter(
              color: _kCyan,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStabilityGauge(bool isDark) {
    final score = _latestReport!.stabilityScore;
    final color = _gaugeColor(score);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 90,
            child: CustomPaint(
              painter: _GaugePainter(
                progress: score / 100,
                color: color,
                isDark: isDark,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    '$score%',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'বাজার স্থিতিশীলতা সূচক',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        score >= 75
                            ? Icons.shield_rounded
                            : score >= 50
                                ? Icons.warning_amber_rounded
                                : Icons.gpp_bad_rounded,
                        color: color,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _latestReport!.marketRiskLevel,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildRangeDot(color: _kGreen, label: '≥75'),
                    const SizedBox(width: 8),
                    _buildRangeDot(color: _kAmber, label: '≥50'),
                    const SizedBox(width: 8),
                    _buildRangeDot(color: _kRed, label: '<50'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeDot({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiGrid(bool isDark) {
    final report = _latestReport!;
    return Row(
      children: [
        Expanded(
          child: _buildKpiCard(
            icon: Icons.shopping_cart_rounded,
            label: 'ট্রেড ভলিউম',
            value: '৳${_formatCompact(report.totalOrderVolumeBdt)}',
            color: _kBrand,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpiCard(
            icon: Icons.receipt_long_rounded,
            label: 'অর্ডার',
            value: '${report.recentOrdersAnalyzed}',
            color: _kCyan,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpiCard(
            icon: Icons.eco_rounded,
            label: 'কৃষি পণ্য',
            value: '${report.totalProductsAnalyzed}',
            color: _kGreen,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpiCard(
            icon: Icons.water_rounded,
            label: 'মৎস্য লট',
            value: '${report.totalFishLotsAnalyzed}',
            color: const Color(0xFF0EA5E9),
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: GoogleFonts.hindSiliguri(
                fontSize: 10,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanAnimation(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _scanLineCtrl,
            builder: (_, __) => Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _kPurple.withValues(alpha: 0.25),
                      width: 2,
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: _scanLineCtrl.value * 2 * math.pi,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          Colors.transparent,
                          _kPurple.withValues(alpha: 0.5),
                        ],
                        stops: const [0.75, 1.0],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? const Color(0xFF111827) : Colors.white,
                  ),
                ),
                const Icon(Icons.radar_rounded, color: _kPurple, size: 28),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ফায়ারবেইস থেকে লাইভ ডাটা বিশ্লেষণ করা হচ্ছে',
            style: GoogleFonts.hindSiliguri(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'পণ্য, মৎস্য লট, অর্ডার ও বেঞ্চমার্ক রেট পর্যালোচনা করা হচ্ছে...',
            style: GoogleFonts.hindSiliguri(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kRed.withValues(alpha: isDark ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kRed.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: _kRed, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'স্ক্যান ব্যর্থ হয়েছে',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _kRed,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _errorMessage ?? '',
                  style: TextStyle(
                    fontSize: 11,
                    color: _kRed.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _triggerFreshScan,
            child: const Text(
              'পুনরায়',
              style: TextStyle(color: _kRed, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String badge,
    required Color badgeColor,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: badgeColor, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.hindSiliguri(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            badge,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: badgeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllClearCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kGreen.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: _kGreen.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kGreen.withValues(alpha: 0.1),
              border: Border.all(color: _kGreen.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.verified_rounded, color: _kGreen, size: 36),
          ),
          const SizedBox(height: 14),
          Text(
            '✅ বাজার স্থিতিশীল',
            style: GoogleFonts.hindSiliguri(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _kGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'সকল পণ্য ও মৎস্য লটের গড় দর বর্তমানে সরকারি বেঞ্চমার্কের সীমার মধ্যে রয়েছে। কোনো জরুরি হস্তক্ষেপের প্রয়োজন নেই।',
            textAlign: TextAlign.center,
            style: GoogleFonts.hindSiliguri(
              fontSize: 13,
              color: isDark ? Colors.white60 : Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProRecommendationCard(
    AiPriceRecommendationItem rec,
    bool isDark,
    int index,
  ) {
    final isDecrease = rec.action == PriceCommandAction.decrease;
    final isIncrease = rec.action == PriceCommandAction.increase;
    final isCritical = rec.urgency == 'critical';
    final isHigh = rec.urgency == 'high';

    final actionColor =
        isDecrease ? _kRed : isIncrease ? _kGreen : _kBrand;
    final urgencyColor = isCritical ? _kRed : isHigh ? _kOrange : _kBrand;
    final actionLabel = isDecrease
        ? '📉 দাম কমানো'
        : isIncrease
            ? '📈 কৃষক সুরক্ষা'
            : '🔄 বেঞ্চমার্ক সিঙ্ক';
    final urgencyLabel =
        isCritical ? '🚨 সংকট' : isHigh ? '⚡ জরুরি' : '💡 পরামর্শ';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCritical
              ? _kRed.withValues(alpha: 0.5)
              : isDark
                  ? const Color(0xFF1F2937)
                  : const Color(0xFFE5E7EB),
          width: isCritical ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (isCritical ? _kRed : actionColor)
                .withValues(alpha: isDark ? 0.15 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top accent gradient bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [actionColor, urgencyColor],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: actionColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: actionColor.withValues(alpha: 0.3)),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: actionColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildChip(
                        label: actionLabel, color: actionColor, isDark: isDark),
                    const SizedBox(width: 6),
                    _buildChip(
                        label: urgencyLabel, color: urgencyColor, isDark: isDark),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            actionColor.withValues(alpha: 0.85),
                            actionColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${isDecrease ? '▼' : '▲'} ${rec.deltaPercent.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  rec.title,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                if (rec.currentAvgPrice > 0 || rec.benchmarkPrice > 0)
                  _buildPriceComparison(rec, actionColor, isDark),
                const SizedBox(height: 10),
                Text(
                  rec.rationaleBn,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 12.5,
                    height: 1.5,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                if (rec.targetCategory != null ||
                    rec.targetDivision != null ||
                    rec.targetDistrict != null) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (rec.targetCategory != null)
                        _buildTag('📦 ${rec.targetCategory}', _kCyan, isDark),
                      if (rec.targetDivision != null)
                        _buildTag(
                            '🗺️ ${rec.targetDivision}', _kAmber, isDark),
                      if (rec.targetDistrict != null)
                        _buildTag(
                            '📍 ${rec.targetDistrict}', _kPurple, isDark),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                // 1-tap apply button
                SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _applyRecommendation(rec),
                      borderRadius: BorderRadius.circular(12),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              actionColor.withValues(alpha: 0.9),
                              actionColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: actionColor.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.bolt_rounded,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              '১-ট্যাপে কার্যকর করুন  (${isDecrease ? '-' : '+'}${rec.deltaPercent.toStringAsFixed(1)}%)',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
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

  Widget _buildPriceComparison(
    AiPriceRecommendationItem rec,
    Color actionColor,
    bool isDark,
  ) {
    final deviation = rec.benchmarkPrice > 0
        ? ((rec.currentAvgPrice - rec.benchmarkPrice) / rec.benchmarkPrice) *
            100
        : 0.0;
    final deviationStr =
        '${deviation >= 0 ? '+' : ''}${deviation.toStringAsFixed(1)}%';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1422) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          _buildPriceBox(
            label: 'বর্তমান গড়',
            value: '৳${rec.currentAvgPrice.toStringAsFixed(0)}',
            color: actionColor,
            isDark: isDark,
          ),
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.compare_arrows_rounded,
                    color: Colors.grey, size: 16),
                Text(
                  deviationStr,
                  style: TextStyle(
                    fontSize: 10,
                    color: actionColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildPriceBox(
            label: 'বেঞ্চমার্ক',
            value: '৳${rec.benchmarkPrice.toStringAsFixed(0)}',
            color: _kCyan,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBox({
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHistoryTimeline(bool isDark) {
    return StreamBuilder<List<AiMarketAnalysisReport>>(
      stream: AiPriceAnalysisService.streamHistoricalReports(limit: 6),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        final history = snapshot.data ?? [];
        if (history.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111827) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF1F2937)
                    : const Color(0xFFE5E7EB),
              ),
            ),
            child: Center(
              child: Text(
                'কোনো পূর্ববর্তী বিশ্লেষণ পাওয়া যায়নি।',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final report = history[index];
            final isLast = index == history.length - 1;
            final color = _gaugeColor(report.stabilityScore);

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 32,
                    child: Column(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF111827)
                                  : Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: isDark
                                  ? const Color(0xFF1F2937)
                                  : const Color(0xFFE5E7EB),
                              margin:
                                  const EdgeInsets.symmetric(vertical: 4),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF111827)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF1F2937)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${report.stabilityScore}% · ${report.marketRiskLevel}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                _formatTimestamp(report.timestamp),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.black38,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            report.overviewBn,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Colors.black54,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: [
                              _buildTag(
                                '${report.recommendations.length} সুপারিশ',
                                _kPurple,
                                isDark,
                              ),
                              _buildTag(report.analysisEngine, _kCyan, isDark),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _gaugeColor(int score) {
    if (score >= 75) return _kGreen;
    if (score >= 50) return _kAmber;
    return _kRed;
  }

  String _formatCompact(double value) {
    if (value >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(1)} কোটি';
    }
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(1)} লাখ';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toStringAsFixed(0);
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} মিনিট আগে';
    if (diff.inHours < 24) return '${diff.inHours} ঘণ্টা আগে';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ══════════════════════════════════════════════════════════════════════
//  GAUGE PAINTER
// ══════════════════════════════════════════════════════════════════════
class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isDark;

  const _GaugePainter({
    required this.progress,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.75);
    final radius = size.width * 0.45;
    const startAngle = math.pi;
    const sweepAngle = math.pi;

    final trackPaint = Paint()
      ..color =
          (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    final fillPaint = Paint()
      ..color = color
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      fillPaint,
    );

    // Dot at tip
    final endAngle = startAngle + sweepAngle * progress;
    final dotX = center.dx + radius * math.cos(endAngle);
    final dotY = center.dy + radius * math.sin(endAngle);

    canvas.drawCircle(
      Offset(dotX, dotY),
      6,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(dotX, dotY),
      6,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.progress != progress || old.color != color;
}
