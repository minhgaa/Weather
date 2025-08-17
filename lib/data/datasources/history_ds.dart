import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryLocalDS {
  static String _dayKey(DateTime d) =>
      'history:${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

  Future<void> saveToday(Map<String, dynamic> entry) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _dayKey(DateTime.now());
    final raw = prefs.getString(key);
    final List list = raw != null ? jsonDecode(raw) as List : <dynamic>[];

    final id = entry['id'];
    final filtered = list.where((e) => e['id'] != id).toList();
    filtered.insert(0, entry);

    if (filtered.length > 20) filtered.removeRange(20, filtered.length);

    await prefs.setString(key, jsonEncode(filtered));
  }

  Future<List<Map<String, dynamic>>> getToday() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _dayKey(DateTime.now());
    final raw = prefs.getString(key);
    if (raw == null) return [];
    final List list = jsonDecode(raw) as List;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> clearNonToday() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final today = _dayKey(DateTime.now());
    for (final k in keys) {
      if (k.startsWith('history:') && k != today) {
        await prefs.remove(k);
      }
    }
  }
}