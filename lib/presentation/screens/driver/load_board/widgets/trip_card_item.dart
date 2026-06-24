import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/transport_model.dart';
import 'package:agrolinkbd/presentation/screens/driver/load_board/providers/load_board_provider.dart';

class TripCardItem extends StatelessWidget {
  final TransportRequestModel trip;
  final LoadBoardProvider provider;
  final VoidCallback onTap;

  const TripCardItem({
    super.key,
    required this.trip,
    required this.provider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate distances
    final distanceToPickup = provider.calculateDistance(
        trip.pickupLatitude ?? 0, trip.pickupLongitude ?? 0);
    final routeDistance = provider.calculateDistance(
        trip.pickupLatitude ?? 0, trip.pickupLongitude ?? 0); // Approximate
    
    // Truck size logic
    String requiredSize = 'All';
    if (trip.weight <= 1000) requiredSize = '1 Ton Pickup';
    else if (trip.weight <= 5000) requiredSize = '5 Ton Truck';
    else requiredSize = '10+ Ton Truck';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            // Top Section (Price & Distance)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${distanceToPickup.toStringAsFixed(1)} কিমি দূরে',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '৳ ${trip.agreedPrice?.toStringAsFixed(0) ?? 'আলোচনা সাপেক্ষে'}',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF57C00),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_shipping,
                      color: Color(0xFFF57C00),
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Route Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.circle, size: 12, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          trip.pickupLocation,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 5),
                    height: 20,
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.grey, width: 2, style: BorderStyle.solid),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          trip.deliveryLocation,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Footer Section (Cargo details)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${trip.productType} (${trip.weight.toStringAsFixed(0)} কেজি)',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.fire_truck_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        requiredSize,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
