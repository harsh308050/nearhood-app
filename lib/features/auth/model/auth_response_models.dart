class AuthResponseData {
  final bool? isNewUser;
  final UserProfile? user;

  const AuthResponseData({this.isNewUser, this.user});

  factory AuthResponseData.fromJson(Map<String, dynamic> json) {
    return AuthResponseData(
      isNewUser: json['isNewUser'] is bool ? json['isNewUser'] as bool : null,
      user: json['user'] is Map<String, dynamic>
          ? UserProfile.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

class OtpResponseData {
  final int? expiresInMinutes;

  const OtpResponseData({this.expiresInMinutes});

  factory OtpResponseData.fromJson(Map<String, dynamic> json) {
    return OtpResponseData(
      expiresInMinutes: json['expiresInMinutes'] is int
          ? json['expiresInMinutes'] as int
          : null,
    );
  }
}

class UserProfile {
  final String? id;
  final String? firebaseUid;
  final String? fullName;
  final String? email;
  final String? profilePhotoUrl;
  final String? authProvider;
  final UserLocation? location;
  final PhoneInfo? phone;
  final OnboardingInfo? onboarding;
  final String? role;
  final bool? isVerified;
  final String? status;
  final String? createdAt;
  final String? businessProfileId;

  const UserProfile({
    this.id,
    this.firebaseUid,
    this.fullName,
    this.email,
    this.profilePhotoUrl,
    this.authProvider,
    this.location,
    this.phone,
    this.onboarding,
    this.role,
    this.isVerified,
    this.status,
    this.createdAt,
    this.businessProfileId,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      firebaseUid: json['firebaseUid']?.toString(),
      fullName: json['fullName']?.toString(),
      email: json['email']?.toString(),
      profilePhotoUrl: json['profilePhotoUrl']?.toString(),
      authProvider: json['authProvider']?.toString(),
      location: json['location'] is Map<String, dynamic>
          ? UserLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      phone: json['phone'] is Map<String, dynamic>
          ? PhoneInfo.fromJson(json['phone'] as Map<String, dynamic>)
          : null,
      onboarding: json['onboarding'] is Map<String, dynamic>
          ? OnboardingInfo.fromJson(
              json['onboarding'] as Map<String, dynamic>,
            )
          : null,
      role: json['role']?.toString(),
      isVerified: json['isVerified'] is bool ? json['isVerified'] as bool : null,
      status: json['status']?.toString(),
      createdAt: json['createdAt']?.toString(),
      businessProfileId: json['businessProfileId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (firebaseUid != null) 'firebaseUid': firebaseUid,
      if (fullName != null) 'fullName': fullName,
      if (email != null) 'email': email,
      if (profilePhotoUrl != null) 'profilePhotoUrl': profilePhotoUrl,
      if (authProvider != null) 'authProvider': authProvider,
      if (location != null) 'location': location!.toJson(),
      if (phone != null) 'phone': phone!.toJson(),
      if (onboarding != null) 'onboarding': onboarding!.toJson(),
      if (role != null) 'role': role,
      if (isVerified != null) 'isVerified': isVerified,
      if (status != null) 'status': status,
      if (createdAt != null) 'createdAt': createdAt,
      if (businessProfileId != null) 'businessProfileId': businessProfileId,
    };
  }
}

class UserLocation {
  final CountryInfo? country;
  final StateInfo? state;
  final CityInfo? city;
  final LocalityInfo? locality;
  final String? pinCode;
  final String? flatBuilding;
  final String? streetLandmark;
  final CoordinatesInfo? coordinates;

  const UserLocation({
    this.country,
    this.state,
    this.city,
    this.locality,
    this.pinCode,
    this.flatBuilding,
    this.streetLandmark,
    this.coordinates,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      country: json['country'] is Map<String, dynamic>
          ? CountryInfo.fromJson(json['country'] as Map<String, dynamic>)
          : null,
      state: json['state'] is Map<String, dynamic>
          ? StateInfo.fromJson(json['state'] as Map<String, dynamic>)
          : null,
      city: json['city'] is Map<String, dynamic>
          ? CityInfo.fromJson(json['city'] as Map<String, dynamic>)
          : null,
      locality: json['locality'] is Map<String, dynamic>
          ? LocalityInfo.fromJson(json['locality'] as Map<String, dynamic>)
          : null,
      pinCode: json['pinCode']?.toString(),
      flatBuilding: json['flatBuilding']?.toString(),
      streetLandmark: json['streetLandmark']?.toString(),
      coordinates: json['coordinates'] is Map<String, dynamic>
          ? CoordinatesInfo.fromJson(
              json['coordinates'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (country != null) 'country': country!.toJson(),
      if (state != null) 'state': state!.toJson(),
      if (city != null) 'city': city!.toJson(),
      if (locality != null) 'locality': locality!.toJson(),
      if (pinCode != null) 'pinCode': pinCode,
      if (flatBuilding != null) 'flatBuilding': flatBuilding,
      if (streetLandmark != null) 'streetLandmark': streetLandmark,
      if (coordinates != null) 'coordinates': coordinates!.toJson(),
    };
  }
}

class CountryInfo {
  final String? isoCode;
  final String? name;
  final String? phonecode;
  final String? flag;

  const CountryInfo({this.isoCode, this.name, this.phonecode, this.flag});

  factory CountryInfo.fromJson(Map<String, dynamic> json) {
    return CountryInfo(
      isoCode: json['isoCode']?.toString(),
      name: json['name']?.toString(),
      phonecode: json['phonecode']?.toString(),
      flag: json['flag']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (isoCode != null) 'isoCode': isoCode,
      if (name != null) 'name': name,
      if (phonecode != null) 'phonecode': phonecode,
      if (flag != null) 'flag': flag,
    };
  }
}

class StateInfo {
  final String? isoCode;
  final String? name;
  final String? countryCode;

  const StateInfo({this.isoCode, this.name, this.countryCode});

  factory StateInfo.fromJson(Map<String, dynamic> json) {
    return StateInfo(
      isoCode: json['isoCode']?.toString(),
      name: json['name']?.toString(),
      countryCode: json['countryCode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (isoCode != null) 'isoCode': isoCode,
      if (name != null) 'name': name,
      if (countryCode != null) 'countryCode': countryCode,
    };
  }
}

class CityInfo {
  final String? name;
  final String? stateCode;
  final String? countryCode;

  const CityInfo({this.name, this.stateCode, this.countryCode});

  factory CityInfo.fromJson(Map<String, dynamic> json) {
    return CityInfo(
      name: json['name']?.toString(),
      stateCode: json['stateCode']?.toString(),
      countryCode: json['countryCode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (stateCode != null) 'stateCode': stateCode,
      if (countryCode != null) 'countryCode': countryCode,
    };
  }
}

class LocalityInfo {
  final String? placeId;
  final String? name;
  final String? fullAddress;

  const LocalityInfo({this.placeId, this.name, this.fullAddress});

  factory LocalityInfo.fromJson(Map<String, dynamic> json) {
    return LocalityInfo(
      placeId: json['placeId']?.toString(),
      name: json['name']?.toString(),
      fullAddress: json['fullAddress']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (placeId != null) 'placeId': placeId,
      if (name != null) 'name': name,
      if (fullAddress != null) 'fullAddress': fullAddress,
    };
  }
}

class CoordinatesInfo {
  final double? lat;
  final double? lng;

  const CoordinatesInfo({this.lat, this.lng});

  factory CoordinatesInfo.fromJson(Map<String, dynamic> json) {
    return CoordinatesInfo(
      lat: json['lat'] is num ? (json['lat'] as num).toDouble() : null,
      lng: json['lng'] is num ? (json['lng'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    };
  }
}

class PhoneInfo {
  final String? number;
  final String? countryCode;
  final bool? isVerified;

  const PhoneInfo({this.number, this.countryCode, this.isVerified});

  factory PhoneInfo.fromJson(Map<String, dynamic> json) {
    return PhoneInfo(
      number: json['number']?.toString(),
      countryCode: json['countryCode']?.toString(),
      isVerified: json['isVerified'] is bool
          ? json['isVerified'] as bool
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (number != null) 'number': number,
      if (countryCode != null) 'countryCode': countryCode,
      if (isVerified != null) 'isVerified': isVerified,
    };
  }
}

class OnboardingInfo {
  final bool? isLocationSet;
  final bool? isAddressSet;
  final bool? isPhoneVerified;
  final bool? isPhoneSkipped;
  final bool? hasAgreedToRules;
  final bool? isComplete;
  final int? currentStep;
  final int? totalSteps;

  const OnboardingInfo({
    this.isLocationSet,
    this.isAddressSet,
    this.isPhoneVerified,
    this.isPhoneSkipped,
    this.hasAgreedToRules,
    this.isComplete,
    this.currentStep,
    this.totalSteps,
  });

  factory OnboardingInfo.fromJson(Map<String, dynamic> json) {
    return OnboardingInfo(
      isLocationSet:
          json['isLocationSet'] is bool ? json['isLocationSet'] as bool : null,
      isAddressSet:
          json['isAddressSet'] is bool ? json['isAddressSet'] as bool : null,
      isPhoneVerified:
          json['isPhoneVerified'] is bool ? json['isPhoneVerified'] as bool : null,
      isPhoneSkipped:
          json['isPhoneSkipped'] is bool ? json['isPhoneSkipped'] as bool : null,
      hasAgreedToRules:
          json['hasAgreedToRules'] is bool ? json['hasAgreedToRules'] as bool : null,
      isComplete:
          json['isComplete'] is bool ? json['isComplete'] as bool : null,
      currentStep:
          json['currentStep'] is int ? json['currentStep'] as int : null,
      totalSteps:
          json['totalSteps'] is int ? json['totalSteps'] as int : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (isLocationSet != null) 'isLocationSet': isLocationSet,
      if (isAddressSet != null) 'isAddressSet': isAddressSet,
      if (isPhoneVerified != null) 'isPhoneVerified': isPhoneVerified,
      if (isPhoneSkipped != null) 'isPhoneSkipped': isPhoneSkipped,
      if (hasAgreedToRules != null) 'hasAgreedToRules': hasAgreedToRules,
      if (isComplete != null) 'isComplete': isComplete,
      if (currentStep != null) 'currentStep': currentStep,
      if (totalSteps != null) 'totalSteps': totalSteps,
    };
  }
}
