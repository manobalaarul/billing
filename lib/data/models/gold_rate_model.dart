class GoldRateModel {
  final String? id;
  final String purity;
  final double rate;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  GoldRateModel({
    this.id,
    required this.purity,
    required this.rate,
    required this.date,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory GoldRateModel.fromJson(Map<String, dynamic> json) {
    return GoldRateModel(
      id: json['id']?.toString(),
      purity: json['purity'] ?? '',
      rate: (json['rate'] ?? 0).toDouble(),
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'purity': purity,
      'rate': rate,
      'date': date.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  GoldRateModel copyWith({
    String? id,
    String? purity,
    double? rate,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoldRateModel(
      id: id ?? this.id,
      purity: purity ?? this.purity,
      rate: rate ?? this.rate,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
