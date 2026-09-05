import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/presentation/screens/admin/widgets/admin_quick_price_command_sheet.dart';
import 'package:agrolinkbd/presentation/screens/admin/widgets/admin_price_command_history_view.dart';
import 'package:agrolinkbd/presentation/screens/admin/widgets/admin_price_safety_policy_card.dart';
import 'package:agrolinkbd/presentation/screens/admin/widgets/admin_ai_price_analysis_tab.dart';
import 'package:agrolinkbd/core/services/admin_price_command_service.dart';

/// ============================================================
/// ADMIN PRICE CONTROL SCREEN
/// Super Admin can increase/decrease product prices.
/// Changes auto-sync to marketplace via Firestore real-time.
/// ============================================================
class AdminPriceControlScreen extends StatefulWidget {
  const AdminPriceControlScreen({super.key});

  @override
  State<AdminPriceControlScreen> createState() =>
      _AdminPriceControlScreenState();
}

class _AdminPriceControlScreenState extends State<AdminPriceControlScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all';

  static const _accent = Color(0xFF2563EB);
  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);
  static const _gradientStart = Color(0xFF0D1B3E);
  static const _gradientMid = Color(0xFF1E3A8A);
  static const _gradientEnd = Color(0xFF312E81);

  final List<Map<String, dynamic>> _categories = [
    {'key': 'all', 'label': 'সব', 'labelEn': 'All', 'icon': Icons.grid_view_rounded},
    {'key': 'vegetables', 'label': 'শাকসবজি', 'labelEn': 'Vegetables', 'icon': Icons.eco_rounded},
    {'key': 'fruits', 'label': 'ফলমূল', 'labelEn': 'Fruits', 'icon': Icons.apple_rounded},
    {'key': 'grains', 'label': 'শস্য', 'labelEn': 'Grains', 'icon': Icons.grain_rounded},
    {'key': 'fish', 'label': 'মাছ', 'labelEn': 'Fish', 'icon': Icons.water_rounded},
    {'key': 'meat', 'label': 'মাংস', 'labelEn': 'Meat', 'icon': Icons.set_meal_rounded},
    {'key': 'spices', 'label': 'মসলা', 'labelEn': 'Spices', 'icon': Icons.local_fire_department_rounded},
    {'key': 'dairy', 'label': 'দুগ্ধ', 'labelEn': 'Dairy', 'icon': Icons.egg_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSec = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_gradientStart, _gradientMid, _gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.price_change_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'প্রাইস কন্ট্রোল সেন্টার',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'AI-powered marketplace management',
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      color: Colors.white54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: GestureDetector(
              onTap: () => AdminQuickPriceCommandSheet.show(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amberAccent.withValues(alpha: 0.85),
                      Colors.orange.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amberAccent.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, color: Colors.white, size: 15),
                    const SizedBox(width: 5),
                    Text(
                      'কমান্ড',
                      style: GoogleFonts.hindSiliguri(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amberAccent,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelStyle: GoogleFonts.hindSiliguri(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: GoogleFonts.hindSiliguri(fontSize: 11),
          tabs: const [
            Tab(icon: Icon(Icons.inventory_2_rounded, size: 16), text: 'পণ্য ও লট'),
            Tab(icon: Icon(Icons.price_change_rounded, size: 16), text: 'বাজার রেট'),
            Tab(icon: Icon(Icons.auto_awesome_rounded, size: 16), text: '🤖 এআই স্ক্যান'),
            Tab(icon: Icon(Icons.history_rounded, size: 16), text: 'কমান্ড লগ'),
            Tab(icon: Icon(Icons.shield_rounded, size: 16), text: 'সেফটি'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ─── Emergency Command Shortcut Bar (Horizontally Scrollable - No Overflow) ───
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_gradientStart, _gradientMid, _gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildShortcutPill(
                    icon: Icons.auto_awesome_rounded,
                    label: '🤖 এআই স্ক্যান',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
                    ),
                    onTap: () => _tabController.animateTo(2),
                  ),
                  const SizedBox(width: 8),
                  _buildShortcutPill(
                    icon: Icons.trending_down_rounded,
                    label: '📉 বাজার ধস (-১০%)',
                    bgColor: const Color(0xFFEF4444).withValues(alpha: 0.25),
                    borderColor: const Color(0xFFEF4444).withValues(alpha: 0.6),
                    onTap: () => AdminQuickPriceCommandSheet.show(
                      context,
                      initialAction: PriceCommandAction.decrease,
                      initialScope: PriceCommandScope.all,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildShortcutPill(
                    icon: Icons.trending_up_rounded,
                    label: '📈 কৃষক সুরক্ষা (+১০%)',
                    bgColor: const Color(0xFF10B981).withValues(alpha: 0.25),
                    borderColor: const Color(0xFF10B981).withValues(alpha: 0.6),
                    onTap: () => AdminQuickPriceCommandSheet.show(
                      context,
                      initialAction: PriceCommandAction.increase,
                      initialScope: PriceCommandScope.all,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildShortcutPill(
                    icon: Icons.tune_rounded,
                    label: '⚡ কমান্ড শর্টকাট',
                    textColor: Colors.amberAccent,
                    bgColor: Colors.white.withValues(alpha: 0.2),
                    borderColor: Colors.white.withValues(alpha: 0.35),
                    onTap: () => AdminQuickPriceCommandSheet.show(
                      context,
                      initialAction: PriceCommandAction.syncBenchmark,
                      initialScope: PriceCommandScope.all,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Search Bar & Category Chips (Only for Tabs 0 & 1) ───
          if (_tabController.index == 0 || _tabController.index == 1) ...[
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_gradientStart, _gradientMid, _gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'পণ্য খুঁজুন... / Search products...',
                  hintStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white70, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              ),
            ),

            // ─── Category Filter Chips ────────────────────────────
            Container(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              height: 46,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                itemCount: _categories.length,
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final isSelected = _selectedCategory == cat['key'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = cat['key']),
                      avatar: Icon(cat['icon'] as IconData,
                          size: 14,
                          color: isSelected ? Colors.white : _accent),
                      label: Text(
                        cat['label'],
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : textPrimary,
                        ),
                      ),
                      backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      selectedColor: _accent,
                      checkmarkColor: Colors.white,
                      showCheckmark: false,
                      side: BorderSide(
                        color: isSelected ? _accent : Colors.transparent,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  );
                },
              ),
            ),
          ],

          // ─── Tab Views (5 Enterprise Tabs) ─────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductPriceList(isDark, cardBg, textPrimary, textSec),
                _buildMarketRatesEditor(isDark, cardBg, textPrimary, textSec),
                AdminAiPriceAnalysisTab(
                  onCommandExecuted: () => setState(() {}),
                ),
                const AdminPriceCommandHistoryView(),
                const AdminPriceSafetyPolicyCard(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AdminQuickPriceCommandSheet.show(context),
        backgroundColor: const Color(0xFF0D47A1),
        icon: const Icon(Icons.bolt_rounded, color: Colors.amberAccent),
        label: Text(
          '⚡ প্রাইস কমান্ড শর্টকাট',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutPill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? bgColor,
    Color? borderColor,
    Color textColor = Colors.white,
    Gradient? gradient,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          gradient: gradient,
          borderRadius: BorderRadius.circular(10),
          border: borderColor != null ? Border.all(color: borderColor) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 15),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.hindSiliguri(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // TAB 1: ALL PRODUCTS PRICE LIST (from `products` collection)
  // ================================================================
  Widget _buildProductPriceList(
      bool isDark, Color cardBg, Color textPrimary, Color textSec) {
    Query query = FirebaseFirestore.instance
        .collection('products')
        .orderBy('title');

    if (_selectedCategory != 'all') {
      query = FirebaseFirestore.instance
          .collection('products')
          .where('category', whereIn: [
        _selectedCategory,
        'ProductCategory.$_selectedCategory',
      ]);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _accent));
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: _red, size: 48),
                const SizedBox(height: 8),
                Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: _red)),
              ],
            ),
          );
        }

        var docs = snapshot.data?.docs ?? [];

        // Client-side search filter
        if (_searchQuery.isNotEmpty) {
          docs = docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            final title = (data['title'] as String? ?? '').toLowerCase();
            final seller = (data['sellerName'] as String? ?? '').toLowerCase();
            return title.contains(_searchQuery) || seller.contains(_searchQuery);
          }).toList();
        }

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: textSec),
                const SizedBox(height: 12),
                Text('কোনো পণ্য পাওয়া যায়নি',
                    style: GoogleFonts.hindSiliguri(
                        color: textSec, fontSize: 15)),
              ],
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final price = (data['price'] as num?)?.toDouble() ?? 0.0;
            final adminPrice = (data['adminOverridePrice'] as num?)?.toDouble();
            final effectivePrice = adminPrice ?? price;
            final isOverridden = adminPrice != null;

            return _buildProductPriceCard(
              context,
              docId: doc.id,
              data: data,
              originalPrice: price,
              effectivePrice: effectivePrice,
              isOverridden: isOverridden,
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSec: textSec,
            );
          },
        );
      },
    );
  }

  Widget _buildProductPriceCard(
    BuildContext context, {
    required String docId,
    required Map<String, dynamic> data,
    required double originalPrice,
    required double effectivePrice,
    required bool isOverridden,
    required bool isDark,
    required Color cardBg,
    required Color textPrimary,
    required Color textSec,
  }) {
    final title = data['title'] as String? ?? 'Unknown Product';
    final seller = data['sellerName'] as String? ?? 'Unknown Seller';
    final unit = data['unit'] as String? ?? 'কেজি';
    final category = data['category'] as String? ?? '';
    final qty = (data['quantity'] as num?)?.toDouble() ?? 0.0;

    String emoji = '🥬';
    Color catColor = _green;
    if (category.contains('fruit')) {
      emoji = '🍎';
      catColor = Colors.red;
    } else if (category.contains('grain')) {
      emoji = '🌾';
      catColor = Colors.amber.shade700;
    } else if (category.contains('fish')) {
      emoji = '🐟';
      catColor = _accent;
    } else if (category.contains('meat')) {
      emoji = '🥩';
      catColor = Colors.brown;
    } else if (category.contains('spice')) {
      emoji = '🌶️';
      catColor = Colors.deepOrange;
    } else if (category.contains('dairy')) {
      emoji = '🥛';
      catColor = Colors.teal;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isOverridden
              ? _accent.withValues(alpha: 0.5)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: isOverridden ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.hindSiliguri(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            color: textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isOverridden)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'ADMIN SET',
                            style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: _accent),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '🧑‍🌾 $seller | Qty: ${qty.toStringAsFixed(0)} $unit',
                    style: GoogleFonts.hindSiliguri(
                        fontSize: 10.5, color: textSec),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (isOverridden) ...[
                        Text(
                          '৳${originalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: textSec,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        '৳${effectivePrice.toStringAsFixed(0)}/$unit',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isOverridden ? _accent : textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Price Action Buttons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPriceActionBtn(
                  icon: Icons.arrow_upward_rounded,
                  color: _red,
                  tooltip: 'Increase Price',
                  onTap: () => _showPriceDialog(
                    context,
                    docId: docId,
                    productName: title,
                    currentPrice: effectivePrice,
                    unit: unit,
                    isIncrease: true,
                  ),
                ),
                const SizedBox(height: 6),
                _buildPriceActionBtn(
                  icon: Icons.arrow_downward_rounded,
                  color: _green,
                  tooltip: 'Decrease Price',
                  onTap: () => _showPriceDialog(
                    context,
                    docId: docId,
                    productName: title,
                    currentPrice: effectivePrice,
                    unit: unit,
                    isIncrease: false,
                  ),
                ),
                if (isOverridden) ...[
                  const SizedBox(height: 6),
                  _buildPriceActionBtn(
                    icon: Icons.refresh_rounded,
                    color: Colors.grey,
                    tooltip: 'Reset to Original',
                    onTap: () => _resetProductPrice(docId, title),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceActionBtn({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }

  // ================================================================
  // TAB 2: MARKET RATES EDITOR (from `market_prices` collection)
  // ================================================================
  Widget _buildMarketRatesEditor(
      bool isDark, Color cardBg, Color textPrimary, Color textSec) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('market_prices')
          .orderBy('productName')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _accent));
        }

        final docs = snapshot.data?.docs ?? [];

        // If no market_prices docs exist, show a create-initial-rates button
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.price_change_rounded,
                    size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No market rates configured yet.',
                  style: GoogleFonts.hindSiliguri(
                      color: textSec, fontSize: 15),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _initializeDefaultMarketRates,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Initialize Default Rates'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          );
        }

        var filteredDocs = docs;
        if (_selectedCategory != 'all') {
          filteredDocs = docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            final cat = (data['category'] as String? ?? '').toLowerCase();
            return cat.contains(_selectedCategory);
          }).toList();
        }
        if (_searchQuery.isNotEmpty) {
          filteredDocs = filteredDocs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            final name =
                (data['productName'] as String? ?? '').toLowerCase();
            return name.contains(_searchQuery);
          }).toList();
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(12),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildMarketRateCard(
              context,
              docId: doc.id,
              data: data,
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSec: textSec,
            );
          },
        );
      },
    );
  }

  Widget _buildMarketRateCard(
    BuildContext context, {
    required String docId,
    required Map<String, dynamic> data,
    required bool isDark,
    required Color cardBg,
    required Color textPrimary,
    required Color textSec,
  }) {
    final productName = data['productName'] as String? ?? 'Unknown';
    final currentPrice = (data['currentPrice'] as num?)?.toDouble() ?? 0.0;
    final previousPrice = (data['previousPrice'] as num?)?.toDouble() ?? currentPrice;
    final unit = data['unit'] as String? ?? 'কেজি';
    final trendStr = data['trend'] as String? ?? 'stable';
    final imageUrl = data['imageUrl'] as String?;

    final isUp = trendStr.contains('up');
    final isDown = trendStr.contains('down');
    final diff = currentPrice - previousPrice;
    final diffPercent = previousPrice > 0 ? (diff / previousPrice * 100) : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image / Emoji
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFE2E8F0),
              ),
              child: imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_outlined, color: Colors.grey),
                      ),
                    )
                  : const Icon(Icons.price_change_rounded,
                      color: Colors.grey, size: 26),
            ),
            const SizedBox(width: 12),

            // Name + Trend
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: GoogleFonts.hindSiliguri(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '৳${currentPrice.toStringAsFixed(0)}/$unit',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isUp ? _red : isDown ? _green : textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (diff != 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (isUp ? _red : _green)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isUp
                                    ? Icons.arrow_upward_rounded
                                    : Icons.arrow_downward_rounded,
                                size: 10,
                                color: isUp ? _red : _green,
                              ),
                              Text(
                                '${diffPercent.abs().toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isUp ? _red : _green,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  Text(
                    'Prev: ৳${previousPrice.toStringAsFixed(0)}',
                    style: GoogleFonts.hindSiliguri(
                        fontSize: 10.5, color: textSec),
                  ),
                ],
              ),
            ),

            // Action buttons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPriceActionBtn(
                  icon: Icons.arrow_upward_rounded,
                  color: _red,
                  tooltip: 'Increase Rate',
                  onTap: () => _showMarketRateDialog(
                    context,
                    docId: docId,
                    productName: productName,
                    currentPrice: currentPrice,
                    unit: unit,
                    isIncrease: true,
                  ),
                ),
                const SizedBox(height: 6),
                _buildPriceActionBtn(
                  icon: Icons.arrow_downward_rounded,
                  color: _green,
                  tooltip: 'Decrease Rate',
                  onTap: () => _showMarketRateDialog(
                    context,
                    docId: docId,
                    productName: productName,
                    currentPrice: currentPrice,
                    unit: unit,
                    isIncrease: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // PRICE ADJUSTMENT DIALOGS
  // ================================================================
  Future<void> _showPriceDialog(
    BuildContext context, {
    required String docId,
    required String productName,
    required double currentPrice,
    required String unit,
    required bool isIncrease,
  }) async {
    final ctrl = TextEditingController();
    bool usePercent = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                isIncrease
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: isIncrease ? _red : _green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${isIncrease ? "Increase" : "Decrease"} Price',
                  style: GoogleFonts.hindSiliguri(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product info
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        productName,
                        style: GoogleFonts.hindSiliguri(
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '৳${currentPrice.toStringAsFixed(0)}/$unit',
                      style: GoogleFonts.hindSiliguri(
                          color: _accent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Toggle: Fixed / Percent
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setS(() => usePercent = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !usePercent ? _accent : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Fixed (৳)',
                            style: TextStyle(
                              color: !usePercent ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setS(() => usePercent = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: usePercent ? _accent : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Percent (%)',
                            style: TextStyle(
                              color: usePercent ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextField(
                controller: ctrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                ],
                decoration: InputDecoration(
                  labelText: usePercent
                      ? 'Enter percentage (%)'
                      : 'Enter amount (৳)',
                  prefixText: usePercent ? '' : '৳ ',
                  suffixText: usePercent ? '%' : '',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _accent, width: 2),
                  ),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final val = double.tryParse(ctrl.text);
                if (val == null || val <= 0) return;
                double newPrice;
                if (usePercent) {
                  newPrice = isIncrease
                      ? currentPrice * (1 + val / 100)
                      : currentPrice * (1 - val / 100);
                } else {
                  newPrice = isIncrease
                      ? currentPrice + val
                      : currentPrice - val;
                }
                if (newPrice < 1) newPrice = 1;
                Navigator.pop(ctx);
                await _applyProductPriceOverride(
                    docId, productName, newPrice.roundToDouble());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isIncrease ? _red : _green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(isIncrease ? 'Increase' : 'Decrease'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMarketRateDialog(
    BuildContext context, {
    required String docId,
    required String productName,
    required double currentPrice,
    required String unit,
    required bool isIncrease,
  }) async {
    final ctrl = TextEditingController();
    bool usePercent = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                isIncrease
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: isIncrease ? _red : _green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Market Rate: $productName',
                  style: GoogleFonts.hindSiliguri(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Current: ৳${currentPrice.toStringAsFixed(0)}/$unit',
                style: GoogleFonts.hindSiliguri(
                    fontSize: 14, color: _accent, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setS(() => usePercent = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !usePercent ? _accent : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Fixed (৳)',
                            style: TextStyle(
                              color: !usePercent ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setS(() => usePercent = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: usePercent ? _accent : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Percent (%)',
                            style: TextStyle(
                              color: usePercent ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                ],
                decoration: InputDecoration(
                  labelText: usePercent ? 'Percentage (%)' : 'Amount (৳)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _accent, width: 2),
                  ),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final val = double.tryParse(ctrl.text);
                if (val == null || val <= 0) return;
                double newPrice;
                if (usePercent) {
                  newPrice = isIncrease
                      ? currentPrice * (1 + val / 100)
                      : currentPrice * (1 - val / 100);
                } else {
                  newPrice = isIncrease
                      ? currentPrice + val
                      : currentPrice - val;
                }
                if (newPrice < 1) newPrice = 1;
                Navigator.pop(ctx);
                await _updateMarketRate(
                    docId, productName, newPrice.roundToDouble(), currentPrice);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isIncrease ? _red : _green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(isIncrease ? 'Increase Rate' : 'Decrease Rate'),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // FIREBASE WRITE OPERATIONS
  // ================================================================

  /// Override price on a specific product document
  Future<void> _applyProductPriceOverride(
      String docId, String productName, double newPrice) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(docId)
          .update({
        'adminOverridePrice': newPrice,
        'adminOverrideAt': FieldValue.serverTimestamp(),
        'adminOverrideBy':
            FirebaseAuth.instance.currentUser?.email ?? 'admin',
      });

      // Log to audit trail
      await FirebaseFirestore.instance.collection('admin_price_logs').add({
        'productId': docId,
        'productName': productName,
        'newPrice': newPrice,
        'action': 'override',
        'adminEmail':
            FirebaseAuth.instance.currentUser?.email ?? 'unknown',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ $productName price updated to ৳${newPrice.toStringAsFixed(0)}',
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: _red,
          ),
        );
      }
    }
  }

  /// Reset product price to farmer's original price
  Future<void> _resetProductPrice(String docId, String productName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Price?'),
        content: Text(
            'Reset "$productName" back to the farmer\'s original price?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(docId)
          .update({
        'adminOverridePrice': FieldValue.delete(),
        'adminOverrideAt': FieldValue.delete(),
        'adminOverrideBy': FieldValue.delete(),
      });

      await FirebaseFirestore.instance.collection('admin_price_logs').add({
        'productId': docId,
        'productName': productName,
        'action': 'reset',
        'adminEmail':
            FirebaseAuth.instance.currentUser?.email ?? 'unknown',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔄 $productName price reset to original.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: _red),
        );
      }
    }
  }

  /// Update a market_prices document
  Future<void> _updateMarketRate(
      String docId, String productName, double newPrice, double prevPrice) async {
    try {
      final trend = newPrice > prevPrice ? 'PriceTrend.up' : 'PriceTrend.down';
      await FirebaseFirestore.instance
          .collection('market_prices')
          .doc(docId)
          .update({
        'currentPrice': newPrice,
        'previousPrice': prevPrice,
        'trend': trend,
        'updatedAt': DateTime.now().toIso8601String(),
        'updatedBy':
            FirebaseAuth.instance.currentUser?.email ?? 'admin',
      });

      await FirebaseFirestore.instance.collection('admin_price_logs').add({
        'collection': 'market_prices',
        'docId': docId,
        'productName': productName,
        'newPrice': newPrice,
        'previousPrice': prevPrice,
        'action': 'market_rate_update',
        'adminEmail':
            FirebaseAuth.instance.currentUser?.email ?? 'unknown',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '📊 $productName market rate → ৳${newPrice.toStringAsFixed(0)}',
            ),
            backgroundColor: _accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: _red),
        );
      }
    }
  }

  /// Initialize default market rate documents in Firestore
  Future<void> _initializeDefaultMarketRates() async {
    final defaults = [
      {'id': 'tomato', 'productName': 'টমেটো', 'category': 'vegetables', 'currentPrice': 80.0, 'unit': 'কেজি', 'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782757091/Tomato_hcjt7o.png'},
      {'id': 'potato', 'productName': 'আলু', 'category': 'vegetables', 'currentPrice': 40.0, 'unit': 'কেজি', 'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782584736/Screenshot_2026-06-28_002524_ziwqmo.png'},
      {'id': 'onion', 'productName': 'পেঁয়াজ', 'category': 'vegetables', 'currentPrice': 90.0, 'unit': 'কেজি', 'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782757375/images_z5w9hg.jpg'},
      {'id': 'chilli', 'productName': 'কাঁচা মরিচ', 'category': 'spices', 'currentPrice': 150.0, 'unit': 'কেজি', 'imageUrl': ''},
      {'id': 'rice', 'productName': 'চাল (মিনিকেট)', 'category': 'grains', 'currentPrice': 70.0, 'unit': 'কেজি', 'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782584453/Screenshot_2026-06-28_002037_e5q6ll.png'},
      {'id': 'mango', 'productName': 'আম (হিমসাগর)', 'category': 'fruits', 'currentPrice': 100.0, 'unit': 'কেজি', 'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782583216/image_sxwwpa.png'},
      {'id': 'rui_fish', 'productName': 'রুই মাছ', 'category': 'fish', 'currentPrice': 350.0, 'unit': 'কেজি', 'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782734272/Screenshot_2026-06-29_175728_q4k1bk.png'},
      {'id': 'beef', 'productName': 'গরুর মাংস', 'category': 'meat', 'currentPrice': 750.0, 'unit': 'কেজি', 'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782756123/images_wrgten.webp'},
      {'id': 'chicken', 'productName': 'মুরগি (ব্রয়লার)', 'category': 'meat', 'currentPrice': 200.0, 'unit': 'কেজি', 'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782757555/images_xgtcyf.jpg'},
      {'id': 'egg', 'productName': 'ডিম (হালি)', 'category': 'dairy', 'currentPrice': 50.0, 'unit': 'হালি', 'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782756249/download_ezwxls.jpg'},
      {'id': 'hilsa', 'productName': 'ইলিশ মাছ', 'category': 'fish', 'currentPrice': 900.0, 'unit': 'কেজি', 'imageUrl': ''},
      {'id': 'catfish', 'productName': 'কই মাছ', 'category': 'fish', 'currentPrice': 280.0, 'unit': 'কেজি', 'imageUrl': ''},
      {'id': 'garlic', 'productName': 'রসুন', 'category': 'spices', 'currentPrice': 200.0, 'unit': 'কেজি', 'imageUrl': ''},
      {'id': 'ginger', 'productName': 'আদা', 'category': 'spices', 'currentPrice': 120.0, 'unit': 'কেজি', 'imageUrl': ''},
    ];

    final batch = FirebaseFirestore.instance.batch();
    for (final item in defaults) {
      final ref = FirebaseFirestore.instance
          .collection('market_prices')
          .doc(item['id'] as String);
      batch.set(ref, {
        ...item,
        'previousPrice': item['currentPrice'],
        'trend': 'PriceTrend.stable',
        'updatedAt': DateTime.now().toIso8601String(),
        'location': 'সারা বাংলাদেশ',
      });
    }
    await batch.commit();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Default market rates initialized!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }
}
