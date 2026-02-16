import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/stats_engine.dart';

class StorageService {
  static const String _keyDailyResults = 'daily_results';
  static const String _keyLifetimeStats = 'lifetime_stats';
  static const String _keyTutorialCompleted = 'tutorial_completed';

  Future<bool> isTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTutorialCompleted) ?? false;
  }

  Future<void> setTutorialCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTutorialCompleted, completed);
  }

  Future<void> saveResult(String date, StatsResult result) async {
    final prefs = await SharedPreferences.getInstance();

    // Save daily result
    Map<String, dynamic> dailyResults = await getDailyResults();
    dailyResults[date] = {
      'luck': result.luck,
      'logic': result.logic,
      'speed': result.speed,
    };
    await prefs.setString(_keyDailyResults, json.encode(dailyResults));

    // Update lifetime stats
    await _updateLifetimeStats(result);
  }

  Future<Map<String, dynamic>> getDailyResults() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString(_keyDailyResults);
    if (data == null) return {};
    return json.decode(data) as Map<String, dynamic>;
  }

  Future<bool> hasPlayedToday(String date) async {
    final results = await getDailyResults();
    return results.containsKey(date);
  }

  Future<StatsResult?> getTodayResult(String date) async {
    final results = await getDailyResults();
    if (!results.containsKey(date)) return null;
    final data = results[date];
    return StatsResult(
      luck: data['luck'],
      logic: data['logic'],
      speed: data['speed'],
    );
  }

  Future<Map<String, double>> getLifetimeStats() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString(_keyLifetimeStats);
    if (data == null) {
      return {'luck': 0.0, 'logic': 0.0, 'speed': 0.0, 'count': 0.0};
    }
    return Map<String, double>.from(json.decode(data));
  }

  Future<void> _updateLifetimeStats(StatsResult newResult) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, double> stats = await getLifetimeStats();

    double count = stats['count'] ?? 0;
    double oldLuck = stats['luck'] ?? 0;
    double oldLogic = stats['logic'] ?? 0;
    double oldSpeed = stats['speed'] ?? 0;

    double newCount = count + 1;
    stats['luck'] = (oldLuck * count + newResult.luck) / newCount;
    stats['logic'] = (oldLogic * count + newResult.logic) / newCount;
    stats['speed'] = (oldSpeed * count + newResult.speed) / newCount;
    stats['count'] = newCount;

    await prefs.setString(_keyLifetimeStats, json.encode(stats));
  }
}
