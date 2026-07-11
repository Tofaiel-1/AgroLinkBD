import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:agrolinkbd/core/services/location_service.dart';

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
  
  Position? _currentPosition;
  bool _isLoading = true;
  bool _isSubmitting = false;
  double _estimatedFare = 0.0;

  @override
  void initState() {
    super.initState();
    _estimatedFare = widget.baseFare;
    _fetchCurrentLocation();
    _distanceController.addListener(_calculateFare);
  }

  @override
  void dispose() {
    _dropoffController.dispose();
    _distanceController.dispose();
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
    final locationService = LocationService();
    final position = await locationService.getCurrentPosition();
    
    if (mounted) {
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_currentPosition == null) {
      Get.snackbar('Location Error', 'Unable to fetch your current pickup location.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'demo_farmer';
      final distance = double.tryParse(_distanceController.text) ?? 0.0;

      final bookingData = {
        'farmerId': userId,
        'driverId': widget.driverId,
        'pickupLocation': GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude),
        'dropoffAddress': _dropoffController.text.trim(),
        'totalDistanceKm': distance,
        'estimatedFare': _estimatedFare,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('transport_bookings').add(bookingData);

      Get.back(); // Go back to directory
      Get.snackbar(
        'Booking Successful',
        'Your request has been sent to ${widget.driverName}.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to create booking: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          'Book Transport',
          style: GoogleFonts.hindSiliguri(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Driver Summary Card
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryGreen.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person, color: primaryGreen, size: 30),
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
                                    '${widget.vehicleType} (${widget.capacity})',
                                    style: GoogleFonts.hindSiliguri(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  if (widget.distanceInKm != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '${widget.distanceInKm!.toStringAsFixed(1)} km away from you',
                                      style: GoogleFonts.hindSiliguri(
                                        fontSize: 13,
                                        color: Colors.orange.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Text(
                      'Trip Details',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Pickup Location (Auto-fetched)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.my_location, color: Colors.blue.shade600),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pickup Location',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                Text(
                                  _currentPosition != null
                                      ? 'Current GPS Location Added'
                                      : 'Unable to get location',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Dropoff Address
                    TextFormField(
                      controller: _dropoffController,
                      decoration: InputDecoration(
                        labelText: 'Drop-off Address',
                        hintText: 'Enter full destination address',
                        prefixIcon: const Icon(Icons.location_on, color: Colors.redAccent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a drop-off address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Estimated Distance
                    TextFormField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Estimated Trip Distance (km)',
                        hintText: 'e.g. 15',
                        prefixIcon: const Icon(Icons.route, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter estimated distance';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Fare Breakdown
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fare Estimate',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Base Fare:', style: GoogleFonts.hindSiliguri(color: Colors.black87)),
                              Text('৳${widget.baseFare.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Per km Rate:', style: GoogleFonts.hindSiliguri(color: Colors.black87)),
                              Text('৳${widget.perKmRate.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Estimated:',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '৳${_estimatedFare.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                'Confirm Booking Request',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
