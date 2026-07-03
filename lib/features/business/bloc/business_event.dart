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
