import 'package:flutter/material.dart';

/// KYC Verification Management Screen
/// Features: Document review, verification workflow, AI validation hints
class AdminKYCVerificationScreen extends StatefulWidget {
  const AdminKYCVerificationScreen({super.key});

  @override
  State<AdminKYCVerificationScreen> createState() =>
      _AdminKYCVerificationScreenState();
}

class _AdminKYCVerificationScreenState
    extends State<AdminKYCVerificationScreen> {
  int _selectedPriority = 0; // 0: All, 1: High, 2: Medium, 3: Low
  String _searchQuery = '';

  final mockPendingKYC = [
    {
      'id': 'KYC-001',
      'name': 'Ahmad Khan',
      'role': 'Farmer',
      'waitingTime': '2 hours',
      'documentsUploaded': '3/3',
      'priority': 'High',
      'rating': 4.5,
    },
    {
      'id': 'KYC-002',
      'name': 'Fatima Ali',
      'role': 'Buyer',
      'waitingTime': '4 hours',
      'documentsUploaded': '2/3',
      'priority': 'High',
      'rating': 4.2,
    },
    {
      'id': 'KYC-003',
      'name': 'Hassan Ahmed',
      'role': 'Seller',
      'waitingTime': '30 minutes',
      'documentsUploaded': '3/3',
      'priority': 'Medium',
      'rating': 3.8,
    },
  ];

  final mockStats = {
    'todayPending': 23,
    'avgVerificationTime': '2.4 hours',
    'approvalRate': '87%',
  };

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('KYC Verification'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats row
              _buildStatsRow(),
              const SizedBox(height: 24),

              // Search and filters
              _buildSearchAndFilters(),
              const SizedBox(height: 24),

              if (!isMobile)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildPendingKYCList(),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: _buildDocumentViewer(),
                    ),
                  ],
                )
              else
                _buildPendingKYCList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Today's Pending",
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: Colors.white70)),
                Text('${mockStats['todayPending']}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Avg Verification Time',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: Colors.white70)),
                Text('${mockStats['avgVerificationTime']}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Approval Rate',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: Colors.white70)),
                Text('${mockStats['approvalRate']}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search by name or phone...',
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.search, color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All', 0),
              _buildFilterChip('High Priority', 1),
              _buildFilterChip('Medium Priority', 2),
              _buildFilterChip('Low Priority', 3),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedPriority = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _selectedPriority == index
                ? const Color(0xFF059669)
                : Colors.white.withOpacity(0.05),
            border: Border.all(
                color: _selectedPriority == index
                    ? const Color(0xFF059669)
                    : Colors.white.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label,
              style: TextStyle(
                  color: _selectedPriority == index
                      ? Colors.white
                      : Colors.white70,
                  fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildPendingKYCList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: mockPendingKYC.length,
        itemBuilder: (context, index) {
          final kyc = mockPendingKYC[index];
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: kyc['priority'] == 'High'
                                ? Colors.red.withOpacity(0.2)
                                : Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            kyc['priority'] as String,
                            style: TextStyle(
                              color: (kyc['priority'] as String) == 'High'
                                  ? Colors.red
                                  : Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          'Waiting ${kyc['waitingTime']}',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: Colors.white54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Color(0xFF059669), Color(0xFF10B981)]),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              (kyc['name'] as String?)?.isNotEmpty == true
                                  ? (kyc['name'] as String)[0]
                                  : '?',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(kyc['name'] as String,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                              Text(
                                  '${kyc['role']} • ${kyc['documentsUploaded']}',
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (index < mockPendingKYC.length - 1)
                Divider(color: Colors.white.withOpacity(0.1)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDocumentViewer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Document Verification',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          // Document tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['NID', 'Trade License', 'Photo']
                  .map((docType) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: docType == 'NID'
                                ? const Color(0xFF059669).withOpacity(0.2)
                                : Colors.white.withOpacity(0.05),
                            border: Border.all(
                                color: docType == 'NID'
                                    ? const Color(0xFF059669)
                                    : Colors.white.withOpacity(0.1)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(docType,
                              style: TextStyle(
                                  color: docType == 'NID'
                                      ? const Color(0xFF059669)
                                      : Colors.white70,
                                  fontSize: 12)),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
          // AI validation hints
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildValidationHint('Name matches profile', true),
                _buildValidationHint('Document not expired', true),
                _buildValidationHint('Photo clear quality', false),
                _buildValidationHint('Signature visible', true),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showVerificationDialog('Approve'),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Approve'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showVerificationDialog('Reject'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showVerificationDialog('Request Info'),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('Request Info'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValidationHint(String hint, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(isValid ? Icons.check_circle : Icons.info,
              color: isValid ? Colors.green : Colors.orange, size: 16),
          const SizedBox(width: 8),
          Text(hint,
              style: TextStyle(
                  color: isValid ? Colors.green : Colors.orange, fontSize: 12)),
        ],
      ),
    );
  }

  void _showVerificationDialog(String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: Text('$action KYC'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (action != 'Approve')
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter reason...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                maxLines: 3,
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                    value: true,
                    onChanged: (_) {},
                    fillColor:
                        WidgetStateProperty.all(const Color(0xFF059669))),
                const Expanded(
                    child: Text('Notify user',
                        style: TextStyle(color: Colors.white70))),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text(action)),
        ],
      ),
    );
  }
}
