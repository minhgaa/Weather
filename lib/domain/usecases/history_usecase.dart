// lib/domain/usecases/history_usecases.dart
import 'package:weather_app/domain/entities/daily_forecast_entity.dart';
import 'package:weather_app/domain/entities/history_entity.dart';
import 'package:weather_app/domain/entities/weather_entity.dart';
import 'package:weather_app/domain/repositories/history_repo.dart';

class SaveWeatherHistoryEntry {
  final HistoryRepository repo;
  SaveWeatherHistoryEntry(this.repo);

  Future<void> call(WeatherEntity w, List<ForecastEntity> f, {required String id, required String title}) {
    final e = HistoryEntity(
      id: id,                      
      title: title,                 
      at: DateTime.now(),
      hisWeather: w,
      hisForecast: f,
    );
    return repo.saveToday(e);
  }
}

class GetTodayHistory {
  final HistoryRepository repo;
  GetTodayHistory(this.repo);
  Future<List<HistoryEntity>> call() => repo.getToday();
}

class ClearOldHistory {
  final HistoryRepository repo;
  ClearOldHistory(this.repo);
  Future<void> call() => repo.clearNonToday();
}