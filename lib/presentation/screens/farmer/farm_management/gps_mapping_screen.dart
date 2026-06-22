import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GpsMappingScreen extends StatelessWidget {
  const GpsMappingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        title: Text(
          'GPS Mapping',
          style: GoogleFonts.openSans(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          // Mock Map Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://maps.googleapis.com/maps/api/staticmap?center=24.3636,88.6241&zoom=15&size=800x800&maptype=satellite&key=YOUR_API_KEY'), // Placeholder URL, won't load without key
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.map, size: 64, color: Colors.blue),
                    const SizedBox(height: 16),
                    Text(
                      'Interactive Map View',
                      style: GoogleFonts.openSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '(Requires Google Maps API Key)',
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Farm Zones',
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildZoneInfo('Zone A (Paddy)', '10 ha', Colors.green),
                  const SizedBox(height: 8),
                  _buildZoneInfo('Zone B (Tomato)', '2.5 ha', Colors.redAccent),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF2196F3),
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  Widget _buildZoneInfo(String name, String area, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: GoogleFonts.openSans(
              fontSize: 14,
              color: const Color(0xFF2D3748),
            ),
          ),
        ),
        Text(
          area,
          style: GoogleFonts.openSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }
}
