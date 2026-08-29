import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/models/fish_transport_model.dart';
import 'package:agrolinkbd/core/services/fish_auction_service.dart';

class FishTransportScreen extends StatefulWidget {
  const FishTransportScreen({super.key});

  @override
  State<FishTransportScreen> createState() => _FishTransportScreenState();
}

class _FishTransportScreenState extends State<FishTransportScreen> {
  final _pickupLocationController = TextEditingController(text: 'সিংড়া বাজার, চলনবিল, নাটোর');
  final _dropoffLocationController = TextEditingController(text: 'যাত্রাবাড়ী মৎস্য আড়ত, ঢাকা');
  final _weightController = TextEditingController(text: '600');
  final _fishTypeController = TextEditingController(text: 'জ্যান্ত রুই ও কাতলা');
  final _distanceController = TextEditingController(text: '210');

  FishVehicleType _selectedVehicle = FishVehicleType.oxygenPickup;
  DateTime _pickupTime = DateTime.now().add(const Duration(hours: 4));
  bool _isLoading = false;

  @override
  void dispose() {
    _pickupLocationController.dispose();
    _dropoffLocationController.dispose();
    _weightController.dispose();
    _fishTypeController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  double _calculateEstimatedFare() {
    final km = double.tryParse(_distanceController.text) ?? 100.0;
    double baseRate = 2500.0;
    double perKm = 28.0;

    if (_selectedVehicle == FishVehicleType.oxygenPickup) {
      baseRate = 3500.0; // oxygen cylinder & aeration kit included
      perKm = 35.0;
    } else if (_selectedVehicle == FishVehicleType.insulatedIceVan) {
      baseRate = 3000.0;
      perKm = 32.0;
    }

    return baseRate + (km * perKm);
  }

  void _bookTransport() {
    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    final auctionService = Get.isRegistered<FishAuctionService>()
        ? Get.find<FishAuctionService>()
        : Get.put(FishAuctionService());

    final fare = _calculateEstimatedFare();

    final newBooking = FishTransportBookingModel(
      id: 'TR-FISH-${DateTime.now().millisecondsSinceEpoch}',
      userId: user?.id ?? 'farmer_demo',
      userName: user?.name ?? 'মৎস্য খামারি',
      userPhone: user?.phone ?? '01711000000',
      vehicleType: _selectedVehicle,
      pickupLocation: _pickupLocationController.text,
      pickupDistrict: user?.district ?? 'নাটোর',
      dropoffLocation: _dropoffLocationController.text,
      dropoffDistrict: 'ঢাকা',
      fishType: _fishTypeController.text,
      fishWeightKg: double.tryParse(_weightController.text) ?? 500.0,
      isLiveFish: _selectedVehicle == FishVehicleType.oxygenPickup,
      pickupTime: _pickupTime,
      estimatedDistanceKm: double.tryParse(_distanceController.text) ?? 200.0,
      estimatedCost: fare,
      status: FishTransportStatus.driverAssigned,
      driverName: 'মোঃ বাবুল মিয়া (অক্সিজেন স্পেশালিস্ট ড্রাইভার)',
      driverPhone: '01712345678',
      vehicleNumber: 'ঢাকা মেট্রো-ন ১২-৩৪৫৬',
      createdAt: DateTime.now(),
    );

    auctionService.addTransportBooking(newBooking);

    setState(() => _isLoading = false);

    Get.snackbar(
      'পরিবহন বুকিং নিশ্চিত হয়েছে! 🚚',
      'নিকটস্থ অক্সিজেন ফিশ ভ্যান ড্রাইভার অ্যাসাইন করা হয়েছে। ড্রাইভার আপনাকে কল করবেন।',
      backgroundColor: const Color(0xFF006064),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color deepAqua = Color(0xFF006064);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final auctionService = Get.isRegistered<FishAuctionService>()
        ? Get.find<FishAuctionService>()
        : Get.put(FishAuctionService());

    final estFare = _calculateEstimatedFare();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'মাছ পরিবহন ও অক্সিজেন ভ্যান',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: deepAqua,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Advantage Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF006064), Color(0xFF00838F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.airport_shuttle, size: 40, color: Colors.cyanAccent),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'জ্যান্ত মাছ পরিবহনে ৩০-৫০% বেশি দর পান',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'অক্সিজেন সিলিন্ডার ভ্যান ও ইনসুলেটেড আইস ট্রাক দিয়ে মাছ তাজা অবস্থায় আড়তে পৌঁছান।',
                          style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Text(
              'গাড়ির ধরন নির্বাচন করুন',
              style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                _buildVehicleSelectCard(
                  FishVehicleType.oxygenPickup,
                  'লাইভ অক্সিজেন ভ্যান',
                  'জ্যান্ত মাছের জন্য ড্রাম ও সিলিন্ডার',
                  Icons.water,
                ),
                const SizedBox(width: 10),
                _buildVehicleSelectCard(
                  FishVehicleType.insulatedIceVan,
                  'ইনসুলেটেড আইস ভ্যান',
                  'বরফ দিয়ে সংরক্ষিত তাজা মাছ',
                  Icons.ac_unit,
                ),
              ],
            ),

            const SizedBox(height: 20),
            Text(
              'যাত্রার বিবরণ ও ভাড়ার হিসাব',
              style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildInputField('পিকআপ পয়েন্ট (খামারের ঠিকানা)', _pickupLocationController, Icons.location_on),
            const SizedBox(height: 10),
            _buildInputField('গন্তব্য আড়ত বা বাজার', _dropoffLocationController, Icons.flag),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(child: _buildInputField('মাছের বিবরণ', _fishTypeController, Icons.set_meal)),
                const SizedBox(width: 10),
                Expanded(child: _buildInputField('ওজন (কেজি)', _weightController, Icons.scale, isNum: true)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildInputField('আনুমানিক দূরত্ব (কিমি)', _distanceController, Icons.route, isNum: true)),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('আনুমানিক ভাড়া', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.green.shade900)),
                        Text('৳${estFare.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _bookTransport,
                icon: const Icon(Icons.local_shipping, color: Colors.white),
                label: Text(
                  'এখনই ভ্যান বুক করুন',
                  style: GoogleFonts.hindSiliguri(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: deepAqua,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 30),
            Text(
              'সক্রিয় ও পূর্বের বুকিং সমূহ',
              style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Obx(() {
              final bookings = auctionService.transportBookings;
              if (bookings.isEmpty) {
                return Center(
                  child: Text('কোনো বুকিং হিস্ট্রি নেই', style: GoogleFonts.hindSiliguri(color: Colors.grey)),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final b = bookings[index];
                  return Card(
                    color: Theme.of(context).cardColor,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(b.vehicleTypeName, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15, color: deepAqua)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('ড্রাইভার নিযুক্ত', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('${b.fishType} (${b.fishWeightKg.toInt()} কেজি)', style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.w600)),
                          Text('রুট: ${b.pickupLocation} ➔ ${b.dropoffLocation}', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600)),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('ড্রাইভার: ${b.driverName ?? "অ্যাসাইন হচ্ছে"}', style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('ভাড়া: ৳${b.estimatedCost.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSelectCard(FishVehicleType type, String title, String subtitle, IconData icon) {
    final isSelected = _selectedVehicle == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedVehicle = type),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF006064).withOpacity(0.12) : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xFF006064) : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: isSelected ? const Color(0xFF006064) : Colors.grey, size: 28),
              const SizedBox(height: 8),
              Text(title, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(subtitle, style: GoogleFonts.hindSiliguri(fontSize: 10, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, {bool isNum = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          onChanged: (_) => setState(() {}),
          style: GoogleFonts.hindSiliguri(fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF006064)),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }
}
