import 'package:weather_app/domain/entities/location_entity.dart';

class LocationDto {
  final String name;
  final String region;
  final String country;
  final double lat;
  final double lon;

  LocationDto({
    required this.name,
    required this.region,
    required this.country,
    required this.lat,
    required this.lon,
  });

  factory LocationDto.fromJson(Map<String, dynamic> j) => LocationDto(
        name: j['name'] ?? '',
        region: j['region'] ?? '',
        country: j['country'] ?? '',
        lat: (j['lat'] as num).toDouble(),
        lon: (j['lon'] as num).toDouble(),
      );

  LocationEntity toEntity() => LocationEntity(
        name: name,
        region: region,
        country: country,
        lat: lat,
        lon: lon,
      );
}