import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nearhood/core/network/api_urls.dart';
import 'package:nearhood/core/network/http_actions.dart';
import 'package:nearhood/core/network/http_response.dart';

class BusinessDataSource {
  final ApiUrls _apiUrls = ApiUrls();
  final http.Client _client = http.Client();

  Future<HttpActions> _http() async {
    return HttpActions(
      client: _client,
      baseUrl: _apiUrls.baseUrl,
      tokenProvider: () async =>
          FirebaseAuth.instance.currentUser?.getIdToken(),
    );
  }

  // ─── Profile ────────────────────────────────────────────────────────────────

  Future<HttpResponse> checkBusinessProfile() async {
    final httpActions = await _http();
    return httpActions.get('/business/my/profile');
  }

  Future<HttpResponse> registerBusiness(Map<String, dynamic> data) async {
    final httpActions = await _http();
    return httpActions.post('/business/register', body: data);
  }

  Future<HttpResponse> updateBusiness(
      String businessId, Map<String, dynamic> data) async {
    final httpActions = await _http();
    return httpActions.put('/business/$businessId', body: data);
  }

  Future<HttpResponse> uploadMedia(String filePath, String field) async {
    final httpActions = await _http();
    final file = await http.MultipartFile.fromPath(field, filePath);
    return httpActions.postMultipart('/business/upload-media', files: [file]);
  }

  // ─── Dashboard ──────────────────────────────────────────────────────────────

  Future<HttpResponse> getDashboard() async {
    final httpActions = await _http();
    return httpActions.get('/business/my/profile');
  }

  // ─── Listings ───────────────────────────────────────────────────────────────

  Future<HttpResponse> getListings(String businessId, String type) async {
    final httpActions = await _http();
    return httpActions.get(
      '/business/$businessId/listings',
      queryParameters: {'type': type},
    );
  }

  Future<HttpResponse> addListing(
      String businessId, Map<String, dynamic> data) async {
    final httpActions = await _http();
    return httpActions.post('/business/$businessId/listings', body: data);
  }

  Future<HttpResponse> updateListing(
      String businessId, String listingId, Map<String, dynamic> data) async {
    final httpActions = await _http();
    return httpActions.put(
      '/business/$businessId/listings/$listingId',
      body: data,
    );
  }

  Future<HttpResponse> deleteListing(
      String businessId, String listingId) async {
    final httpActions = await _http();
    return httpActions.delete('/business/$businessId/listings/$listingId');
  }

  Future<HttpResponse> toggleAvailability(
      String businessId, String listingId) async {
    final httpActions = await _http();
    return httpActions.patch(
      '/business/$businessId/listings/$listingId/availability',
    );
  }

  // ─── Marketplace ────────────────────────────────────────────────────────────

  Future<HttpResponse> getMarketplaceFeed({
    required double lat,
    required double lng,
    int? radius,
    String? category,
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    final httpActions = await _http();
    final params = <String, String>{
      'lat': lat.toString(),
      'lng': lng.toString(),
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (radius != null) params['radius'] = radius.toString();
    if (category != null) params['category'] = category;
    if (type != null) params['type'] = type;
    return httpActions.get('/marketplace', queryParameters: params);
  }

  Future<HttpResponse> getMarketplaceStories({
    required double lat,
    required double lng,
  }) async {
    final httpActions = await _http();
    return httpActions.get(
      '/marketplace/stories',
      queryParameters: {
        'lat': lat.toString(),
        'lng': lng.toString(),
      },
    );
  }

  // ─── Boost ──────────────────────────────────────────────────────────────────

  Future<HttpResponse> purchaseBoost(
      String businessId, Map<String, dynamic> data) async {
    final httpActions = await _http();
    return httpActions.post('/business/$businessId/boost', body: data);
  }

  Future<HttpResponse> getActiveBoosts(String businessId) async {
    final httpActions = await _http();
    return httpActions.get('/business/$businessId/boosts');
  }

  // ─── Phone Plan ─────────────────────────────────────────────────────────────

  Future<HttpResponse> purchasePhonePlan() async {
    final httpActions = await _http();
    return httpActions.post('/business/plans/phone');
  }

  Future<HttpResponse> cancelPhonePlan() async {
    final httpActions = await _http();
    return httpActions.delete('/business/plans/phone');
  }

  Future<HttpResponse> getListingCategories() async {
    final httpActions = await _http();
    return httpActions.get('/business/listings/categories');
  }

  Future<HttpResponse> getBusinessProfileCategories() async {
    final httpActions = await _http();
    return httpActions.get('/business/profile/categories');
  }

  void dispose() {
    _client.close();
  }
}
