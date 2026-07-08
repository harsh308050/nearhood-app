import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiUrls {
  final String baseUrl = dotenv.env['BASE_URL']!;

  String get health => '$baseUrl/health';

  String get authRegister => '$baseUrl/auth/register';
  String get authGoogleSignIn => '$baseUrl/auth/google-signin';
  String get authEmailSignIn => '$baseUrl/auth/email-signin';

  String get userProfile => '$baseUrl/users/profile';
  String get userSendOtp => '$baseUrl/users/send-otp';
  String get userVerifyOtp => '$baseUrl/users/verify-otp';

  String get locationCountries => '$baseUrl/locations/countries';

  String get locationStates => '$baseUrl/locations/states';

  String locationCities({required String stateName}) {
    return '$baseUrl/locations/cities/$stateName';
  }

  String locationLocalities({
    required String input,
    String? city,
    String? stateName,
    int? page,
    int? limit,
  }) {
    final params = <String, String>{
      'input': input,
      if (city != null && city.isNotEmpty) 'city': city,
      if (stateName != null && stateName.isNotEmpty) 'stateName': stateName,
      if (page != null) 'page': page.toString(),
      if (limit != null) 'limit': limit.toString(),
    };

    final query = Uri(queryParameters: params).query;
    return '$baseUrl/locations/localities?$query';
  }

  String get chatUploadMedia => '$baseUrl/chat/upload-media';

  // Business
  String get businessRegister => '$baseUrl/business/register';
  String get businessMyProfile => '$baseUrl/business/my/profile';
  String get businessUploadMedia => '$baseUrl/business/upload-media';
  String businessPublicProfile(String id) => '$baseUrl/business/$id';
  String businessUpdate(String id) => '$baseUrl/business/$id';

  // Business Listings
  String businessListings(String id) => '$baseUrl/business/$id/listings';
  String businessListingUpdate(String businessId, String listingId) =>
      '$baseUrl/business/$businessId/listings/$listingId';
  String businessListingAvailability(String businessId, String listingId) =>
      '$baseUrl/business/$businessId/listings/$listingId/availability';

  // Boost
  String businessBoost(String id) => '$baseUrl/business/$id/boost';
  String businessBoosts(String id) => '$baseUrl/business/$id/boosts';

  // Phone Plan
  String get businessPhonePlan => '$baseUrl/business/plans/phone';

  // Analytics
  String businessAnalytics(String id) => '$baseUrl/business/$id/analytics';
}
