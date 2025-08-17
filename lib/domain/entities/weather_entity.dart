class WeatherEntity {
  final String locationName;
  final double tempC;
  final double windKph;
  final int humidity;
  final String conditionText;
  final String iconUrl;
  final DateTime lastUpdated;

  const WeatherEntity({
    required this.locationName,
    required this.tempC,
    required this.windKph,
    required this.humidity,
    required this.conditionText,
    required this.iconUrl,
    required this.lastUpdated,
  });
}