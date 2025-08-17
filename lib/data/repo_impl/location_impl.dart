import 'package:weather_app/data/models/location_dto.dart';
import 'package:weather_app/domain/repositories/location_repo.dart';
import 'package:weather_app/data/datasources/location_ds.dart';
import 'package:weather_app/domain/entities/location_entity.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDS remote;
  LocationRepositoryImpl(this.remote);

  @override
  Future<List<LocationEntity>> search(String query) async {
    try {
      final arr = await remote.searchRaw(query);
      return arr.map((e) => LocationDto.fromJson(e).toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }
}