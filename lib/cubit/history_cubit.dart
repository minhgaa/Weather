import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weather_app/domain/entities/history_entity.dart';
import 'package:weather_app/domain/entities/weather_entity.dart';
import 'package:weather_app/domain/entities/daily_forecast_entity.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/cubit/weather_cubit.dart';
import 'package:weather_app/cubit/forecast_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HistoryState {
  final bool loading;
  final String? error;
  final List<HistoryEntity> items;

  const HistoryState({
    this.loading = false,
    this.error,
    this.items = const [],
  });

  HistoryState copyWith({
    bool? loading,
    String? error,
    List<HistoryEntity>? items,
  }) {
    return HistoryState(
      loading: loading ?? this.loading,
      error: error,
      items: items ?? this.items,
    );
  }
}

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit() : super(const HistoryState());

  String _dayKey(DateTime d) =>
      'history:${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> loadToday() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayKey = _dayKey(DateTime.now());
      for (final k in prefs.getKeys()) {
        if (k.startsWith('history:') && k != todayKey) {
          await prefs.remove(k);
        }
      }

      final raw = prefs.getString(todayKey);
      final List<HistoryEntity> list;
      if (raw == null) {
        list = [];
      } else {
        final decoded = jsonDecode(raw) as List;
        list = decoded.map((e) => _fromJson(e as Map<String, dynamic>)).toList();
      }
      emit(state.copyWith(loading: false, items: list));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> saveSnapshot(HistoryEntity entry, {int maxItems = 20}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _dayKey(DateTime.now());
      final current = List<HistoryEntity>.from(state.items);

      final filtered = current.where((h) => h.id != entry.id).toList();
      filtered.insert(0, entry);
      if (filtered.length > maxItems) {
        filtered.removeRange(maxItems, filtered.length);
      }

      final serialized = jsonEncode(filtered.map(_toJson).toList());
      await prefs.setString(key, serialized);

      emit(state.copyWith(items: filtered));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> remove(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _dayKey(DateTime.now());
    final updated = state.items.where((e) => e.id != id).toList();
    await prefs.setString(key, jsonEncode(updated.map(_toJson).toList()));
    emit(state.copyWith(items: updated));
  }

  Future<void> clearToday() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _dayKey(DateTime.now());
    await prefs.remove(key);
    emit(state.copyWith(items: []));
  }

  void showSnapshotInUi(BuildContext context, HistoryEntity e) {
    context.read<WeatherCubit>().showFromHistory(e);
    if (e.hisForecast.isNotEmpty) {
      context.read<ForecastCubit>().showFromHistory(e.hisForecast);
    } else {
      context.read<ForecastCubit>().clear();
    }
  }


  Map<String, dynamic> _toJson(HistoryEntity e) {
    return {
      'id': e.id,
      'title': e.title,
      'at': e.at.toIso8601String(),
      'hisWeather': {
        'locationName': e.hisWeather.locationName,
        'tempC': e.hisWeather.tempC,
        'conditionText': e.hisWeather.conditionText,
        'iconUrl': e.hisWeather.iconUrl,
        'humidity': e.hisWeather.humidity,
        'windKph': e.hisWeather.windKph,
        'lastUpdated': e.hisWeather.lastUpdated.toIso8601String(),
      },
      'hisForecast': e.hisForecast.map((f) => {
        'date': f.date.toIso8601String(),
        'minTempC': f.minTempC,
        'maxTempC': f.maxTempC,
        'avgHumidity': f.avgHumidity,
        'maxWindKph': f.maxWindKph,
        'iconUrl': f.iconUrl,
      }).toList(),
    };
  }

  HistoryEntity _fromJson(Map<String, dynamic> m) {
    final hw = m['hisWeather'] as Map<String, dynamic>;
    final List<ForecastEntity> days = ((m['hisForecast'] ?? []) as List).map((x) {
      final map = x as Map<String, dynamic>;
      return ForecastEntity(
        date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
        minTempC: (map['minTempC'] as num).toDouble(),
        maxTempC: (map['maxTempC'] as num).toDouble(),
        avgHumidity: (map['avgHumidity'] as num).toDouble(),
        maxWindKph: (map['maxWindKph'] as num).toDouble(),
        iconUrl: map['iconUrl'] ?? '',
      );
    }).toList();

    final weather = WeatherEntity(
      locationName: hw['locationName'] ?? m['title'] ?? '',
      tempC: (hw['tempC'] as num).toDouble(),
      conditionText: hw['conditionText'] ?? '',
      iconUrl: hw['iconUrl'] ?? '',
      humidity: (hw['humidity'] as num).toInt(),
      windKph: (hw['windKph'] as num).toDouble(),
      lastUpdated: DateTime.tryParse(hw['lastUpdated'] ?? '') ?? DateTime.now(),
    );

    return HistoryEntity(
      id: m['id'],
      title: m['title'],
      at: DateTime.tryParse(m['at'] ?? '') ?? DateTime.now(),
      hisWeather: weather,
      hisForecast: days,
    );
    }
}