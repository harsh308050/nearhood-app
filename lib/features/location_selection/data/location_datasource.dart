import 'package:nearhood/core/network/api_urls.dart';
import 'package:nearhood/core/network/http_actions.dart';
import 'package:nearhood/features/location_selection/model/location_models.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class LocationRemoteDataSource extends HttpActions {
  final ApiUrls urls;

  LocationRemoteDataSource({
    http.Client? client,
    ApiUrls? urls,
    Future<String?> Function()? tokenProvider,
  }) : urls = urls ?? ApiUrls(),
       super(
         client: client ?? http.Client(),
         baseUrl: (urls ?? ApiUrls()).baseUrl,
         tokenProvider:
             tokenProvider ??
             () async => FirebaseAuth.instance.currentUser?.getIdToken(),
       );

  Future<List<LocationModel>> getCountries() async {
    final response = await get(urls.locationCountries, includeAuth: false);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> list = response.data['data']['countries'] ?? [];
      return list.map((e) => LocationModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load countries');
  }

  Future<List<LocationModel>> getStates() async {
    final response = await get(urls.locationStates, includeAuth: false);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> list = response.data['data']['states'] ?? [];
      return list.map((e) => LocationModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load states');
  }

  Future<List<LocationModel>> getCities({required String stateName}) async {
    final response = await get(
      urls.locationCities(stateName: stateName),
      includeAuth: false,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> list = response.data['data']['cities'] ?? [];
      return list.map((e) => LocationModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load cities');
  }

  Future<List<LocationModel>> searchLocalities({
    required String input,
    String? city,
    String? stateName,
    int page = -1,
    int limit = 20,
  }) async {
    final response = await get(
      urls.locationLocalities(
        input: input,
        city: city,
        stateName: stateName,
        page: page,
        limit: limit,
      ),
      includeAuth: false,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> list = response.data['data']['localities'] ?? [];
      return list.map((e) => LocationModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load localities');
  }
}
