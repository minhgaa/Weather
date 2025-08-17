import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/core/theme/theme.dart';
import 'package:weather_app/cubit/weather_cubit.dart';
import 'package:intl/intl.dart';

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, s) {
        final c = s.current!;
        final formattedDate = DateFormat('yyyy-MM-dd').format(c.lastUpdated);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${c.locationName} (${formattedDate})",
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  "Temperature: ${c.tempC}°C",
                  style: TextStyle(color: AppTheme.white, fontSize: 13),
                ),
                SizedBox(height: 7),
                Text(
                  "Wind: ${c.windKph} M/S",
                  style: TextStyle(color: AppTheme.white, fontSize: 13),
                ),
                SizedBox(height: 7),
                Text(
                  "Humidity: ${c.humidity}%",
                  style: TextStyle(color: AppTheme.white, fontSize: 13),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  c.iconUrl,
                  width: 80,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.cloud_off, size: 48),
                ),
                Text(c.conditionText, style: TextStyle(color: AppTheme.white, fontSize: 13),),
              ],
            ),
          ],
        );
      },
    );
  }
}
