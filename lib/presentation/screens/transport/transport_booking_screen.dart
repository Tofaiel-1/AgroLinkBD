import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:agrolinkbd/core/services/location_service.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';

class TransportBookingScreen extends StatefulWidget {
  final String driverId;
  final String driverName;
  final String vehicleType;
  final String capacity;
  final double? distanceInKm;
  final double perKmRate;
  final double baseFare;

  const TransportBookingScreen({
    Key? key,
    required this.driverId,
    required this.driverName,
    required this.vehicleType,
    required this.capacity,
    this.distanceInKm,
    required this.perKmRate,
    required this.baseFare,
  }) : super(key: key);

  @override
  State<TransportBookingScreen> createState() => _TransportBookingScreenState();
}

class _TransportBookingScreenState extends State<TransportBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dropoffController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _goodsDescController = TextEditingController();

  Position? _currentPosition;
  bool _isLoadingLocation = true;
  bool _isSubmitting = false;
  bool _locationError = false;
  double _estimatedFare = 0.0;
  String _locationDisplayText = 'GPS লোকেশন নেওয়া হচ্ছে...';

  @override
  void initState() {
    super.initState();
    _estimatedFare = widget.baseFare;

    if (widget.distanceInKm != null) {
      _distanceController.text = widget.distanceInKm!.toStringAsFixed(1);
      _calculateFare();
    }

    _distanceController.addListener(_calculateFare);
    _fetchCurrentLocation();
  }

  @override
  void dispose() {
    _dropoffController.dispose();
    _distanceController.dispose();
    _goodsDescController.dispose();
    super.dispose();
  }

  void _calculateFare() {
    final distanceText = _distanceController.text;
    if (distanceText.isNotEmpty) {
      final distance = double.tryParse(distanceText);
      if (distance != null && distance > 0) {
        setState(() {
          _estimatedFare = widget.baseFare + (distance * widget.perKmRate);
        });
        return;
      }
    }
    setState(() {
      _estimatedFare = widget.baseFare;
    });
  }

  Future<void> _fetchCurrentLocation() async {
    final bool isBn = LanguageProvider.isBn(context);
    setState(() {
      _isLoadingLocation = true;
      _locationError = false;
      _locationDisplayText = isBn ? 'GPS লোকেশন ও রুট হিসাব করা হচ্ছে...' : 'Fetching GPS & route...';
    });

    final locationService = LocationService();
    final position = await locationService.getCurrentPosition();

    if (mounted) {
      if (position != null) {
        final addressRes = await locationService.resolveAddressFromCoordinates(position.latitude, position.longitude);

        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false;
          _locationError = false;
          _locationDisplayText = '📍 ${addressRes.formattedAddress}\n(${position.latitude.toStringAsFixed(4)}°N, ${position.longitude.toStringAsFixed(4)}°E)';

          if (_distanceController.text.isEmpty) {
            _distanceController.text = '15.0'; // Smart default local trip
            _calculateFare();
          }
        });
      } else {
        setState(() {
          _isLoadingLocation = false;
          _locationError = true;
          _locationDisplayText = isBn ? 'GPS লোকেশন পাওয়া যায়নি (ম্যানুয়ালি ঠিকানা দিন)' : 'GPS unavailable (enter address manually)';
        });
      }
    }
  }

  Future<void> _submitBooking(bool isBn) async {
    if (!_formKey.currentState!.validate()) return;

    if (_currentPosition == null && _locationError) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(isBn ? 'GPS ছাড়া বুকিং' : 'Booking Without GPS', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
          content: Text(
            isBn ? 'আপনার GPS লোকেশন পাওয়া যায়নি। তবুও বুকিং করতে চান?' : 'Your GPS location was not found. Do you still want to proceed?',
            style: GoogleFonts.hindSiliguri(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(isBn ? 'না' : 'No', style: GoogleFonts.hindSiliguri()),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
              child: Text(isBn ? 'হ্যাঁ, বুক করুন' : 'Yes, Book', style: GoogleFonts.hindSiliguri(color: Colors.white)),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'demo_farmer';
      final distance = double.tryParse(_distanceController.text) ?? 0.0;

      final bookingData = {
        'farmerId': userId,
        'driverId': widget.driverId,
        'driverName': widget.driverName,
        'vehicleType': widget.vehicleType,
        'capacity': widget.capacity,
        if (_currentPosition != null)
          'pickupLocation': GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude),
        'pickupLocationText': _locationDisplayText,
        'dropoffAddress': _dropoffController.text.trim(),
        'goodsDescription': _goodsDescController.text.trim(),
        'totalDistanceKm': distance,
        'baseFare': widget.baseFare,
        'perKmRate': widget.perKmRate,
        'estimatedFare': _estimatedFare,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      };

      final docRef = await FirebaseFirestore.instance
          .collection('transport_bookings')
          .add(bookingData);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.driverId)
          .collection('notifications')
          .add({
        'type': 'booking_request',
        'bookingId': docRef.id,
        'farmerName': isBn ? 'কৃষক' : 'Farmer',
        'message': '${isBn ? 'নতুন ট্রিপ রিকোয়েস্ট' : 'New Trip Request'}: ${_dropoffController.text.trim()}',
        'estimatedFare': _estimatedFare,
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Get.back();
        Get.snackbar(
          isBn ? '✅ বুকিং সফল!' : '✅ Booking Placed!',
          isBn ? '${widget.driverName} এর কাছে আপনার অনুরোধ পাঠানো হয়েছে।' : 'Your request has been sent to ${widget.driverName}.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          isBn ? 'ত্রুটি' : 'Error',
          '${isBn ? 'বুকিং করতে সমস্যা হয়েছে:' : 'Failed to book transport:'} $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);
    final bool isBn = LanguageProvider.isBn(context);

    final destinationSuggestions = isBn
        ? [
            'ঢাকা কাওরান বাজার',
            'চট্টগ্রাম খাতুনগঞ্জ',
            'রাজশাহী সাহেব বাজার',
            'বগুড়া সাতমাথা',
            'সিলেট বন্দর বাজার',
            'নাটোর বড় হাট',
            'যশোর বেনাপোল',
            'কুমিল্লা মনোহরপুর',
          ]
        : [
            'Dhaka Karwan Bazar',
            'Chittagong Khatunganj',
            'Rajshahi Shaheb Bazar',
            'Bogra Satmatha',
            'Sylhet Bandar Bazar',
            'Natore Boro Haat',
            'Jashore Benapole',
            'Cumilla Manoharpur',
          ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          isBn ? 'ট্রিপ বুক করুন 🚛' : 'Book Transport 🚛',
          style: GoogleFonts.hindSiliguri(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Driver Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryGreen.withValues(alpha: 0.08), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryGreen.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: primaryGreen.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: primaryGreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_shipping, color: primaryGreen, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.driverName,
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.vehicleType} • ${widget.capacity}',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _infoChip(
                                isBn ? 'বেস ৳${widget.baseFare.toStringAsFixed(0)}' : 'Base ৳${widget.baseFare.toStringAsFixed(0)}',
                                Colors.green.shade700,
                              ),
                              const SizedBox(width: 6),
                              _infoChip(
                                isBn ? '৳${widget.perKmRate.toStringAsFixed(0)}/কিমি' : '৳${widget.perKmRate.toStringAsFixed(0)}/km',
                                Colors.orange.shade700,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _sectionTitle(isBn ? 'ট্রিপ বিবরণ' : 'Trip Details'),
              const SizedBox(height: 12),

              // GPS Pickup Location Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _locationError
                        ? Colors.orange.shade300
                        : (_currentPosition != null ? Colors.green.shade300 : Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _locationError
                            ? Colors.orange.shade50
                            : Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isLoadingLocation
                            ? Icons.location_searching
                            : (_locationError ? Icons.location_off : Icons.my_location),
                        color: _locationError ? Colors.orange : Colors.blue.shade600,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBn ? 'পিকআপ লোকেশন (আপনার অবস্থান)' : 'Pickup Location (Your Position)',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          _isLoadingLocation
                              ? Row(
                                  children: [
                                    SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.blue.shade600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isBn ? 'GPS খুঁজছে...' : 'Locating GPS...',
                                      style: GoogleFonts.hindSiliguri(fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                )
                              : Text(
                                  _locationDisplayText,
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _locationError ? Colors.orange.shade700 : Colors.black87,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    if (!_isLoadingLocation)
                      IconButton(
                        onPressed: _fetchCurrentLocation,
                        icon: const Icon(Icons.refresh, color: Color(0xFF2E7D32)),
                        tooltip: isBn ? 'আবার চেষ্টা করুন' : 'Retry GPS',
                        iconSize: 20,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Dropoff Address with suggestions
              TextFormField(
                controller: _dropoffController,
                decoration: InputDecoration(
                  labelText: isBn ? 'গন্তব্য ঠিকানা *' : 'Destination Address *',
                  hintText: isBn ? 'যেমন: ঢাকা কাওরান বাজার' : 'e.g., Karwan Bazar, Dhaka',
                  prefixIcon: const Icon(Icons.location_on, color: Colors.redAccent),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: GoogleFonts.hindSiliguri(),
                  hintStyle: GoogleFonts.hindSiliguri(color: Colors.grey.shade400),
                ),
                style: GoogleFonts.hindSiliguri(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return isBn ? 'গন্তব্য ঠিকানা দিন' : 'Enter destination address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Quick destination suggestions
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: destinationSuggestions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    return GestureDetector(
                      onTap: () => _dropoffController.text = destinationSuggestions[i],
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          destinationSuggestions[i],
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 12,
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // Distance Field
              TextFormField(
                controller: _distanceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: isBn ? 'আনুমানিক দূরত্ব (কিলোমিটার) *' : 'Approximate Distance (km) *',
                  hintText: isBn ? 'যেমন: ১৫' : 'e.g., 15',
                  prefixIcon: const Icon(Icons.route, color: Colors.grey),
                  suffixText: isBn ? 'কিমি' : 'km',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: GoogleFonts.hindSiliguri(),
                  hintStyle: GoogleFonts.hindSiliguri(color: Colors.grey.shade400),
                  helperText: isBn ? 'দূরত্ব দিলে ভাড়া স্বয়ংক্রিয়ভাবে হিসাব হবে' : 'Fare will auto-calculate based on km',
                  helperStyle: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade500),
                ),
                style: GoogleFonts.hindSiliguri(),
                validator: (value) {
                  if (value == null || value.isEmpty) return isBn ? 'দূরত্ব দিন' : 'Enter distance';
                  if (double.tryParse(value) == null) return isBn ? 'সঠিক সংখ্যা দিন' : 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Goods Description
              TextFormField(
                controller: _goodsDescController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: isBn ? 'মালামালের বিবরণ' : 'Goods / Cargo Description',
                  hintText: isBn ? 'যেমন: ৫০০ কেজি ধান, ২০০ কেজি আলু' : 'e.g., 500 kg rice, 200 kg potato',
                  prefixIcon: const Icon(Icons.inventory_2, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: GoogleFonts.hindSiliguri(),
                  hintStyle: GoogleFonts.hindSiliguri(color: Colors.grey.shade400),
                ),
                style: GoogleFonts.hindSiliguri(),
              ),
              const SizedBox(height: 20),

              // Fare Breakdown Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade50, Colors.green.shade100.withValues(alpha: 0.5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.receipt_long, color: Color(0xFF2E7D32), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isBn ? 'ভাড়ার হিসাব' : 'Fare Breakdown',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _fareRow(
                      isBn ? 'বেস ভাড়া:' : 'Base Fare:',
                      '৳${widget.baseFare.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 8),
                    _fareRow(
                      isBn ? 'দূরত্ব খরচ:' : 'Distance Cost:',
                      _distanceController.text.isNotEmpty && double.tryParse(_distanceController.text) != null
                          ? '${_distanceController.text} ${isBn ? 'কিমি' : 'km'} × ৳${widget.perKmRate.toStringAsFixed(0)} = ৳${(double.tryParse(_distanceController.text)! * widget.perKmRate).toStringAsFixed(0)}'
                          : (isBn ? 'দূরত্ব দিন' : 'Enter distance'),
                    ),
                    const SizedBox(height: 8),
                    _fareRow(
                      isBn ? 'প্ল্যাটফর্ম প্রটেকশন ফি (৫%):' : 'Platform Protection (5%):',
                      '৳${(_estimatedFare * 0.05).toStringAsFixed(0)}',
                    ),
                    const Divider(height: 20, color: Colors.green),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isBn ? 'মোট প্রদেয় ভাড়া:' : 'Total Payable Fare:',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '৳${_estimatedFare.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isBn ? 'চালক নেট আয় পাবেন (৯৫%):' : 'Driver Net Payout (95%):',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '৳${(_estimatedFare * 0.95).toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.security, size: 14, color: Color(0xFF1976D2)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              isBn
                                  ? '🔒 ভাড়া এস্ক্রোতে সুরক্ষিত থাকবে এবং গন্তব্যে পৌঁছার পর ওটিপি দিলে চালকের ওয়ালেটে জমা হবে।'
                                  : '🔒 Fare is safely held in escrow and released to the driver upon delivery OTP confirmation.',
                              style: GoogleFonts.hindSiliguri(fontSize: 10, color: const Color(0xFF0D47A1)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : () => _submitBooking(isBn),
                  icon: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    _isSubmitting
                        ? (isBn ? 'পাঠানো হচ্ছে...' : 'Sending Request...')
                        : (isBn ? 'বুকিং নিশ্চিত করুন' : 'Confirm Transport Booking'),
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 3,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Note
              Center(
                child: Text(
                  isBn 
                      ? '📞 বুকিং নিশ্চিত হলে চালক আপনাকে ফোন করবেন'
                      : '📞 Driver will contact you upon booking confirmation',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.hindSiliguri(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _infoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.hindSiliguri(fontSize: 11, color: color, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _fareRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.hindSiliguri(color: Colors.black87, fontSize: 14)),
        Text(
          value,
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }
}
