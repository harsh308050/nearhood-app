import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CityMapService {
  /// Generates the static map URL for the given latitude and longitude.
  static String getStaticMapUrl({
    required double latitude,
    required double longitude,
    String style = 'stamen_toner_lite',
    int zoom = 12,
  }) {
    final apiKey = (dotenv.env['STADIAMAPS_API_KEY'] ?? '').trim();
    return 'https://tiles.stadiamaps.com/static/$style.png?center=$latitude,$longitude&zoom=$zoom&size=600x400@2x&api_key=$apiKey';
  }

  /// Geocodes a city name and state to retrieve coordinates via Stadia Geocoding REST API.
  static Future<String?> getStaticMapUrlForAddress({
    required String cityName,
    String? stateName,
    String? countryName,
    String style = 'stamen_toner_lite',
  }) async {
    try {
      final apiKey = (dotenv.env['STADIAMAPS_API_KEY'] ?? '').trim();
      if (apiKey.isEmpty) {
        debugPrint("CityMapService: STADIAMAPS_API_KEY is empty");
        return null;
      }

      final queryBuffer = StringBuffer(cityName);
      if (stateName != null && stateName.isNotEmpty) {
        queryBuffer.write(', $stateName');
      }
      if (countryName != null && countryName.isNotEmpty) {
        queryBuffer.write(', $countryName');
      }

      final query = Uri.encodeComponent(queryBuffer.toString());
      final url = Uri.parse(
        'https://api.stadiamaps.com/geocoding/v1/search?text=$query&api_key=$apiKey',
      );

      debugPrint("CityMapService: Requesting geocoding: $url");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List?;
        if (features != null && features.isNotEmpty) {
          final firstFeature = features.first;
          final geometry = firstFeature['geometry'];
          if (geometry != null) {
            final coords = geometry['coordinates'] as List?;
            if (coords != null && coords.length >= 2) {
              // GeoJSON coordinates are [longitude, latitude]
              final double lng = (coords[0] as num).toDouble();
              final double lat = (coords[1] as num).toDouble();
              debugPrint("CityMapService: Geocoded successfully to: lat=$lat, lng=$lng");
              return getStaticMapUrl(
                latitude: lat,
                longitude: lng,
                style: style,
              );
            }
          }
        }
        debugPrint("CityMapService: No geocoding features found for $queryBuffer");
      } else {
        debugPrint("CityMapService: Geocoding failed with status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("CityMapService error during HTTP geocoding: $e");
    }
    return null;
  }
}
