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
  final String? open;
  final String? close;

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

class BusinessListing {
  final String? id;
  final String businessId;
  final String type; // 'product' | 'service'
  final String title;
  final String? description;
  final List<String> mediaUrls;
  final double? price;
  final String? priceType; // 'fixed' | 'range' | 'contact'
  final double? priceMin;
  final double? priceMax;
  final bool isAvailable;
  final String? category;
  final String? condition; // product: 'new' | 'like_new' | 'good' | 'fair'
  final String? brand;
  final String? priceUnit; // product: 'per_piece' | 'per_kg' | 'per_dozen' | 'per_litre' | 'per_set'
  final int? quantityAvailable;
  final String? serviceArea; // service: 'at_location' | 'home_visit'
  final String? duration;
  final int viewCount;
  final int enquiryCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? boostInfo;

  const BusinessListing({
    this.id,
    required this.businessId,
    required this.type,
    required this.title,
    this.description,
    this.mediaUrls = const [],
    this.price,
    this.priceType,
    this.priceMin,
    this.priceMax,
    this.isAvailable = true,
    this.category,
    this.condition,
    this.brand,
    this.priceUnit,
    this.quantityAvailable,
    this.serviceArea,
    this.duration,
    this.viewCount = 0,
    this.enquiryCount = 0,
    this.createdAt,
    this.updatedAt,
    this.boostInfo,
  });

  factory BusinessListing.fromJson(Map<String, dynamic> json) {
    final boost = json['boostInfo'] as Map<String, dynamic>?;
    return BusinessListing(
      id: json['_id']?.toString(),
      businessId: json['businessId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'product',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      mediaUrls: (json['mediaUrls'] as List?)?.map((e) => e.toString()).toList() ?? [],
      price: (json['price'] as num?)?.toDouble(),
      priceType: json['priceType']?.toString(),
      priceMin: (json['priceMin'] as num?)?.toDouble(),
      priceMax: (json['priceMax'] as num?)?.toDouble(),
      isAvailable: json['isAvailable'] == true,
      category: json['category']?.toString(),
      condition: json['condition']?.toString(),
      brand: json['brand']?.toString(),
      priceUnit: json['priceUnit']?.toString(),
      quantityAvailable: json['quantityAvailable'] as int?,
      serviceArea: json['serviceArea']?.toString(),
      duration: json['duration']?.toString(),
      viewCount: json['viewCount'] as int? ?? 0,
      enquiryCount: json['enquiryCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      boostInfo: boost,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'businessId': businessId,
      'type': type,
      'title': title,
      if (description != null) 'description': description,
      'mediaUrls': mediaUrls,
      if (price != null) 'price': price,
      if (priceType != null) 'priceType': priceType,
      if (priceMin != null) 'priceMin': priceMin,
      if (priceMax != null) 'priceMax': priceMax,
      'isAvailable': isAvailable,
      if (category != null) 'category': category,
      if (condition != null) 'condition': condition,
      if (brand != null) 'brand': brand,
      if (priceUnit != null) 'priceUnit': priceUnit,
      if (quantityAvailable != null) 'quantityAvailable': quantityAvailable,
      if (serviceArea != null) 'serviceArea': serviceArea,
      if (duration != null) 'duration': duration,
    };
  }

  bool get isBoosted => boostInfo?['isBoosted'] == true;
}

class BusinessDashboard {
  final BusinessProfile? profile;
  final int completionPercent;
  final int totalProfileViews;
  final int activeBoosts;
  final int weeklyPostsUsed;
  final int weeklyPostsLimit;
  final bool hasPhonePlan;

  const BusinessDashboard({
    this.profile,
    this.completionPercent = 0,
    this.totalProfileViews = 0,
    this.activeBoosts = 0,
    this.weeklyPostsUsed = 0,
    this.weeklyPostsLimit = 2,
    this.hasPhonePlan = false,
  });

  factory BusinessDashboard.fromJson(Map<String, dynamic> json) {
    final profileJson = json['businessProfile'] as Map<String, dynamic>?;
    final dashJson = json['dashboard'] as Map<String, dynamic>?;
    return BusinessDashboard(
      profile: profileJson != null ? BusinessProfile.fromJson(profileJson) : null,
      completionPercent: dashJson?['completionPercent'] as int? ?? 0,
      totalProfileViews: dashJson?['totalProfileViews'] as int? ?? 0,
      activeBoosts: dashJson?['activeBoosts'] as int? ?? 0,
      weeklyPostsUsed: dashJson?['postCount'] as int? ?? 0,
      weeklyPostsLimit: dashJson?['maxPosts'] as int? ?? 2,
      hasPhonePlan: profileJson?['isPhonePlanActive'] == true,
    );
  }
}

/// Embedded business info returned with marketplace listings.
class MarketplaceBusinessInfo {
  final String? id;
  final String businessName;
  final String? logoUrl;
  final String? localityName;
  final String? city;
  final String? category;
  final bool isVerified;

  const MarketplaceBusinessInfo({
    this.id,
    required this.businessName,
    this.logoUrl,
    this.localityName,
    this.city,
    this.category,
    this.isVerified = false,
  });

  factory MarketplaceBusinessInfo.fromJson(Map<String, dynamic> json) {
    return MarketplaceBusinessInfo(
      id: json['_id']?.toString(),
      businessName: json['businessName']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString(),
      localityName: json['localityName']?.toString(),
      city: json['city']?.toString(),
      category: json['category']?.toString(),
      isVerified: json['isVerified'] == true,
    );
  }
}

/// A listing enriched with business info, used in marketplace feeds.
class MarketplaceListing {
  final BusinessListing listing;
  final MarketplaceBusinessInfo? business;
  final double? distance; // distance in meters from user (geo-query)

  const MarketplaceListing({
    required this.listing,
    this.business,
    this.distance,
  });

  factory MarketplaceListing.fromJson(Map<String, dynamic> json) {
    final businessJson = json['business'] as Map<String, dynamic>?;
    return MarketplaceListing(
      listing: BusinessListing.fromJson(json),
      business: businessJson != null
          ? MarketplaceBusinessInfo.fromJson(businessJson)
          : null,
      distance: (json['distance'] as num?)?.toDouble(),
    );
  }
}

class ListingSubcategory {
  final String name;
  final String slug;

  const ListingSubcategory({required this.name, required this.slug});

  factory ListingSubcategory.fromJson(Map<String, dynamic> json) {
    return ListingSubcategory(
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
    );
  }
}

class ListingCategory {
  final String name;
  final String slug;
  final String? icon;
  final List<ListingSubcategory> subcategories;

  const ListingCategory({
    required this.name,
    required this.slug,
    this.icon,
    required this.subcategories,
  });

  factory ListingCategory.fromJson(Map<String, dynamic> json) {
    return ListingCategory(
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      icon: json['icon']?.toString(),
      subcategories: (json['subcategories'] as List?)
              ?.map((e) => ListingSubcategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class BusinessSubcategory {
  final String name;
  final String slug;

  const BusinessSubcategory({required this.name, required this.slug});

  factory BusinessSubcategory.fromJson(Map<String, dynamic> json) {
    return BusinessSubcategory(
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
    );
  }
}

class BusinessCategory {
  final String name;
  final String slug;
  final String? icon;
  final List<BusinessSubcategory> subcategories;

  const BusinessCategory({
    required this.name,
    required this.slug,
    this.icon,
    required this.subcategories,
  });

  factory BusinessCategory.fromJson(Map<String, dynamic> json) {
    return BusinessCategory(
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      icon: json['icon']?.toString(),
      subcategories: (json['subcategories'] as List?)
              ?.map((e) => BusinessSubcategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}


