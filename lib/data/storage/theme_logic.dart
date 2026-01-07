import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:project_proposal/model/user_settings.dart';

class ThemeLogic {
  Future<void> toggleTheme() async {
    final settings = await _loadSettings();
    settings.darkMode = !settings.darkMode;
    await _saveSettings(settings);
  }

  Future<void> saveTheme(bool darkMode) async {
    final settings = await _loadSettings();
    settings.darkMode = darkMode;
    await _saveSettings(settings);
  }

  Future<UserSettings> _loadSettings() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user_settings.json');
      
      if (!await file.exists()) {
        return UserSettings();
      }
      
      final contents = await file.readAsString();
      final json = jsonDecode(contents) as Map<String, dynamic>;
      return UserSettings.fromJson(json);
    } catch (e) {
      return UserSettings();
    }
  }

  Future<void> _saveSettings(UserSettings settings) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/user_settings.json');
    await file.writeAsString(jsonEncode(settings.toJson()));
  }
}
