class PondActivityModel {
  final String id;
  final String title;
  final String description;
  final double amount;
  final DateTime date;
  final String type; // e.g., 'Feed', 'Medicine', 'Stock', 'Maintenance', 'Harvest', 'Sale'
  final bool isIncome;

  PondActivityModel({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
    this.isIncome = false,
  });
}

class PondModel {
  final String id;
  final String name;
  final String area;
  final String fishSpecies;
  final DateTime stockedDate;
  final int totalFishCount;
  
  // Dynamic fields
  String status;
  double ph;
  double ammonia;

  // Track activities and costs
  List<PondActivityModel> activities;

  PondModel({
    required this.id,
    required this.name,
    required this.area,
    required this.fishSpecies,
    required this.stockedDate,
    required this.totalFishCount,
    this.status = 'স্বাভাবিক',
    this.ph = 7.0,
    this.ammonia = 0.0,
    List<PondActivityModel>? activities,
  }) : activities = activities ?? [];

  double get totalCost {
    return activities.where((a) => a.isIncome != true).fold(0.0, (sum, activity) => sum + activity.amount);
  }

  double get totalIncome {
    return activities.where((a) => a.isIncome == true).fold(0.0, (sum, activity) => sum + activity.amount);
  }

  int get daysSinceStocked {
    return DateTime.now().difference(stockedDate).inDays;
  }
}
