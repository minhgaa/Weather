import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/cubit/forecast_cubit.dart';
import 'package:weather_app/cubit/history_cubit.dart';
import 'package:weather_app/domain/entities/history_entity.dart';
import 'package:weather_app/domain/entities/location_entity.dart';
import 'package:weather_app/cubit/location_cubit.dart';
import 'package:weather_app/core/theme/theme.dart';
import 'package:weather_app/cubit/weather_cubit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:weather_app/feature/history/presentation/widget/history_list.dart';

class LocationSearchBox extends StatefulWidget {
  final void Function(LocationEntity selected) onSelect;
  const LocationSearchBox({super.key, required this.onSelect});

  @override
  State<LocationSearchBox> createState() => _LocationSearchBoxState();
}

class _LocationSearchBoxState extends State<LocationSearchBox> {
  final _controller = TextEditingController();
  Timer? _debounce;

  Future<void> _searchAndSaveSnapshot(String q, String displayTitle) async {
    final weatherCubit = context.read<WeatherCubit>();
    final forecastCubit = context.read<ForecastCubit>();
    final historyCubit = context.read<HistoryCubit>();

    weatherCubit.loadCurrentByQuery(q);
    forecastCubit.load(q, 4);

    try {
      final weatherDone = await weatherCubit.stream.firstWhere(
        (s) => !s.loading && s.error == null && s.current != null,
      );

      final forecastDone = await forecastCubit.stream.firstWhere(
        (s) => !s.loading && s.error == null && s.days.isNotEmpty,
      );
      final current = weatherDone.current!;
      final forecast = forecastDone.days;
      final snap = HistoryEntity(
        id: q,
        title: displayTitle.isNotEmpty ? displayTitle : current.locationName,
        at: DateTime.now(),
        hisWeather: current,
        hisForecast: forecast,
      );

      await historyCubit.saveSnapshot(snap);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search error: $e')),
      );
    }
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    if (v.trim().isEmpty) {
      context.read<LocationCubit>().clear();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<LocationCubit>().search(v.trim());
    });
  }

  void _onSearchPressed() async {
    final q = _controller.text.trim();
    if (q.isEmpty) {
      context.read<LocationCubit>().clear();
      return;
    }
    await _searchAndSaveSnapshot(q, _controller.text.trim());
  }

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, s) {
        final isDisabled = _controller.text.trim().isEmpty || s.loading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search city...',
                border: OutlineInputBorder(),
              ),
              onChanged: _onChanged,
              onSubmitted: (v) async {
                final q = v.trim();
                if (q.isEmpty) {
                  context.read<LocationCubit>().clear();
                  return;
                }
                await _searchAndSaveSnapshot(q, q);
              },
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: isDisabled
                      ? AppTheme.primarySeed.withOpacity(0.6)
                      : AppTheme.primarySeed,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: isDisabled ? null : _onSearchPressed,
                child: const Text(
                  'Search',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            // Spacer(),
            if (s.loading)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(),
              ),

            if (!s.loading && s.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Error: ${s.error}'),
              ),

            if (!s.loading && s.results.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 260),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: s.results.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final item = s.results[i];
                      return ListTile(
                        leading: const Icon(Icons.location_on_outlined),
                        title: Text(item.displayName),
                        subtitle: Text(
                          '(${item.lat.toStringAsFixed(2)}, ${item.lon.toStringAsFixed(2)})',
                        ),
                        onTap: () {
                          widget.onSelect(item);
                          context.read<LocationCubit>().clear();
                          _controller.text = item.displayName;
                        },
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Expanded(
                  child: Divider(color: Colors.grey, thickness: 1),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Or',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                const Expanded(
                  child: Divider(color: Colors.grey, thickness: 1),
                ),
              ],
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.button,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () async {
                  try {
                    final pos = await _getCurrentPosition();
                    final q = '${pos.latitude},${pos.longitude}';
                    String display = q;
                    try {
                      final placemarks = await placemarkFromCoordinates(
                        pos.latitude,
                        pos.longitude,
                      );
                      if (placemarks.isNotEmpty) {
                        final p = placemarks.first;
                        final city = (p.locality?.isNotEmpty == true)
                            ? p.locality!
                            : (p.subAdministrativeArea?.isNotEmpty == true)
                            ? p.subAdministrativeArea!
                            : (p.administrativeArea ?? '');
                        final country = p.country ?? '';
                        final parts = [
                          city,
                          country,
                        ].where((e) => e.trim().isNotEmpty).toList();
                        if (parts.isNotEmpty) {
                          display = parts.join(', ');
                        }
                      }
                    } catch (_) {}
                    _controller.text = display;
                    if (mounted) {
                      await _searchAndSaveSnapshot(q, display);
                    }
                  } catch (_) {}
                },
                child: const Text(
                  'Use Current Location',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 15),
            Text("Last searches", style: TextStyle(color: AppTheme.button, fontSize: 13) ),
            SizedBox(height: 10),
            HistoryToday(),
          ],
        );
      },
    );
  }
}
