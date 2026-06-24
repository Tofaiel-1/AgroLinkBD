import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/presentation/screens/driver/load_board/providers/load_board_provider.dart';
import 'package:agrolinkbd/presentation/screens/driver/load_board/widgets/trip_card_item.dart';

class LoadBoardScreen extends StatelessWidget {
  const LoadBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoadBoardProvider(),
      child: const _LoadBoardContent(),
    );
  }
}

class _LoadBoardContent extends StatelessWidget {
  const _LoadBoardContent();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoadBoardProvider>(context);
    final trips = provider.filteredTrips;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF57C00),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'কাজের তালিকা (Load Board)',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.my_location, size: 12, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  'বর্তমান অবস্থান: ${provider.currentLocationName}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              _showFilterBottomSheet(context, provider);
            },
          ),
        ],
      ),
      body: trips.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'আপনার আশেপাশে কোনো ট্রিপ নেই',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return TripCardItem(
                  trip: trip,
                  provider: provider,
                  onTap: () {
                    // Navigate to details / Accept job
                    _showJobAcceptanceDialog(context, trip);
                  },
                );
              },
            ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, LoadBoardProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String selectedTruckSize = 'All'; // Should come from provider in real app
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ট্রিপ ফিল্টার করুন',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'ট্রাকের সাইজ',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: 'All',
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                items: ['All', '1 Ton Pickup', '5 Ton Truck', '10+ Ton Truck']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  selectedTruckSize = val ?? 'All';
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF57C00),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    provider.updateFilters(truckSize: selectedTruckSize);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'প্রয়োগ করুন',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showJobAcceptanceDialog(BuildContext context, dynamic trip) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('কাজ গ্রহণ করুন'),
        content: Text('আপনি কি ${trip.pickupLocation} থেকে ${trip.deliveryLocation} এর ট্রিপটি গ্রহণ করতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('কাজটি সফলভাবে গ্রহণ করা হয়েছে!')),
              );
            },
            child: const Text('হ্যাঁ, গ্রহণ করুন', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
