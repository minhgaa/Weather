import 'package:flutter/material.dart';
import 'package:weather_app/core/theme/theme.dart';
import 'package:weather_app/domain/entities/location_entity.dart';
import 'package:weather_app/feature/weather/presentation/widget/forecast_list.dart';
import 'package:weather_app/feature/weather/presentation/widget/location_search_box.dart';
import 'package:weather_app/feature/weather/presentation/widget/weather_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/cubit/weather_cubit.dart';
import 'package:weather_app/cubit/forecast_cubit.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/cubit/history_cubit.dart';
import 'package:weather_app/domain/entities/history_entity.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  Future<void> _refreshLatest() async {
    final fc = context.read<ForecastCubit>();
    final wc = context.read<WeatherCubit>();
    final hc = context.read<HistoryCubit>();

    final q = wc.state.activeQueryId ?? fc.state.lastQuery; 

    if (q == null || q.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No previous search to refresh.')),
      );
      return;
    }

    // Trigger fresh fetches
    wc.loadCurrentByQuery(q, displayTitle: wc.state.current?.locationName);
    fc.load(q, fc.state.requestedDays);

    try {
      // Wait for both to complete successfully
      final weatherDone = await wc.stream.firstWhere(
        (s) => !s.loading && s.error == null && s.current != null,
      );
      final forecastDone = await fc.stream.firstWhere(
        (s) => !s.loading && s.error == null && s.days.isNotEmpty,
      );

      // Build snapshot and save
      final current = weatherDone.current!;
      final forecast = forecastDone.days;
      final snap = HistoryEntity(
        id: q,
        title: current.locationName,
        at: DateTime.now(),
        hisWeather: current,
        hisForecast: forecast,
      );
      await hc.saveSnapshot(snap);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Refresh error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enter a City Name', style: TextStyle(fontSize: 15)),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: LocationSearchBox(onSelect: (LocationEntity loc) {}),
                ),
                
              ],
            ),
          ),
        ),

        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<WeatherCubit, WeatherState>(
                  builder: (context, s) {
                    final hasData = s.current != null;
                    final ts = s.lastSearchAt;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasData && ts != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Text(
                                  'Last search: ${DateFormat('HH:mm dd/MM/yyyy').format(ts.toLocal())}',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () { _refreshLatest(); },
                                  child: const Text('Get new.'),
                                ),
                              ],
                            ),
                          ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: AppTheme.primarySeed,
                          ),
                          child: hasData
                              ? const WeatherCard()
                              : const _IntroBanner(),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 20),
                Text(
                  "4-Day Forecast",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(child: ForecastList()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _IntroBanner extends StatelessWidget {
  const _IntroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Welcome to Weather App 👋',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Search a city on the left to view the current weather and a 4-day forecast.\n'
          'Tip: Selecting a suggestion will be more accurate (uses coordinates).',
          style: TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
        ),
      ],
    );
  }
}
