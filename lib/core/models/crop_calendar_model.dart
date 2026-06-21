enum CropType {
  rice,
  wheat,
  maize,
  potato,
  jute,
  sugarcane,
  vegetables,
  fruits,
  other,
}

enum TaskType {
  planting,
  fertilizing,
  watering,
  pestControl,
  weeding,
  harvesting,
  other,
}

enum TaskStatus { pending, completed, skipped }

class CropCalendarModel {
  final String id;
  final String farmerId;
  final CropType cropType;
  final String cropName;
  final double landSize;
  final DateTime plantingDate;
  final DateTime expectedHarvestDate;
  final String location;
  final List<TaskModel> tasks;
  final DateTime createdAt;

  CropCalendarModel({
    required this.id,
    required this.farmerId,
    required this.cropType,
    required this.cropName,
    required this.landSize,
    required this.plantingDate,
    required this.expectedHarvestDate,
    required this.location,
    required this.tasks,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'cropType': cropType.toString(),
      'cropName': cropName,
      'landSize': landSize,
      'plantingDate': plantingDate.toIso8601String(),
      'expectedHarvestDate': expectedHarvestDate.toIso8601String(),
      'location': location,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CropCalendarModel.fromJson(Map<String, dynamic> json) {
    return CropCalendarModel(
      id: json['id'],
      farmerId: json['farmerId'],
      cropType: CropType.values.firstWhere(
        (e) => e.toString() == json['cropType'],
      ),
      cropName: json['cropName'],
      landSize: json['landSize'].toDouble(),
      plantingDate: DateTime.parse(json['plantingDate']),
      expectedHarvestDate: DateTime.parse(json['expectedHarvestDate']),
      location: json['location'],
      tasks: (json['tasks'] as List)
          .map((task) => TaskModel.fromJson(task))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class TaskModel {
  final String id;
  final TaskType type;
  final String title;
  final String description;
  final DateTime scheduledDate;
  final TaskStatus status;
  final bool reminderSent;
  final DateTime? completedDate;

  TaskModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.scheduledDate,
    this.status = TaskStatus.pending,
    this.reminderSent = false,
    this.completedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'title': title,
      'description': description,
      'scheduledDate': scheduledDate.toIso8601String(),
      'status': status.toString(),
      'reminderSent': reminderSent,
      'completedDate': completedDate?.toIso8601String(),
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      type: TaskType.values.firstWhere((e) => e.toString() == json['type']),
      title: json['title'],
      description: json['description'],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      status: TaskStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      reminderSent: json['reminderSent'] ?? false,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
    );
  }
}
