import 'package:weather_app/domain/entities/location_entity.dart';
import 'package:weather_app/domain/repositories/location_repo.dart';

class SearchLocations {
  final LocationRepository repo;
  SearchLocations(this.repo);
  Future<List<LocationEntity>> call(String query) => repo.search(query);
}