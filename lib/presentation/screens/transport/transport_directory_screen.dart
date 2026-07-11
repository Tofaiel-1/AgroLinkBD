import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:agrolinkbd/presentation/widgets/driver_card.dart';
import 'package:agrolinkbd/core/services/location_service.dart';

class TransportDirectoryScreen extends StatefulWidget {
  const TransportDirectoryScreen({Key? key}) : super(key: key);

  @override
  State<TransportDirectoryScreen> createState() => _TransportDirectoryScreenState();
}

class _TransportDirectoryScreenState extends State<TransportDirectoryScreen> {
  final List<String> _vehicleSizes = ['Small', 'Mid', 'Big'];
  String _selectedSize = 'Small';
  
  Position? _currentPosition;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    final locationService = LocationService();
    final position = await locationService.getCurrentPosition();
    
    if (mounted) {
      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color lightBackground = Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          'Transport Directory',
          style: GoogleFonts.hindSiliguri(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Tabs (Vehicle Size)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: _vehicleSizes.map((size) {
                  final isSelected = _selectedSize == size;
                  String displayTitle = '';
                  switch (size) {
                    case 'Small':
                      displayTitle = 'Small Pickup';
                      break;
                    case 'Mid':
                      displayTitle = 'Mid Truck';
                      break;
                    case 'Big':
                      displayTitle = 'Big Truck';
                      break;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        displayTitle,
                        style: GoogleFonts.hindSiliguri(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: primaryGreen,
                      backgroundColor: Colors.grey.shade200,
                      onSelected: (bool selected) {
                        if (selected) {
                          setState(() {
                            _selectedSize = size;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Location Status Banner
          Container(
            width: double.infinity,
            color: Colors.green.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Icon(
                  _isLoadingLocation ? Icons.satellite_alt : Icons.my_location,
                  color: primaryGreen, 
                  size: 20
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isLoadingLocation
                        ? 'Getting your current location...'
                        : (_currentPosition != null
                            ? 'Showing drivers near your location'
                            : 'Location unavailable. Showing all drivers.'),
                    style: GoogleFonts.hindSiliguri(
                      color: primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_isLoadingLocation)
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: primaryGreen),
                  )
              ],
            ),
          ),
          
          const SizedBox(height: 8),

          // Body List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('userType', isEqualTo: 'Driver')
                  .where('vehicleSize', isEqualTo: _selectedSize)
                  // Note: Real app should filter 'isAvailable' == true
                  // .where('isAvailable', isEqualTo: true) 
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !_isLoadingLocation) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryGreen),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}', style: GoogleFonts.hindSiliguri()),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No drivers found in this category',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Process and Sort Drivers by Distance
                final locationService = LocationService();
                
                List<Map<String, dynamic>> driversList = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  data['id'] = doc.id;
                  
                  double? distance;
                  if (_currentPosition != null && data['location'] != null) {
                    final GeoPoint driverLoc = data['location'];
                    distance = locationService.calculateDistance(
                      startLatitude: _currentPosition!.latitude,
                      startLongitude: _currentPosition!.longitude,
                      endLatitude: driverLoc.latitude,
                      endLongitude: driverLoc.longitude,
                    );
                  }
                  data['distanceInKm'] = distance;
                  return data;
                }).toList();

                // Sort: Drivers with distance first, closest to furthest
                driversList.sort((a, b) {
                  final double? distA = a['distanceInKm'];
                  final double? distB = b['distanceInKm'];
                  
                  if (distA == null && distB == null) return 0;
                  if (distA == null) return 1;
                  if (distB == null) return -1;
                  
                  return distA.compareTo(distB);
                });

                return ListView.builder(
                  itemCount: driversList.length,
                  itemBuilder: (context, index) {
                    final data = driversList[index];
                    
                    return DriverCard(
                      driverId: data['id'],
                      name: data['name'] ?? 'Unknown Driver',
                      phone: data['phone'] ?? 'N/A',
                      vehicleType: data['vehicleSize'] == 'Small' ? 'Pickup' : 'Truck',
                      vehicleNumber: data['vehicleNumber'] ?? 'Unknown',
                      capacity: data['capacity'] ?? 'Unknown',
                      profileImageUrl: data['profileImageUrl'],
                      distanceInKm: data['distanceInKm'],
                      perKmRate: (data['perKmRate'] as num?)?.toDouble() ?? 50.0,
                      baseFare: (data['baseFare'] as num?)?.toDouble() ?? 500.0,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
