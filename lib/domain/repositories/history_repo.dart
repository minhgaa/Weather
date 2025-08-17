import 'package:weather_app/domain/entities/history_entity.dart';

abstract class HistoryRepository {
  Future<void> saveToday(HistoryEntity e);
  Future<List<HistoryEntity>> getToday();
  Future<void> clearNonToday();
}