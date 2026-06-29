import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class UserLocation {
  const UserLocation({
    required this.latitude,
    required this.longitude,
    this.state,
    this.city,
    this.fromGps = false,
  });

  final double latitude;
  final double longitude;
  final String? state;
  final String? city;
  final bool fromGps;
}

class LocationService {
  Future<bool> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<UserLocation?> getCurrentLocation() async {
    final hasPermission = await ensurePermission();
    if (!hasPermission) {
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );

      String? state;
      String? city;
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          state = _normalizeMalaysianState(
            place.administrativeArea ?? place.subAdministrativeArea,
          );
          city = place.locality ?? place.subLocality;
        }
      } catch (_) {
        // Reverse geocoding may fail on some platforms; GPS coords still usable.
      }

      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        state: state,
        city: city,
        fromGps: true,
      );
    } catch (_) {
      return null;
    }
  }

  String? _normalizeMalaysianState(String? raw) {
    if (raw == null || raw.isEmpty) return null;

    final normalized = raw.trim();
    const mapping = {
      'Wilayah Persekutuan Kuala Lumpur': 'Kuala Lumpur',
      'Federal Territory of Kuala Lumpur': 'Kuala Lumpur',
      'WP Kuala Lumpur': 'Kuala Lumpur',
      'Selangor Darul Ehsan': 'Selangor',
      'Pulau Pinang': 'Penang',
      'Penang': 'Penang',
      'Johor Darul Ta\'zim': 'Johor',
      'Melaka': 'Melaka',
      'Malacca': 'Melaka',
      'Negeri Sembilan Darul Khusus': 'Negeri Sembilan',
    };

    if (mapping.containsKey(normalized)) {
      return mapping[normalized];
    }

    for (final entry in mapping.entries) {
      if (normalized.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }

    return normalized;
  }
}
