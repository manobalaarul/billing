class GirviModel {
  final String? id;
  final String girviNo;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String metalType; // GOLD, SILVER, DIAMOND, OTHER
  final double grossWeight;
  final double netWeight;
  final double loanAmount;
  final double interestAmount; // per month
  final DateTime? dueDate;
  final String status; // ACTIVE, CLOSED
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  GirviModel({
    this.id,
    required this.girviNo,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.metalType,
    required this.grossWeight,
    required this.netWeight,
    required this.loanAmount,
    required this.interestAmount,
    this.dueDate,
    this.status = 'ACTIVE',
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory GirviModel.fromJson(Map<String, dynamic> json) {
    return GirviModel(
      id: json['id']?.toString(),
      girviNo: json['girvi_no'] ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      metalType: json['metal_type'] ?? 'GOLD',
      grossWeight: (json['gross_weight'] ?? 0).toDouble(),
      netWeight: (json['net_weight'] ?? 0).toDouble(),
      loanAmount: (json['loan_amount'] ?? 0).toDouble(),
      interestAmount: (json['interest_amount'] ?? 0).toDouble(),
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'])
          : null,
      status: json['status'] ?? 'ACTIVE',
      notes: json['notes'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'girvi_no': girviNo,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'metal_type': metalType,
      'gross_weight': grossWeight,
      'net_weight': netWeight,
      'loan_amount': loanAmount,
      'interest_amount': interestAmount,
      'due_date': dueDate?.toIso8601String(),
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  GirviModel copyWith({
    String? id,
    String? girviNo,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? metalType,
    double? grossWeight,
    double? netWeight,
    double? loanAmount,
    double? interestAmount,
    DateTime? dueDate,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GirviModel(
      id: id ?? this.id,
      girviNo: girviNo ?? this.girviNo,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      metalType: metalType ?? this.metalType,
      grossWeight: grossWeight ?? this.grossWeight,
      netWeight: netWeight ?? this.netWeight,
      loanAmount: loanAmount ?? this.loanAmount,
      interestAmount: interestAmount ?? this.interestAmount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isActive => status == 'ACTIVE';

  bool get isOverdue =>
      dueDate != null && dueDate!.isBefore(DateTime.now()) && isActive;

  bool get isDueSoon {
    if (dueDate == null || isOverdue || !isActive) return false;
    final diff = dueDate!.difference(DateTime.now()).inDays;
    return diff <= 30;
  }
}
