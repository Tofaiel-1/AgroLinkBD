import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FarmProfileScreen extends StatefulWidget {
  const FarmProfileScreen({Key? key}) : super(key: key);

  @override
  State<FarmProfileScreen> createState() => _FarmProfileScreenState();
}

class _FarmProfileScreenState extends State<FarmProfileScreen> {
  bool _isEditing = false;

  final TextEditingController _nameController = TextEditingController(text: 'Green Valley Farm');
  final TextEditingController _locationController = TextEditingController(text: 'Rajshahi, Bangladesh');
  final TextEditingController _areaController = TextEditingController(text: '12.5');
  final TextEditingController _soilController = TextEditingController(text: 'Loamy Soil');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Basic Details', Icons.info_outline),
                  const SizedBox(height: 16),
                  _buildFormCard(),
                  const SizedBox(height: 30),
                  _buildSectionHeader('Quick Statistics', Icons.bar_chart),
                  const SizedBox(height: 16),
                  _buildStatisticsGrid(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _isEditing = !_isEditing;
          });
          if (!_isEditing) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Farm details saved successfully!')),
            );
          }
        },
        backgroundColor: _isEditing ? const Color(0xFF1976D2) : const Color(0xFF4CAF50),
        icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.white),
        label: Text(
          _isEditing ? 'Save Changes' : 'Edit Profile',
          style: GoogleFonts.openSans(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      pinned: true,
      backgroundColor: const Color(0xFF4CAF50),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text(
          'Farm Profile',
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF81C784),
                    Color(0xFF388E3C),
                  ],
                ),
              ),
            ),
            Positioned(
              right: -50,
              top: -50,
              child: Icon(
                Icons.agriculture,
                size: 200,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2E7D32), size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.openSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCBD5E1).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField('Farm Name', _nameController, Icons.landscape),
          const SizedBox(height: 16),
          _buildTextField('Location', _locationController, Icons.location_on),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField('Area (ha)', _areaController, Icons.aspect_ratio),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField('Soil Type', _soilController, Icons.grass),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      style: GoogleFonts.openSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2D3748),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.openSans(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: _isEditing ? const Color(0xFF4CAF50) : Colors.grey.shade400),
        filled: true,
        fillColor: _isEditing ? Colors.white : Colors.grey.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Crops', '4 Active', Icons.grass, const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
        _buildStatCard('Employees', '12 Staff', Icons.people, const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
        _buildStatCard('Est. Yield', '850 Tons', Icons.analytics, const Color(0xFFFFF3E0), const Color(0xFFE65100)),
        _buildStatCard('Last Harvest', '2 Weeks Ago', Icons.history, const Color(0xFFF3E5F5), const Color(0xFF6A1B9A)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCBD5E1).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.openSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.openSans(
              fontSize: 12,
              color: const Color(0xFF718096),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
