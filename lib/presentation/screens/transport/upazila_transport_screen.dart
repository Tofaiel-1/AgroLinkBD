import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:agrolinkbd/core/services/transport_data_seeder.dart';

/*
  ========================================================================
  FIRESTORE COMPOSITE INDEX REQUIREMENT:
  ========================================================================
  Since this query uses multiple `.where()` clauses with equality operators,
  you MUST create a Composite Index in your Firebase Console.
  
  Go to Firebase Console -> Firestore Database -> Indexes -> Add Index.
  Collection ID: users
  Fields to index:
    - userType: Arrays/Ascending
    - district: Arrays/Ascending
    - upazila: Arrays/Ascending
    - vehicleSize: Arrays/Ascending
    - isAvailable: Arrays/Ascending
  (All fields ascending). 
  Alternatively, run the app, check the debug console for a Firebase 
  error link, and click the link to automatically create the index.
  ========================================================================
*/

class UpazilaTransportScreen extends StatefulWidget {
  const UpazilaTransportScreen({Key? key}) : super(key: key);

  @override
  State<UpazilaTransportScreen> createState() => _UpazilaTransportScreenState();
}

class _UpazilaTransportScreenState extends State<UpazilaTransportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Hardcoded District -> Upazila map
  final Map<String, List<String>> _locations = {
    'Bogura': ['Shibganj', 'Sherpur', 'Kahaloo', 'Nandigram', 'Sariakandi'],
    'Dhaka': ['Savar', 'Keraniganj', 'Dhamrai', 'Nawabganj', 'Dohar'],
    'Rajshahi': ['Paba', 'Godagari', 'Mohanpur', 'Tanore', 'Bagmara'],
    'Dinajpur': ['Birol', 'Bochaganj', 'Khansama', 'Parbatipur', 'Nawabganj'],
    'Jessore': ['Abhaynagar', 'Bagherpara', 'Chaugachha', 'Jhikargachha', 'Keshabpur'],
  };

  String? _selectedDistrict;
  String? _selectedUpazila;
  
  final List<String> _vehicleSizes = ['Small', 'Mid', 'Big'];
  String _selectedSize = 'Small';
  bool _isSeeding = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Set default selections
    _selectedDistrict = _locations.keys.first;
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
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint('Could not launch $launchUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color accentOrange = Color(0xFFFF9800);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6), // Modern light gray/green bg
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          'Find Local Transport',
          style: GoogleFonts.outfit(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          _isSeeding 
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20, height: 20, 
                  child: CircularProgressIndicator(strokeWidth: 2, color: primaryGreen)
                ),
              )
            : IconButton(
                icon: const Icon(Icons.add_box, color: primaryGreen),
                tooltip: 'Seed Dummy Data',
                onPressed: () async {
                  setState(() => _isSeeding = true);
                  try {
                    await TransportDataSeeder.seedDatabase();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dummy drivers seeded successfully!'),
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
                    if (mounted) {
                      setState(() => _isSeeding = false);
                    }
                  }
                },
              ),
        ],
      ),
      body: Column(
        children: [
          // Top Section: Cascading Dropdowns
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
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Service Area',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // District Dropdown
                    Expanded(
                      child: _buildDropdown(
                        icon: Icons.map,
                        hint: 'District',
                        value: _selectedDistrict,
                        items: _locations.keys.toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedDistrict = val;
                            _selectedUpazila = _locations[val!]!.first; // Auto-select first Upazila
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Upazila Dropdown
                    Expanded(
                      child: _buildDropdown(
                        icon: Icons.location_on,
                        hint: 'Upazila',
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

          // Middle Section: TabBar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
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
              labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'Small (1-2T)'),
                Tab(text: 'Mid (3-5T)'),
                Tab(text: 'Big (6T+)'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),

          // Bottom Section: Firebase Query Results
          Expanded(
            child: _selectedDistrict == null || _selectedUpazila == null
                ? Center(
                    child: Text(
                      'Please select District and Upazila',
                      style: GoogleFonts.outfit(color: Colors.grey.shade600),
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
                          child: Text(
                            'Something went wrong.\nPlease check composite index.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(color: Colors.red),
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
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                    )
                                  ],
                                ),
                                child: Icon(Icons.no_transfer, size: 64, color: Colors.grey.shade400),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No $_selectedSize vehicles found\nin $_selectedUpazila right now.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final drivers = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: drivers.length,
                        itemBuilder: (context, index) {
                          final data = drivers[index].data() as Map<String, dynamic>;
                          
                          return _buildAwesomeDriverCard(data, primaryGreen, accentOrange);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Custom Dropdown Builder
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
                hint: Text(hint, style: GoogleFonts.outfit(fontSize: 14)),
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                style: GoogleFonts.outfit(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Awesome Driver Card UI
  Widget _buildAwesomeDriverCard(Map<String, dynamic> data, Color primary, Color accent) {
    final name = data['name'] ?? 'Driver';
    final vehicleType = data['vehicleType'] ?? 'Tata Ace';
    final capacity = data['capacity'] ?? 'N/A';
    final phone = data['phone'] ?? '';
    final profileImageUrl = data['profileImageUrl'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Driver Avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primary.withOpacity(0.2), width: 2),
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundColor: primary.withOpacity(0.1),
                backgroundImage: profileImageUrl != null && profileImageUrl.toString().isNotEmpty
                    ? NetworkImage(profileImageUrl)
                    : null,
                child: profileImageUrl == null || profileImageUrl.toString().isEmpty
                    ? Icon(Icons.person, size: 32, color: primary)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.local_shipping, size: 12, color: Colors.blue.shade700),
                            const SizedBox(width: 4),
                            Text(
                              vehicleType,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.fitness_center, size: 12, color: accent),
                            const SizedBox(width: 4),
                            Text(
                              '$capacity Cap.',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                    color: primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => _makePhoneCall(phone),
                icon: const Icon(Icons.call, color: Colors.white),
                iconSize: 24,
                splashRadius: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
