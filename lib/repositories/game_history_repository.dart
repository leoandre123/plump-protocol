import 'dart:convert';

import 'package:plumpen_app/models/game_history_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameHistoryRepository {
  static const _key = "game_history";
  static const _maxEntries = 50;

  Future<List<GameHistoryEntry>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    final entries = <GameHistoryEntry>[];
    for (final entry in raw) {
      try {
        entries.add(
          GameHistoryEntry.fromJson(jsonDecode(entry) as Map<String, dynamic>),
        );
      } catch (_) {
        // Skip corrupt entries rather than losing the whole history.
      }
    }
    return entries;
  }

  Future<void> addEntry(GameHistoryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    raw.insert(0, jsonEncode(entry.toJson()));
    if (raw.length > _maxEntries) {
      raw.removeRange(_maxEntries, raw.length);
    }

    await prefs.setStringList(_key, raw);
  }

  Future<void> deleteEntryAt(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    if (index < 0 || index >= raw.length) return;
    raw.removeAt(index);

    await prefs.setStringList(_key, raw);
  }
}
