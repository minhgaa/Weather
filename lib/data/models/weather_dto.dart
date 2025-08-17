import 'package:weather_app/domain/entities/weather_entity.dart';

class WeatherDto {
  final WeatherEntity entity;
  WeatherDto(this.entity);

  factory WeatherDto.fromJson(Map<String, dynamic> j) => WeatherDto(
    WeatherEntity(
      locationName: j['location']['name'],
      tempC: (j['current']['temp_c'] as num).toDouble(),
      windKph: (j['current']['wind_kph'] as num).toDouble(),
      humidity: j['current']['humidity'] as int,
      conditionText: j['current']['condition']['text'],
      iconUrl: 'https:${j['current']['condition']['icon']}',
      lastUpdated: DateTime.parse(j['current']['last_updated']),
    ),
  );
}