// lib/data/repo_impl/history_impl.dart
import 'package:weather_app/data/datasources/history_ds.dart';
import 'package:weather_app/domain/entities/history_entity.dart';
import 'package:weather_app/domain/entities/weather_entity.dart';
import 'package:weather_app/domain/entities/daily_forecast_entity.dart';
import 'package:weather_app/domain/repositories/history_repo.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryLocalDS local;
  HistoryRepositoryImpl(this.local);

  @override
  Future<void> saveToday(HistoryEntity e) async {
    await local.saveToday({
      'id': e.id,
      'title': e.title,
      'at': e.at.toIso8601String(),
      'hisWeather': {
        'tempC': e.hisWeather.tempC,
        'conditionText': e.hisWeather.conditionText,
        'iconUrl': e.hisWeather.iconUrl,
        'humidity': e.hisWeather.humidity,
        'windKph': e.hisWeather.windKph,
      },
      'hisForecast': e.hisForecast.map((f) => {
        'date': f.date,
        'minTempC': f.minTempC,
        'maxTempC': f.maxTempC,
        'avgHumidity': f.avgHumidity,
        'maxWindKph': f.maxWindKph,
        'iconUrl': f.iconUrl,
      }).toList(),
    });
  }

  @override
  Future<List<HistoryEntity>> getToday() async {
    final raw = await local.getToday();
    return raw.map((m) => HistoryEntity(
      id: m['id'],
      title: m['title'],
      at: DateTime.tryParse(m['at'] ?? '') ?? DateTime.now(),
      hisWeather: WeatherEntity(
        locationName: m['title'],
        tempC: m['hisWeather']['tempC'],
        conditionText: m['hisWeather']['conditionText'],
        iconUrl: m['hisWeather']['iconUrl'],
        humidity: m['hisWeather']['humidity'],
        windKph: m['hisWeather']['windKph'],
        lastUpdated: DateTime.tryParse(m['at'] ?? '') ?? DateTime.now(),
      ),
      hisForecast: (m['hisForecast'] as List<dynamic>).map((f) => ForecastEntity(
        date: f['date'],
        minTempC: f['minTempC'],
        maxTempC: f['maxTempC'],
        avgHumidity: f['avgHumidity'],
        maxWindKph: f['maxWindKph'],
        iconUrl: f['iconUrl'],
      )).toList(),
    )).toList();
  }

  @override
  Future<void> clearNonToday() => local.clearNonToday();
}