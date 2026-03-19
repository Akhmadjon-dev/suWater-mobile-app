class RegionConfig {
  final String name;
  final String country;
  final String countryCode;
  final String city;
  final String state;
  final double centerLng;
  final double centerLat;
  final int zoom;
  // Bounding box: west, east, south, north
  final double viewboxWest;
  final double viewboxEast;
  final double viewboxSouth;
  final double viewboxNorth;

  const RegionConfig({
    required this.name,
    required this.country,
    required this.countryCode,
    required this.city,
    required this.state,
    required this.centerLng,
    required this.centerLat,
    required this.zoom,
    required this.viewboxWest,
    required this.viewboxEast,
    required this.viewboxSouth,
    required this.viewboxNorth,
  });

  /// Nominatim viewbox format: west,south,east,north
  String get viewboxParam =>
      '$viewboxWest,$viewboxSouth,$viewboxEast,$viewboxNorth';
}

const regions = {
  'jizzakh': RegionConfig(
    name: 'Jizzakh',
    country: 'Uzbekistan',
    countryCode: 'uz',
    city: 'Jizzakh',
    state: 'Jizzax',
    centerLng: 67.8422,
    centerLat: 40.1158,
    zoom: 13,
    viewboxWest: 67.78,
    viewboxEast: 67.92,
    viewboxSouth: 40.08,
    viewboxNorth: 40.16,
  ),
  'tashkent': RegionConfig(
    name: 'Tashkent',
    country: 'Uzbekistan',
    countryCode: 'uz',
    city: 'Tashkent',
    state: 'Toshkent',
    centerLng: 69.2401,
    centerLat: 41.2995,
    zoom: 12,
    viewboxWest: 69.12,
    viewboxEast: 69.38,
    viewboxSouth: 41.22,
    viewboxNorth: 41.38,
  ),
  'samarkand': RegionConfig(
    name: 'Samarkand',
    country: 'Uzbekistan',
    countryCode: 'uz',
    city: 'Samarkand',
    state: 'Samarqand',
    centerLng: 66.9597,
    centerLat: 39.6542,
    zoom: 13,
    viewboxWest: 66.90,
    viewboxEast: 67.02,
    viewboxSouth: 39.62,
    viewboxNorth: 39.70,
  ),
};

// Active region — change this to switch deployment target
const activeRegionKey = 'jizzakh';
final activeRegion = regions[activeRegionKey]!;
