class LocationEntity {
  final String name;
  final String region;   
  final String country;  
  final double lat;
  final double lon;
  const LocationEntity({
    required this.name, required this.region, required this.country,
    required this.lat, required this.lon,
  });

  String get displayName =>
      region.isNotEmpty && region != name ? '$name, $region, $country'
                                          : '$name, $country';
}