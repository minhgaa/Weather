import 'package:weather_app/domain/entities/daily_forecast_entity.dart';
import 'package:weather_app/domain/repositories/weather_repo.dart';

class getDailyForecast {
  final WeatherRepository repo;
  getDailyForecast(this.repo);
  Future<List<ForecastEntity>> call(String q, int days) => repo.getDailyForecastByQuery(q, days);
}