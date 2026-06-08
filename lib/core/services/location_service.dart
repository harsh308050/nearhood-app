import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Check permissions and get the current position
  Future<Position> getCurrentPosition() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      throw Exception('Location permissions are permanently denied. Please enable them in the settings page that was opened.');
    }

    bool serviceEnabled;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      
      // Wait for the user to enable location services (timeout after 30 seconds)
      try {
        await Geolocator.getServiceStatusStream()
            .firstWhere((status) => status == ServiceStatus.enabled)
            .timeout(const Duration(seconds: 30));
      } catch (e) {
        // If it times out or fails, check one last time before throwing
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          throw Exception('Location services are still disabled. Please enable them and tap again.');
        }
      }
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  /// Get the full Placemark from coordinates
  Future<Placemark?> getPlacemarkFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        return placemarks.first;
      }
    } catch (e) {
      // Ignore geocoding errors and return null
    }
    return null;
  }

  /// Get the locality string (postal code or subLocality) from coordinates
  Future<String?> getLocalityFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        // Prefer postal code for better accuracy with the backend
        if (placemark.postalCode != null && placemark.postalCode!.isNotEmpty) {
          return placemark.postalCode;
        }
        // Fallback to subLocality or locality
        if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
          return placemark.subLocality;
        }
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          return placemark.locality;
        }
      }
    } catch (e) {
      // Ignore geocoding errors and return null
    }
    return null;
  }
}
