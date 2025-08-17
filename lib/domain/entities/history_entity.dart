import 'package:weather_app/domain/entities/daily_forecast_entity.dart';
import 'package:weather_app/domain/entities/weather_entity.dart';

class HistoryEntity {
  final String id;          
  final String title;       
  final DateTime at;       
  final WeatherEntity hisWeather;
  final List<ForecastEntity> hisForecast;

  const HistoryEntity({
    required this.id,
    required this.title,
    required this.at,
    required this.hisWeather,
    required this.hisForecast,
  });
}