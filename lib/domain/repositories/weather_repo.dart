import "package:weather_app/domain/entities/daily_forecast_entity.dart";
import "package:weather_app/domain/entities/weather_entity.dart";

abstract class WeatherRepository {
  Future <WeatherEntity> getCurrentByQuery (String q);
  Future <List<ForecastEntity>> getDailyForecastByQuery (String q, int days);
}