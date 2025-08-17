import "package:weather_app/domain/entities/location_entity.dart";

abstract class LocationRepository {
  Future<List<LocationEntity>> search(String query);
}