import 'package:weather_app/data/models/forecast_dto.dart';
import 'package:weather_app/data/models/weather_dto.dart';
import 'package:weather_app/domain/entities/daily_forecast_entity.dart';
import 'package:weather_app/domain/repositories/weather_repo.dart';
import 'package:weather_app/data/datasources/weather_ds.dart';
import 'package:weather_app/domain/entities/weather_entity.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDS remote;
  WeatherRepositoryImpl(this.remote);

  @override
  Future<WeatherEntity> getCurrentByQuery(String query) async {
    try {
      final json = await remote.searchWeather(query);
      return WeatherDto.fromJson(json).entity;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ForecastEntity>> getDailyForecastByQuery(String query, int days) async {
    try {
      final Map<String, dynamic> map = await remote.searchForecast(query, days);
      return ForecastDto.fromJson(map).days;
    } catch (e) {
      rethrow;
    }
  }
}