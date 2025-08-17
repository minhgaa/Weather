import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:weather_app/core/theme/theme.dart';
import 'package:weather_app/cubit/weather_cubit.dart';
import 'package:weather_app/data/datasources/weather_ds.dart';
import 'package:weather_app/data/repo_impl/weather_impl.dart';
import 'package:weather_app/domain/usecases/current_weather.dart';
import 'package:weather_app/domain/usecases/daily_forecast.dart';
import 'package:weather_app/feature/weather/presentation/pages/mainpage.dart';
import 'package:weather_app/data/repo_impl/location_impl.dart';
import 'package:weather_app/core/network/http_client.dart';
import 'package:weather_app/data/datasources/location_ds.dart';
import 'package:weather_app/domain/usecases/search_location.dart';
import 'package:weather_app/cubit/location_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/cubit/forecast_cubit.dart';
import 'package:sizer/sizer.dart';
import 'package:weather_app/cubit/history_cubit.dart';
import 'package:weather_app/feature/subscribe/presentation/widget/subscribe_panel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final http = HttpClient();
  final locDs = LocationRemoteDS(http);
  final locRepo = LocationRepositoryImpl(locDs);
  final ucSearch = SearchLocations(locRepo);
  final wDs = WeatherRemoteDS(http);
  final wRepo = WeatherRepositoryImpl(wDs);
  final ucCurrent = getCurrentWeather(wRepo);
  final ucForecast = getDailyForecast(wRepo);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocationCubit(ucSearch)),
        BlocProvider<HistoryCubit>(create: (_) => HistoryCubit()..loadToday()),
        BlocProvider<WeatherCubit>(create: (_) => WeatherCubit(ucCurrent)),
        BlocProvider(create: (_) => ForecastCubit(ucForecast)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Weather App',
          theme: AppTheme.theme,
          home: const MyHomePage(title: 'Weather Dashboard'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primarySeed,
        title: Text(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mail_outline, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Subscribe to Daily Forecast"),
                    content: const SubscriptionPanel(),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Close"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: const Mainpage(),
    );
  }
}
