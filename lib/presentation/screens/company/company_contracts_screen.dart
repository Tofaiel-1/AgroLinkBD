import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import 'package:agrolinkbd/presentation/screens/company/providers/company_provider.dart';

/// Company Contracts Management Screen
/// Manage contract farming agreements with farmers
class CompanyContractsScreen extends StatefulWidget {
  const CompanyContractsScreen({super.key});

  @override
  State<CompanyContractsScreen> createState() => _CompanyContractsScreenState();
}

class _CompanyContractsScreenState extends State<CompanyContractsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CompanyProvider>(
      builder: (context, provider, child) {
        // Filter contracts
        List<CompanyContract> filteredContracts = provider.contracts;
        if (_selectedFilter != 'all') {
          filteredContracts = provider.contracts
              .where((c) => c.status == _selectedFilter)
              .toList();
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          appBar: AppBar(
            backgroundColor: const Color(0xFF4169E1),
            elevation: 0,
            title: Text(
              'চুক্তি ব্যবস্থাপনা',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  // Create new contract
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'চুক্তি অনুসন্ধান করুন...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ),

              // Filter chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('সক্রিয়', 'active'),
                      const SizedBox(width: 8),
                      _buildFilterChip('সমাপ্ত', 'completed'),
                      const SizedBox(width: 8),
                      _buildFilterChip('বাতিল', 'cancelled'),
                      const SizedBox(width: 8),
                      _buildFilterChip('সমস্ত', 'all'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Contracts list
              Expanded(
                child: filteredContracts.isEmpty 
                    ? const Center(child: Text("কোনো চুক্তি পাওয়া যায়নি"))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredContracts.length,
                        itemBuilder: (context, index) {
                          final contract = filteredContracts[index];
                          return _buildContractCard(
                            contractId: contract.id,
                            farmer: contract.farmerName,
                            crop: contract.crop,
                            quantity: contract.quantity,
                            startDate: contract.startDate,
                            endDate: contract.endDate,
                            status: contract.status,
                            progress: contract.progress,
                            onComplete: contract.status == 'active' ? () {
                              provider.completeContract(contract.id);
                            } : null,
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF4169E1),
            onPressed: () {
              // Create new contract
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value) {
    bool isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF4169E1).withOpacity(0.2),
      labelStyle: GoogleFonts.openSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isSelected ? const Color(0xFF4169E1) : const Color(0xFF666666),
      ),
      side: BorderSide(
        color:
            isSelected ? const Color(0xFF4169E1) : Colors.grey.withOpacity(0.2),
      ),
    );
  }

  Widget _buildContractCard({
    required String contractId,
    required String farmer,
    required String crop,
    required String quantity,
    required String startDate,
    required String endDate,
    required String status,
    required int progress,
    VoidCallback? onComplete,
  }) {
    Color statusColor = status == 'active'
        ? const Color(0xFF2ECC71)
        : (status == 'completed'
            ? const Color(0xFF3498DB)
            : const Color(0xFFE74C3C));
    String statusLabel = status == 'active'
        ? 'চলমান'
        : (status == 'completed' ? 'সমাপ্ত' : 'বাতিল');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                contractId,
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.openSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            farmer,
            style: GoogleFonts.openSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.grass,
                size: 16,
                color: Color(0xFF999999),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '$crop - $quantity',
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    color: const Color(0xFF999999),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 6,
              backgroundColor: const Color(0xFFEEEEEE),
              valueColor:
                  AlwaysStoppedAnimation<Color>(statusColor.withOpacity(0.7)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                startDate,
                style: GoogleFonts.openSans(
                  fontSize: 11,
                  color: const Color(0xFFCCCCCC),
                ),
              ),
              Text(
                endDate,
                style: GoogleFonts.openSans(
                  fontSize: 11,
                  color: const Color(0xFFCCCCCC),
                ),
              ),
            ],
          ),
          if (onComplete != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4169E1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('সম্পন্ন করুন', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
