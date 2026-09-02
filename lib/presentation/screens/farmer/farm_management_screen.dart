import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/services/phase2_services/farm_service.dart';
import 'package:agrolinkbd/core/models/phase2_models/farm_models.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';

import 'package:agrolinkbd/presentation/screens/farmer/farm_management/farm_profile_screen.dart';
import 'package:agrolinkbd/presentation/screens/farmer/farm_management/crop_production_screen.dart';
import 'package:agrolinkbd/presentation/screens/farmer/farm_management/expense_management_screen.dart';
import 'package:agrolinkbd/presentation/screens/farmer/farm_management/revenue_profit_screen.dart';
import 'package:agrolinkbd/presentation/screens/farmer/farm_management/task_management_screen.dart';
import 'package:agrolinkbd/presentation/screens/farmer/farm_management/inventory_screen.dart';
import 'package:agrolinkbd/presentation/screens/farmer/farm_management/farm_gallery_screen.dart';
import 'package:agrolinkbd/presentation/screens/farmer/farm_management/gps_mapping_screen.dart';
import 'package:agrolinkbd/presentation/screens/farmer/farm_management/harvest_tracking_screen.dart';
import 'package:agrolinkbd/presentation/screens/farmer/farm_management/yield_prediction_screen.dart';
import 'package:agrolinkbd/presentation/screens/farmer/farm_management/farm_notifications_screen.dart';

import 'package:agrolinkbd/presentation/screens/analytics/farmer_analytics.dart';

class FarmManagementScreen extends StatefulWidget {
  const FarmManagementScreen({Key? key}) : super(key: key);

  @override
  State<FarmManagementScreen> createState() => _FarmManagementScreenState();
}

class _FarmManagementScreenState extends State<FarmManagementScreen> {
  final farmService = FarmService();
  late Stream<List<Farm>> farmsStream;

  List<Map<String, dynamic>> _getModules(BuildContext context) {
    final bool isBn = LanguageProvider.isBn(context);
    return [
      {
        'title': isBn ? 'খামার ব্যবস্থাপনা' : 'Farm Profile',
        'subtitle': isBn ? 'বিবরণ ও সেটআপ' : 'Details & Setup',
        'icon': Icons.agriculture,
        'color': const Color(0xFF4CAF50),
        'screen': const FarmProfileScreen(),
      },
      {
        'title': isBn ? 'ফসল উৎপাদন' : 'Crop Production',
        'subtitle': isBn ? 'ট্র্যাকিং ও বৃদ্ধি' : 'Tracking & Growth',
        'icon': Icons.grass,
        'color': const Color(0xFF8BC34A),
        'screen': const CropProductionScreen(),
      },
      {
        'title': isBn ? 'খরচ ব্যবস্থাপনা' : 'Expense Mgmt',
        'subtitle': isBn ? 'খরচ ও ব্যয়' : 'Costs & Spending',
        'icon': Icons.money_off_rounded,
        'color': const Color(0xFFF44336),
        'screen': const ExpenseManagementScreen(),
      },
      {
        'title': isBn ? 'আয় ও লাভ' : 'Revenue & Profit',
        'subtitle': isBn ? 'বিক্রয় ও মুনাফা' : 'Sales & Margins',
        'icon': Icons.attach_money_rounded,
        'color': const Color(0xFF009688),
        'screen': const RevenueProfitScreen(),
      },
      {
        'title': isBn ? 'কাজ ব্যবস্থাপনা' : 'Task Mgmt',
        'subtitle': isBn ? 'করণীয় ও কর্মী' : 'To-Dos & Staff',
        'icon': Icons.assignment_rounded,
        'color': const Color(0xFFFF9800),
        'screen': const TaskManagementScreen(),
      },
      {
        'title': isBn ? 'মালামাল ও মজুত' : 'Inventory',
        'subtitle': isBn ? 'বীজ ও সার' : 'Seeds & Fertilizer',
        'icon': Icons.inventory_2_rounded,
        'color': const Color(0xFF795548),
        'screen': const InventoryScreen(),
      },
      {
        'title': isBn ? 'খামারের গ্যালারি' : 'Farm Gallery',
        'subtitle': isBn ? 'ছবি ও মিডিয়া' : 'Photos & Media',
        'icon': Icons.photo_library_rounded,
        'color': const Color(0xFF9C27B0),
        'screen': const FarmGalleryScreen(),
      },
      {
        'title': isBn ? 'জিপিএস ম্যাপিং' : 'GPS Mapping',
        'subtitle': isBn ? 'সীমানা ও এলাকা' : 'Borders & Zones',
        'icon': Icons.map_rounded,
        'color': const Color(0xFF2196F3),
        'screen': const GpsMappingScreen(),
      },
      {
        'title': isBn ? 'ফসল তোলা' : 'Harvesting',
        'subtitle': isBn ? 'ফলন ও লগ' : 'Yields & Logs',
        'icon': Icons.shopping_basket_rounded,
        'color': const Color(0xFFFFC107),
        'screen': const HarvestTrackingScreen(),
      },
      {
        'title': isBn ? 'ফলনের পূর্বাভাস' : 'Yield Forecast',
        'subtitle': isBn ? 'এআই পূর্বাভাস' : 'AI Forecasts',
        'icon': Icons.analytics_rounded,
        'color': const Color(0xFF3F51B5),
        'screen': const YieldPredictionScreen(),
      },
      {
        'title': isBn ? 'নোটিফিকেশন' : 'Alerts',
        'subtitle': isBn ? 'সতর্কবার্তা' : 'Alerts & Reminders',
        'icon': Icons.notifications_active_rounded,
        'color': const Color(0xFFFF5722),
        'screen': const FarmNotificationsScreen(),
      },
      {
        'title': isBn ? 'অ্যানালিটিক্স' : 'Analytics',
        'subtitle': isBn ? 'গ্রাফ ও ডেটা' : 'Graphs & Data',
        'icon': Icons.insights_rounded,
        'color': const Color(0xFF673AB7),
        'screen': const FarmerAnalyticsScreen(),
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    farmsStream = farmService.getFarmsStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildSummarySection(),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            sliver: SliverToBoxAdapter(
              child: Text(
                LanguageProvider.isBn(context) ? 'খামার ব্যবস্থাপনা মডিউল' : 'Management Modules',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 10,
                childAspectRatio: 0.78,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildModuleCard(_getModules(context)[index]);
                },
                childCount: _getModules(context).length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FarmProfileScreen()),
          );
        },
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final bool isBn = LanguageProvider.isBn(context);
    return SliverAppBar(
      expandedHeight: 160.0,
      pinned: true,
      backgroundColor: const Color(0xFF2E7D32),
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 20),
        title: Text(
          isBn ? 'আমার খামার সমূহ' : 'My Farms & Plots',
          style: GoogleFonts.hindSiliguri(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF388E3C),
                Color(0xFF1B5E20),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -40,
                top: -40,
                child: CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              Positioned(
                right: 40,
                bottom: -20,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              Positioned(
                right: 20,
                top: 60,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.person, color: Color(0xFF2E7D32)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return StreamBuilder<List<Farm>>(
      stream: farmsStream,
      builder: (context, snapshot) {
        String activeFarms = '-';
        String totalArea = '-';

        if (snapshot.hasData) {
          activeFarms = snapshot.data!.length.toString();
          double area = snapshot.data!.fold(0, (sum, farm) => sum + farm.area);
          totalArea = '${area.toStringAsFixed(1)} ha';
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  LanguageProvider.isBn(context) ? 'সক্রিয় খামার' : 'Active Farms',
                  activeFarms,
                  Icons.agriculture_rounded,
                  const Color(0xFFE8F5E9),
                  const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  LanguageProvider.isBn(context) ? 'মোট জমি' : 'Total Area',
                  totalArea,
                  Icons.landscape_rounded,
                  const Color(0xFFFFF3E0),
                  const Color(0xFFEF6C00),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 12,
                    color: const Color(0xFF718096),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(Map<String, dynamic> module) {
    final Color color = module['color'] as Color;
    final String title = module['title'] as String;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (module['screen'] != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => module['screen']),
              );
            }
          },
          splashColor: color.withOpacity(0.12),
          highlightColor: color.withOpacity(0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    module['icon'] as IconData,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.hindSiliguri(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: const Color(0xFF2D3748),
                      height: 1.15,
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
}
