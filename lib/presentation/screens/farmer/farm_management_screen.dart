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
        'title': isBn ? 'খামার ব্যবস্থাপনা' : 'Farm Management',
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
        'title': isBn ? 'কাজ ব্যবস্থাপনা' : 'Task Management',
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
        'title': isBn ? 'ফসল তোলার হিসাব' : 'Harvest Tracking',
        'subtitle': isBn ? 'ফলন ও লগ' : 'Yields & Logs',
        'icon': Icons.shopping_basket_rounded,
        'color': const Color(0xFFFFC107),
        'screen': const HarvestTrackingScreen(),
      },
      {
        'title': isBn ? 'ফলনের পূর্বাভাস' : 'Yield Prediction',
        'subtitle': isBn ? 'এআই পূর্বাভাস' : 'AI Forecasts',
        'icon': Icons.analytics_rounded,
        'color': const Color(0xFF3F51B5),
        'screen': const YieldPredictionScreen(),
      },
      {
        'title': isBn ? 'নোটিফিকেশন' : 'Notifications',
        'subtitle': isBn ? 'সতর্কবার্তা ও রিমাইন্ডার' : 'Alerts & Reminders',
        'icon': Icons.notifications_active_rounded,
        'color': const Color(0xFFFF5722),
        'screen': const FarmNotificationsScreen(),
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            sliver: SliverToBoxAdapter(
              child: Text(
                LanguageProvider.isBn(context) ? 'খামার ব্যবস্থাপনা মডিউল' : 'Management Modules',
                style: GoogleFonts.openSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.05,
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
        onPressed: () {},
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
          LanguageProvider.isBn(context) ? 'আমার খামার সমূহ' : 'Agro Dashboard',
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
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
                  backgroundColor: Colors.white.withOpacity(0.08),
                ),
              ),
              Positioned(
                right: 40,
                bottom: -20,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white.withOpacity(0.05),
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
                        color: Colors.black.withOpacity(0.1),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCBD5E1).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.openSans(
                    fontSize: 13,
                    color: const Color(0xFF718096),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.openSans(
                    fontSize: 18,
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
    final Color color = module['color'];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCBD5E1).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            if (module['screen'] != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => module['screen']),
              );
            }
          },
          splashColor: color.withOpacity(0.1),
          highlightColor: color.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        module['icon'] as IconData,
                        color: color,
                        size: 28,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey.shade300,
                      size: 16,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module['title'] as String,
                      style: GoogleFonts.openSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: const Color(0xFF2D3748),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      module['subtitle'] as String,
                      style: GoogleFonts.openSans(
                        fontSize: 12,
                        color: const Color(0xFF718096),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
