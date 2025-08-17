import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/cubit/history_cubit.dart';
import 'package:weather_app/domain/entities/daily_forecast_entity.dart';
import 'package:weather_app/domain/entities/history_entity.dart';
import 'package:weather_app/domain/usecases/daily_forecast.dart';

class ForecastState {
  final bool loading;
  final String? error;
  final List<ForecastEntity> days;   
  final int requestedDays;          
  final String? lastQuery;         

  const ForecastState({
    this.loading = false,
    this.error,
    this.days = const [],
    this.requestedDays = 4,
    this.lastQuery,
  });

  ForecastState copyWith({
    bool? loading,
    String? error,
    List<ForecastEntity>? days,
    int? requestedDays,
    String? lastQuery,
  }) {
    return ForecastState(
      loading: loading ?? this.loading,
      error: error,
      days: days ?? this.days,
      requestedDays: requestedDays ?? this.requestedDays,
      lastQuery: lastQuery ?? this.lastQuery,
    );
  }
}

class ForecastCubit extends Cubit<ForecastState> {
  final getDailyForecast getForecast;
  ForecastCubit(this.getForecast) : super(const ForecastState());

  Future<void> load(String query, int days) async {
  final q = query.trim();
  if (q.isEmpty) return;

  emit(state.copyWith(
    loading: true,
    error: null,
    requestedDays: days,
    lastQuery: q,
  ));

  try {
    final result = await getForecast(q, days);
    emit(state.copyWith(loading: false, days: result));
  } catch (e) {
    emit(state.copyWith(loading: false, error: e.toString()));
  }
}

  Future<void> loadMore({int step = 4, int maxDays = 10}) async {
    final q = state.lastQuery;
    if (q == null || q.isEmpty) return;

    final nextDays = (state.requestedDays + step).clamp(1, maxDays);
    await load(q, nextDays);
  }

    void showFromHistory(List<ForecastEntity> days) {
    emit(state.copyWith(
      loading: false,
      error: null,
      days: days,
      requestedDays: days.length,
    ));
  }
  void clear() => emit(const ForecastState());
}