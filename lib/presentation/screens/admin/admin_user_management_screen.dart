import 'package:flutter/material.dart';

/// Advanced User Management Screen
/// Features: Advanced filtering, role management, bulk actions, user profiles
class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final _searchController = TextEditingController();
  String _selectedRole = 'All';
  String _selectedStatus = 'All';
  List<bool> _selectedUsers = [];

  final roles = ['All', 'Farmer', 'Buyer', 'Seller', 'Moderator', 'Suspended'];
  final statuses = ['All', 'Active', 'Inactive', 'Pending'];

  final mockUsers = [
    {
      'id': 'USR-001',
      'name': 'Ahmad Khan',
      'email': 'ahmad@example.com',
      'role': 'Farmer',
      'status': 'Active',
      'joinDate': 'Jan 15, 2026',
      'lastActive': '2 hours ago',
      'verified': true,
    },
    {
      'id': 'USR-002',
      'name': 'Fatima Ali',
      'email': 'fatima@example.com',
      'role': 'Buyer',
      'status': 'Active',
      'joinDate': 'Feb 20, 2026',
      'lastActive': '30 mins ago',
      'verified': true,
    },
    {
      'id': 'USR-003',
      'name': 'Hassan Ahmed',
      'email': 'hassan@example.com',
      'role': 'Seller',
      'status': 'Inactive',
      'joinDate': 'Mar 10, 2026',
      'lastActive': '5 days ago',
      'verified': false,
    },
    {
      'id': 'USR-004',
      'name': 'Rina Das',
      'email': 'rina@example.com',
      'role': 'Farmer',
      'status': 'Pending',
      'joinDate': 'Mar 18, 2026',
      'lastActive': 'Never',
      'verified': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedUsers = List.filled(mockUsers.length, false);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('User Management'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Manage Users',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddUserDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add User'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Search and filter bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search by name or email...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildFilterButton('Role', _selectedRole, roles, (value) {
                    setState(() => _selectedRole = value);
                  }),
                  const SizedBox(width: 12),
                  _buildFilterButton('Status', _selectedStatus, statuses,
                      (value) {
                    setState(() => _selectedStatus = value);
                  }),
                ],
              ),

              const SizedBox(height: 24),

              // Bulk actions bar (if any users selected)
              if (_selectedUsers.any((element) => element))
                _buildBulkActionsBar(),

              const SizedBox(height: 16),

              // Users table/list
              _buildUsersTable(isMobile),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(
    String label,
    String selected,
    List<String> options,
    Function(String) onSelected,
  ) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (BuildContext context) {
        return options
            .map((String option) => PopupMenuItem(
                  value: option,
                  child: Text(option),
                ))
            .toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              '$label: $selected',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.white54, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkActionsBar() {
    final selectedCount = _selectedUsers.where((element) => element).length;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF059669).withOpacity(0.1),
        border: Border.all(color: const Color(0xFF059669).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$selectedCount user(s) selected',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('Send Email'),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Change Role'),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Suspend'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTable(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateColor.resolveWith(
            (states) => Colors.white.withOpacity(0.05),
          ),
          columns: [
            DataColumn(
              label: Checkbox(
                value: _selectedUsers.every((element) => element),
                onChanged: (value) {
                  setState(() {
                    for (int i = 0; i < _selectedUsers.length; i++) {
                      _selectedUsers[i] = value ?? false;
                    }
                  });
                },
              ),
            ),
            const DataColumn(label: Text('User ID')),
            const DataColumn(label: Text('Name')),
            const DataColumn(label: Text('Email')),
            const DataColumn(label: Text('Role')),
            const DataColumn(label: Text('Status')),
            const DataColumn(label: Text('Join Date')),
            const DataColumn(label: Text('Actions')),
          ],
          rows: List.generate(
            mockUsers.length,
            (index) {
              final user = mockUsers[index];
              return DataRow(
                cells: [
                  DataCell(
                    Checkbox(
                      value: _selectedUsers[index],
                      onChanged: (value) {
                        setState(() {
                          _selectedUsers[index] = value ?? false;
                        });
                      },
                    ),
                  ),
                  DataCell(Text(user['id'] as String,
                      style: const TextStyle(color: Colors.white70))),
                  DataCell(
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF059669), Color(0xFF10B981)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              (user['name'] as String)[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(user['name'] as String,
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  DataCell(Text(user['email'] as String,
                      style: const TextStyle(color: Colors.white70))),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRoleColor(user['role'] as String)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        user['role'] as String,
                        style: TextStyle(
                          color: _getRoleColor(user['role'] as String),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(user['status'] as String)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        user['status'] as String,
                        style: TextStyle(
                          color: _getStatusColor(user['status'] as String),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(user['joinDate'] as String,
                      style: const TextStyle(color: Colors.white70))),
                  DataCell(
                    PopupMenuButton<String>(
                      onSelected: (String value) {
                        _handleUserAction(value, user);
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(
                            value: 'view', child: Text('View Profile')),
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                            value: 'verify', child: Text('Verify')),
                        const PopupMenuItem(
                            value: 'suspend', child: Text('Suspend')),
                        const PopupMenuItem(
                            value: 'delete', child: Text('Delete')),
                      ],
                      child: const Icon(Icons.more_vert,
                          color: Colors.white54, size: 16),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Farmer':
        return Colors.green;
      case 'Buyer':
        return Colors.blue;
      case 'Seller':
        return Colors.orange;
      case 'Moderator':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Inactive':
        return Colors.grey;
      case 'Pending':
        return Colors.orange;
      case 'Suspended':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _handleUserAction(String action, Map<String, dynamic> user) {
    switch (action) {
      case 'view':
        _showUserProfile(user);
        break;
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'verify':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user['name']} verified successfully')),
        );
        break;
      case 'suspend':
        _showSuspendDialog(user);
        break;
      case 'delete':
        _showDeleteConfirmation(user);
        break;
    }
  }

  void _showUserProfile(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: Text('${user['name']} Profile'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildProfileField('ID', user['id']),
              _buildProfileField('Email', user['email']),
              _buildProfileField('Role', user['role']),
              _buildProfileField('Status', user['status']),
              _buildProfileField('Join Date', user['joinDate']),
              _buildProfileField('Last Active', user['lastActive']),
              _buildProfileField(
                  'Email Verified', user['verified'] ? 'Yes' : 'No'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Add New User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Full Name',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User added successfully')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: Text('Edit ${user['name']}'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit form fields
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User updated successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSuspendDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: Text('Suspend ${user['name']}?'),
        content:
            const Text('This user will not be able to access the platform.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('${user['name']} suspended successfully')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: Text('Delete ${user['name']}?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user['name']} deleted successfully')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
