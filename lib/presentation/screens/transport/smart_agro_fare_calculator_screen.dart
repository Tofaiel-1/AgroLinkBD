import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/services/location_service.dart';
import 'package:agrolinkbd/core/services/road_distance_fare_service.dart';
import 'package:agrolinkbd/presentation/screens/transport/transport_directory_screen.dart';

class SmartAgroFareCalculatorScreen extends StatefulWidget {
  const SmartAgroFareCalculatorScreen({super.key});

  @override
  State<SmartAgroFareCalculatorScreen> createState() => _SmartAgroFareCalculatorScreenState();
}

class _SmartAgroFareCalculatorScreenState extends State<SmartAgroFareCalculatorScreen> {
  final RoadDistanceFareService _fareService = RoadDistanceFareService();
  final LocationService _locationService = LocationService();

  String _pickupDistrict = 'Dhaka';
  String _dropoffDistrict = 'Bogura';
  AgroVehicleType _selectedVehicle = AgroVehicleType.pickupVan;
  bool _isReturnTrip = false;
  bool _isCalculating = false;
  RouteFareEstimate? _estimate;
  String? _detectedGpsName;

  final List<String> _districts = LocationService.bdDistrictMap.keys.toList()..sort();

  @override
  void initState() {
    super.initState();
    _calculateFare();
  }

  Future<void> _detectGpsPickup() async {
    setState(() => _isCalculating = true);
    final res = await _locationService.getCurrentLocationAddress();
    setState(() {
      _pickupDistrict = res.district;
      _detectedGpsName = res.formattedAddress;
    });
    await _calculateFare();
  }

  Future<void> _calculateFare() async {
    setState(() => _isCalculating = true);
    try {
      final est = await _fareService.calculateFareBetweenDistricts(
        pickupDistrict: _pickupDistrict,
        dropoffDistrict: _dropoffDistrict,
        vehicleType: _selectedVehicle,
        isReturnTrip: _isReturnTrip,
      );
      setState(() {
        _estimate = est;
        _isCalculating = false;
      });
    } catch (e) {
      setState(() => _isCalculating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2E7D32);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text(
          'স্মার্ট কৃষি পরিবহন ভাড়া ক্যালকুলেটর 🚛',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17),
        ),
        backgroundColor: primaryGreen,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Free API Guarantee Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: Colors.amberAccent, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '১০০% ফ্রি লাইভ রোড রাউটিং ও দূরত্ব 🛣️',
                          style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          'ওপেনস্ট্রিটম্যাপ ও ওএসআরএম ইঞ্জিন দিয়ে যেকোনো উপজেলার সঠিক সড়ক দূরত্ব ও ফেয়ার হিসাব।',
                          style: GoogleFonts.hindSiliguri(color: Colors.white.withOpacity(0.9), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Route Selector Card
            Card(
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('যাত্রার রুট নির্ধারণ', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15)),
                        TextButton.icon(
                          onPressed: _detectGpsPickup,
                          icon: const Icon(Icons.my_location, size: 16, color: primaryGreen),
                          label: Text('জিপিএস লোকেশন', style: GoogleFonts.hindSiliguri(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                    if (_detectedGpsName != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text('📍 সনাক্তকৃত অবস্থান: $_detectedGpsName', style: GoogleFonts.hindSiliguri(color: Colors.green.shade800, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    
                    // Pickup District
                    DropdownButtonFormField<String>(
                      value: _pickupDistrict,
                      decoration: InputDecoration(
                        labelText: 'লোডিং পয়েন্ট (উৎপাদনস্থল/মোকাম)',
                        prefixIcon: const Icon(Icons.trip_origin, color: Colors.green),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _districts.map((d) {
                        final bn = LocationService.bdDistrictMap[d]?['nameBn'] ?? d;
                        return DropdownMenuItem(value: d, child: Text('$bn ($d)', style: GoogleFonts.hindSiliguri(fontSize: 13)));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _pickupDistrict = val);
                          _calculateFare();
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Dropoff District
                    DropdownButtonFormField<String>(
                      value: _dropoffDistrict,
                      decoration: InputDecoration(
                        labelText: 'আনলোডিং পয়েন্ট (গন্তব্য/বাজার)',
                        prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _districts.map((d) {
                        final bn = LocationService.bdDistrictMap[d]?['nameBn'] ?? d;
                        return DropdownMenuItem(value: d, child: Text('$bn ($d)', style: GoogleFonts.hindSiliguri(fontSize: 13)));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _dropoffDistrict = val);
                          _calculateFare();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Vehicle Category Selector
            Card(
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('গাড়ির ধরণ ও ক্ষমতা নির্বাচন করুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<AgroVehicleType>(
                      value: _selectedVehicle,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.local_shipping, color: primaryGreen),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: RoadDistanceFareService.vehicleRates.entries.map((e) {
                        return DropdownMenuItem(
                          value: e.key,
                          child: Text('${e.value['nameBn']} • ${e.value['capacity']}', style: GoogleFonts.hindSiliguri(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedVehicle = val);
                          _calculateFare();
                        }
                      },
                    ),
                    const SizedBox(height: 10),

                    // Backhaul return trip toggle
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('ফিরতি খালি গাড়ির ট্রিপ (Backhaul)', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('গাড়ি আনলোড শেষে খালি ফেরার পথে ৪০% পর্যন্ত ডিসকাউন্ট', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
                      value: _isReturnTrip,
                      activeColor: Colors.orange.shade700,
                      onChanged: (val) {
                        setState(() => _isReturnTrip = val);
                        _calculateFare();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Fare Result Breakdown Card
            if (_isCalculating)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (_estimate != null) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _isReturnTrip ? Colors.orange : primaryGreen, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
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
                        Text('প্রাক্কলিত সড়ক দূরত্ব ও সময়', style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade600)),
                        if (_estimate!.isRoadRoutingOnline)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Live OSRM 🌐', style: GoogleFonts.poppins(fontSize: 10, color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.straighten, color: primaryGreen, size: 22),
                        const SizedBox(width: 6),
                        Text('${_estimate!.distanceKm} কিমি', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(width: 16),
                        const Icon(Icons.timer_outlined, color: Colors.orange, size: 22),
                        const SizedBox(width: 6),
                        Text(_estimate!.estimatedTimeText, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const Divider(height: 24),

                    // Fare Breakdown
                    _buildFareRow('মূল ভাড়া (Base Fare)', '৳${_estimate!.baseFare.toInt()}'),
                    _buildFareRow('দূরত্ব ভাড়া (${_estimate!.distanceKm} কিমি)', '৳${_estimate!.distanceFare.toInt()}'),
                    if (_estimate!.tollFee > 0)
                      _buildFareRow('সেতু ও হাইওয়ে টোল ফি', '৳${_estimate!.tollFee.toInt()}', isToll: true),
                    if (_estimate!.applicableTolls.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 4),
                        child: Text('টোল: ${_estimate!.applicableTolls.join(", ")}', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
                      ),
                    if (_isReturnTrip)
                      _buildFareRow('ফিরতি ট্রিপ ডিসকাউন্ট (-৪০%)', '- ৳${((_estimate!.baseFare + _estimate!.distanceFare + _estimate!.tollFee) - _estimate!.totalFare).toInt()}', isDiscount: true),

                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('সর্বমোট প্রস্তাবিত ভাড়া:', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          '৳${_estimate!.totalFare.toInt()}',
                          style: GoogleFonts.hindSiliguri(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: _isReturnTrip ? Colors.orange.shade800 : primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Get.to(() => const TransportDirectoryScreen());
                            },
                            icon: const Icon(Icons.phone_in_talk, color: Colors.white, size: 18),
                            label: Text('ড্রাইভার খুঁজুন ও কল দিন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFareRow(String title, String amount, {bool isToll = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.hindSiliguri(fontSize: 13, color: isDiscount ? Colors.orange.shade800 : (isToll ? Colors.blue.shade800 : Colors.black87))),
          Text(amount, style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.bold, color: isDiscount ? Colors.orange.shade800 : (isToll ? Colors.blue.shade800 : Colors.black87))),
        ],
      ),
    );
  }
}
