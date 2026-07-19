import 'dart:convert';

import 'package:plumpen_app/models/game_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameRepository {
  static const _key = "game_session";

  Future<void> saveGame(GameData gameData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(gameData.toJson()));
  }

  Future<GameData?> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return GameData.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
