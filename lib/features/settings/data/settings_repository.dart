import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/game_settings.dart';

class SettingsRepository {
  static const _key = 'game_settings';

  Future<GameSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const GameSettings();
    return GameSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(GameSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(settings.toJson()));
  }
}
