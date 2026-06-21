import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/models/admin_model.dart';
import 'package:agrolinkbd/core/providers/admin_provider.dart';

class SuperadminManagement extends StatefulWidget {
  const SuperadminManagement({super.key});

  @override
  State<SuperadminManagement> createState() => _SuperadminManagementState();
}

class _SuperadminManagementState extends State<SuperadminManagement> {
  String _searchQuery = '';
  String? _filterRole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).loadAllAdmins();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Admins'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle),
            tooltip: 'Create Admin',
            onPressed: _showCreateAdminDialog,
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          if (!adminProvider.isSuperAdmin) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Super Admin Access Required',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Only super admins can manage other admins',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          final admins = adminProvider.allAdmins;

          // Filter admins
          var filteredAdmins = admins.where((admin) {
            bool matchesSearch = admin.name
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                admin.email.toLowerCase().contains(_searchQuery.toLowerCase());
            bool matchesRole = _filterRole == null || admin.role == _filterRole;
            return matchesSearch && matchesRole;
          }).toList();

          return Column(
            children: [
              // Search and Filter
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by name or email...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                    ),
                    const SizedBox(height: 12),
                    // Role filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'All',
                            isSelected: _filterRole == null,
                            onTap: () => setState(() => _filterRole = null),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Super Admin',
                            isSelected: _filterRole == 'super_admin',
                            onTap: () =>
                                setState(() => _filterRole = 'super_admin'),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Admin',
                            isSelected: _filterRole == 'admin',
                            onTap: () => setState(() => _filterRole = 'admin'),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Moderator',
                            isSelected: _filterRole == 'moderator',
                            onTap: () =>
                                setState(() => _filterRole = 'moderator'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Admin count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Showing ${filteredAdmins.length} of ${admins.length}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Admin list
              Expanded(
                child: filteredAdmins.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No admins found',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredAdmins.length,
                        itemBuilder: (context, index) {
                          final admin = filteredAdmins[index];
                          return _buildAdminCard(context, admin);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildAdminCard(BuildContext context, AdminModel admin) {
    final roleColor = admin.role == 'super_admin'
        ? Colors.red
        : admin.role == 'admin'
            ? Colors.blue
            : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: roleColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            admin.role == 'super_admin'
                ? Icons.shield
                : admin.role == 'admin'
                    ? Icons.admin_panel_settings
                    : Icons.person,
            color: roleColor,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(admin.name),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                admin.role.toUpperCase(),
                style: TextStyle(
                  color: roleColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              admin.email,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (admin.isSuspended)
                  Chip(
                    label: const Text('Suspended'),
                    backgroundColor: Colors.red.withOpacity(0.2),
                    labelStyle: const TextStyle(
                      color: Colors.red,
                      fontSize: 11,
                    ),
                    visualDensity: VisualDensity.compact,
                  )
                else
                  Chip(
                    label: const Text('Active'),
                    backgroundColor: Colors.green.withOpacity(0.2),
                    labelStyle: const TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                const SizedBox(width: 8),
                if (admin.lastLogin != null)
                  Text(
                    'Last: ${_formatDate(admin.lastLogin!)}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Edit'),
              onTap: () => _showEditAdminDialog(context, admin),
            ),
            if (!admin.isSuspended)
              PopupMenuItem(
                child: const Text('Suspend'),
                onTap: () => _showSuspendDialog(context, admin),
              )
            else
              PopupMenuItem(
                child: const Text('Activate'),
                onTap: () => _activateAdmin(context, admin),
              ),
            if (admin.role != 'super_admin')
              PopupMenuItem(
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => _deleteAdmin(context, admin),
              ),
          ],
        ),
      ),
    );
  }

  void _showCreateAdminDialog() {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'admin';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Admin'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setState) => DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    prefixIcon: const Icon(Icons.security),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(
                        value: 'moderator', child: Text('Moderator')),
                  ],
                  onChanged: (value) {
                    setState(() => selectedRole = value ?? 'admin');
                  },
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
          ElevatedButton(
            onPressed: () => _createAdmin(
              context,
              nameController.text,
              emailController.text,
              passwordController.text,
              selectedRole,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _createAdmin(
    BuildContext context,
    String name,
    String email,
    String password,
    String role,
  ) {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // TODO: Call super admin provider
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Admin created successfully')),
    );
  }

  void _showEditAdminDialog(BuildContext context, AdminModel admin) {
    final nameController = TextEditingController(text: admin.name);
    final emailController = TextEditingController(text: admin.email);
    String selectedRole = admin.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Admin'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Email (Cannot change)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (admin.role != 'super_admin')
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(
                        value: 'moderator',
                        child: Text('Moderator'),
                      ),
                      DropdownMenuItem(
                        value: 'support',
                        child: Text('Support'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => selectedRole = value ?? admin.role);
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _updateAdmin(
                  context, admin, nameController.text, selectedRole),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateAdmin(
      BuildContext context, AdminModel admin, String name, String role) {
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    // TODO: Call super admin provider
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Admin updated successfully')),
    );
  }

  void _showSuspendDialog(BuildContext context, AdminModel admin) {
    final reasonController = TextEditingController();
    int suspensionDays = 7;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend Admin'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Suspend ${admin.name}?',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Reason for suspension',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setState) => Row(
                  children: [
                    Text('Duration: $suspensionDays days'),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () =>
                          setState(() => suspensionDays = (suspensionDays - 1)),
                    ),
                    Text(suspensionDays.toString()),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () =>
                          setState(() => suspensionDays = (suspensionDays + 1)),
                    ),
                  ],
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => _suspendAdmin(
              context,
              admin,
              reasonController.text,
              suspensionDays,
            ),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }

  void _suspendAdmin(BuildContext context, AdminModel admin, String reason,
      int suspensionDays) {
    // TODO: Call super admin provider
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${admin.name} suspended for $suspensionDays days'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _activateAdmin(BuildContext context, AdminModel admin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activate Admin'),
        content: Text('Activate ${admin.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              // TODO: Call super admin provider
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Admin activated'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Activate'),
          ),
        ],
      ),
    );
  }

  void _deleteAdmin(BuildContext context, AdminModel admin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Admin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete ${admin.name}?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '⚠️ This action will be permanently logged in the audit trail. The admin will be marked as deleted but their history will remain.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // TODO: Call super admin provider
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Admin deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}
