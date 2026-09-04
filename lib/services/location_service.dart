import 'package:geolocator/geolocator.dart';

class LocationService {
  // ============================================================
  // CHECK WHETHER LOCATION SERVICES ARE ENABLED
  // ============================================================

  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // ============================================================
  // CHECK / REQUEST LOCATION PERMISSION
  // ============================================================

  static Future<LocationPermission> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  // ============================================================
  // GET CURRENT LOCATION
  // ============================================================

  static Future<Position?> getCurrentLocation() async {
    try {
      // Check whether location services are enabled.
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return null;
      }

      // Check/request permission.
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Permission still denied.
      if (permission == LocationPermission.denied) {
        return null;
      }

      // Permission permanently denied.
      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Get the current position.
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      return position;
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // GET LOCATION AS SIMPLE DATA
  // ============================================================

  static Future<Map<String, dynamic>?> getLocationData() async {
    final Position? position = await getCurrentLocation();

    if (position == null) {
      return null;
    }

    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': position.accuracy,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
