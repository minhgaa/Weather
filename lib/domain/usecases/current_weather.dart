import 'package:weather_app/domain/entities/weather_entity.dart';
import 'package:weather_app/domain/repositories/weather_repo.dart';

class getCurrentWeather {
  final WeatherRepository repo;
  getCurrentWeather(this.repo);
  Future <WeatherEntity> call(String q) => repo.getCurrentByQuery(q);
}