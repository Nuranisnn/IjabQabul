/// Approximate coordinates for Malaysian cities used by wedding planners.
class MalaysiaLocations {
  static const Map<String, ({double lat, double lng, String state})> cities = {
    'Shah Alam': (lat: 3.0738, lng: 101.5183, state: 'Selangor'),
    'Damansara': (lat: 3.1579, lng: 101.6122, state: 'Selangor'),
    'Kajang': (lat: 2.9927, lng: 101.7909, state: 'Selangor'),
    'Kuala Lumpur': (lat: 3.1390, lng: 101.6869, state: 'Kuala Lumpur'),
    'Petaling Jaya': (lat: 3.1073, lng: 101.6067, state: 'Selangor'),
    'Penang': (lat: 5.4141, lng: 100.3288, state: 'Penang'),
    'Johor Bahru': (lat: 1.4927, lng: 103.7414, state: 'Johor'),
    'Ipoh': (lat: 4.5975, lng: 101.0901, state: 'Perak'),
    'Melaka': (lat: 2.1896, lng: 102.2501, state: 'Melaka'),
    'Kota Kinabalu': (lat: 5.9804, lng: 116.0735, state: 'Sabah'),
    'Kuching': (lat: 1.5535, lng: 110.3593, state: 'Sarawak'),
  };

  /// State centroid used when only the state is known (no GPS).
  static const Map<String, ({double lat, double lng})> stateCentroids = {
    'Selangor': (lat: 3.0738, lng: 101.5183),
    'Kuala Lumpur': (lat: 3.1390, lng: 101.6869),
    'Johor': (lat: 1.9344, lng: 103.3587),
    'Penang': (lat: 5.4164, lng: 100.3327),
    'Perak': (lat: 4.5921, lng: 101.0901),
    'Kedah': (lat: 6.1184, lng: 100.3685),
    'Melaka': (lat: 2.1896, lng: 102.2501),
    'Negeri Sembilan': (lat: 2.7258, lng: 101.9424),
    'Pahang': (lat: 3.8126, lng: 103.3256),
    'Kelantan': (lat: 6.1254, lng: 102.2381),
    'Terengganu': (lat: 5.3117, lng: 103.1324),
    'Perlis': (lat: 6.4449, lng: 100.2048),
    'Sabah': (lat: 5.9788, lng: 116.0753),
    'Sarawak': (lat: 1.5535, lng: 110.3593),
  };

  static ({double lat, double lng})? coordsForState(String state) {
    return stateCentroids[state];
  }
}
