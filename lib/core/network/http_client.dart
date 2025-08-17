import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/core/constants/constants.dart';

class HttpClient {
  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse( '${ApiConstants.baseUrl}$path').replace(
      queryParameters: {'key': ApiConstants.apiKey, ...?query},
    );
    final r = await http.get(uri);
    if (r.statusCode >= 200 && r.statusCode < 300) return jsonDecode(r.body);
    throw Exception('HTTP ${r.statusCode}: ${r.body}');
  }
}