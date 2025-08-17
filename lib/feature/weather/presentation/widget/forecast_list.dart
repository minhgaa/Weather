import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/core/theme/theme.dart';
import 'package:weather_app/cubit/forecast_cubit.dart';
import 'package:intl/intl.dart';

class ForecastList extends StatelessWidget {
  const ForecastList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForecastCubit, ForecastState>(
      builder: (context, s) {
        if (s.loading && s.days.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (s.error != null && s.days.isEmpty) {
          return Text('Error: ${s.error}');
        }
        if (s.days.isEmpty) {
          return const Text('No forecast data');
        }

        final list = s.days;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              GridView.builder(
                shrinkWrap: true,
                // physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 30,
                  childAspectRatio: 5 / 6,
                ),
                itemBuilder: (context, i) {
                  final day = list[i];
                  final hasIcon = day.iconUrl.isNotEmpty;
                  final formattedDate = DateFormat(
                    'yyyy-MM-dd',
                  ).format(day.date);

                  return Card(
                    color: AppTheme.button,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "($formattedDate)",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          hasIcon
                              ? Image.network(
                                  day.iconUrl,
                                  width: 80,
                                  height: 80,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.image_not_supported),
                                )
                              : const Icon(Icons.image_not_supported),
                          Spacer(),
                          Text(
                            "Temperature: ${day.maxTempC}°C",
                            style: TextStyle(
                              color: AppTheme.white,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            "Wind: ${day.maxWindKph} M/S",
                            style: TextStyle(
                              color: AppTheme.white,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            "Humidity: ${day.avgHumidity}%",
                            style: TextStyle(
                              color: AppTheme.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.read<ForecastCubit>().loadMore(
                    step: 4,
                    maxDays: 12,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Load more'),
                ),
              ),

              if (s.loading)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
        );
      },
    );
  }
}
