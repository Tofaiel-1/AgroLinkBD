import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/services/transport_data_seeder.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/presentation/screens/transport/transport_booking_screen.dart';

class UpazilaTransportScreen extends StatefulWidget {
  const UpazilaTransportScreen({Key? key}) : super(key: key);

  @override
  State<UpazilaTransportScreen> createState() => _UpazilaTransportScreenState();
}

class _UpazilaTransportScreenState extends State<UpazilaTransportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Use seeder's comprehensive location map
  final Map<String, List<String>> _locations = TransportDataSeeder.locations;

  String? _selectedDistrict;
  String? _selectedUpazila;

  final List<String> _vehicleSizes = ['Small', 'Mid', 'Big'];
  String _selectedSize = 'Small';
  bool _isSeeding = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Default to Natore
    _selectedDistrict = _locations.containsKey('Natore') ? 'Natore' : _locations.keys.first;
    _selectedUpazila = _locations[_selectedDistrict!]!.first;

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedSize = _vehicleSizes[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color accentOrange = Color(0xFFFF9800);
    final bool isBn = LanguageProvider.isBn(context);

    final Map<String, String> sizeLabels = {
      'Small': isBn ? 'ছোট (১-২ টন)' : 'Small (1-2 Ton)',
      'Mid': isBn ? 'মাঝারি (৩-৫ টন)' : 'Mid (3-5 Ton)',
      'Big': isBn ? 'বড় (৬+ টন)' : 'Big (6+ Ton)',
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          isBn ? 'পরিবহন খুঁজুন 🚛' : 'Find Transport 🚛',
          style: GoogleFonts.hindSiliguri(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          _isSeeding
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: primaryGreen),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh, color: primaryGreen),
                  tooltip: isBn ? 'ডেটা রিফ্রেশ করুন' : 'Refresh Data',
                  onPressed: () async {
                    setState(() => _isSeeding = true);
                    try {
                      await TransportDataSeeder.seedDatabase();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isBn ? 'ড্রাইভার তথ্য আপডেট হয়েছে!' : 'Driver data updated!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isSeeding = false);
                    }
                  },
                ),
        ],
      ),
      body: Column(
        children: [
          // Top: Location Selection
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF2E7D32), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      isBn ? 'এলাকা নির্বাচন করুন' : 'Select Location',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        icon: Icons.map,
                        hint: isBn ? 'জেলা' : 'District',
                        value: _selectedDistrict,
                        items: _locations.keys.toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedDistrict = val;
                            _selectedUpazila = _locations[val!]!.first;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown(
                        icon: Icons.location_on,
                        hint: isBn ? 'উপজেলা' : 'Upazila',
                        value: _selectedUpazila,
                        items: _selectedDistrict != null ? _locations[_selectedDistrict!]! : [],
                        onChanged: (val) {
                          setState(() {
                            _selectedUpazila = val;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Vehicle Size Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w500, fontSize: 13),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(text: isBn ? 'ছোট ১-২টন' : 'Small 1-2 Ton'),
                Tab(text: isBn ? 'মাঝারি ৩-৫টন' : 'Mid 3-5 Ton'),
                Tab(text: isBn ? 'বড় ৬+টন' : 'Big 6+ Ton'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Driver List
          Expanded(
            child: _selectedDistrict == null || _selectedUpazila == null
                ? Center(
                    child: Text(
                      isBn ? 'জেলা ও উপজেলা নির্বাচন করুন' : 'Select District & Upazila',
                      style: GoogleFonts.hindSiliguri(color: Colors.grey.shade600, fontSize: 16),
                    ),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('userType', isEqualTo: 'Driver')
                        .where('district', isEqualTo: _selectedDistrict)
                        .where('upazila', isEqualTo: _selectedUpazila)
                        .where('vehicleSize', isEqualTo: _selectedSize)
                        .where('isAvailable', isEqualTo: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: primaryGreen),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  isBn 
                                      ? 'ডেটা লোড হয়নি।\nFirestore Index তৈরি করুন।'
                                      : 'Failed to load data.\nPlease build Firestore Index.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.hindSiliguri(color: Colors.red, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                    )
                                  ],
                                ),
                                child: Icon(Icons.no_transfer, size: 64, color: Colors.grey.shade400),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isBn 
                                    ? '$_selectedUpazila-তে\n${sizeLabels[_selectedSize]} গাড়ি পাওয়া যায়নি'
                                    : 'No ${sizeLabels[_selectedSize]} vehicles found in $_selectedUpazila',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: () async {
                                  setState(() => _isSeeding = true);
                                  await TransportDataSeeder.seedDatabase();
                                  if (mounted) setState(() => _isSeeding = false);
                                },
                                icon: const Icon(Icons.refresh, color: Color(0xFF2E7D32)),
                                label: Text(
                                  isBn ? 'ড্রাইভার যোগ করুন (Demo)' : 'Seed Drivers (Demo)',
                                  style: GoogleFonts.hindSiliguri(color: const Color(0xFF2E7D32)),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final drivers = snapshot.data!.docs;

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Text(
                                  isBn ? '${drivers.length} জন ড্রাইভার পাওয়া গেছে' : '${drivers.length} driver(s) found',
                                  style: GoogleFonts.hindSiliguri(
                                    color: primaryGreen,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: drivers.length,
                              itemBuilder: (context, index) {
                                final data = drivers[index].data() as Map<String, dynamic>;
                                return _buildDriverCard(data, primaryGreen, accentOrange, isBn);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required IconData icon,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value,
                hint: Text(hint, style: GoogleFonts.hindSiliguri(fontSize: 14)),
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                style: GoogleFonts.hindSiliguri(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(value: item, child: Text(item));
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(Map<String, dynamic> data, Color primary, Color accent, bool isBn) {
    final String driverId = data['uid'] ?? '';
    final String name = data['name'] ?? (isBn ? 'ড্রাইভার' : 'Driver');
    final String vehicleType = data['vehicleType'] ?? 'Tata Ace';
    final String capacity = data['capacity'] ?? 'N/A';
    final String phone = data['phone'] ?? '';
    final String? profileImageUrl = data['profileImageUrl'];
    final double baseFare = (data['baseFare'] ?? 300.0).toDouble();
    final double perKmRate = (data['perKmRate'] ?? 40.0).toDouble();
    final double rating = (data['rating'] ?? 4.5).toDouble();
    final int totalTrips = (data['totalTrips'] ?? 0).toInt();
    final String vehicleNumber = data['vehicleNumber'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Row 1: Avatar + Info + Call
            Row(
              children: [
                // Driver Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primary.withValues(alpha: 0.2), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: primary.withValues(alpha: 0.1),
                    backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : null,
                    child: profileImageUrl == null || profileImageUrl.isEmpty
                        ? Icon(Icons.person, size: 30, color: primary)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),

                // Name + Vehicle + Rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _chip(Icons.local_shipping, vehicleType, Colors.blue.shade700, Colors.blue.shade50),
                          const SizedBox(width: 6),
                          _chip(Icons.fitness_center, capacity, accent, accent.withValues(alpha: 0.1)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                          const SizedBox(width: 3),
                          Text(
                            isBn 
                                ? '${rating.toStringAsFixed(1)} • $totalTrips ট্রিপ'
                                : '${rating.toStringAsFixed(1)} • $totalTrips Trips',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (vehicleNumber.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              vehicleNumber,
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Call Button
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, const Color(0xFF43A047)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => _makePhoneCall(phone),
                    icon: const Icon(Icons.call, color: Colors.white),
                    iconSize: 22,
                    tooltip: isBn ? 'কল করুন' : 'Call Driver',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Row 2: Fare Info + Book Now Button
            Row(
              children: [
                // Fare info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBn ? 'ভাড়ার হার' : 'Fare Rate',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _fareChip(
                            isBn ? 'বেস ভাড়া ৳${baseFare.toStringAsFixed(0)}' : 'Base ৳${baseFare.toStringAsFixed(0)}',
                            Colors.green.shade700,
                          ),
                          const SizedBox(width: 8),
                          _fareChip(
                            isBn ? '৳${perKmRate.toStringAsFixed(0)}/কিমি' : '৳${perKmRate.toStringAsFixed(0)}/km',
                            Colors.orange.shade700,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Book Now Button
                ElevatedButton.icon(
                  onPressed: () {
                    Get.to(() => TransportBookingScreen(
                      driverId: driverId,
                      driverName: name,
                      vehicleType: vehicleType,
                      capacity: capacity,
                      perKmRate: perKmRate,
                      baseFare: baseFare,
                    ));
                  },
                  icon: const Icon(Icons.bookmark_add, size: 18),
                  label: Text(
                    isBn ? 'বুক করুন' : 'Book Now',
                    style: GoogleFonts.hindSiliguri(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: GoogleFonts.hindSiliguri(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fareChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.hindSiliguri(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
