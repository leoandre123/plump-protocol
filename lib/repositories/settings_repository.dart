import 'package:plumpen_app/models/game_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const _key = "game_settings";

  Future<void> saveSettings(GameSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    var saveString = settings.toMap().entries.fold(
      "",
      (store, item) => "$store${item.key}:${item.value},",
    );

    //prefs.setString(_key, settings.toMap().toString());
    prefs.setString(_key, saveString);
  }

  Future<GameSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      var entries = raw.split(",").where((e) => e.isNotEmpty).map((entry) {
        var parts = entry.split(":");
        return MapEntry(parts[0].trim(), parts[1].trim());
      });

      final map = Map.fromEntries(entries);
      //final map = Map<String, String>.from(
      //  entries, //raw.replaceAll(RegExp(r'[{}]'), '').split(','),
      //);
      var settings = GameSettings.fromMap(map);
      return settings;
    }
    return GameSettings();
  }
}
