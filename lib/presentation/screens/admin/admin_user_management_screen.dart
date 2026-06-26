import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/admin_provider.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Theme tracking
  bool _isLightMode = false;

  Color get _bgColor => _isLightMode ? const Color(0xFFF3F4F6) : const Color(0xFF0B0F19);
  Color get _textColor => _isLightMode ? const Color(0xFF1F2937) : Colors.white;
  Color get _cardColor => _isLightMode ? Colors.white.withOpacity(0.7) : Colors.white.withOpacity(0.03);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Ambient glowing background orbs
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF059669).withOpacity(_isLightMode ? 0.2 : 0.15),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              right: -50,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF3B82F6).withOpacity(_isLightMode ? 0.2 : 0.1),
                ),
              ),
            ),
            // Backdrop filter
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(color: Colors.transparent),
            ),
            
            // Content
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildUsersList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: _textColor),
                    onPressed: () => Get.back(),
                  ),
                  Text(
                    'User Database',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              // Theme Toggle
              GestureDetector(
                onTap: () => setState(() => _isLightMode = !_isLightMode),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _textColor.withOpacity(0.1)),
                  ),
                  child: Icon(
                    _isLightMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: _textColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Search Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                style: TextStyle(color: _textColor),
                decoration: InputDecoration(
                  hintText: 'Search by name, email, or phone...',
                  hintStyle: TextStyle(color: _textColor.withOpacity(0.5)),
                  prefixIcon: Icon(Icons.search_rounded, color: _textColor.withOpacity(0.7)),
                  filled: true,
                  fillColor: _cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: _textColor.withOpacity(0.1)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    Query query = FirebaseFirestore.instance.collection('users');
    
    final bool isFilteredByUpazila = !adminProvider.isSuperAdmin && adminProvider.currentAdmin?.upazila != null;
    
    if (isFilteredByUpazila) {
      query = query.where('upazila', isEqualTo: adminProvider.currentAdmin!.upazila);
    } else {
      query = query.orderBy('createdAt', descending: true);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading users', style: TextStyle(color: Colors.red)));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
        }

        var users = snapshot.data!.docs.toList();
        
        // Local sort if we filtered by upazila
        if (isFilteredByUpazila) {
          users.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            
            DateTime aTime = DateTime.fromMillisecondsSinceEpoch(0);
            DateTime bTime = DateTime.fromMillisecondsSinceEpoch(0);
            
            if (aData['createdAt'] != null) {
              aTime = (aData['createdAt'] is Timestamp) ? (aData['createdAt'] as Timestamp).toDate() : DateTime.tryParse(aData['createdAt'].toString()) ?? aTime;
            }
            if (bData['createdAt'] != null) {
              bTime = (bData['createdAt'] is Timestamp) ? (bData['createdAt'] as Timestamp).toDate() : DateTime.tryParse(bData['createdAt'].toString()) ?? bTime;
            }
            return bTime.compareTo(aTime);
          });
        }

        // Filter by search query
        if (_searchQuery.isNotEmpty) {
          users = users.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['name'] ?? '').toString().toLowerCase();
            final email = (data['email'] ?? '').toString().toLowerCase();
            final phone = (data['phone'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery) || email.contains(_searchQuery) || phone.contains(_searchQuery);
          }).toList();
        }

        if (users.isEmpty) {
          return Center(
            child: Text('No users found', style: TextStyle(color: _textColor.withOpacity(0.5))),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          physics: const BouncingScrollPhysics(),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final doc = users[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildUserCard(doc.id, data);
          },
        );
      },
    );
  }

  Widget _buildUserCard(String uid, Map<String, dynamic> userData) {
    final name = userData['name'] ?? 'Unknown User';
    final email = userData['email'] ?? 'No email';
    final role = userData['role'] ?? 'buyer';
    final isBanned = userData['isBanned'] == true;

    Color roleColor;
    switch (role.toString().toLowerCase()) {
      case 'admin':
      case 'superadmin':
        roleColor = const Color(0xFF8B5CF6);
        break;
      case 'farmer':
        roleColor = const Color(0xFF10B981);
        break;
      case 'driver':
        roleColor = const Color(0xFFF59E0B);
        break;
      default:
        roleColor = const Color(0xFF3B82F6);
    }

    return GestureDetector(
      onTap: () => _showUserProfileModal(uid, userData),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _textColor.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [roleColor.withOpacity(0.8), roleColor],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                color: _textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                decoration: isBanned ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            if (isBanned) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('BANNED', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ]
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(email, style: TextStyle(color: _textColor.withOpacity(0.6), fontSize: 13)),
                      ],
                    ),
                  ),

                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: roleColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      role.toString().toUpperCase(),
                      style: TextStyle(color: roleColor, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showUserProfileModal(String uid, Map<String, dynamic> userData) {
    final name = userData['name'] ?? 'Unknown User';
    final email = userData['email'] ?? 'No email';
    final phone = userData['phone'] ?? 'No phone';
    final role = userData['role'] ?? 'buyer';
    final isBanned = userData['isBanned'] == true;
    final createdAt = userData['createdAt'] as Timestamp?;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(top: BorderSide(color: _textColor.withOpacity(0.1))),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: _textColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Big Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.4), blurRadius: 20, spreadRadius: 2)
                      ]
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 36),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Text(name, style: TextStyle(color: _textColor, fontSize: 24, fontWeight: FontWeight.w900)),
                  Text(email, style: TextStyle(color: _textColor.withOpacity(0.6), fontSize: 14)),
                  
                  const SizedBox(height: 30),
                  
                  _buildDetailRow('Phone', phone),
                  _buildDetailRow('Role', role.toString().toUpperCase()),
                  _buildDetailRow('Joined', createdAt != null ? createdAt.toDate().toString().split(' ')[0] : 'Unknown'),
                  
                  const SizedBox(height: 40),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            // Toggle Ban Status
                            await FirebaseFirestore.instance.collection('users').doc(uid).update({
                              'isBanned': !isBanned,
                            });
                            
                            // Log the action
                            if (mounted) {
                              final action = isBanned ? 'USER_UNBANNED' : 'USER_BANNED';
                              final desc = isBanned ? 'Unbanned user: $name ($uid)' : 'Banned user: $name ($uid)';
                              await Provider.of<AdminProvider>(context, listen: false).logAdminAction(action, desc);
                            }

                            Get.back();
                            Get.snackbar(
                              'Success', 
                              isBanned ? 'User unbanned' : 'User banned successfully',
                              backgroundColor: isBanned ? Colors.green : Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isBanned ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          icon: Icon(isBanned ? Icons.check_circle_outline : Icons.block_rounded),
                          label: Text(isBanned ? 'UNBAN USER' : 'BAN USER', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: _textColor.withOpacity(0.5), fontSize: 14)),
          Text(value, style: TextStyle(color: _textColor, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
