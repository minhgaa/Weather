import 'package:weather_app/core/network/http_client.dart';

class LocationRemoteDS {
  final HttpClient http;
  LocationRemoteDS(this.http);

  Future<List<dynamic>> searchRaw(String q) async {
    final data = await http.get('/search.json', query: {'q': q});
    return data as List<dynamic>;
  }
}