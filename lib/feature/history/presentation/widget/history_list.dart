import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/cubit/history_cubit.dart';

class HistoryToday extends StatelessWidget {
  const HistoryToday({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, s) {
        if (s.loading) return const LinearProgressIndicator();
        if (s.items.isEmpty) return const Text('No history yet today');

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: s.items.map((e) {
            return ActionChip(
              label: Text(e.title),
              avatar: (e.hisWeather.iconUrl.isNotEmpty)
                  ? CircleAvatar(backgroundImage: NetworkImage(e.hisWeather.iconUrl))
                  : const CircleAvatar(child: Icon(Icons.history)),
              onPressed: () {
                context.read<HistoryCubit>().showSnapshotInUi(context, e);
              },
            );
          }).toList(),
        );
      },
    );
  }
}