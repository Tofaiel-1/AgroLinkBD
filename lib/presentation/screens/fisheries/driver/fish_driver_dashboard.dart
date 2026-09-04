import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart' as prov;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/providers/payment_provider.dart';
import 'package:agrolinkbd/core/providers/driver_notification_provider.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/presentation/widgets/weather_card_widget.dart';
import 'package:agrolinkbd/presentation/widgets/global_announcement_banner.dart';
import 'package:agrolinkbd/presentation/widgets/report_generation_card.dart';
import 'package:agrolinkbd/presentation/widgets/premium_dashboard_widgets.dart';
import 'package:agrolinkbd/presentation/screens/notifications/driver_notifications.dart';
import 'package:agrolinkbd/presentation/screens/transport/order_qr_delivery_screen.dart';
import 'package:agrolinkbd/presentation/screens/driver/return_truck_sharing_screen.dart';
import 'package:agrolinkbd/presentation/screens/driver/driver_trip_meter_screen.dart';
import 'package:agrolinkbd/presentation/screens/driver/driver_fuel_expense_tracker_screen.dart';
import 'package:agrolinkbd/presentation/screens/transport/smart_agro_fare_calculator_screen.dart';
import 'package:agrolinkbd/core/models/order_model.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/driver/fish_driver_deliveries_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/driver/fish_driver_job_board_screen.dart';

/// Fish Driver Dashboard - Ultra Pro Edition
/// Dedicated transport dashboard tailored for Live Fish Oxygen Vans,
/// Insulated Ice Trucks, Gher-to-Arat trips, and fisheries supply chain logistics.
class FishDriverDashboard extends ConsumerStatefulWidget {
  const FishDriverDashboard({super.key});

  @override
  ConsumerState<FishDriverDashboard> createState() => _FishDriverDashboardState();
}

class _FishDriverDashboardState extends ConsumerState<FishDriverDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isOnline = true;
  bool _hasActiveTrip = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBn = LanguageProvider.isBn(context);
    final userProvider = prov.Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;
    final userId = user?.id ?? 'fish_driver_demo';
    final walletBalanceAsync = ref.watch(walletBalanceProvider(userId));
    final walletBalance = walletBalanceAsync.value ?? 18500.0;
    final unreadNotificationCount = ref.watch(unreadDriverNotificationCountProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F9FC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ============================================
            // HEADER - Fish Transport Status & Earnings
            // ============================================
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: const Color(0xFF0277BD),
              elevation: 0,
              actions: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                      onPressed: () => Get.to(() => const DriverNotificationsScreen()),
                    ),
                    if (unreadNotificationCount > 0)
                      Positioned(
                        right: 8,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$unreadNotificationCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.share_location, color: Colors.cyanAccent),
                  tooltip: isBn ? 'লোকেশন শেয়ারিং' : 'Live Share',
                  onPressed: () {
                    Get.snackbar(
                      isBn ? 'লাইভ জিপিএস সক্রিয়' : 'Live GPS Active',
                      isBn ? 'আপনার অক্সিজেন ভ্যানের লোকেশন খামারি ও আড়তদার দেখতে পাচ্ছেন।' : 'Live van location is shared with farmer & buyer.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF01579B),
                      colorText: Colors.white,
                    );
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF01579B), const Color(0xFF002F6C)]
                          : [const Color(0xFF0277BD), const Color(0xFF0091EA)],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Water wave background motif
                      Positioned(
                        right: -40,
                        top: -40,
                        child: CircleAvatar(
                          radius: 90,
                          backgroundColor: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'স্বাগতম, ${user?.name ?? "মৎস্য চালক"}! 🐟🚚',
                                          style: GoogleFonts.hindSiliguri(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'অক্সিজেন ভ্যান ও মাছ পরিবহন স্পেশালিস্ট',
                                          style: GoogleFonts.hindSiliguri(
                                            fontSize: 12,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Online toggle pill
                                  InkWell(
                                    onTap: () {
                                      setState(() => _isOnline = !_isOnline);
                                      Get.snackbar(
                                        _isOnline ? 'অনলাইন' : 'অফলাইন',
                                        _isOnline ? 'আপনি নতুন মাছ পরিবহনের ট্রিপ পাওয়ার জন্য প্রস্তুত।' : 'ট্রিপ রিকোয়েস্ট সাময়িক বন্ধ করা হয়েছে।',
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _isOnline ? Colors.green.shade700 : Colors.grey.shade700,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white38),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _isOnline ? Colors.greenAccent : Colors.redAccent,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _isOnline ? (isBn ? 'অনলাইন' : 'Online') : (isBn ? 'অফলাইন' : 'Offline'),
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              // Earnings and live stats
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isBn ? 'আজকের পরিবহন আয়' : 'Today\'s Haul Earnings',
                                        style: GoogleFonts.hindSiliguri(
                                          fontSize: 11,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        '৳ ${walletBalance.toStringAsFixed(0)}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amberAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        isBn ? 'মাছ ডেলিভারি' : 'Biomass Hauled',
                                        style: GoogleFonts.hindSiliguri(
                                          fontSize: 11,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        '১.৪ টন / ৩৫ মণ',
                                        style: GoogleFonts.hindSiliguri(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        isBn ? 'সারভাইভাল রেট' : 'Fish Survival',
                                        style: GoogleFonts.hindSiliguri(
                                          fontSize: 11,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        '৯৯.৮% ⭐',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.greenAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ============================================
            // BODY CONTENT
            // ============================================
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic Weather & Transport Logistics Advisory
                    const WeatherCardWidget(isFisheriesTheme: true),
                    const SizedBox(height: 16),

                    // ============================================
                    // ACTIVE LIVE FISH TRIP CARD (If Active)
                    // ============================================
                    if (_hasActiveTrip) _buildActiveFishTripCard(context, isDark, isBn),
                    if (_hasActiveTrip) const SizedBox(height: 20),

                    // Quick Stats Grid
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        PremiumStatCard(
                          icon: Icons.local_shipping,
                          color: const Color(0xFF0277BD),
                          label: isBn ? 'নতুন ট্রিপ রিকোয়েস্ট' : 'New Load Requests',
                          value: '৪টি',
                          subtitle: isBn ? 'সিংড়া ও সাতক্ষীরা' : 'Natore & Satkhira',
                          onTap: () => Get.to(() => const FishDriverJobBoardScreen()),
                        ),
                        PremiumStatCard(
                          icon: Icons.alt_route,
                          color: const Color(0xFF00897B),
                          label: isBn ? 'সক্রিয় রুট ও ম্যাপ' : 'Live Delivery Route',
                          value: '১টি চালু',
                          subtitle: isBn ? 'যাত্রাবাড়ী আড়ত রুট' : 'To Jatrabari Arat',
                          onTap: () => Get.to(() => const FishDriverDeliveriesScreen()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ============================================
                    // FISH TRANSPORT POWER HUB & RADAR
                    // ============================================
                    _buildSectionHeader(
                      isBn ? 'মৎস্য পরিবহন পাওয়ার হাব ও টুলস' : 'Fish Logistics Power Hub',
                      isDark,
                      icon: Icons.speed,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF16252F), const Color(0xFF1E3A4C)]
                              : [const Color(0xFFE1F5FE), const Color(0xFFB3E5FC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark ? const Color(0xFF0288D1).withOpacity(0.4) : const Color(0xFF81D4FA),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildPowerToolButton(
                                icon: Icons.calculate_outlined,
                                label: isBn ? 'ভাড়া ক্যালকুলেটর' : 'Fare Calc',
                                subtitle: isBn ? 'অক্সিজেন ও দূরত্ব' : 'O2 & Distance',
                                color: const Color(0xFF0288D1),
                                isDark: isDark,
                                onTap: () => Get.to(() => const SmartAgroFareCalculatorScreen()),
                              ),
                              const SizedBox(width: 10),
                              _buildPowerToolButton(
                                icon: Icons.timer_outlined,
                                label: isBn ? 'লাইভ ট্রিপ মিটার' : 'Trip Meter',
                                subtitle: isBn ? 'কিমি ও গতি ট্র্যাকিং' : 'Km & Speed',
                                color: const Color(0xFF00897B),
                                isDark: isDark,
                                onTap: () => Get.to(() => const DriverTripMeterScreen()),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildPowerToolButton(
                                icon: Icons.local_gas_station_outlined,
                                label: isBn ? 'ডিজেল ও বরফ খরচ' : 'Fuel & Ice',
                                subtitle: isBn ? 'খরচ ও লাভ হিসাব' : 'Expense & Profit',
                                color: const Color(0xFFE65100),
                                isDark: isDark,
                                onTap: () => Get.to(() => const DriverFuelExpenseTrackerScreen()),
                              ),
                              const SizedBox(width: 10),
                              _buildPowerToolButton(
                                icon: Icons.sync_alt,
                                label: isBn ? 'ফিরতি ভ্যান লোড' : 'Return Truck',
                                subtitle: isBn ? 'খালি ফেরা রোধ' : 'Return Sharing',
                                color: const Color(0xFF6A1B9A),
                                isDark: isDark,
                                onTap: () => Get.to(() => const ReturnTruckSharingScreen()),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Global Announcements
                    const GlobalAnnouncementBanner(),
                    const SizedBox(height: 20),

                    // Activity & Monthly Earnings Report Card
                    ReportGenerationCard(
                      userName: user?.name ?? (isBn ? 'মৎস্য পরিবহন চালক' : 'Fish Driver'),
                      userId: userId,
                      userRole: 'fishDriver',
                      amount1Label: isBn ? 'মোট পরিবহন বিল' : 'Total Haul Billings',
                      amount2Label: isBn ? 'ডিজেল, বরফ ও অক্সিজেন' : 'Fuel, Ice & O2',
                      color: const Color(0xFF0277BD),
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions / Telemetry Check
                    _buildSectionHeader(
                      isBn ? 'লাইভ অক্সিজেন ও পানির অবস্থা' : 'Live O2 & Tank Status',
                      isDark,
                      icon: Icons.water_drop,
                    ),
                    const SizedBox(height: 12),
                    _buildTankTelemetryCard(isDark, isBn),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: const Color(0xFF0288D1), size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: GoogleFonts.hindSiliguri(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFishTripCard(BuildContext context, bool isDark, bool isBn) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16252F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0288D1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0288D1).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0288D1).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.airport_shuttle, color: Color(0xFF0288D1), size: 22),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBn ? 'চলমান ট্রিপ #TR-FISH-401' : 'Active Trip #TR-FISH-401',
                        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        isBn ? '৮০০ কেজি জ্যান্ত রুই ও কাতল (অক্সিজেন অন)' : '800 kg Live Fish (Oxygen Active)',
                        style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isBn ? 'পথে রয়েছে' : 'In Transit',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              const Icon(Icons.radio_button_checked, size: 16, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isBn ? 'পিকআপ: সিংড়া বাজার ঘের, নাটোর' : 'Pickup: Singra Gher, Natore',
                  style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isBn ? 'গন্তব্য: যাত্রাবাড়ী মৎস্য আড়ত, ঢাকা' : 'Dropoff: Jatrabari Fish Arat, Dhaka',
                  style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Get.to(() => const FishDriverDeliveriesScreen()),
                  icon: const Icon(Icons.map, size: 16, color: Color(0xFF0288D1)),
                  label: Text(
                    isBn ? 'রুট ও সেন্সর ম্যাপ' : 'Route & Sensor',
                    style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF0288D1)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0288D1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Get.to(() => OrderQrDeliveryScreen(
                        order: OrderModel(
                          id: 'TR-FISH-401',
                          buyerId: 'buyer_01',
                          farmerId: 'farmer_01',
                          farmerName: 'মোঃ আব্দুল কুদ্দুস',
                          productName: 'জ্যান্ত রুই ও কাতলা মাছ',
                          productImageUrl: 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788505454/images_jzjue9.jpg',
                          quantity: 800.0,
                          totalAmount: 8500.0,
                          status: 'in_transit',
                          statusStep: 3,
                          deliveryOtp: '5821',
                          createdAt: DateTime.now(),
                        ),
                      )),
                  icon: const Icon(Icons.qr_code_scanner, size: 16),
                  label: Text(
                    isBn ? 'ডেলিভারি QR স্ক্যান' : 'Scan Delivery QR',
                    style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0277BD),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPowerToolButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2D38) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.hindSiliguri(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 10,
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTankTelemetryCard(bool isDark, bool isBn) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16252F) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTelemetryItem(
            icon: Icons.air,
            label: isBn ? 'অক্সিজেন প্রেসার' : 'O2 Pressure',
            value: '7.8 bar',
            status: isBn ? 'স্বাভাবিক (Safe)' : 'Safe',
            statusColor: Colors.green,
            isDark: isDark,
          ),
          _buildTelemetryItem(
            icon: Icons.thermostat,
            label: isBn ? 'পানির তাপমাত্রা' : 'Water Temp',
            value: '23.5 °C',
            status: isBn ? 'অনুকূল (Optimal)' : 'Optimal',
            statusColor: Colors.cyan,
            isDark: isDark,
          ),
          _buildTelemetryItem(
            icon: Icons.battery_charging_full,
            label: isBn ? 'অ্যারেটর ব্যাটারি' : 'Aerator Battery',
            value: '94%',
            status: isBn ? 'চার্জড' : 'Charged',
            statusColor: Colors.green,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryItem({
    required IconData icon,
    required String label,
    required String value,
    required String status,
    required Color statusColor,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(icon, color: statusColor, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: 10,
            color: isDark ? Colors.white60 : Colors.grey.shade600,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status,
            style: GoogleFonts.hindSiliguri(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }
}
