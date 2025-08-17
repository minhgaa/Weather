import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/domain/entities/location_entity.dart';
import 'package:weather_app/domain/usecases/search_location.dart';

class LocationState {
  final bool loading;
  final String? error;
  final List<LocationEntity> results;

  const LocationState({this.loading=false, this.error, this.results=const []});

  LocationState copyWith({bool? loading, String? error, List<LocationEntity>? results}) =>
      LocationState(
        loading: loading ?? this.loading,
        error: error,
        results: results ?? this.results,
      );
}

class LocationCubit extends Cubit<LocationState> {
  final SearchLocations searchLocations;
  LocationCubit(this.searchLocations) : super(const LocationState());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;
    emit(state.copyWith(loading: true, error: null));
    try {
      final rs = await searchLocations(query);
      emit(LocationState(results: rs));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void clear() => emit(const LocationState());
}