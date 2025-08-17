import 'package:weather_app/core/network/http_client.dart';

class WeatherRemoteDS {
   final HttpClient http;
  WeatherRemoteDS(this.http);

  Future<Map<String, dynamic>> searchWeather(String q) async {
    final data = await http.get('/current.json', query: {'q': q});
    return data as Map<String, dynamic>;
  }

 Future<Map<String, dynamic>> searchForecast(String q, int days) async {
  final data = await http.get('/forecast.json', query: {'q': q, 'days': '$days'});
  return data as Map<String, dynamic>;
}
}