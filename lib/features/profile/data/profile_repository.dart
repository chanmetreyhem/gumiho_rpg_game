import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/player_profile.dart';

class ProfileRepository {
  static const _key = 'player_profile';

  Future<PlayerProfile> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const PlayerProfile();
    return PlayerProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(PlayerProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }
}
