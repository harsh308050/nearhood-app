class BusinessProfile {
  final String? id;
  final String userId;
  final String businessType; // 'neighbor_for_hire' | 'professional'
  final String businessName;
  final String category;
  final String? subCategory;
  final String description;
  final String address;
  final double? latitude;
  final double? longitude;
  final String localityId;
  final String localityName;
  final String city;
  final String logoUrl;
  final String? coverUrl;
  final String? phone;
  final String? website;
  final Map<String, WorkingHours>? workingHours;
  final String? gstNumber;
  final bool isGstVerified;
  final bool isVerified;
  final String visibilityState; // 'hidden' | 'active' | 'boosted'
  final int recommendationCount;
  final DateTime? createdAt;

  const BusinessProfile({
    this.id,
    required this.userId,
    required this.businessType,
    required this.businessName,
    required this.category,
    this.subCategory,
    required this.description,
    required this.address,
    this.latitude,
    this.longitude,
    required this.localityId,
    required this.localityName,
    required this.city,
    required this.logoUrl,
    this.coverUrl,
    this.phone,
    this.website,
    this.workingHours,
    this.gstNumber,
    this.isGstVerified = false,
    this.isVerified = false,
    this.visibilityState = 'hidden',
    this.recommendationCount = 0,
    this.createdAt,
  });

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    final loc = json['location'];
    final coords = loc is Map ? loc['coordinates'] : null;

    final hoursJson = json['workingHours'] as Map<String, dynamic>?;
    final hours = hoursJson?.map(
      (k, v) => MapEntry(k, WorkingHours.fromJson(v as Map<String, dynamic>)),
    );

    return BusinessProfile(
      id: json['_id']?.toString(),
      userId: json['userId']?.toString() ?? '',
      businessType: json['businessType']?.toString() ?? 'professional',
      businessName: json['businessName']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      subCategory: json['subCategory']?.toString(),
      description: json['description']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: coords != null && coords.length > 1
          ? (coords[1] as num?)?.toDouble()
          : null,
      longitude: coords != null && coords.isNotEmpty
          ? (coords[0] as num?)?.toDouble()
          : null,
      localityId: json['localityId']?.toString() ?? '',
      localityName: json['localityName']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString() ?? '',
      coverUrl: json['coverUrl']?.toString(),
      phone: json['phone']?.toString(),
      website: json['website']?.toString(),
      workingHours: hours,
      gstNumber: json['gstNumber']?.toString(),
      isGstVerified: json['isGstVerified'] == true,
      isVerified: json['isVerified'] == true,
      visibilityState: json['visibilityState']?.toString() ?? 'hidden',
      recommendationCount: json['recommendationCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final hoursJson = workingHours?.map(
      (k, v) => MapEntry(k, v.toJson()),
    );

    return {
      if (id != null) '_id': id,
      'userId': userId,
      'businessType': businessType,
      'businessName': businessName,
      'category': category,
      if (subCategory != null) 'subCategory': subCategory,
      'description': description,
      'address': address,
      if (latitude != null && longitude != null)
        'location': {
          'type': 'Point',
          'coordinates': [longitude, latitude],
        },
      'localityId': localityId,
      'localityName': localityName,
      'city': city,
      'logoUrl': logoUrl,
      if (coverUrl != null) 'coverUrl': coverUrl,
      if (phone != null) 'phone': phone,
      if (website != null) 'website': website,
      if (hoursJson != null) 'workingHours': hoursJson,
      if (gstNumber != null) 'gstNumber': gstNumber,
    };
  }
}

class WorkingHours {
  final bool isOpen;
  final String? open; // "09:00"
  final String? close; // "18:00"

  const WorkingHours({this.isOpen = false, this.open, this.close});

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      isOpen: json['isOpen'] == true,
      open: json['open']?.toString(),
      close: json['close']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'isOpen': isOpen,
        if (open != null) 'open': open,
        if (close != null) 'close': close,
      };
}
