import 'package:geolocator/geolocator.dart';

class LocationService {
  // Check if student is within `allowedRadiusMeters` of the session's location
  static Future<bool> isWithinRange(double targetLat, double targetLng, {double allowedRadiusMeters = 50.0}) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied, we cannot request permissions.');
    }

    final Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final double distanceInMeters = Geolocator.distanceBetween(
      targetLat,
      targetLng,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    return distanceInMeters <= allowedRadiusMeters;
  }
}
