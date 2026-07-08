abstract class BusinessEvent {}

class CheckBusinessProfile extends BusinessEvent {}

class ResetRegisterStatus extends BusinessEvent {}

class FetchBusinessProfile extends BusinessEvent {}

class RegisterBusiness extends BusinessEvent {
  final String businessType;
  final String businessName;
  final String category;
  final String? subCategory;
  final String description;
  final String address;
  final String logoUrl;
  final String? coverUrl;
  final String? phone;
  final String? website;
  final Map<String, dynamic>? workingHours;
  final String? gstNumber;
  final String? localityId;
  final String? localityName;
  final String? city;
  final double? latitude;
  final double? longitude;

  RegisterBusiness({
    required this.businessType,
    required this.businessName,
    required this.category,
    this.subCategory,
    required this.description,
    required this.address,
    required this.logoUrl,
    this.coverUrl,
    this.phone,
    this.website,
    this.workingHours,
    this.gstNumber,
    this.localityId,
    this.localityName,
    this.city,
    this.latitude,
    this.longitude,
  });
}

class UpdateBusinessProfile extends BusinessEvent {
  final String? businessType;
  final String? businessName;
  final String? category;
  final String? subCategory;
  final String? description;
  final String? address;
  final String? logoUrl;
  final String? coverUrl;
  final String? phone;
  final String? website;
  final Map<String, dynamic>? workingHours;
  final String? gstNumber;
  final String? localityId;
  final String? localityName;
  final String? city;
  final double? latitude;
  final double? longitude;

  UpdateBusinessProfile({
    this.businessType,
    this.businessName,
    this.category,
    this.subCategory,
    this.description,
    this.address,
    this.logoUrl,
    this.coverUrl,
    this.phone,
    this.website,
    this.workingHours,
    this.gstNumber,
    this.localityId,
    this.localityName,
    this.city,
    this.latitude,
    this.longitude,
  });
}

class UploadBusinessLogo extends BusinessEvent {
  final String filePath;
  UploadBusinessLogo(this.filePath);
}

class UploadBusinessCover extends BusinessEvent {
  final String filePath;
  UploadBusinessCover(this.filePath);
}

// ─── Dashboard ────────────────────────────────────────────────────────────────

class LoadDashboard extends BusinessEvent {}

// ─── Listings ────────────────────────────────────────────────────────────────

class LoadListings extends BusinessEvent {
  final String type; // 'product' | 'service'
  LoadListings(this.type);
}

class AddListing extends BusinessEvent {
  final String type;
  final String title;
  final String? description;
  final List<String> mediaUrls;
  final double? price;
  final String? priceType;
  final double? priceMin;
  final double? priceMax;
  final bool isAvailable;
  final String? category;
  final String? condition;
  final String? brand;
  final String? priceUnit;
  final int? quantityAvailable;
  final String? serviceArea;
  final String? duration;
  AddListing({
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
  });
}

class UpdateListing extends BusinessEvent {
  final String listingId;
  final String? title;
  final String? description;
  final List<String>? mediaUrls;
  final double? price;
  final String? priceType;
  final double? priceMin;
  final double? priceMax;
  final bool? isAvailable;
  final String? category;
  final String? condition;
  final String? brand;
  final String? priceUnit;
  final int? quantityAvailable;
  final String? serviceArea;
  final String? duration;
  UpdateListing({
    required this.listingId,
    this.title,
    this.description,
    this.mediaUrls,
    this.price,
    this.priceType,
    this.priceMin,
    this.priceMax,
    this.isAvailable,
    this.category,
    this.condition,
    this.brand,
    this.priceUnit,
    this.quantityAvailable,
    this.serviceArea,
    this.duration,
  });
}

class DeleteListing extends BusinessEvent {
  final String listingId;
  DeleteListing(this.listingId);
}

class ToggleListingAvailability extends BusinessEvent {
  final String listingId;
  ToggleListingAvailability(this.listingId);
}

// ─── Boost ────────────────────────────────────────────────────────────────────

class PurchaseBoost extends BusinessEvent {
  final String listingId;
  final String boostType; // 'listing' | 'post' | 'profile'
  PurchaseBoost({required this.listingId, required this.boostType});
}

class LoadActiveBoosts extends BusinessEvent {}

// ─── Phone Plan ──────────────────────────────────────────────────────────────

class PurchasePhonePlan extends BusinessEvent {}

class CancelPhonePlan extends BusinessEvent {}

class FetchListingCategories extends BusinessEvent {}

class FetchBusinessCategories extends BusinessEvent {}

