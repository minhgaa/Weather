import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/domain/entities/history_entity.dart';
import 'package:weather_app/domain/entities/weather_entity.dart';
import 'package:weather_app/domain/usecases/current_weather.dart';

class WeatherState {
  final bool loading;
  final String? error;
  final WeatherEntity? current;
  final DateTime? lastSearchAt;
  final String? activeQueryId;

  const WeatherState({
    this.loading = false,
    this.error,
    this.current,
    this.lastSearchAt,
    this.activeQueryId,
  });

  WeatherState copyWith({
    bool? loading,
    String? error,
    WeatherEntity? current,
    DateTime? lastSearchAt,
    String? activeQueryId,
  }) {
    return WeatherState(
      loading: loading ?? this.loading,
      error: error,
      current: current ?? this.current,
      lastSearchAt: lastSearchAt ?? this.lastSearchAt,
      activeQueryId: activeQueryId ?? this.activeQueryId,
    );
  }
}

class WeatherCubit extends Cubit<WeatherState> {
  final getCurrentWeather getCurrent;
  WeatherCubit(this.getCurrent)
    : super(const WeatherState());
  Future<void> loadCurrentByQuery(String query, {String? displayTitle}) async {
    final q = query.trim();
    if (q.isEmpty) return;
    emit(state.copyWith(loading: true, error: null));
    try {
      final c = await getCurrent(q);
      final now = DateTime.now();
      emit(
        state.copyWith(
          loading: false,
          current: c,
          lastSearchAt: now,
          activeQueryId: q,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void showFromHistory(HistoryEntity h) {
    emit(
      state.copyWith(
        loading: false,
        error: null,
        current: h.hisWeather,
        lastSearchAt: h.at,
        activeQueryId: h.id,
      ),
    );
  }

  void clear() => emit(const WeatherState());
}
