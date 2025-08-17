class ForecastEntity {
  final DateTime date;
  final double minTempC;
  final double maxTempC;
  final double avgHumidity;
  final double maxWindKph;
  final String iconUrl;
  const ForecastEntity({
    required this.date, required this.minTempC, required this.maxTempC,
    required this.avgHumidity, required this.maxWindKph, required this.iconUrl,
  });
}