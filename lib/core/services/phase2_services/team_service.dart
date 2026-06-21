import 'package:agrolinkbd/core/models/phase2_models/team_models.dart';

/// Service for managing company team
class TeamService {
  /// Get all team members
  Future<List<TeamMember>> getTeamMembers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      TeamMember(
        id: '1',
        name: 'Ahmed Hassan',
        email: 'ahmed@company.com',
        phone: '01712345678',
        position: 'Sales Manager',
        department: 'Sales',
        status: 'active',
        salary: 50000.0,
        joinDate: DateTime(2020, 5, 15),
        profileImage: 'profile1.jpg',
        permissions: ['manage_orders', 'view_reports'],
      ),
      TeamMember(
        id: '2',
        name: 'Fatima Khan',
        email: 'fatima@company.com',
        phone: '01987654321',
        position: 'Operations Manager',
        department: 'Operations',
        status: 'active',
        salary: 55000.0,
        joinDate: DateTime(2019, 3, 20),
        profileImage: 'profile2.jpg',
        permissions: ['manage_team', 'view_reports', 'manage_contracts'],
      ),
    ];
  }

  /// Add team member
  Future<TeamMember> addTeamMember(TeamMember member) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return member;
  }

  /// Update team member
  Future<void> updateTeamMember(TeamMember member) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Implementation will update Firestore
  }

  /// Remove team member
  Future<void> removeTeamMember(String memberId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Implementation will delete from Firestore
  }

  /// Get departments
  Future<List<Department>> getDepartments() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Department(
        name: 'Sales',
        memberCount: 5,
        head: 'Ahmed Hassan',
        description: 'Handles all sales operations',
      ),
      Department(
        name: 'Operations',
        memberCount: 8,
        head: 'Fatima Khan',
        description: 'Manages daily operations and logistics',
      ),
    ];
  }

  /// Get team members by department
  Future<List<TeamMember>> getTeamByDepartment(String department) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final allMembers = await getTeamMembers();
    return allMembers
        .where((member) => member.department == department)
        .toList();
  }
}
