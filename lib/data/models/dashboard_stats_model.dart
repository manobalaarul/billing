class DashboardStatsModel {
  final int totalCustomers;
  final int totalOrders;
  final double todaysSales;
  final double currentGoldRate;
  final List<RecentActivity> recentActivities;

  DashboardStatsModel({
    required this.totalCustomers,
    required this.totalOrders,
    required this.todaysSales,
    required this.currentGoldRate,
    required this.recentActivities,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalCustomers: json['total_customers'] ?? 0,
      totalOrders: json['total_orders'] ?? 0,
      todaysSales: (json['todays_sales'] ?? 0).toDouble(),
      currentGoldRate: (json['current_gold_rate'] ?? 0).toDouble(),
      recentActivities:
          (json['recent_activities'] as List<dynamic>?)
              ?.map((e) => RecentActivity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_customers': totalCustomers,
      'total_orders': totalOrders,
      'todays_sales': todaysSales,
      'current_gold_rate': currentGoldRate,
      'recent_activities': recentActivities.map((e) => e.toJson()).toList(),
    };
  }
}

class RecentActivity {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String type;

  RecentActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      type: json['type'] ?? 'general',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }
}
