import 'package:agrolinkbd/core/models/phase2_models/team_models.dart';

/// Mock data for team management module testing
class TeamMocks {
  /// Sample team members
  static List<TeamMember> getSampleTeamMembers() {
    return [
      TeamMember(
        id: 'TM_001',
        name: 'Ahmed Hassan',
        email: 'ahmed.hassan@agrilink.com',
        phone: '01712345678',
        position: 'Sales Manager',
        department: 'Sales',
        status: 'active',
        salary: 50000.0,
        joinDate: DateTime(2020, 5, 15),
        profileImage: 'profile1.jpg',
        permissions: ['manage_orders', 'view_reports', 'edit_contracts'],
      ),
      TeamMember(
        id: 'TM_002',
        name: 'Fatima Khan',
        email: 'fatima.khan@agrilink.com',
        phone: '01987654321',
        position: 'Operations Manager',
        department: 'Operations',
        status: 'active',
        salary: 55000.0,
        joinDate: DateTime(2019, 3, 20),
        profileImage: 'profile2.jpg',
        permissions: [
          'manage_team',
          'view_reports',
          'manage_contracts',
          'approve_orders'
        ],
      ),
      TeamMember(
        id: 'TM_003',
        name: 'Karim Ali',
        email: 'karim.ali@agrilink.com',
        phone: '01534567890',
        position: 'Logistics Coordinator',
        department: 'Operations',
        status: 'active',
        salary: 35000.0,
        joinDate: DateTime(2021, 1, 10),
        profileImage: 'profile3.jpg',
        permissions: ['manage_deliveries', 'view_orders'],
      ),
      TeamMember(
        id: 'TM_004',
        name: 'Noor Jahan',
        email: 'noor.jahan@agrilink.com',
        phone: '01645678901',
        position: 'Finance Officer',
        department: 'Finance',
        status: 'on_leave',
        salary: 45000.0,
        joinDate: DateTime(2020, 8, 05),
        profileImage: 'profile4.jpg',
        permissions: ['manage_payments', 'view_financial_reports'],
      ),
    ];
  }

  /// Sample departments
  static List<Department> getSampleDepartments() {
    return [
      Department(
        name: 'Sales',
        memberCount: 5,
        head: 'Ahmed Hassan',
        description: 'Handles all sales operations and customer relations',
      ),
      Department(
        name: 'Operations',
        memberCount: 8,
        head: 'Fatima Khan',
        description: 'Manages logistics, delivery, and day-to-day operations',
      ),
      Department(
        name: 'Finance',
        memberCount: 3,
        head: 'Noor Jahan',
        description: 'Manages financial operations and reporting',
      ),
      Department(
        name: 'IT',
        memberCount: 4,
        head: 'Reza Khan',
        description: 'Handles technical infrastructure and support',
      ),
    ];
  }
}
