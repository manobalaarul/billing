class CustomerModel {
  final String? id;
  final String? customerCode;

  // Basic Info
  final String name;
  final String? dateOfBirth;
  final String? relationType; // S/O, D/O, W/O, H/O, C/O
  final String? relationName;
  final String sex; // MALE, FEMALE, OTHER
  final String? photoUrl;

  // Contact Details
  final String mobile;
  final String? altMobile;
  final String? email;
  final String? address1;
  final String? address2;
  final String? location;
  final String? city;
  final String? pincode;

  // KYC
  final String? aadharNumber;
  final String? panNumber;
  final String? rationCard;
  final String? otherProof;
  final String? aadharPhotoUrl;
  final String? otherProofPhotoUrl;

  // Misc
  final String? notes;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CustomerModel({
    this.id,
    this.customerCode,
    required this.name,
    this.dateOfBirth,
    this.relationType,
    this.relationName,
    this.sex = 'MALE',
    this.photoUrl,
    required this.mobile,
    this.altMobile,
    this.email,
    this.address1,
    this.address2,
    this.location,
    this.city,
    this.pincode,
    this.aadharNumber,
    this.panNumber,
    this.rationCard,
    this.otherProof,
    this.aadharPhotoUrl,
    this.otherProofPhotoUrl,
    this.notes,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id']?.toString(),
      customerCode: json['customer_code'],
      name: json['name'] ?? '',
      dateOfBirth: json['date_of_birth'],
      relationType: json['relation_type'],
      relationName: json['relation_name'],
      sex: json['sex'] ?? 'MALE',
      photoUrl: json['photo'],
      mobile: json['mobile'] ?? '',
      altMobile: json['alt_mobile'],
      email: json['email'],
      address1: json['address1'],
      address2: json['address2'],
      location: json['location'],
      city: json['city'],
      pincode: json['pincode'],
      aadharNumber: json['aadhar_number'],
      panNumber: json['pan_number'],
      rationCard: json['ration_card'],
      otherProof: json['other_proof'],
      aadharPhotoUrl: json['aadhar_photo'],
      otherProofPhotoUrl: json['other_proof_photo'],
      notes: json['notes'],
      isActive: (json['is_active'] ?? 1) == 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (customerCode != null) 'customer_code': customerCode,
      'name': name,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (relationType != null) 'relation_type': relationType,
      if (relationName != null) 'relation_name': relationName,
      'sex': sex,
      'mobile': mobile,
      if (altMobile != null) 'alt_mobile': altMobile,
      if (email != null) 'email': email,
      if (address1 != null) 'address1': address1,
      if (address2 != null) 'address2': address2,
      if (location != null) 'location': location,
      if (city != null) 'city': city,
      if (pincode != null) 'pincode': pincode,
      if (aadharNumber != null) 'aadhar_number': aadharNumber,
      if (panNumber != null) 'pan_number': panNumber,
      if (rationCard != null) 'ration_card': rationCard,
      if (otherProof != null) 'other_proof': otherProof,
      if (notes != null) 'notes': notes,
      'is_active': isActive ? 1 : 0,
    };
  }

  CustomerModel copyWith({
    String? id,
    String? customerCode,
    String? name,
    String? dateOfBirth,
    String? relationType,
    String? relationName,
    String? sex,
    String? photoUrl,
    String? mobile,
    String? altMobile,
    String? email,
    String? address1,
    String? address2,
    String? location,
    String? city,
    String? pincode,
    String? aadharNumber,
    String? panNumber,
    String? rationCard,
    String? otherProof,
    String? aadharPhotoUrl,
    String? otherProofPhotoUrl,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      customerCode: customerCode ?? this.customerCode,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      relationType: relationType ?? this.relationType,
      relationName: relationName ?? this.relationName,
      sex: sex ?? this.sex,
      photoUrl: photoUrl ?? this.photoUrl,
      mobile: mobile ?? this.mobile,
      altMobile: altMobile ?? this.altMobile,
      email: email ?? this.email,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      location: location ?? this.location,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      panNumber: panNumber ?? this.panNumber,
      rationCard: rationCard ?? this.rationCard,
      otherProof: otherProof ?? this.otherProof,
      aadharPhotoUrl: aadharPhotoUrl ?? this.aadharPhotoUrl,
      otherProofPhotoUrl: otherProofPhotoUrl ?? this.otherProofPhotoUrl,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Masked aadhar for display e.g. ●●●● 4567
  String get maskedAadhar {
    if (aadharNumber == null || aadharNumber!.isEmpty) return '—';
    final clean = aadharNumber!.replaceAll(' ', '');
    if (clean.length < 4) return '—';
    return '●●●● ${clean.substring(clean.length - 4)}';
  }
}
