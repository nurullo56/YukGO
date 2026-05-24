import 'dart:math';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static const _cities = {
    'Toshkent':  [41.2995, 69.2401],
    'Samarqand': [39.6542, 66.9597],
    'Buxoro':    [39.7747, 64.4286],
    'Namangan':  [41.0011, 71.6724],
    'Andijon':   [40.7821, 72.3442],
    "Farg'ona":  [40.3864, 71.7864],
    'Qarshi':    [38.8606, 65.7882],
    'Nukus':     [42.4626, 59.6166],
    'Urganch':   [41.5503, 60.6341],
    'Termiz':    [37.2241, 67.2783],
    'Jizzax':    [40.1158, 67.8422],
    'Sirdaryo':  [40.8355, 68.6638],
    'Navoiy':    [40.1033, 65.3794],
    'Guliston':  [40.4897, 68.7801],
  };

  /// Returns the nearest city name or null if permission denied / error.
  static Future<String?> detectNearestCity() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );

      String? nearest;
      double minDist = double.infinity;
      for (final entry in _cities.entries) {
        final d = _dist(pos.latitude, pos.longitude, entry.value[0], entry.value[1]);
        if (d < minDist) {
          minDist = d;
          nearest = entry.key;
        }
      }
      return nearest;
    } catch (_) {
      return null;
    }
  }

  static double _dist(double lat1, double lon1, double lat2, double lon2) {
    final dLat = lat1 - lat2;
    final dLon = lon1 - lon2;
    return sqrt(dLat * dLat + dLon * dLon);
  }
}
