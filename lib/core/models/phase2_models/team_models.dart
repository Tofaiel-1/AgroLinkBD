// Team Management Models for Phase 2

class TeamMember {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String position;
  final String department;
  final String status; // active, inactive, on_leave
  final double salary;
  final DateTime joinDate;
  final String profileImage;
  final List<String> permissions;

  TeamMember({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.position,
    required this.department,
    required this.status,
    required this.salary,
    required this.joinDate,
    required this.profileImage,
    required this.permissions,
  });
}

class Department {
  final String name;
  final int memberCount;
  final String head;
  final String description;

  Department({
    required this.name,
    required this.memberCount,
    required this.head,
    required this.description,
  });
}
