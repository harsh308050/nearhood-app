class RegisterRequest {
  final String fullName;

  const RegisterRequest({required this.fullName});

  Map<String, dynamic> toJson() {
    return {'fullName': fullName};
  }
}

class CountryRef {
  final String? isoCode;
  final String? name;

  const CountryRef({this.isoCode, this.name});

  Map<String, dynamic> toJson() {
    return {
      if (isoCode != null) 'isoCode': isoCode,
      if (name != null) 'name': name,
    };
  }
}

class StateRef {
  final String? isoCode;
  final String? name;

  const StateRef({this.isoCode, this.name});

  Map<String, dynamic> toJson() {
    return {
      if (isoCode != null) 'isoCode': isoCode,
      if (name != null) 'name': name,
    };
  }
}

class CityRef {
  final String? name;

  const CityRef({this.name});

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
    };
  }
}

class LocalityRef {
  final String? placeId;
  final String? name;

  const LocalityRef({this.placeId, this.name});

  Map<String, dynamic> toJson() {
    return {
      if (placeId != null) 'placeId': placeId,
      if (name != null) 'name': name,
    };
  }
}

class Coordinates {
  final double? lat;
  final double? lng;

  const Coordinates({this.lat, this.lng});

  Map<String, dynamic> toJson() {
    return {
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    };
  }
}

class LocationUpdate {
  final CountryRef? country;
  final StateRef? state;
  final CityRef? city;
  final LocalityRef? locality;
  final String? pinCode;
  final String? flatBuilding;
  final String? streetLandmark;
  final Coordinates? coordinates;

  const LocationUpdate({
    this.country,
    this.state,
    this.city,
    this.locality,
    this.pinCode,
    this.flatBuilding,
    this.streetLandmark,
    this.coordinates,
  });

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

class OnboardingUpdate {
  final bool? isPhoneSkipped;
  final bool? hasAgreedToRules;
  final bool? isPhoneVerified;

  const OnboardingUpdate({
    this.isPhoneSkipped,
    this.hasAgreedToRules,
    this.isPhoneVerified,
  });

  Map<String, dynamic> toJson() {
    return {
      if (isPhoneSkipped != null) 'isPhoneSkipped': isPhoneSkipped,
      if (hasAgreedToRules != null) 'hasAgreedToRules': hasAgreedToRules,
      if (isPhoneVerified != null) 'isPhoneVerified': isPhoneVerified,
    };
  }
}

class UpdateRegisterRequest {
  final LocationUpdate? location;
  final OnboardingUpdate? onboarding;

  const UpdateRegisterRequest({this.location, this.onboarding});

  Map<String, dynamic> toJson() {
    return {
      if (location != null) 'location': location!.toJson(),
      if (onboarding != null) 'onboarding': onboarding!.toJson(),
    };
  }
}

class UpdateProfileRequest {
  final String? fullName;
  final String? profilePhotoUrl;

  const UpdateProfileRequest({this.fullName, this.profilePhotoUrl});

  Map<String, dynamic> toJson() {
    return {
      if (fullName != null) 'fullName': fullName,
      if (profilePhotoUrl != null) 'profilePhotoUrl': profilePhotoUrl,
    };
  }
}

class SendOtpRequest {
  final String phoneNumber;
  final String countryCode;

  const SendOtpRequest({required this.phoneNumber, this.countryCode = '+91'});

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'countryCode': countryCode,
    };
  }
}

class VerifyOtpRequest {
  final String otp;

  const VerifyOtpRequest({required this.otp});

  Map<String, dynamic> toJson() {
    return {'otp': otp};
  }
}
