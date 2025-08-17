import 'package:weather_app/domain/entities/daily_forecast_entity.dart';

class ForecastDto {
  final List<ForecastEntity> days;
  ForecastDto(this.days);

  factory ForecastDto.fromJson(Map<String, dynamic> j) {
    if (j['forecast'] == null || j['forecast']['forecastday'] == null) {
      return ForecastDto([]);
    }

    final list = (j['forecast']['forecastday'] as List).map((d) {
      final day = d['day'] ?? {};
      return ForecastEntity(
        date: DateTime.tryParse(d['date'] ?? '') ?? DateTime.now(),
        minTempC: (day['mintemp_c'] as num?)?.toDouble() ?? 0.0,
        maxTempC: (day['maxtemp_c'] as num?)?.toDouble() ?? 0.0,
        avgHumidity: (day['avghumidity'] as num?)?.toDouble() ?? 0.0,
        maxWindKph: (day['maxwind_kph'] as num?)?.toDouble() ?? 0.0,
        iconUrl: day['condition']?['icon'] != null
            ? 'https:${day['condition']['icon']}'
            : '',
      );
    }).toList();

    return ForecastDto(list);
  }
}
